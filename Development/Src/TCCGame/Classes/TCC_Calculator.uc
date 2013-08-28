class TCC_Calculator extends Actor
	placeable;

function MAKESET() {
	local TccCalcNode SelNode;
	foreach AllActors(class'TccCalcNode', SelNode) {
		SelNode.Parent = none;
	}
}

function TccCalcNode FINDSET(TccCalcNode x) {
	if (x.Parent == none)
		return x;
	else 
		return FINDSET(x.Parent);
}

function SortEdgesAscending(out array<TCC_Edge> Ordered) {
	local array<TCC_Edge> Unordered;
	local float CurrentDistance;
	local TCC_Edge SelEdge, SmallerEdge;
	//local string Debug;
	foreach AllActors(class'TCC_Edge', SelEdge) {
		Unordered.AddItem(SelEdge);
	}
	while (Unordered.Length != 0) {
		CurrentDistance = MaxInt;
		foreach Unordered(SelEdge) {
			if (SelEdge.Distance < CurrentDistance) {
				SmallerEdge=SelEdge;
				CurrentDistance = SelEdge.Distance;
			}
		}
		Ordered.AddItem(SmallerEdge);
		Unordered.RemoveItem(SmallerEdge);
		SmallerEdge = none;
	}
	/*foreach Ordered(SelEdge) {
		Debug @= SelEdge.Distance @ "(" $ SelEdge.NodeA.ID $","$SelEdge.NodeB.ID$") ->";
	}
	WorldInfo.Game.Broadcast(self, Debug);*/
}

function ResetDistance(TccCalcNode Start) {
	local TccCalcNode SelNode;
	foreach AllActors(class'TccCalcNode', SelNode) {
		SelNode.Distance = (SelNode.ID == Start.ID) ? 0 : MaxInt;
	}
}

function ResetSteps() {
	local TCC_Edge SelEdge;
	local TccCalcNode SelNode;
	foreach AllActors(class'TCC_Edge', SelEdge) {
		SelEdge.Steps.Remove(0, SelEdge.Steps.Length);
	}
	foreach AllActors(class'TccCalcNode', SelNode) {
		SelNode.Steps.Remove(0, SelNode.Steps.Length);
		SelNode.SetStarter(false);
	}
}

function PlotSteps(int LastStep) {
	local TCC_Edge SelEdge;
	foreach AllActors(class'TCC_Edge', SelEdge) {
		SelEdge.PlotSteps(LastStep);
	}
}

function PlotVertexSteps(int LastStep) {
	local TccCalcNode SelNode;
	foreach AllActors(class'TccCalcNode', SelNode) {
		SelNode.PlotSteps(LastStep);
	}
}

function String DoKruskal() {
	local int laststep, AUX;
	local float TotalDistance;
	local TccCalcNode Node1, Node2;
	local array<TCC_Edge> OrderedEdges;
	//Declara que o passo atual � o primeiro
	laststep = 0;
	//Inicia a vari�vel da dist�ncia total da �rvore m�nima;
	TotalDistance = 0;
	//Deleta a lista de passos de todas as arestas
	ResetSteps();
	//Faz com que os pais de cada v�rtice sejam nulos
	MAKESET();
	//Recebe uma lista com as dist�ncias em ordem crescente
	SortEdgesAscending(OrderedEdges);
	//Enquanto houverem arestas...
	for (AUX = 0; AUX < OrderedEdges.Length; AUX++) {
		//Diz pra aresta atual que ela est� sendo processada
		OrderedEdges[AUX].SetStep(laststep, 1);
		laststep += 1;
		//Referencia os v�rtices da aresta
		Node1 = OrderedEdges[AUX].NodeA;
		Node2 = OrderedEdges[AUX].NodeB;
		//Se ambos os v�rtices forem de conjuntos diferentes...
		if (FINDSET(Node1).ID != FINDSET(Node2).ID) {
			//Executa a UNI�O dos dois conjuntos
			FINDSET(Node2).Parent = Node1;
			//Soma a dist�ncia desta ao peso total
			TotalDistance += OrderedEdges[AUX].Distance;
			//Diz pra aresta que ela � v�lida
			OrderedEdges[AUX].SetStep(laststep, 3);
		} else {
			//Diz pra aresta que ela � inv�lida
			OrderedEdges[AUX].SetStep(laststep, 2);
		}
	}
	//Define, em todos os passos, o estado de todas as arestas n�o-processadas em cada passo.
	PlotSteps(laststep);
	//Mostra o custo total da �rvore Geradora M�nima
	return "Custo Total:" @ TotalDistance;
}

function String DoPrim(TccCalcNode Start) {
	local int laststep, AUX, SelNode;
	local bool bValid;
	local float TotalDistance;
	local TccCalcNode Node1, Node2;
	local array<TCC_Edge> OrderedEdges;
	local array<int> VertexInSet;
	//Declara que o passo atual � o primeiro
	laststep = 0;
	//Deleta a lista de passos de todas as arestas
	ResetSteps();
	//Faz com que os pais de cada v�rtice sejam nulos
	MAKESET();
	//Inicia a lista de v�rtices, adicionando o inicial
	VertexInSet.AddItem(Start.ID);
	//Recebe uma lista com as dist�ncias em ordem crescente
	SortEdgesAscending(OrderedEdges);
	while (OrderedEdges.Length > 0) {
		//Pega a aresta de peso menor que contenha pelo menos um v�rtice v�lido
		bValid = false;
		for (AUX = 0; AUX < OrderedEdges.Length; AUX++) {
			foreach VertexInSet(SelNode) {
				if (SelNode == OrderedEdges[AUX].NodeA.ID || SelNode == OrderedEdges[AUX].NodeB.ID) {
					bValid = true;
				}
			} if (bValid) break;
		}
		if (bValid) {
			//Diz pra aresta atual que ela est� sendo processada
			OrderedEdges[AUX].SetStep(laststep, 1);
			laststep += 1;
			//Referencia os v�rtices da aresta
			Node1 = OrderedEdges[AUX].NodeA;
			Node2 = OrderedEdges[AUX].NodeB;
			//Se ambos os v�rtices forem de conjuntos diferentes...
			if (FINDSET(Node1).ID != FINDSET(Node2).ID) {
				//Executa a UNI�O dos dois conjuntos
				FINDSET(Node2).Parent = FINDSET(Node1);
				//Soma a dist�ncia desta ao peso total
				TotalDistance += OrderedEdges[AUX].Distance;
				//Diz pra aresta que ela � v�lida
				OrderedEdges[AUX].SetStep(laststep, 3);
				//Se A n�o estiver no grupo de v�rtices poss�veis, adiciona-a
				bValid = false;
				foreach VertexInSet(SelNode) {
					if (SelNode == OrderedEdges[AUX].NodeA.ID) {
						bValid = true;
						break;
					}
				}
				if (!bValid) VertexInSet.AddItem(OrderedEdges[AUX].NodeA.ID);
				//Se B n�o estiver no grupo de v�rtices poss�veis, adiciona-a
				bValid = false;
				foreach VertexInSet(SelNode) {
					if (SelNode == OrderedEdges[AUX].NodeB.ID) {
						bValid = true;
						break;
					}
				}
				if (!bValid) VertexInSet.AddItem(OrderedEdges[AUX].NodeB.ID);
			} else {
				//Diz pra aresta que ela � inv�lida
				OrderedEdges[AUX].SetStep(laststep, 2);
			}
			OrderedEdges.RemoveItem(OrderedEdges[AUX]);
		}	
	}
	//Define, em todos os passos, o estado de todas as arestas n�o-processadas em cada passo.
	PlotSteps(laststep);
	//Mostra o custo total da �rvore Geradora M�nima
	return "Custo Total:" @ TotalDistance;
}

function DoDijkstra(TccCalcNode Start) {
	local int laststep;
	local float AuxDistance;
	local TccCalcNode MinNode, SelNode, TempNode;
	local TCC_Edge SelEdge;
	local array<TCC_Edge> EdgesA, EdgesB;
	local array<TccCalcNode> VertexInSet;
	//Declara que o passo atual � o primeiro
	laststep = 0;
	//Deleta a lista de passos de todas as arestas
	ResetSteps();
	Start.SetStarter(true);
	//Faz com que os pais de cada v�rtice sejam nulos
	MAKESET();
	//Adiciona todos os v�rtices � uma lista
	foreach AllActors(class'TccCalcNode', SelNode) {
		SelNode.Distance = MaxInt;
		SelNode.Parent = none;
		VertexInSet.AddItem(SelNode);
	}
	//Define a dist�ncia do inicial como 0
	Start.Distance = 0;
	//Enquanto existirem v�rtices v�lidos
	while (VertexInSet.Length > 0) {
		//cria um n� tempor�rio com dist�ncia infinita
		TempNode = Spawn(class'TccCalcNode', self);
		TempNode.Distance = MaxInt;
		//Define o tempor�rio como o menor n� at� agora
		MinNode = TempNode;
		//Procura em todos os n�s v�lidos o de menor peso
		foreach VertexInSet(SelNode) {
			if (MinNode.Distance > SelNode.Distance) {
				MinNode = SelNode;
			}
		}
		//Destr�i o n� tempor�rio
		TempNode.Destroy();
		//Remove o n� m�nimo da lista de v�rtices v�lidos
		VertexInSet.RemoveItem(MinNode);
		//O n� m�nimo assume estado "Em processamento"
		MinNode.SetStep(laststep, 1);
		//Se for infinito, quebrar la�o e terminar fun��o
		if (MinNode.Distance == MaxInt)	{
			break;
		}
		//Para todas as arestas
		foreach AllActors (class'TCC_Edge', SelEdge) {
			//Se o N� A for o m�nimo
			if (SelEdge.NodeA.ID == MinNode.ID) {
				//Se seu pai for o N� B, ajustar estado "V�lido"
				if (MinNode.Parent != none && SelEdge.NodeB.ID == MinNode.Parent.ID) {
					SelEdge.SetStep(laststep, 3);
				//Sen�o, adicionar a EdgesA e ajustar estado "Em Processamento"
				} else {
					EdgesA.AddItem(SelEdge);
					SelEdge.SetStep(laststep, 1);
				}
			//Se N� B for o m�nimo
			} else if(SelEdge.NodeB.ID == MinNode.ID) {
				//Se seu pai for o N� A, ajustar estado "V�lido"
				if (MinNode.Parent != none && SelEdge.NodeA.ID == MinNode.Parent.ID) {
					SelEdge.SetStep(laststep, 3);
				//Sen�o, adicionar a EdgesB e ajustar estado "Em Processamento"
				} else {
					EdgesB.AddItem(SelEdge);
					SelEdge.SetStep(laststep, 1);
				}
			}
		}
		//Avan�ar Passo
		laststep+=1;
		//Para cada aresta em EdgesA
		foreach EdgesA (SelEdge) {
			//Se dist�ncia de A + aresta < Dist�ncia de B
			AuxDistance = SelEdge.NodeA.Distance + SelEdge.Distance;
			if (AuxDistance < SelEdge.NodeB.Distance) {
				//Atualiza dist�ncia de B
				SelEdge.NodeB.Distance = AuxDistance;
				//Define pai de B como sendo A
				SelEdge.NodeB.Parent = SelEdge.NodeA;
				//Ajusta a dist�ncia do n� durante passo
				SelEdge.NodeB.SetStep(laststep, 3);
			}
			//Aresta assume estado "inv�lido"
			SelEdge.SetStep(laststep, 2);
		}
		//Para cada aresta em EdgesB
		foreach EdgesB (SelEdge) {
			//Se dist�ncia de B + aresta < Dist�ncia de A
			AuxDistance = SelEdge.NodeB.Distance + SelEdge.Distance;
			if (AuxDistance < SelEdge.NodeA.Distance) {
				//Atualiza dist�ncia de A
				SelEdge.NodeA.Distance = AuxDistance;
				//Define pai de B como sendo B
				SelEdge.NodeA.Parent = SelEdge.NodeB;
				//Ajusta a dist�ncia do n� durante passo
				SelEdge.NodeA.SetStep(laststep, 3);
			}
			//Aresta assume estado "inv�lido"
			SelEdge.SetStep(laststep, 2);
		}
		//N� m�nimo assume estado "J� processado"
		MinNode.SetStep(laststep, 2);
		//Limpa as listas de arestas
		EdgesA.Remove(0, EdgesA.Length);
		EdgesB.Remove(0, EdgesB.Length);
		//Avan�a passo
		laststep+=1;
	}
	//Fun��es PlotSteps de Aresta e V�rtice
	PlotSteps(laststep-1);
	PlotVertexSteps(laststep);
}

function String SerializeMatrix();

DefaultProperties
{
}
