class TccCalcNode extends Actor
	placeable;
// Modelo 3D do nó
var(Appearance) StaticMeshComponent Mesh;
// Material do nó
var(Appearance) MaterialInstanceConstant VertexMIC;
// Usado para armazenar o nó pai durante algoritmos de Kruskal e Prim
var TccCalcNode Parent;
// Usado para armazenar a distância durante algoritmo de Dijkstra
var float Distance;
// Usado para armazenar o ID do nó
var int ID;

var(Appearance) bool bIsStart;

enum STATUS {
	STS_IDLE,
	STS_PROCESSING,
	STS_ACCEPTED,
	STS_KEEP
};

// Definição dos passos de um vértice
struct Step {
	//Número do passo
	var int StepNumber;
	//Distância do vértice durante o passo
	var float StepDistance;
	//Estado do vértice durante o passo
	var byte STATUS;
};

var array<Step> Steps;

function SetStep(int StepToSet, byte StatusToSet) {
	local Step NewStep;
	NewStep.StepNumber = StepToSet;
	NewStep.StepDistance = Distance;
	NewStep.STATUS = StatusToSet;
	Steps.AddItem(NewStep);
}

function SetStarter(bool bStart) {
	bIsStart = bStart;
}

function PlotSteps(int LastStep) {
	local Step SelStep, NewStep;
	local array<Step> FinalStepList;
	local int AUX;
	NewStep.STATUS = STS_IDLE;
	for (AUX = 0; AUX <= LastStep; AUX++) {
		foreach Steps(SelStep) {
			If (SelStep.StepNumber == AUX) {
				if (SelStep.STATUS != STS_KEEP)
					NewStep.STATUS = SelStep.STATUS;
				NewStep.StepDistance = SelStep.StepDistance;
			}
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
	local LinearColor StepColor;
	if (StepToDo > Steps.Length) return;
	if (bIsStart) {
		StepColor = MakeLinearColor(0.00, 0.50, 1.00, 1.0);
	} else {
		switch (Steps[StepToDo].STATUS) {
		case STS_PROCESSING :
			StepColor = MakeLinearColor(1.00, 1.00, 0.00, 1.0);
			break;
		case STS_ACCEPTED :
			StepColor = MakeLinearColor(1.00, 0.00, 0.00, 1.0);
			break;
		default :
			StepColor = MakeLinearColor(0.25, 0.50, 0.25, 1.0);
			
		}
	}
	VertexMIC.SetVectorParameterValue('Color', StepColor);
	Distance = Steps[StepToDo].StepDistance;
	//WorldInfo.Game.Broadcast(self ,"Vértice " $ID @ "assume estado" @ Steps[StepToDo].STATUS);
}

// Executada antes da criação do Nó.
function PreBeginPlay() {
	//Aponta para o GameType, a classe gerenciadora.
	local TCCGame GType;
	GType = TCCGame(WorldInfo.Game);
	if (GType == none) {
		self.Destroy();
		return;
	}
	ID = GType.GetSmallerID(self);
	// Apenas para não bugar
	Mesh = new class'StaticMeshComponent';
	AttachComponent(Mesh);
	// Cria o modelo certo
	UpdateMesh();
	VertexMIC = new class'MaterialInstanceConstant';
	VertexMIC.SetParent(Material'TCCEffects.Material.Base.Color_Base');
	Mesh.SetMaterial(0, VertexMIC);
	// Chama a função da SuperClasse
	super.PreBeginPlay();
}

//Função que muda o modelo do Nó.
function UpdateMesh(){
	//Confirma que o GameType certo está sendo usado
	if (TCCGame(WorldInfo.Game) != none) {
		//Remove o modelo atual (errado)
		DetachComponent(Mesh);
		//Define um modelo de acordo com uma variável no GameType
		Mesh.SetStaticMesh(StaticMesh'TCCEffects.Mesh.Static.Sphere', true);
		/*switch(TCCGame(WorldInfo.Game).GameStyle) {
		case 0:
			Mesh.SetStaticMesh(StaticMesh'TCCEffects.Mesh.Static.Sphere', true);
			break;
		case 1:
			Mesh.SetStaticMesh(StaticMesh'Pickups.Ammo_Shock.Mesh.S_Ammo_ShockRifle',true);
			break;
		case 2:
			Mesh.SetStaticMesh(StaticMesh'Pickups.Ammo_Rockets.Mesh.S_Ammo_RocketLauncher',true);
			break;
		default:
			Mesh.SetStaticMesh(StaticMesh'Pickups.Ammo_Link.Mesh.S_Ammo_LinkGun',true);
		}*/
		//Adiciona o modelo certo
		AttachComponent(Mesh);
	}
}

function DoDestroy() {
	local TCC_Edge Edge;
	foreach AllActors(class'TCC_Edge', Edge) {
		if (Edge.NodeA.ID == ID || Edge.NodeB.ID == ID)
			Edge.Destroy();
	}
	ID = -1;
	self.Destroy();
}

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
	Parent = none
	Distance = MaxInt
	bIsStart = false

	Components.Add(Sprite)
}