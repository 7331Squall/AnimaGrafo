class TccPlayerController extends PlayerController;

var byte CurrentHUDMode;

var byte AlgRunning;

var bool bBlockedControls, bDoDijkstra;

struct Path {
	var TccCalcNode NodeA, NodeB;
};

var Path NewPath;

var TCC_Edge EdgeInEdit;

var bool bWasBlockedBeforeTutor, bInTutor, bBlockTutor;

enum HUDModes {
	HUD_View,
	HUD_Vertex,
	HUD_Edge,
	HUD_Run
};
/** ======================================================================================================================
 *  Debug Functions
 *  ======================================================================================================================*/

exec function PrintNodes(){
	local TccCalcNode A;
	foreach AllActors(class'TccCalcNode', A) {
		//`log ("Node" @ A.Name);
		WorldInfo.Game.Broadcast(Self, "Node" @ A.Name);
	}
}

exec function PrintIDS(){
	local TccCalcNode A;
	foreach AllActors(class'TccCalcNode', A) {
		//`log ("Node" @ A.Name);
		WorldInfo.Game.Broadcast(Self, "Node ID" @ A.ID);
	}
}

exec function PrintEdges(){
	local TCC_Edge Edge;
	//TCCGame(WorldInfo.Game).PrintAllPaths();
	foreach AllActors(class'TCC_Edge', Edge) {
		WorldInfo.Game.Broadcast(self, "Caminho:" @ Edge.NodeA.ID @ "->" @ Edge.Distance @ "->" @ Edge.NodeB.ID);
	}
}

exec function CheckPopped() {
	ClientMessage("RunningAlg:" @ !IsInState('RunningAlg'));
	ClientMessage("PrimSelect:" @ !IsInState('PrimSelect'));
}

/** ======================================================================================================================
 *  Input Functions 
 *  ======================================================================================================================*/

exec function LeftClick() {
	local TccCalcNode NewNode;
	local Vector Position;
	if (CurrentHUDMode == HUD_Run || bBlockedControls) return;
	GetClicked(NewNode, Position);
	WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'TCCEffects.Particle.LeftClickParticle',Position);
	if (CurrentHUDMode == HUD_Vertex){
		if (NewNode != none) return;
		Spawn(class'TccCalcNode',,,Position);
		Worldinfo.PlaySound(SoundCue'TCC_UDKExternal.Sound.Cue.A_Character_RobotImpact_GibLarge_Cue',,,,Position);
	}
	if (CurrentHUDMode == HUD_Edge) {
		if(NewNode != none) {
			NewPath.NodeA = NewNode;
			CheckEdgeValid();
		}
	}
}

exec function RightClick() {
	local TccCalcNode NewNode;
	local Vector Position;
	if (CurrentHUDMode == HUD_Run || bBlockedControls) return;
	GetClicked(NewNode, Position);
	WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'TCCEffects.Particle.RightClickParticle',Position);
	if (CurrentHUDMode == HUD_Vertex){
		if (NewNode == none) return;
		NewNode.DoDestroy();
		Worldinfo.PlaySound(SoundCue'TCC_UDKExternal.Sound.Cue.A_Character_RobotImpact_GibLarge_Cue',,,,Position);
	}
	if (CurrentHUDMode == HUD_Edge) {
		if(NewNode != none) {
			NewPath.NodeB = NewNode;
			CheckEdgeValid();
		}
	}
}

/** Camera Functions =====================================================================================================*/

exec function CameraUp(){
	local Vector NewLocation;
	if (bBlockedControls) return;
	if (PlayerCamera == none) {
		WorldInfo.Game.Broadcast(self,"Invalid Camera");
		return;
	}
	NewLocation = PlayerCamera.Location;
	if (NewLocation.X < 512)
		NewLocation.X += 32;
	PlayerCamera.SetLocation(NewLocation);
}

exec function CameraDown(){
	local Vector NewLocation;
	if (bBlockedControls) return;
	if (PlayerCamera == none) {
		WorldInfo.Game.Broadcast(self,"Invalid Camera");
		return;
	}
	NewLocation = PlayerCamera.Location;
	if (NewLocation.X > -512)
		NewLocation.X -= 32;
	PlayerCamera.SetLocation(NewLocation);
}

exec function CameraLeft(){
	local Vector NewLocation;
	if (bBlockedControls) return;
	if (PlayerCamera == none) {
		WorldInfo.Game.Broadcast(self,"Invalid Camera");
		return;
	}
	NewLocation = PlayerCamera.Location;
	if (NewLocation.Y > -512)
		NewLocation.Y -= 32;
	PlayerCamera.SetLocation(NewLocation);
}

exec function CameraRight(){
	local Vector NewLocation;
	if (bBlockedControls) return;
	if (PlayerCamera == none) {
		WorldInfo.Game.Broadcast(self,"Invalid Camera");
		return;
	}
	NewLocation = PlayerCamera.Location;
	if (NewLocation.Y < 512)
		NewLocation.Y += 32;
	PlayerCamera.SetLocation(NewLocation);
}

exec function CameraZoomIn(){
	local Vector NewLocation;
	if (bBlockedControls) return;
	if (PlayerCamera == none) {
		WorldInfo.Game.Broadcast(self,"Invalid Camera");
		return;
	}
	NewLocation = PlayerCamera.Location;
	if (NewLocation.Z > 64)
		NewLocation.Z -= 32;
	PlayerCamera.SetLocation(NewLocation);
}

exec function CameraZoomOut(){
	local Vector NewLocation;
	if (bBlockedControls) return;
	if (PlayerCamera == none) {
		WorldInfo.Game.Broadcast(self,"Invalid Camera");
		return;
	}
	NewLocation = PlayerCamera.Location;
	if (NewLocation.Z < 512)
		NewLocation.Z += 32;
	PlayerCamera.SetLocation(NewLocation);
}

/**  Changing Modes =======================================================================================================*/

exec function ModeView() {
	if (bBlockedControls) return;
	CurrentHUDMode = HUD_View;
	TCCHUD(myHUD).TCC_GFx.UpdateHUDMode(int(CurrentHUDMode));
	TCCHUD(myHUD).TCC_GFx.Assistance(true, "Entrando no Modo VISUALIZAÇÃO");
	SetTimer(1.0,false,'EndHelper');
}

exec function ModeVertex() {
	if (bBlockedControls) return;
	CurrentHUDMode = HUD_Vertex;
	TCCHUD(myHUD).TCC_GFx.UpdateHUDMode(int(CurrentHUDMode));
	TCCHUD(myHUD).TCC_GFx.Assistance(true, "Entrando no Modo VÉRTICE");
	SetTimer(1.0,false,'EndHelper');
}

//Função que muda pro Modo Aresta
exec function ModeEdge() {
	//Caso alguma janela bloqueie os controles, cancelar a mudança.
	if (bBlockedControls) return;
	//Define que o Modo atual é o Modo Aresta
	CurrentHUDMode = HUD_Edge;
	//Atualiza o HUD
	TCCHUD(myHUD).TCC_GFx.UpdateHUDMode(int(CurrentHUDMode));
	//Exibindo uma mensagem avisando da mudança de modo.
	TCCHUD(myHUD).TCC_GFx.Assistance(true, "Entrando no Modo ARESTA");
	//Sumindo com a mensagem em 1 segundo
	SetTimer(1.0,false,'EndHelper');
}

exec function ModeRun() {
	if (bBlockedControls) return;
	CurrentHUDMode = HUD_Run;
	TCCHUD(myHUD).TCC_GFx.UpdateHUDMode(int(CurrentHUDMode));
	TCCHUD(myHUD).TCC_GFx.Assistance(true, "Entrando no Modo EXECUÇÃO");
	SetTimer(1.0,false,'EndHelper');
}

exec function HelpTutor() {
	if (bBlockTutor) return;
	if (!bInTutor) {
		bWasBlockedBeforeTutor = bBlockedControls;
		bBlockedControls = true;
		bInTutor = true;
	} else {
		bBlockedControls = bWasBlockedBeforeTutor;
		bInTutor = false;
	}
	if (!IsInState('RunningAlg')) {
		TCCHUD(myHUD).TCC_GFx.TutorMe(bInTutor);
		TCCHUD(myHUD).TCC_GFx.SpecialTutorMe(false, 1);
		TCCHUD(myHUD).TCC_GFx.Assistance(bInTutor, "<< Pressione F1 para Retornar >>");
	} else {
		TCCHUD(myHUD).TCC_GFx.TutorMe(false);
		TCCHUD(myHUD).TCC_GFx.SpecialTutorMe(bInTutor, AlgRunning);
		TCCHUD(myHUD).TCC_GFx.Assistance(bInTutor, "<< Pressione F1 para Retornar >>");
	}
}

exec function ChangeColor( byte ColorToSet, int R, int G, int B) {
	local LinearColor NewColor;
	local TCCGame GType;
	local float NR, NG, NB;
	GType = TCCGame(WorldInfo.Game);
	if (GType == none) return;
	NR = float(R)/255;
	NG = float(G)/255;
	NB = float(B)/255;
	//ClientMessage("Cor Nova:" @ NR @ NG @ NB);
	NewColor = MakeLinearColor(NR, NG, NB, 1.0);
	switch (ColorToSet) {
	case 0:
		GType.BGColor = NewColor;
		break;
	case 1:
		GType.DotColor = NewColor;
		break;
	default:
		GType.LineColor = NewColor;
	}
	GType.Floor.UpdateColor();
	GType.SaveConfig();
}

function UpdateResolution() {
	local TCCGame GType;
	GType = TCCGame(WorldInfo.Game);
	if (GType == none) return;
	if (GType.bFullscreen) {
		ConsoleCommand("setres 800x600f");
	} else {
		ConsoleCommand("setres 800x600w");
	}
}

/** ======================================================================================================================
 *  Saving Functions
 *  ======================================================================================================================*/

//Salva um objeto
exec function SaveState(string SaveName) {
	local TCCSave SaveState;
	local TccCalcNode SelectedNode;
	local TCC_Edge SelectedEdge;
	//Aborta se não especificar um nome
	if (SaveName == "") return;
	//Cria um objeto Save
	SaveState = new class 'TCCSave';
	//Adiciona todas as arestas ao save
	foreach AllActors(class'TCC_Edge', SelectedEdge) {
		SaveState.AddEdge(SelectedEdge.NodeA.ID, SelectedEdge.Distance, SelectedEdge.NodeB.ID);
	}
	//Adiciona todos os vértices ao save
	foreach AllActors(class'TccCalcNode', SelectedNode) {
		SaveState.AddNode(SelectedNode.Location, SelectedNode.ID);
	}
	//Se conseguir salvar o objeto num arquivo
	if (class'Engine'.static.BasicSaveObject(SaveState, "..\\..\\Save\\" $  SaveName $ ".ags", true, 1)) {
		if (SaveName != "Quick")
			//Exibe mensagem normal
			TCCHUD(myHUD).TCC_GFx.Assistance(true, "Arquivo" @ SaveName @ "criado com sucesso. (" $ SaveState.Edges.Length @ "arestas," @ SaveState.Nodes.Length @ "nós).");
		else
			//Mensagem de QuickSave
			TCCHUD(myHUD).TCC_GFx.Assistance(true, "Quicksaving...");
		//Tempo para apagar a mensagem da tela.
		SetTimer(2.0,false,'EndHelper');
	}
}

//Carrega um objeto salvo
exec function LoadState(string SaveName) {
	local TCCSave SaveState;
	local int aaa;
	local TCCCalcNode SelectedNode, StartNode, EndNode;
	local TCC_Edge SelectedEdge;
	//Aborta se não especificar um nome
	if (SaveName == "") return;
	//Cria um objeto Save
	SaveState = new class 'TCCSave';
	//Se conseguir carregar o objeto especificado
	if (class'Engine'.static.BasicLoadObject(SaveState, "..\\..\\Save\\" $ SaveName $ ".ags", true, 1)) {
		if (SaveName != "Quick") 
			//Exibe mensagem normal
			TCCHUD(myHUD).TCC_GFx.Assistance(true, "Arquivo" @ SaveName @ "carregado com sucesso.");
		else
			//Mensagem de QuickLoad
			TCCHUD(myHUD).TCC_GFx.Assistance(true, "Quickloading...");
		//Tempo para apagar a mensagem da tela.
		SetTimer(2.0,false,'EndHelper');
	}
	else {
		//Se não conseguir carregar, exibir mensagem de erro
		TCCHUD(myHUD).TCC_GFx.Assistance(true, "Falhou em carregar o arquivo" @ SaveName $ ".");
		SetTimer(2.0,false,'EndHelper');
		//Cancelar função
		return;
	}
	//Limpar Grafo
	CleanStage();
	//Pra cada nó
	for (aaa = 0; aaa < SaveState.Nodes.Length; aaa++) {
		//Criar nó na posição do nó salvo
		SelectedNode = Spawn(class'TccCalcNode',,,SaveState.Nodes[aaa].Location);
		//Ajustar a mesma ID do salvo
		SelectedNode.ID = SaveState.Nodes[aaa].ID;
	}
	//Pra cada aresta
	for (aaa = 0; aaa < SaveState.Edges.Length; aaa++) {
		//Achar o NodeA
		foreach AllActors(class'TccCalcNode', SelectedNode) {
			if (SelectedNode.ID == SaveState.Edges[aaa].ID1) {
				StartNode = SelectedNode;
				break;
			}
		}
		//Achar o NodeB
		foreach AllActors(class'TccCalcNode', SelectedNode) {
			if (SelectedNode.ID == SaveState.Edges[aaa].ID2) {
				EndNode = SelectedNode;
				break;
			}
		}
		//Criar uma aresta qualquer
		SelectedEdge = Spawn(class'TCC_Edge');
		//Ajustá-la de acordo com a aresta salva
		SelectedEdge.AdjustEdge(StartNode, EndNode, SaveState.Edges[aaa].Distance);
	}
}

/** ======================================================================================================================
 *  Edge Functions
 *  ======================================================================================================================*/

function CheckEdgeValid() {
	local TCC_Edge SelEdge;
	local TccCalcNode SWAPPER;
	local int NewDistance;
	local float EuclidianDistance;
	if (NewPath.NodeA == none || NewPath.NodeB == none) return;
	if (NewPath.NodeA == NewPath.NodeB) return;
	if (NewPath.NodeA.ID > NewPath.NodeB.ID) {
		SWAPPER = NewPath.NodeA;
		NewPath.NodeA = NewPath.NodeB;
		NewPath.NodeB = SWAPPER;
	}
	foreach AllActors(class'TCC_Edge', SelEdge) {
		if ((SelEdge.NodeA.ID == NewPath.NodeA.ID) && (SelEdge.NodeB.ID == NewPath.NodeB.ID)) {
			EdgeInEdit = SelEdge;
			TCCHUD(myHUD).TCC_GFx.EditEdgeDialog(String(EdgeInEdit.Distance));
		}
	}
	if (EdgeInEdit == None) {
		//Calculating the Euclidian Distance
		NewDistance = (VSize(NewPath.NodeA.Location - NewPath.NodeB.Location)/16)*10000;
		EuclidianDistance = float(NewDistance)/10000;
		//Assigning stuff for the GFx.
		EdgeInEdit = Spawn(class'TCC_Edge');
		EdgeInEdit.NodeA = NewPath.NodeA;
		EdgeInEdit.NodeB = NewPath.NodeB;
		EdgeInEdit.Distance = EuclidianDistance;
		EdgeInEdit.AdjustEdge(EdgeInEdit.NodeA, EdgeInEdit.NodeB, EdgeInEdit.Distance);
		TCCHUD(myHUD).TCC_GFx.DistanceDialog(String(EuclidianDistance));
	}
	ResetPath();
}

function UpdateEdge(float FinalDistance) {
	EdgeInEdit.Distance = FinalDistance;
	EdgeInEdit = none;
}

function RemoveEdge() {
	EdgeInEdit.Destroy();
	EdgeInEdit = none;
}

/** ======================================================================================================================
 *  Utilitary Functions
 *  ======================================================================================================================*/

exec function CleanStage() {
	local TccCalcNode SelectedNode;
	local TCC_Edge SelectedEdge;
	foreach AllActors(class'TCC_Edge', SelectedEdge) {
		SelectedEdge.Destroy();
	}
	foreach AllActors(class'TccCalcNode', SelectedNode) {
		SelectedNode.Destroy();
	}
}

exec function QuitGame() {
	ConsoleCommand("Exit");
}

exec function SetStageStep(int StepNo) {
	local TCC_Edge SelEdge;
	local TccCalcNode SelNode;
	foreach AllActors(class'TCC_Edge', SelEdge) {
		SelEdge.DoStep(StepNo);
	}
	if (TCCHUD(myHUD).bInDijkstra) {
		foreach AllActors(class'TccCalcNode', SelNode) {
			SelNode.DoStep(StepNo);
		}
	}
	PlaySound(SoundCue'TCCEffects.Sound.Cue.EdgeSound');
}

exec function DoKruskal() {
	local TCC_Calculator Calc;
	local TCC_Edge SelEdge;
	local bool bHasEdge;
	//Checa se existe alguma aresta no grafo
	bHasEdge = false;
	foreach AllActors(class'TCC_Edge',SelEdge) {
		bHasEdge = true;
		break;
	}
	//Se não existir nenhuma aresta
	if (!bHasEdge) {
		//Exibe mensagem de erro
		TCCHUD(myHUD).TCC_GFx.Assistance(true, "Crie pelo menos 1 aresta!");
		//Apagar a mensagem em 3 segundos
		SetTimer(3.0,false,'EndHelper');
		//Terminar a função
		return;
	}
	//Algoritmo de Kruskal = Ajuda 0
	AlgRunning = 0;
	//Esconde os botões do modo de Execução.
	TCCHUD(myHUD).TCC_GFx.HideRUNwindow(true);
	//Cria uma calculadora
	Calc = Spawn(class'TCC_Calculator');
	//Exibe o resultado da calculadora
	TCCHUD(myHUD).TCC_GFx.Assistance(true, "Algoritmo de Kruskal:" @ Calc.DoKruskal());
	//Entra no estado "RunningAlg"
	PushState('RunningAlg');
	//CheckPopped();
	Calc.Destroy();
}

exec function GFxPrim() {
	local bool bHasEdge;
	local TCC_Edge SelEdge;
	//Assim como em DoKruskal, checa se existe alguma aresta no grafo e esconde os botões
	bHasEdge = false;
	foreach AllActors(class'TCC_Edge',SelEdge) {
		bHasEdge = true;
		break;
	}
	if (!bHasEdge) {
		TCCHUD(myHUD).TCC_GFx.Assistance(true, "Crie pelo menos 1 aresta!");
		SetTimer(3.0,false,'EndHelper');
		return;
	}
	TCCHUD(myHUD).TCC_GFx.HideRUNwindow(true);
	//Entra no estado PrimSelect
	PushState('PrimSelect');
}

exec function DoPrim(TccCalcNode Start) {
	local TCC_Calculator Calc;
	//Cria uma calculadora
	Calc = Spawn(class'TCC_Calculator');
	//Algoritmo de Prim = Ajuda 1
	AlgRunning = 1;
	//Exibe o resultado da calculadora
	TCCHUD(myHUD).TCC_GFx.Assistance(true, "Algoritmo de Prim: " @ Calc.DoPrim(Start));
	//Entra no estado "RunningAlg"
	PushState('RunningAlg');
	//Destrói a Calculadora
	Calc.Destroy();
}

exec function GFxDijkstra() {
	local bool bHasEdge;
	local TCC_Edge SelEdge;
	bHasEdge = false;
	foreach AllActors(class'TCC_Edge',SelEdge) {
		bHasEdge = true;
		break;
	}
	if (!bHasEdge) {
		TCCHUD(myHUD).TCC_GFx.Assistance(true, "Crie pelo menos 1 aresta!");
		SetTimer(3.0,false,'EndHelper');
		return;
	}
	TCCHUD(myHUD).TCC_GFx.HideRUNwindow(true);
	PushState('DijkstraSelect');
	//CheckPopped();
}

exec function DoDijkstra(TccCalcNode Start) {
	local TCC_Calculator Calc;
	//Cria uma calculadora
	Calc = Spawn(class'TCC_Calculator');
	//Algoritmo de Dijkstra = Ajuda 2
	AlgRunning = 2;
	TCCHUD(myHUD).bInDijkstra = true;
	//Roda o Algoritmo de Dijkstra da Calculadora
	Calc.DoDijkstra(Start);
	//Exibe uma mensagem no HUD
	TCCHUD(myHUD).TCC_GFx.Assistance(true, "Algoritmo de Dijkstra");
	//Entra no estado "RunningAlg"
	PushState('RunningAlg');
	//Destrói a Calculadora
	Calc.Destroy();
}

exec function OpenQuitWindow() {
	if (bBlockedControls || bInTutor) return;
	TCCHUD(myHUD).TCC_GFx.OpenQuitWindow();
}

/** ======================================================================================================================
 *  Auxiliary Functions
 *  ======================================================================================================================*/

simulated function PostBeginPlay() {
	super.PostBeginPlay();
	UpdateResolution();
	ResetPath();
	SetTimer(3.0,false,'EndHelper');
}

function EndHelper(){
	TCCHUD(myHUD).TCC_GFx.Assistance(false);
}

function ResetPath(){
	NewPath.NodeA = none;
	NewPath.NodeB = none;
}

function GetClicked(out TccCalcNode ClickedNode, out vector Position) {
	local TccCalcNode SelectedNode;
	ClickedNode = none;
	Position = TCCHUD(myHUD).Mouse3DLocation;
	Position.X = (Position.X >= 0) ? int((Position.X+8)/16)*16 : int((Position.X-8)/16)*16;
	Position.Y = (Position.Y >= 0) ? int((Position.Y+8)/16)*16 : int((Position.Y-8)/16)*16;
	Position.Z = (Position.Z >= 0) ? int((Position.Z+8)/16)*16 : int((Position.Z-8)/16)*16;
	foreach AllActors(class'TccCalcNode', SelectedNode) {
		if (SelectedNode.Location == Position) ClickedNode = SelectedNode;
	}
	//WorldInfo.Game.Broadcast(self, "TRACED: " @ ClickedNode.Name);
	WorldInfo.Game.Broadcast(self, "Posição do Mouse:");
	WorldInfo.Game.Broadcast(self, "X:" @ Position.X);
	WorldInfo.Game.Broadcast(self, "Y:" @ Position.Y);
	WorldInfo.Game.Broadcast(self, "Z:" @ Position.Z);
	//if (ClickedNode != none) WorldInfo.Game.Broadcast(self, "ClickedNode:" @ ClickedNode.Name);
}

//Anula a função que atualiza a rotação do jogador
function UpdateRotation(float DeltaTime);

function StopStepper() {
	ClientMessage("Chamou a função base");
}



/** ======================================================================================================================
 *  Estado do Algoritmo de Prim
 *  ======================================================================================================================*/
state PrimSelect {
	//Função executada pelo botão esquerdo do Mouse
	exec function LeftClick() {
		local TccCalcNode NewNode;
		local Vector Position;
		//Checa se clicou num espaço vazio ou em um vértice
		GetClicked(NewNode, Position);
		//Exibe um efeito
		WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'TCCEffects.Particle.RunClickParticle',Position);
		//Cancela se clicou em um espaço vazio
		if (NewNode == none) return;
		//Sai do estado
		PopState();
		//Chama a função DoPrim
		DoPrim(NewNode);
	}

	//Função executada pelo botão direito do Mouse
	exec function RightClick() {
		//Chama a função LeftClick
		LeftClick();
	}
	//Anulando funções que mudam de modo
	exec function ModeView();
	exec function ModeVertex();
	exec function ModeEdge();
	exec function ModeRun();
//Ao começar a execução do estado
Begin:
	//Chamar mensagem de ajuda
	 TCCHUD(myHUD).TCC_GFx.Assistance(true, "SELECIONE O VÉRTICE INICIAL");
}
/** ======================================================================================================================
 *  Estado do Algoritmo de Dijkstra
 *  ======================================================================================================================*/
state DijkstraSelect {
	exec function LeftClick() {
		local TccCalcNode NewNode;
		local Vector Position;
		GetClicked(NewNode, Position);
		WorldInfo.MyEmitterPool.SpawnEmitter(ParticleSystem'TCCEffects.Particle.RunClickParticle',Position);
		if (NewNode == none) return;
		PopState();
		DoDijkstra(NewNode);
	}

	exec function RightClick() {
		LeftClick();
	}
	//Anulando funções que mudam de modo
	exec function ModeView();
	exec function ModeVertex();
	exec function ModeEdge();
	exec function ModeRun();
Begin:
	 TCCHUD(myHUD).TCC_GFx.Assistance(true, "SELECIONE O VÉRTICE INICIAL");
}
/** ======================================================================================================================
 *  Estado da Janela de Execução
 *  ======================================================================================================================*/
state RunningAlg {
	//Variáveis do estado
	local int CurStep, MaxStep;
	//Retorna a quantidade de passos da primeira aresta disponível.
	function int GetNumberOfSteps() {
		local TCC_Edge SelEdge;
		foreach AllActors(class'TCC_Edge', SelEdge) {
			return SelEdge.Steps.Length;
		}
	}
	//Esconde/Mostra janela de passos
	exec function OpenQuitWindow() {
		TCCHUD(myHUD).TCC_GFx.HideStepper();
	}

	//Anulando funções que mudam de modo
	exec function ModeView();
	exec function ModeVertex();
	exec function ModeEdge();
	exec function ModeRun();

	//Termina a execução do estado
	function StopStepper() {
		local TCC_Calculator Calc;
		//Limpa a lista de passos
		Calc = Spawn(class'TCC_Calculator');
		Calc.ResetSteps();
		Calc.Destroy();
		//Reseta o estado de todos os objetos
		SetStageStep(-1);
		//Mostra botões do Modo de Execução do HUD
		TCCHUD(myHUD).TCC_GFx.HideRUNwindow(false);
		//Limpa a mensagem do algoritmo
		TCCHUD(myHUD).TCC_GFx.Assistance(false);
		//Reseta o Overlay dos vértices
		TCCHUD(myHUD).bInDijkstra = false;
		//Sai do estado
		PopState();
	}

	exec function LeftClick() {
		//Define passo como o penúltimo
		CurStep = MaxStep-1;
	}

	exec function RightClick() {
		LeftClick();
	}

Begin:
	//Ajusta o nº de passos máximo
	MaxStep = GetNumberOfSteps();
	//Primeiro passo
	CurStep = 0;
	//Se deve tocar animação automática
	if (TCCGame(WorldInfo.Game).bShallPrePlay) {
		//pula pra NextStep
		goto('NextStep');
	} else {
		//Senão, define último passo
		CurStep = MaxStep;
		SetStageStep(MaxStep-1);
		//Pula pra OpenWindow
		goto('OpenWindow');
	}

NextStep:
	//Executa passo atual
	SetStageStep(CurStep);
	//Avança passo
	CurStep++;
	//Se não for o último
	if (CurStep < MaxStep) {
		//Espera X segundos
		sleep(TCCGame(WorldInfo.Game).AnimInterval);
		//Volta pra NextStep
		goto('NextStep');
	} else {
		//Senão, pula pra OpenWindow
		goto('OpenWindow');
	}
OpenWindow:
	//Cria a janela de passos
	TCCHUD(myHUD).TCC_GFx.StartStepper(CurStep, MaxStep);
	//Desbloqueia a câmera
	bBlockedControls = false;
}

DefaultProperties
{
	CameraClass = class'TccCamera'
	InputClass = class'TccInput'
	CurrentHUDMode=0
	bBlockedControls = false
	bBlockTutor = false
}
