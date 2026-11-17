class_name PalavraSenha
extends RefCounted
## Estado dos espacos de uma palavra-senha. -1 = aberto; senao indice do mago.

var dados: DadosPalavra
var preenchido_por: Array[int] = []


func _init(d: DadosPalavra) -> void:
	dados = d
	for k in range(d.silabas.size()):
		preenchido_por.append(-1)


func total_espacos() -> int:
	return dados.silabas.size()


func silaba(i: int) -> String:
	return dados.silabas[i]


func espaco_aberto(i: int) -> bool:
	return preenchido_por[i] == -1


func preencher(i: int, jogador: int) -> void:
	preenchido_por[i] = jogador


func completa() -> bool:
	for v in preenchido_por:
		if v == -1:
			return false
	return true
