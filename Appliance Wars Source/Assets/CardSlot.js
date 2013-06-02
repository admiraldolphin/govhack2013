#pragma strict

var cardType : String;
var card : Card;
var cardLabel : TextMesh;

var owner : Player;

function Start () {
	cardLabel.text = cardType;
}

function Update () {

}

function CanReceiveCard() {
	return card == null && GameManager.sharedManager.CurrentPlayer() == owner;
}