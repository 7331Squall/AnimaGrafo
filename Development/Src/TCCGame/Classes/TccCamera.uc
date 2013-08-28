class TccCamera extends Camera;

var(DefaultView) const Vector DefaultLocation;
var(DefaultView) const Rotator DefaultRotation;

// Função executada após a criação da câmera
function PostBeginPlay() {
	//Define a localização padrão
	SetLocation(DefaultLocation);
	//Define a rotação padrão
	SetRotation(DefaultRotation);
}

// Função executada quando o ponto de vista muda.
function UpdateViewTarget( out TViewTarget OutVT, float DeltaTime) {
	//Atualiza a localização da Câmera
	OutVT.POV.Location = Location;
	//Atualiza a Rotação da Câmera
	OutVT.POV.Rotation = DefaultRotation;
}

DefaultProperties
{
	//Localização Padrão
	DefaultLocation=(X=0,Y=0,Z=512)
	//Rotação Padrão
	DefaultRotation=(Pitch=-16384,Yaw=0,Roll=0)
}
