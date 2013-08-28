class TCCGame extends GameInfo
	config(AdvancedConfig);

// Estilo dos Modelos
var byte GameStyle;

var(Configurable) config LinearColor BGColor, DotColor, LineColor;

var(Configurable) config bool bFullscreen, bVertexOverlay, bEdgeOverlay, bShallPrePlay;

var(Configurable) config float AnimInterval;

var(Configurable) TCC_Floor Floor;

function int GetSmallerID(TccCalcNode Caller){
	local TccCalcNode SelectedNode;
	local int ID;
	local bool bShouldCalcAgain;
	ID = 0;
	bShouldCalcAgain = true;
	while (bShouldCalcAgain) {
		bShouldCalcAgain = false;
		foreach AllActors(class'TccCalcNode', SelectedNode) {
			if (SelectedNode != Caller) {
				`log("SelectedNode.Name" @ SelectedNode.Name);
				`log("ID (" $ ID $ ") == SelectedNode.ID (" $ SelectedNode.ID $ " ) =>" @ (ID == SelectedNode.ID));
				if (ID == SelectedNode.ID) {
					ID += 1;
					bShouldCalcAgain = true;
				}
				`log("ID (" $ ID $ ")");
			} else `log("Se chamou!");
		}
	}
	return ID;
}

simulated event PreBeginPlay () {
	local TCC_Floor SelFloor;
	super.PreBeginPlay();
	foreach AllActors(class'TCC_Floor', SelFloor)
		Floor = SelFloor;
	Floor.UpdateColor();
}
	

DefaultProperties
{
	HUDType = class'TCCHUD'
	PlayerControllerClass = class'TccPlayerController'
}