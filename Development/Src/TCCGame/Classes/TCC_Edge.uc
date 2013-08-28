class TCC_Edge extends Actor;

var ParticleSystemComponent Particle;
var TccCalcNode NodeA, NodeB;
var float Distance;

enum STATUS {
	STS_IDLE,
	STS_PROCESSING,
	STS_REFUSED,
	STS_ACCEPTED
};

struct Step {
	var int StepNumber;
	var byte STATUS;
};

var array<Step> Steps;

function SetStep(int StepToSet, byte StatusToSet) {
	local Step NewStep;
	NewStep.StepNumber = StepToSet;
	NewStep.Status = StatusToSet;
	Steps.AddItem(NewStep);
}

function PlotSteps(int LastStep) {
	local Step SelStep, NewStep;
	local array<Step> FinalStepList;
	local int AUX;
	NewStep.STATUS = STS_IDLE;
	for (AUX = 0; AUX <= LastStep; AUX++) {
		foreach Steps(SelStep) {
			If (SelStep.StepNumber == AUX)
				NewStep.STATUS = SelStep.STATUS;
		}
		NewStep.StepNumber = AUX;
		FinalStepList.AddItem(NewStep);
	}
	Steps = FinalStepList;
}

function int GetStatusFor(int StepNo) {
	local Step SelStep;
	foreach Steps(SelStep) {
		If (SelStep.StepNumber == StepNo)
			return SelStep.STATUS;
	}
}

function DoStep(int StepToDo) {
	if (StepToDo > Steps.Length) return;
	switch (Steps[StepToDo].STATUS) {
	case STS_IDLE :
		Particle.SetVectorParameter('BeamColor', vect(1,1,20));
		break;
	case STS_PROCESSING :
		Particle.SetVectorParameter('BeamColor', vect(20,20,1));
		break;
	case STS_REFUSED :
		Particle.SetVectorParameter('BeamColor', vect(20,1,1));
		break;
	default:
		Particle.SetVectorParameter('BeamColor', vect(1,20,1));
	}
	//WorldInfo.Game.Broadcast(self ,"Aresta (" $ NodeA.ID $ ","$ NodeB.ID $ ") assume estado" @ Steps[StepToDo].STATUS);
}

function AdjustEdge(TccCalcNode Na, TccCalcNode Nb, float Ds) {
	NodeA = Na;
	NodeB = Nb;
	Distance = Ds;
	Particle = new class'ParticleSystemComponent';
	Particle.SetTemplate(ParticleSystem'TCCEffects.Particle.Beam.Edge');
	AttachComponent(Particle);
	Particle.ActivateSystem();
	Particle.SetVectorParameter('BeamSource', NodeA.Location);
	Particle.SetVectorParameter('BeamEnd', NodeB.Location);
	Particle.SetVectorParameter('BeamColor', vect(1,1,20));
	SetLocation(GetAdjustedLocation());
	//TCCGame(WorldInfo.Game).Broadcast(self,"CAMINHO:" @ Distance);
}

function DoPath() {
	Particle.SetVectorParameter('BeamColor', vect(20,20,1));
}

function UndoPath() {
	Particle.SetVectorParameter('BeamColor', vect(1,1,20));
}

function Vector GetAdjustedLocation() {
	local Vector Loc;
	Loc.X = (NodeA.Location.X + NodeB.Location.X)/2; 
	Loc.Y = (NodeA.Location.Y + NodeB.Location.Y)/2;
	Loc.Z = ((NodeA.Location.Z + NodeB.Location.Z)/2)+32;
	return Loc;
}

/** Deprecated: Usa partículas agora
function Tick(float DeltaTime) {
	local Vector Start, End;
	Start = NodeA.Location;
	End = NodeB.Location;
	Start.Z += 32;
	End.Z += 32;
	DrawDebugLine(Start, End, 0, 0, 255);
}*/

DefaultProperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorMaterials.Anchor'
		Scale=1.0  // we are using 128x128 textures so we need to scale them down
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Lighting"
	End Object
}
