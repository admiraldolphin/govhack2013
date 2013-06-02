#pragma strict

var label : TextMesh;

function PresentWithWinner(player : Player) {
	label.text = String.Format("Player {0} Wins!", player.playerNumber);
	
	iTween.PunchScale(gameObject, Vector3(0.2,0.2,0.2), 0.3);
	
}

function Start () {

}

function Update () {

}