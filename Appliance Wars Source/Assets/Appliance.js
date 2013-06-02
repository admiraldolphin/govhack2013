#pragma strict

var capacity = 0.0;
var cost = 0.0;
var durability = 0.0;
var applianceName = "Appliance Name";
var rating = 0.0;
var type = "Appliance";

var capacityLabel : TextMesh;
var costLabel : TextMesh;
var durabilityLabel : TextMesh;
var ratingGauge : Renderer;
var typeLabel : TextMesh;
var nameLabel : TextMesh;

var player : Player;

var card : Card;

var cardBack : Renderer;

var backboard : Renderer;

var typeImage : Renderer;

function Awake() {
	card = GetComponent(Card);
}

function Start() {
	cardBack.material.mainTexture = TextureManager.sharedManager.CardBackTexture();
}

function SetCapacity(newCapacity : String) {
	capacity = float.Parse(newCapacity);
	capacityLabel.text = capacity.ToString();
}

function SetCost(newCost : String) {
	cost = float.Parse(newCost) * 100;
	cost = Mathf.Floor(cost);
	costLabel.text = String.Format("${0}", cost);
}

function SetRating(newRating : String) {
	rating = float.Parse(newRating);
	rating = Mathf.Floor(rating);
	
	ratingGauge.material.mainTexture = TextureManager.sharedManager.StarRatingImage(rating);
}

function SetDurability(newDurability : String) {

	durability = float.Parse(newDurability);
	durabilityLabel.text = durability.ToString();
}

function SetName(newName : String) {

	if (newName.Length > 16) {
		newName = newName.Substring(0,16);
		newName += "...";
	}

	applianceName = newName;
	nameLabel.text = applianceName;
}

function SetType(newType : String) {
	type = newType;
	typeLabel.text = type;
	
	if (type == "Refridgerator") {
		typeImage.material.mainTexture = TextureManager.sharedManager.FridgeTexture();
	}
	
	if (type == "Clothes Washer") {
		typeImage.material.mainTexture = TextureManager.sharedManager.ClothesWasherTexture();
	}
	if (type == "Clothes Dryer") {
		typeImage.material.mainTexture = TextureManager.sharedManager.ClothesDryerTexture();
	}
	if (type == "Air Conditioner") {
		typeImage.material.mainTexture = TextureManager.sharedManager.AirConditionerTexture();
	}
	if (type == "Television") {
		typeImage.material.mainTexture = TextureManager.sharedManager.TelevisionTexture();
	}
	if (type == "Dish Washer") {
		typeImage.material.mainTexture = TextureManager.sharedManager.DishWasherTexture();
	}
}

function SetPurchasable(purchasable : boolean) {
	var alpha = purchasable ? 1.0 : 0.25;

	cardBack.material.color.a = alpha;
	backboard.material.color.a = alpha;
	typeImage.material.color.a = alpha;
}

function Update () {

}

function ReduceDurability() {
	SetDurability((durability-1).ToString());
}

function Purchased() {
	costLabel.gameObject.SetActive(false);
	nameLabel.gameObject.SetActive(false);
	typeLabel.gameObject.SetActive(false);
}