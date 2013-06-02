#pragma strict

private var selected = false;
private var offset : Vector3;

private var dropTarget : GameObject;

function OnTriggerEnter(other:Collider) {

	if (other.gameObject.CompareTag("Card Slot") == false)
		return;
		
	dropTarget = other.gameObject;

}

function OnTriggerExit(other:Collider) {
	if (other.gameObject == dropTarget)
		dropTarget = null;
}

function Start () {

}

private function PositionForMouse() {
	var mousePosition = Input.mousePosition;
	mousePosition.x = Mathf.Clamp(mousePosition.x,0,Screen.width);
	mousePosition.y = Mathf.Clamp(mousePosition.y,0,Screen.height);
	
	var pos = Camera.mainCamera.ScreenToWorldPoint(Vector3(mousePosition.x, mousePosition.y, Camera.mainCamera.transform.position.y));
	pos.y = transform.position.y;
	
	return pos;
}

function OnMouseDown() {
	selected = true;
	
	var currentPosition = transform.position;
	var mousePosition = PositionForMouse();
	
	offset = currentPosition - mousePosition;
}

function OnMouseUp() {
	selected = false;
	if (dropTarget) {
		var position = dropTarget.transform.position;
		position.y = transform.position.y;
		transform.position = position;
	}
		
}

function Update () {
	if (selected) {
		transform.position = PositionForMouse() + offset;
	}
}