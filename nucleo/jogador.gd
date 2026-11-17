class_name Jogador
extends RefCounted
## Um mago. pontos e apenas contador simbolico de silabas colocadas.

var indice: int = 0
var mao: Array[String] = []
var pontos: int = 0


func _init(i: int = 0) -> void:
	indice = i
