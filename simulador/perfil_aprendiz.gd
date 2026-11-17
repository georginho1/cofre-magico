class_name PerfilAprendiz
extends Perfil
## Como o perfeito, mas erra o espaco com probabilidade cfg.taxa_erro_aprendiz (D-17).


func _init() -> void:
	nome = "aprendiz"


func decidir(partida: Partida, rng: RandomNumberGenerator) -> Dictionary:
	var j := _jogada_certa(partida)
	if j.is_empty():
		return {"acao": "trocar"}
	if rng.randf_range(0.0, 1.0) < partida.cfg.taxa_erro_aprendiz:
		var carta: String = partida.jogadores[partida.jogador_atual].mao[j["carta"]]
		var erradas: Array = []
		for p in range(partida.palavras.size()):
			var w: PalavraSenha = partida.palavras[p]
			for e in range(w.total_espacos()):
				if w.espaco_aberto(e) and w.silaba(e) != carta:
					erradas.append([p, e])
		if not erradas.is_empty():
			var alvo: Array = erradas[rng.randi_range(0, erradas.size() - 1)]
			return {"acao": "jogar", "carta": j["carta"], "palavra": alvo[0], "espaco": alvo[1]}
	return j
