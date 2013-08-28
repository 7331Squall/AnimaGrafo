class TccCamera extends Camera;

var(DefaultView) const Vector DefaultLocation;
var(DefaultView) const Rotator DefaultRotation;

// Fun��o executada ap�s a cria��o da c�mera
function PostBeginPlay() {
	//Define a localiza��o padr�o
	SetLocation(DefaultLocation);
	//Define a rota��o padr�o
	SetRotation(DefaultRotation);
}

// Fun��o executada quando o ponto de vista muda.
function UpdateViewTarget( out TViewTarget OutVT, float DeltaTime) {
	//Atualiza a localiza��o da C�mera
	OutVT.POV.Location = Location;
	//Atualiza a Rota��o da C�mera
	OutVT.POV.Rotation = DefaultRotation;
}

DefaultProperties
{
	//Localiza��o Padr�o
	DefaultLocation=(X=0,Y=0,Z=512)
	//Rota��o Padr�o
	DefaultRotation=(Pitch=-16384,Yaw=0,Roll=0)
}
