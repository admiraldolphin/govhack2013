#pragma strict

var airConditioners : Texture2D[];
var fridges : Texture2D[];
var dishWasher : Texture2D[];
var clothesWasher : Texture2D[];
var clothesDryer : Texture2D[];
var television : Texture2D[];

var cardBacks : Texture2D[];

var starRatings : Texture2D[];

function StarRatingImage(number : int) {
	number = Mathf.Clamp(number, 1, starRatings.length);
	return starRatings[number-1];
}


static var sharedManager : TextureManager;

function Awake() {
	sharedManager = this;
}

function RandomInArray(array : Object[]) {
	var index = Random.Range(0, array.length);
	return array[index];
}

function AirConditionerTexture() {
	return RandomInArray(airConditioners);
}

function FridgeTexture() {
	return RandomInArray(fridges);
}

function DishWasherTexture() {
	return RandomInArray(dishWasher);
}

function TelevisionTexture() {
	return RandomInArray(television);
}

function ClothesDryerTexture() {
	return RandomInArray(clothesWasher);
}

function ClothesWasherTexture() {
	return RandomInArray(clothesWasher);
}

function CardBackTexture() {
	return RandomInArray(cardBacks);
}



function Start () {

}

function Update () {

}