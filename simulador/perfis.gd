class_name Perfil
extends RefCounted
## Estrategia de um bot. Usa so a API publica da Partida.

var nome: String = "base"


## Retorno: {"acao": "jogar", "carta": int, "palavra": int, "espaco": int} ou {"acao": "trocar"}
func decidir(_partida: Partida, _rng: RandomNumberGenerator) -> Dictionary:
	return {"acao": "trocar"}


## Primeira jogada correta (carta, palavra, espaco em ordem) ou {} se nao ha.
func _jogada_certa(partida: Partida) -> Dictionary:
	var mao: Array[String] = partida.jogadores[partida.jogador_atual].mao
	for c in range(mao.size()):
		for p in range(partida.palavras.size()):
			var w: PalavraSenha = partida.palavras[p]
			for e in range(w.total_espacos()):
				if w.espaco_aberto(e) and w.silaba(e) == mao[c]:
					return {"acao": "jogar", "carta": c, "palavra": p, "espaco": e}
	return {}
