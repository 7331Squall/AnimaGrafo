class TCCHUD extends HUD;

// The texture which represents the cursor on the screen
var const Texture2D CursorTexture; 
// The color of the cursor
var const Color CursorColor;
// Use ScaleForm?
var(HUD) bool bDrawEdgeOverlay, bDrawVertexOverlay, bInDijkstra;
var bool UsingScaleForm;
// Mouse 3D Location
var Vector Mouse3DLocation;
// Scaleform mouse movie
var TCC_GFx TCC_GFx;

simulated event PostBeginPlay()
{
  Super.PostBeginPlay();

  // If we are using ScaleForm, then create the ScaleForm movie
  if (UsingScaleForm)
  {
    TCC_GFx = new () class'TCC_GFx';
    if (TCC_GFx != None)
    {
      TCC_GFx.TCCHUD = Self;
      TCC_GFx.SetTimingMode(TM_Game);
	  TCC_GFx.SetViewScaleMode(SM_ShowAll);
      TCC_GFx.Init(class'Engine'.static.GetEngine().GamePlayers[TCC_GFx.LocalPlayerOwnerIndex]);
    }
  }
}

function PreCalcValues()
{
  Super.PreCalcValues();

  // If the ScaleForm movie exists, then reset it's viewport, scale mode and alignment to match the
  // screen resolution
  if (TCC_GFx != None)
  {
    TCC_GFx.SetViewport(0, 0, SizeX, SizeY);
    TCC_GFx.SetViewScaleMode(SM_NoScale);
    TCC_GFx.SetAlignment(Align_TopLeft);  
  }
}

simulated event Destroyed()
{
  Super.Destroyed();
  
  // If the ScaleForm movie exists, then destroy it
  if (TCC_GFx != None)
  {
    TCC_GFx.Close(true);
    TCC_GFx = None;
  }
}

event PostRender()
{
  local TccInput TccInput;
  local TCC_Edge SelEdge;
  local TccCalcNode SelNode;
  local Vector EdgePos;
  local float W, H;
  local String Dijkstra;
  local TCCGame GType;
  GType = TCCGame(WorldInfo.Game);
  if (GType == none) return;
  //local TCC_InteractionInterface MouseInteractionInterface;
  //local Vector HitLocation, HitNormal;
  Super.PostRender();
  Canvas.Font = Font'TCCEffects.Font.DistanceFont';
  if (GType.bEdgeOverlay) {
	foreach AllActors(class'TCC_Edge', SelEdge) {

		EdgePos = GetScreenFor(SelEdge.Location); //This wil transform the 3D position to screen space-coordinates.
		Canvas.TextSize(SelEdge.Distance, W, H);
		Canvas.SetPos((EdgePos.X-W/2)-2,(EdgePos.Y-H/2)-2);
		Canvas.SetDrawColor(0,0,64,80);
		Canvas.DrawRect(W+4,H+4);
		Canvas.SetPos(EdgePos.X-W/2,EdgePos.Y-H/2);
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.DrawText(SelEdge.Distance,true);
	}
  }
  if (bInDijkstra) {
	foreach AllActors(class'TccCalcNode', SelNode) {
		EdgePos = GetScreenFor(SelNode.Location); //This wil transform the 3D position to screen space-coordinates.
		Dijkstra = (SelNode.Distance == 0 && !SelNode.bIsStart) ? "INF" : String(SelNode.Distance);
		Canvas.TextSize(Dijkstra, W, H);
		Canvas.SetPos((EdgePos.X-W/2)-2,(EdgePos.Y-H/2)-2);
		Canvas.SetDrawColor(0,64,0,80);
		Canvas.DrawRect(W+4,H+4);
		Canvas.SetPos(EdgePos.X-W/2,EdgePos.Y-H/2);
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.DrawText(Dijkstra,true);
	}
  } else if (GType.bVertexOverlay) {
	foreach AllActors(class'TccCalcNode', SelNode) {
		EdgePos = GetScreenFor(SelNode.Location); //This wil transform the 3D position to screen space-coordinates.
		Canvas.TextSize(SelNode.ID, W, H);
		Canvas.SetPos((EdgePos.X-W/2)-2,(EdgePos.Y-H/2)-2);
		Canvas.SetDrawColor(0,64,0,80);
		Canvas.DrawRect(W+4,H+4);
		Canvas.SetPos(EdgePos.X-W/2,EdgePos.Y-H/2);
		Canvas.SetDrawColor(255,255,255,255);
		Canvas.DrawText(SelNode.ID,true);
	}
  }
  // Ensure that we aren't using ScaleForm and that we have a valid cursor
  if (!UsingScaleForm && CursorTexture != None)
  {
    // Ensure that we have a valid PlayerOwner
    if (PlayerOwner != None)
    {
      // Cast to get the TccInput
      TccInput = TccInput(PlayerOwner.PlayerInput);

      // If we're not using scale form and we have a valid cursor texture, render it
      if (TccInput != None)
      {
        // Set the canvas position to the mouse position
        Canvas.SetPos(TccInput.MousePosition.X, TccInput.MousePosition.Y);
        // Set the cursor color
        Canvas.DrawColor = CursorColor;
        // Draw the texture on the screen
        Canvas.DrawTile(CursorTexture, CursorTexture.SizeX, CursorTexture.SizeY, 0.f, 0.f, CursorTexture.SizeX, CursorTexture.SizeY,, true);
      }
    }
  }
  Mouse3DLocation = GetMouseWorldLocation();
}

function Vector GetScreenFor(Vector LocalVect) {
	local Vector Vect;
	LocalVect.Z = 0;
	Vect = Canvas.Project(LocalVect);
	return Vect;
}

function Vector GetMouseWorldLocation()
{
  local TccInput TccInput;
  local Vector2D MousePosition;
  local Vector MouseWorldOrigin, MouseWorldDirection, HitLocation, HitNormal;

  // Ensure that we have a valid canvas and player owner
  if (Canvas == None || PlayerOwner == None)
  {
    if (Canvas == none) WorldInfo.Game.Broadcast(self, "Invalid Canvas");
	if (PlayerOwner == none) WorldInfo.Game.Broadcast(self, "Invalid Player Owner");
    return Vect(0, 0, 0);
  }

  // Type cast to get the new player input
  TccInput = TccInput(PlayerOwner.PlayerInput);

  // Ensure that the player input is valid
  if (TccInput == None)
  {
	WorldInfo.Game.Broadcast(self, "Invalid Player Input");
    return Vect(0, 0, 0);
  }

  // We stored the mouse position as an IntPoint, but it's needed as a Vector2D
  MousePosition.X = TccInput.MousePosition.X;
  MousePosition.Y = TccInput.MousePosition.Y;
  // Deproject the mouse position and store it in the cached vectors
  Canvas.DeProject(MousePosition, MouseWorldOrigin, MouseWorldDirection);

  // Perform a trace to get the actual mouse world location.
  Trace(HitLocation, HitNormal, MouseWorldOrigin + MouseWorldDirection * 65536.f, MouseWorldOrigin , true,,, TRACEFLAG_Bullet);
  return HitLocation;
}

DefaultProperties
{
  CursorColor=(R=255,G=255,B=255,A=255)
  CursorTexture=Texture2D'EngineResources.Cursors.Arrow'
  UsingScaleForm=True
  bDrawEdgeOverlay=True
  bDrawVertexOverlay=False
  bInDijkstra=false
}