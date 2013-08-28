class TCCSave extends Object;

//Estrutura do v�rtice
struct Node {
	//Localiza��o 3D
	var vector Location;
	//ID do v�rtice
	var int ID;
};
//Estrutura da Aresta
struct Edge {
	//Dist�ncia
	var float Distance;
	//IDs dos n�s que a comp�e.
	var int ID1, ID2;
};
//Lista de v�rtices
var array<Node> Nodes;
//Lista de Arestas
var array<Edge> Edges;

//Adicionar V�rtice
function AddNode(vector locLocation, int locID) {
	//Cria uma nova estrutura
	local Node NewNode;
	//Armazena a Localiza��o 3D e o ID
	NewNode.Location = locLocation;
	NewNode.ID = locID;
	//Adiciona a estrutura � lista.
	Nodes.AddItem(NewNode);
}
//Adicionar Aresta
function AddEdge(int locID1, float locDistance, int locID2) {
	//Cria uma nova estrutura
	local Edge NewEdge;
	//Armazena IDs e Dist�ncia
	NewEdge.ID1 = locID1;
	NewEdge.ID2 = locID2;
	NewEdge.Distance = locDistance;
	//Adiciona a estrutura � lista
	Edges.AddItem(NewEdge);
}

DefaultProperties
{
}
