class_name DistribuicaoBaralho
extends Resource
## Copias por silaba do baralho fisico (100 cartas, 22 silabas). Somente leitura.

@export var copias: Dictionary[String, int] = {}


func copias_de(silaba: String) -> int:
	return copias.get(silaba, 0)


func total() -> int:
	var soma: int = 0
	for s in copias:
		soma += copias[s]
	return soma
