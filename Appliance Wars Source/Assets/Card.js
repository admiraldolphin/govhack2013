#pragma strict

var flooped : boolean = false;

var canFloop = true;
var canPurchase = false;

var origin : Vector3;

var engaged = false;

var player : Player;

var floop : AudioClip;
var unfloop : AudioClip;



function Start () {
	
}

function OnMouseDown() {
	if ((canFloop && (flooped == false || (flooped == true && engaged == true))) || (flooped && GameManager.sharedManager.CardCanUnfloopInUpdatePhase(this))) {
		if (GameManager.sharedManager.CurrentPlayer() )
			SetFlooped(!flooped);
	}
	if (canPurchase) {
		origin = transform.position;
			
		if (GameManager.sharedManager.PlayerCanPurchaseAppliance(GameManager.sharedManager.CurrentPlayer(), GetComponent(Appliance))) {
			selected = true;
			
			
			var currentPosition = transform.position;
			var mousePosition = PositionForMouse();
			
			offset = currentPosition - mousePosition;
		}
	
	}
}

function SetFlooped(newFlooped:boolean) {

	

	if (newFlooped != flooped) {
		
		flooped = newFlooped;
		
		if (flooped) {
			iTween.RotateTo(gameObject, Vector3(0,90,0), 0.25);
			audio.PlayOneShot(floop);
		} else {
			iTween.RotateTo(gameObject, Vector3(0,0,0), 0.25);
			audio.PlayOneShot(unfloop);
		}
		
		if (flooped)
			engaged = true;
			
			
		GameManager.sharedManager.CardWasUnflooped();
	
	}
}

private var selected = false;
private var offset : Vector3;

private var dropTarget : GameObject;

function OnTriggerEnter(other:Collider) {

	if (selected == false)
		return;

	if (other.gameObject.CompareTag("Card Slot") == false)
		return;
		
	var cardSlot = other.gameObject.GetComponent(CardSlot) as CardSlot;
	if (cardSlot.CanReceiveCard() == false)
		return;
		
	dropTarget = other.gameObject;

}

function OnTriggerExit(other:Collider) {
	
	if (other.gameObject == dropTarget)
		dropTarget = null;
}


private function PositionForMouse() {
	var mousePosition = Input.mousePosition;
	mousePosition.x = Mathf.Clamp(mousePosition.x,0,Screen.width);
	mousePosition.y = Mathf.Clamp(mousePosition.y,0,Screen.height);
	
	var pos = Camera.mainCamera.ScreenToWorldPoint(Vector3(mousePosition.x, mousePosition.y, Camera.mainCamera.transform.position.y));
	pos.y = transform.position.y;
	
	return pos;
}


function OnMouseUp() {
	selected = false;
	
	if (canPurchase == false)
		return;
		
	if (dropTarget) {
		var position = dropTarget.transform.position;
		position.y += 0.5;
		
		iTween.MoveTo(gameObject, position, 0.25);
		
		transform.parent = null;
		
		var cardSlot = dropTarget.GetComponent(CardSlot);
		cardSlot.card = this;
		
		(GetComponent(Appliance) as Appliance).player = GameManager.sharedManager.CurrentPlayer();
		
		GameManager.sharedManager.store.CardWasPurchased(gameObject);
		GameManager.sharedManager.PlayerPurchasedAppliance(GetComponent(Appliance));
		
		canPurchase = false;
		canFloop = false;
		
		GameManager.sharedManager.CurrentPlayer().AddCard(this);
		
		
		
	} else {
		iTween.MoveTo(gameObject, origin, 0.25);
	}
		
}

function Update () {
	if (selected) {
		transform.position = PositionForMouse() + offset;
	}
}

function SetCanFloop(newCanFloop : boolean) {

	canFloop = newCanFloop;
	
}