#pragma strict

function Start () {

}

function OnDrawGizmos() {
	var mainCamera = Camera.mainCamera;
	var height = mainCamera.orthographicSize * 2;
	var width = height * (4.0/3.0);
	
	Gizmos.color = Color.red;
	Gizmos.DrawWireCube(Vector3.zero, Vector3(width,0,height));
}

function Update () {

}