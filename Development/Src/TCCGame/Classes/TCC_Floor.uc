class TCC_Floor extends Actor
	placeable 
	ClassGroup(TCC);

// Modelo do chão
var(Appearance) StaticMeshComponent	StaticMeshComponent;
// Material do chão
var(Appearance) MaterialInstanceConstant FloorMIC;

// Executada antes da criação do Nó.
function PreBeginPlay() {
	// Cria o modelo certo
	FloorMIC = new class'MaterialInstanceConstant';
	//Ajusta o Material
	FloorMIC.SetParent(Material'TCCEffects.Material.Base.Grid');
	UpdateColor();
	StaticMeshComponent.SetMaterial(1, FloorMIC);
	//Adiciona o Modelo à classe.
	if (TCCGame(WorldInfo.Game) != none) {
		TCCGame(WorldInfo.Game).Floor = self;
	}
	// Chama a função da SuperClasse
	//AttachComponent(FloorMesh);
	super.PreBeginPlay();
}

function UpdateColor() {
	//Aponta para o GameType, a classe gerenciadora.
	local TCCGame GType;
	GType = TCCGame(WorldInfo.Game);
	if (GType == none) return;
	FloorMIC.SetVectorParameterValue('BG', GType.BGColor);
	FloorMIC.SetVectorParameterValue('Dot', GType.DotColor);
	FloorMIC.SetVectorParameterValue('Line', GType.LineColor);
}

DefaultProperties
{
	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'TCCEffects.Mesh.Static.Floor'
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
	End Object
	CollisionComponent=StaticMeshComponent0
	StaticMeshComponent=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)
	bEdShouldSnap=true
	bStatic=false
	bMovable=false
	bCollideActors=true
	bBlockActors=true
	bWorldGeometry=true
	bGameRelevant=true
	bRouteBeginPlayEvenIfStatic=false
	bCollideWhenPlacing=false
}
