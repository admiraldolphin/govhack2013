#pragma strict

import MiniJSON;

static var sharedManager : GameManager;

var store : Store;

var allAppliances : IList;

var showStoreButton : Button;
var hideStoreButton : Button;
var endTurnButton   : Button;

var player1 : Player;
var player2 : Player;

var battleDarken : Renderer;

var currentTurnDescription : TextMesh;

private var cardsUnfloopedThisTurn = 0;

var winnerDisplay : Winner;

var fightMusic : AudioSource;
var shopMusic : AudioSource;

var attackSucceeded : AudioClip;
var attackFailed : AudioClip;


enum Turn {
	Player1Purchase,
	Player2Purchase,
	Player1Attack1,
	Player2Defend1,
	Battle1,
	Player2Attack1,
	Player1Defend1,
	Battle2,
	Player1Unfloop1,
	Player2Unfloop1,
	Player2Attack2,
	Player1Defend2,
	Battle3,
	Player1Attack2,
	Player2Defend2,
	Battle4,
	Player1Unfloop2,
	Player2Unfloop2,
	Player1Update,
	Player2Update,
	
	
}

function NextTurn() {
	
	var winningPlayer : Player = null;
	if (player1.cash <= 0) {
		winningPlayer = player2;
	} else if (player2.cash <= 0) {
		winningPlayer = player1;
	}
	
	
	if (winningPlayer != null) {

		winnerDisplay.gameObject.SetActive(true);
		winnerDisplay.PresentWithWinner(winningPlayer);
		endTurnButton.gameObject.SetActive(false);
		showStoreButton.gameObject.SetActive(false);
		hideStoreButton.gameObject.SetActive(false);
		
		return;
	}

	var currentTurnNumber : int = currentTurn;
	
	currentTurnNumber++;
	if (currentTurnNumber > Turn.Player2Update)
		currentTurnNumber = 0;
		
	currentTurn = currentTurnNumber;
	
	UpdateUIForCurrentTurn();
		cardsUnfloopedThisTurn = 0;
}

function CardCanUnfloopInUpdatePhase(card : Card) {
	if ((currentTurn == Turn.Player1Unfloop1 || currentTurn == Turn.Player1Unfloop2) && card.player == player1)
		return true;
	
	if ((currentTurn == Turn.Player2Unfloop1  || currentTurn == Turn.Player2Unfloop2) && card.player == player2)
		return true;
		
	return false;
		
}

function UpdateUIForCurrentTurn() {
	
	currentTurnDescription.text = "";
	
	showStoreButton.gameObject.SetActive(false);
	hideStoreButton.gameObject.SetActive(false);
	endTurnButton.gameObject.SetActive(false);

	switch (currentTurn) {
		case Turn.Player1Purchase:
		case Turn.Player2Purchase:
			player1.SetCardsCanFloop(false);
			player2.SetCardsCanFloop(false);
			currentTurnDescription.text = String.Format("Player {0}, go shopping!", CurrentPlayerNumber());
			showStoreButton.gameObject.SetActive(true);
			break;
		
		case Turn.Player1Attack1:
		case Turn.Player1Attack2:
		case Turn.Player2Attack1:
		case Turn.Player2Attack2:
			currentTurnDescription.text = String.Format("Player {0}, choose your cards and attack!", CurrentPlayerNumber());
			endTurnButton.gameObject.SetActive(true);
			CurrentPlayer().SetCardsCanFloop(true);
			OtherPlayer().SetCardsCanFloop(false);
			break;
			
		case Turn.Player1Unfloop1:
		case Turn.Player1Unfloop2:
		case Turn.Player2Unfloop1:
		case Turn.Player2Unfloop2:
			currentTurnDescription.text = String.Format("Player {0}, unfloop two cards!", CurrentPlayerNumber());
			endTurnButton.gameObject.SetActive(true);
			CurrentPlayer().SetCardsCanFloop(true);
			OtherPlayer().SetCardsCanFloop(false);
			break;
			
		case Turn.Player1Defend1:
		case Turn.Player1Defend2:
		case Turn.Player2Defend1:
		case Turn.Player2Defend2:
			currentTurnDescription.text = String.Format("Player {0}, choose cards to defend!", CurrentPlayerNumber());
			endTurnButton.gameObject.SetActive(true);
			CurrentPlayer().SetCardsCanFloop(true);
			OtherPlayer().SetCardsCanFloop(false);
			
			break;
		
		case Turn.Battle1:
		case Turn.Battle2:
		case Turn.Battle3:
		case Turn.Battle4:
			currentTurnDescription.text = String.Format("APPLIANCE BATTLE!", CurrentPlayerNumber());
			
			DoBattle();
			CurrentPlayer().SetCardsCanFloop(false);
			OtherPlayer().SetCardsCanFloop(false);
			
			break;
		
		case Turn.Player1Update:
			yield ApplyUpdateForPlayer(player1);
			NextTurn();
			
			break;
		
		case Turn.Player2Update:
			yield ApplyUpdateForPlayer(player2);
			NextTurn();
			
			break;
		
	}
	
}

function ApplyUpdateForPlayer(player : Player) {
	player.ReduceDurability();
	
	yield WaitForSeconds(1.0);
	
	player.AddCash(player.income);
	
	yield WaitForSeconds(1.0);
	
}

function DoBattle() {

	iTween.Stop(battleDarken.gameObject);
	iTween.FadeTo(battleDarken.gameObject, 0.5, 0.5);

	yield WaitForSeconds(1.0);
	
	var currentPlayer = CurrentPlayer();
	var otherPlayer = OtherPlayer();
	
	/*currentPlayer.PositionCards();
	
	yield WaitForSeconds(0.5);
	
	otherPlayer.PositionCards();
	
	yield WaitForSeconds(1.0);*/
	
	var attackValue = currentPlayer.TotalAttackValue();
	var defenceValue = otherPlayer.TotalDefenceValue();
	
	currentPlayer.ShowCombatValue(attackValue);
	
	yield WaitForSeconds(0.1);
	
	otherPlayer.ShowCombatValue(defenceValue);
	
	yield WaitForSeconds(1.0);
	
	if (attackValue > defenceValue) {
		audio.PlayOneShot(attackSucceeded);
		currentPlayer.AttackEnded(true);
		otherPlayer.DefenceEnded(false);
		
		otherPlayer.RemoveCash((attackValue - defenceValue) * 100);
		
		yield WaitForSeconds(2.5);
	} else if (attackValue < defenceValue) {
		audio.PlayOneShot(attackFailed);
		currentPlayer.AttackEnded(false);
		otherPlayer.DefenceEnded(true);
		yield WaitForSeconds(2.5);
	}
	
	currentPlayer.CombatComplete();
	otherPlayer.CombatComplete();
	
	iTween.FadeTo(battleDarken.gameObject, 0.0, 0.5);
	
	NextTurn();
}

function ResetGame() {
	Application.LoadLevel("MainScene");
}

function PlayerPurchasedAppliance(appliance : Appliance) {
	CurrentPlayer().RemoveCash(appliance.cost);
	appliance.Purchased();
	store.UpdatePricing();
}

function CurrentPlayerNumber() {
	return CurrentPlayer().playerNumber;
}

function CurrentPlayer() {
	switch (currentTurn) {
	
		case Turn.Player1Purchase:
		case Turn.Player1Defend1:
		case Turn.Player1Defend2:
		case Turn.Player1Attack1:
		case Turn.Player1Attack2:
		case Turn.Player1Update:
		case Turn.Player1Unfloop1:
		case Turn.Player1Unfloop2:
		case Turn.Battle1:
		case Turn.Battle4:
			return player1;
	
		case Turn.Player2Purchase:
		case Turn.Player2Defend1:
		case Turn.Player2Defend2:
		case Turn.Player2Attack1:
		case Turn.Player2Attack2:
		case Turn.Player2Update:
		case Turn.Player2Unfloop1:
		case Turn.Player2Unfloop2:
		case Turn.Battle2:
		case Turn.Battle3:
		
			return player2;
		
	}
	
	return null;
	
	
	
	
}


function CardWasUnflooped() {
	cardsUnfloopedThisTurn++;
	if (cardsUnfloopedThisTurn >= 2) {
		if (currentTurn == Turn.Player1Unfloop1 || currentTurn == Turn.Player1Unfloop2 ||
			currentTurn == Turn.Player2Unfloop1 || currentTurn == Turn.Player2Unfloop2)
			NextTurn();
			
	}
	
}

function OtherPlayer() {
	var player = CurrentPlayer();
	if (player == player1)
		return player2;
	else
		return player1;
}

var currentTurn : Turn;

function Awake() {
	sharedManager = this;
	
	var applianceJSON = (Resources.Load("ApplianceData") as TextAsset).text;
	
	allAppliances = Json.Deserialize(applianceJSON) as IList;
	
}

function RandomAppliance() : IDictionary {
	var index = Random.Range(0, allAppliances.Count);
	
	return allAppliances[index] as IDictionary;
}

function Start () {
	currentTurn = Turn.Player1Purchase;
	UpdateUIForCurrentTurn();
	
	battleDarken.material.color.a = 0.0;
	winnerDisplay.gameObject.SetActive(false);
}

function Update () {

}

function ShowStore() {

	shopMusic.volume = 1;
	fightMusic.volume = 0;

	store.gameObject.SetActive(true);
	
	store.Show(CurrentPlayer());
	
	hideStoreButton.gameObject.SetActive(true);
	showStoreButton.gameObject.SetActive(false);
}

function HideStore() {

	shopMusic.volume = 0;
	fightMusic.volume = 1;


	store.Hide();

	store.gameObject.SetActive(false);
	
	hideStoreButton.gameObject.SetActive(false);
	showStoreButton.gameObject.SetActive(true);
	
	NextTurn();

}

function PlayerCanPurchaseAppliance(player: Player, appliance : Appliance) {
	return player.cash >= appliance.cost;
}

function EndTurn() {
	NextTurn();
}
function BuyNewSlot() {
	CurrentPlayer().AddExtraSlot();
}