#pragma strict

var target : GameObject;
var message : String;
var background : Renderer;

var buttonEnabled = true;

function Start () {
	iTween.Init(gameObject);
}

function OnMouseDown() {
	if (buttonEnabled == false)
		return;
		
	iTween.ScaleTo(gameObject, Vector3(0.9,1,0.9), 0.2);
}

function OnMouseUp() {
	if (buttonEnabled == false)
		return;
	
	iTween.ScaleTo(gameObject, Vector3(1,1,1), 0.2);
}

function OnMouseUpAsButton() {
	if (buttonEnabled == false)
		return;
	
	target.SendMessage(message);
}

function Update () {

}

function SetButtonEnabled(newEnabled : boolean) {
	buttonEnabled = newEnabled;
	
	if (buttonEnabled) {
		background.material.color.a = 1.0;
	} else {
		background.material.color.a = 0.5;
	}
}