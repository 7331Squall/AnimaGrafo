class TCCSave extends Object;

//Estrutura do vértice
struct Node {
	//Localização 3D
	var vector Location;
	//ID do vértice
	var int ID;
};
//Estrutura da Aresta
struct Edge {
	//Distância
	var float Distance;
	//IDs dos nós que a compõe.
	var int ID1, ID2;
};
//Lista de vértices
var array<Node> Nodes;
//Lista de Arestas
var array<Edge> Edges;

//Adicionar Vértice
function AddNode(vector locLocation, int locID) {
	//Cria uma nova estrutura
	local Node NewNode;
	//Armazena a Localização 3D e o ID
	NewNode.Location = locLocation;
	NewNode.ID = locID;
	//Adiciona a estrutura à lista.
	Nodes.AddItem(NewNode);
}
//Adicionar Aresta
function AddEdge(int locID1, float locDistance, int locID2) {
	//Cria uma nova estrutura
	local Edge NewEdge;
	//Armazena IDs e Distância
	NewEdge.ID1 = locID1;
	NewEdge.ID2 = locID2;
	NewEdge.Distance = locDistance;
	//Adiciona a estrutura à lista
	Edges.AddItem(NewEdge);
}

DefaultProperties
{
}
