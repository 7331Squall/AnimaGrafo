class TCC_GFx extends GFxMoviePlayer;
/*
 * Esse código é responsável pela interação do
 * Scaleform GFx com a Engine.
 */

//Classe HUD dona desse Scaleform
var TCCHUD TCCHUD;

//Função executada quando o Scaleform é criado
function Init(optional LocalPlayer LocalPlayer)
{
  // Executa o código da Super-Classe
  Super.Init(LocalPlayer);
  // Inicia a reprodução do Movie
  Start();
  // A partir do frame 0
  Advance(0);
}

//Evento chamado cada vez que o jogador mover o Mouse
event UpdateMousePosition(float X, float Y)
{
  // Declaração de Variáveis
  local TccInput TccInput;
  //Se tivermos um HUD e um jogador que seja seu dono
  if (TCCHUD != None && TCCHUD.PlayerOwner != None)
  {
	//Recebe o gerenciador de inputs do jogador dono
    TccInput = TccInput(TCCHUD.PlayerOwner.PlayerInput);
	//Se for válido, executa a função da classe Input.
    if (TccInput != None)
    {
      TccInput.SetMousePosition(X, Y);
    }
  }
}

function BlockInput(bool Block) {
	if (TCCHUD.PlayerOwner != none)
		TCCPlayerController(TCCHUD.PlayerOwner).bBlockedControls = Block;
}

function QuitGame() {
	if (TCCHUD.PlayerOwner != none)
		TCCPlayerController(TCCHUD.PlayerOwner).QuitGame();
}

function SaveGame(string SaveName) {
	if (TCCHUD.PlayerOwner != none)
		TCCPlayerController(TCCHUD.PlayerOwner).SaveState(SaveName);
}

function LoadGame(string SaveName) {
	if (TCCHUD.PlayerOwner != none)
		TCCPlayerController(TCCHUD.PlayerOwner).LoadState(SaveName);
}

function WipeGame() {
	if (TCCHUD.PlayerOwner != none)
		TCCPlayerController(TCCHUD.PlayerOwner).CleanStage();
}

function KruskalGFx() {
	if (TCCHUD.PlayerOwner != none) {
		TCCPlayerController(TCCHUD.PlayerOwner).DoKruskal();
	}
}

function PrimGFx() {
	if (TCCHUD.PlayerOwner != none) {
		TCCPlayerController(TCCHUD.PlayerOwner).GFxPrim();
	}
}

function DijkstraGFx() {
	if (TCCHUD.PlayerOwner != none) {
		TCCPlayerController(TCCHUD.PlayerOwner).GFxDijkstra();
	}
}

function AdjustStuff(bool bFS, bool bEO, bool bVO, bool bPP, float fAI) {
	local TCCGame GType;
	GType = TCCGame(TCCHUD.PlayerOwner.WorldInfo.Game);
	if (GType == none) return;
	if (GType.bFullscreen != bFS) {
		GType.bFullscreen = bFS;
		TccPlayerController(TCCHUD.PlayerOwner).UpdateResolution();
	}
	if (GType.bEdgeOverlay != bEO) {
		GType.bEdgeOverlay = bEO;
	}
	if (GType.bVertexOverlay != bVO) {
		GType.bVertexOverlay = bVO;
	}
	if (GType.bShallPrePlay != bPP) {
		GType.bShallPrePlay = bPP;
	}
	if (GType.AnimInterval != fAI) {
		GType.AnimInterval = fAI;
	}
	GType.SaveConfig();
}

function SetColor(byte ColorToSet, int R, int G, int B) {
	if (TCCHUD.PlayerOwner != none) {
		TCCPlayerController(TCCHUD.PlayerOwner).ChangeColor(ColorToSet, R, G, B);
	}
}

function UpdateEdge(float FinalDistance) {
	if (TCCHUD.PlayerOwner != none)
		TCCPlayerController(TCCHUD.PlayerOwner).UpdateEdge(FinalDistance);
}
function RemoveEdge() {
	if (TCCHUD.PlayerOwner != none)
		TCCPlayerController(TCCHUD.PlayerOwner).RemoveEdge();
}

function GFxObject GetColor(byte ColorToGet) {
	local GFxObject TempObj;
	local ASValue asvalR, asvalG, asvalB;
	local array<ASValue> args;
	local TCCGame GType;
	local LinearColor RColor;
	GType = TCCGame(TCCHUD.PlayerOwner.WorldInfo.Game);
	if (TCCHUD.PlayerOwner != none && GType != none) {
		TempObj = CreateObject("Object");
		asvalR.Type = AS_Number;
		asvalG.Type = AS_Number;
		asvalB.Type = AS_Number;
		switch(ColorToGet) {
		case 0:
			RColor = GType.BGColor;
			break;
		case 1:
			RColor = GType.DotColor;
			break;
		default:
			RColor = GType.LineColor;
		}
		asvalR.n = RColor.R *255;
		asvalG.n = RColor.G *255;
		asvalB.n = RColor.B *255;
		args[0] = asvalR;
		args[1] = asvalG;
		args[2] = asvalB;
		TempObj.Set("R", args[0]);
		TempObj.Set("G", args[1]);
		TempObj.Set("B", args[2]);
		return TempObj;
	}
}

function GFxObject GetBools() {
	local GFxObject TempObj;
	local ASValue asFS, asEO, asVO, asPP, asAI;
	local array<ASValue> args;
	local TCCGame GType;
	GType = TCCGame(TCCHUD.PlayerOwner.WorldInfo.Game);
	if (TCCHUD.PlayerOwner != none && GType != none) {
		TempObj = CreateObject("Object");
		asFS.Type = AS_Boolean;
		asEO.Type = AS_Boolean;
		asVO.Type = AS_Boolean;
		asPP.Type = AS_Boolean;
		asAI.Type = AS_Number;
		asFS.b = GType.bFullscreen;
		asEO.b = GType.bEdgeOverlay;
		asVO.b = GType.bVertexOverlay;
		asPP.b = GType.bShallPrePlay;
		asAI.n = GType.AnimInterval;
		args[0] = asFS;
		args[1] = asEO;
		args[2] = asVO;
		args[3] = asPP;
		args[4] = asAI;
		TempObj.Set("asFS", args[0]);
		TempObj.Set("asEO", args[1]);
		TempObj.Set("asVO", args[2]);
		TempObj.Set("asPP", args[3]);
		TempObj.Set("asAI", args[4]);
		return TempObj;
	}
}

//Wrapper que se associa a uma função no Flash.
function Assistance(bool bVisible, optional String sMessage = "") {
	TCCPlayerController(TCCHUD.PlayerOwner).ClearTimer('EndHelper');
	`log("Rodando Assistance");
	ActionScriptVoid("_root.Assistance");
}

//Wrapper que se associa a uma função no Flash.
function OpenQuitWindow() {
	`log("Rodando OpenQuitWindow");
	ActionScriptVoid("_root.OpenQuitWindow");
}

//Wrapper que se associa a uma função no Flash.
function HideStepper() {
	`log("Rodando HideStepper");
	ActionScriptVoid("_root.HideStepper");
}

//Wrapper que se associa a uma função no Flash.
function TutorMe(bool bTutor) {
	`log("Rodando TutorMe");
	ActionScriptVoid("_root.TutorMe");
}

//Wrapper que se associa a uma função no Flash.
function SpecialTutorMe(bool bTutor, byte AlgRunning) {
	`log("Rodando SpecialTutorMe");
	ActionScriptVoid("_root.SpecialTutorMe");
}

//Wrapper que se associa a uma função no Flash.
function UpdateHUDMode(int NewMode) {
	`log("Rodando UpdateHUDMode");
	ActionScriptVoid("_root.UpdateHUDMode");
}

//Wrapper que se associa a uma função no Flash.
function HideRUNwindow(bool bHidden) {
	`log("Rodando HideRUNwindow");
	ActionScriptVoid("_root.HideRUNwindow");
}

//Wrapper que se associa a uma função no Flash.
function DistanceDialog(string Distance) {
	`log("Rodando DistanceDialog");
	ActionScriptVoid("_root.DistanceDialog");
}

//Wrapper que se associa a uma função no Flash.
function EditEdgeDialog(string Distance) {
	`log("Rodando EditEdgeDialog");
	ActionScriptVoid("_root.EditEdgeDialog");
}

//Wrapper que se associa a uma função no Flash.
function StartStepper(int CurStep, int MaxStep) {
	`log("Rodando StartStepper");
	ActionScriptVoid("_root.StartStepper");
}

function SetStepper(int StepNo) { 
	if (TCCHUD.PlayerOwner != none) {
		//TCCPlayerController(TCCHUD.PlayerOwner).ClientMessage("Fazendo passo:" @ StepNo-1);
		TCCPlayerController(TCCHUD.PlayerOwner).SetStageStep(StepNo-1);
	}
}

function StopStepper() { 
	if (TCCHUD.PlayerOwner != none)
		TCCPlayerController(TCCHUD.PlayerOwner).StopStepper();
}

defaultproperties
{    
  bDisplayWithHudOff=false
  TimingMode=TM_Game
	//Arquivo Flash
  MovieInfo=SwfMovie'TCCInterface.Interface'
  bPauseGameWhileActive=false
}