class TccInput extends PlayerInput;

// Stored mouse position. Set to private write as we don't want other classes to modify it, but still allow other classes to access it.
var PrivateWrite IntPoint MousePosition; 

event PlayerInput(float DeltaTime)
{
  local TCCHUD TCCHUD;

  // Handle mouse movement
  // Check that we have the appropriate HUD class
  TCCHUD = TCCHUD(MyHUD);
  if (TCCHUD != None)
  {
    if (!TCCHUD.UsingScaleForm)
    {
      // If we are not using ScaleForm, then read the mouse input directly
      // Add the aMouseX to the mouse position and clamp it within the viewport width
      MousePosition.X = Clamp(MousePosition.X + aMouseX, 0, TCCHUD.SizeX);
      // Add the aMouseY to the mouse position and clamp it within the viewport height
      MousePosition.Y = Clamp(MousePosition.Y - aMouseY, 0, TCCHUD.SizeY);
    }
  }

  Super.PlayerInput(DeltaTime);
}

function SetMousePosition(int X, int Y)
{
  if (MyHUD != None)
  {
    MousePosition.X = Clamp(X, 0, MyHUD.SizeX);
    MousePosition.Y = Clamp(Y, 0, MyHUD.SizeY);
  }
}

DefaultProperties
{
}
