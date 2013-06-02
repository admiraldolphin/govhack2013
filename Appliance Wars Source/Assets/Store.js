#pragma strict

var applianceCardLocations : Transform[];
var applianceCardTemplate : GameObject;

var player1Anchor : Transform;
var player2Anchor : Transform;

var newSlotCost : TextMesh;

var newSlotButton : Button;

var applianceCards = Array();

function Start () {
//	gameObject.SetActive(false);
}

function Show(player:Player) {

	if (player.playerNumber == 1)
		transform.position = player1Anchor.position;
	if (player.playerNumber == 2)
		transform.position = player2Anchor.position;
		
	
	UpdateStore();
	iTween.PunchScale(gameObject, Vector3(0.1,0,0.1), 1.0);
}

function Hide() {
	iTween.Stop(gameObject);
}

function Update () {

}

function UpdatePricing() {
	var slotCost = GameManager.sharedManager.CurrentPlayer().CostOfExtraSlot();
	var playerCash = GameManager.sharedManager.CurrentPlayer().cash;
	
	newSlotCost.text = String.Format("${0}", slotCost);
	
	
	for (var card : GameObject in applianceCards) {
		var appliance = card.GetComponent(Appliance);
		
		if (appliance.cost > playerCash) {
			appliance.SetPurchasable(false);
		} else {
			appliance.SetPurchasable(true);
		}
	}
	
	if (playerCash > slotCost) {
		newSlotButton.SetButtonEnabled(true);
	} else {
		newSlotButton.SetButtonEnabled(false);
	}
}

function CardWasPurchased(card : GameObject) {
	applianceCards.Remove(card);
	Debug.Log(String.Format("Removed {0} from list of appliance cards, which is now {1}", card, applianceCards));
}

function UpdateStore() {

	for (var cardObject : GameObject in applianceCards) {
		if ((cardObject.GetComponent(Appliance) as Appliance).player == null)
			Destroy(cardObject);
	}
	
	applianceCards.Clear();

	for (var location : Transform in applianceCardLocations) {
		var appliance = GameManager.sharedManager.RandomAppliance();
		
		var card = Instantiate(applianceCardTemplate);
		
		var cardAppliance = card.GetComponent(Appliance);
		
		card.transform.position = location.position;
		
		card.transform.parent = transform;
		
		cardAppliance.SetName(appliance["name"]);
		cardAppliance.SetCapacity(appliance["capacity"]);
		cardAppliance.SetDurability(appliance["durability"]);
		cardAppliance.SetType(appliance["type"]);
		cardAppliance.SetRating(appliance["rating"]);
		cardAppliance.SetCost(appliance["cost"]);
		
		cardAppliance.card.canPurchase = true;
		cardAppliance.card.canFloop = false;
		
		applianceCards.Add(cardAppliance.gameObject);
	}
	
	UpdatePricing();

}