#pragma strict

var playerNumber = 0;
var cash = 0;

var cashLabel : TextMesh;

var cardSlots = ArrayList();

var cards = ArrayList();

var combatLabel : TextMesh;

var attackEffect: GameObject;
var defendEffect : GameObject;
var cashEffect : GameObject;

var cashSound : AudioClip;

private var combatLabelOrigin : Vector3;
private var combatLabelRotation : Quaternion;

var income = 500;

var extraSlots : CardSlot[];

var numberOfExtraSlots = 0;

function AddExtraSlot() {

	if (numberOfExtraSlots >= extraSlots.length) {
		return;
	}
	
	if (CanBuyExtraSlot() == false)
		return;
		
	SetCash(cash - CostOfExtraSlot());

	var newSlot = extraSlots[numberOfExtraSlots];
	newSlot.gameObject.SetActive(true);
	
	income += 100;
	
	numberOfExtraSlots++;
	
	GameManager.sharedManager.store.UpdatePricing();
}

function CanBuyExtraSlot() {
	return cash >= CostOfExtraSlot() && numberOfExtraSlots < extraSlots.length;
}

function CostOfExtraSlot() {
	return income;
}

function AddCard(card : Card) {
	Debug.Log("Adding card " + card);
	card.player = this;
	cards.Add(card);
}

function RemoveCard(card : Card) {
	cards.Remove(card);
}

function Start () {

	var randomBonus = Random.Range(100, 500);
	cash += randomBonus;

	cashLabel.text = String.Format("${0}", cash.ToString());
	
	combatLabelOrigin = combatLabel.transform.position;
	combatLabelRotation = combatLabel.transform.rotation;
	combatLabel.gameObject.SetActive(false);
}

function SetCash(newCash : int) {
	cash = newCash;
	cashLabel.text = String.Format("${0}", cash.ToString());
	
	var cash = Instantiate(cashEffect);
	cash.transform.position = cashLabel.transform.position;
	
	audio.PlayOneShot(cashSound);
	
}

function AddCash(amount : int) {
	SetCash(cash + amount);
}

function RemoveCash(amount : int) {
	SetCash(cash - amount);
}

function PositionCards() {
	Debug.Log("Player {0} positioning cards");
}

function AttackEnded(succeeded : boolean) {
combatLabel.transform.localScale = Vector3(1,1,1);
	Debug.Log(String.Format("Player {0} attack ended: {1}", playerNumber, succeeded));
	if (succeeded) {
			var effect = Instantiate(defendEffect);
		effect.transform.position = combatLabel.transform.position;

		iTween.PunchScale(combatLabel.gameObject, Vector3(2,2,2), 1.0);
	} else {
		iTween.MoveBy(combatLabel.gameObject, Vector3(0,2,0), 1.0);
		iTween.RotateBy(combatLabel.gameObject, Vector3(0, 0, 12.5), 1.0);
		iTween.FadeTo(combatLabel.gameObject, 0, 1.0);
	}
}

function DefenceEnded(succeeded : boolean) {
	iTween.Stop(combatLabel.gameObject);
	combatLabel.transform.localScale = Vector3(1,1,1);

	Debug.Log(String.Format("Player {0} attack ended: {1}", playerNumber, succeeded));
	if (succeeded == false) {
		iTween.ScaleTo(combatLabel.gameObject, Vector3(0.5, 0.5, 0.0), 1);
	} else {
		var effect = Instantiate(defendEffect);
		effect.transform.position = combatLabel.transform.position;
	}
}

function ShowCombatValue(value : int) {
	combatLabel.gameObject.SetActive(true);
	iTween.ScaleFrom(combatLabel.gameObject, Vector3(0.8, 0.8, 0.8), 0.5);
	combatLabel.text = value.ToString();
}

function CombatComplete() {
	combatLabel.gameObject.SetActive(false);
	combatLabel.transform.position = combatLabelOrigin;
	combatLabel.transform.rotation = combatLabelRotation;
	combatLabel.renderer.material.color.a = 1.0;
	
	var engagedCards = FloopedCards();
	for (var card : Card in engagedCards) {
		card.engaged = false;
	}
}

function SetCardsCanFloop(canFloop : boolean) {
	Debug.Log("Setting cards floop to " + canFloop);
	for (var card : Card in cards) {
		card.SetCanFloop(canFloop);
	}
}

function FloopedCards() {
	var floopedCards = ArrayList();
	for (var card : Card in cards) {
		if (card.flooped)
			floopedCards.Add(card);
	}
	return floopedCards;
}

function TotalAttackValue() {
	var attackingCards = FloopedCards();
	
	var totalValue = 0;
	
	for (var card : Card in attackingCards) {
		var appliance : Appliance = card.GetComponent(Appliance);
		if (card.engaged)
			totalValue += appliance.rating;
	}
	
	return totalValue;
}

function TotalDefenceValue() {
	var defendingCards = FloopedCards();
	
	var totalValue = 0;
	
	for (var card : Card in defendingCards) {
		var appliance : Appliance = card.GetComponent(Appliance);
		if (card.engaged)
			totalValue += appliance.capacity;
	}
	
	return totalValue;
}

function ReduceDurability() {
	var theCards = cards;
	
	var cardsToRemove = ArrayList();
	
	for (var card : Card in theCards) {
	
		var appliance = card.GetComponent(Appliance);
		
		appliance.ReduceDurability();
		
		if (appliance.durability <= 0)
			cardsToRemove.Add(card);
		
	}
	
	Debug.Log(String.Format("Removing {0} cards", cardsToRemove.Count));
	
	for (var cardToRemove : Card in cardsToRemove) {
		cards.Remove(cardToRemove);
		Destroy(cardToRemove.gameObject);
	}
}