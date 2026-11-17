class_name Simulacao
extends RefCounted
## Motor do simulador: roda N partidas com bots usando a API publica da Partida.


static func rodar(
	cfg: ConfigRegras,
	bib: BibliotecaPalavras,
	dist: DistribuicaoBaralho,
	n_magos: int,
	perfil: Perfil,
	n_partidas: int,
	semente: int
) -> Dictionary:
	cfg.normalizar()
	var limite: int = cfg.limite_turnos_partida
	var terminadas: int = 0
	var turnos_por_partida: Array = []
	var total_turnos: int = 0
	var sem_ponto: int = 0
	var por_troca: int = 0
	var por_erro: int = 0
	var zerados: int = 0
	var soma_pontos: int = 0
	var soma_turnos_mago: float = 0.0
	# texto -> {aparicoes, soma_turnos, completadas, ultima}
	var palavras: Dictionary = {}

	for i in range(n_partidas):
		var rng := RandomNumberGenerator.new()
		rng.seed = hash([semente, i, n_magos])
		var partida := Partida.new(cfg, bib, dist, n_magos, rng)
		for w in partida.palavras:
			var reg: Dictionary = palavras.get(w.dados.texto, {"aparicoes": 0, "soma_turnos": 0, "completadas": 0, "ultima": 0})
			reg["aparicoes"] += 1
			palavras[w.dados.texto] = reg
		var completa_antes: Array = []
		for w in partida.palavras:
			completa_antes.append(false)

		var acoes: int = 0
		var turnos: int = 0
		var sp: int = 0
		var tr: int = 0
		var er: int = 0
		var estourou: bool = false
		while not partida.concluida():
			var t0: int = partida.turnos_jogados
			var teve_acerto: bool = false
			var ultima: ResultadoJogada.Tipo = ResultadoJogada.Tipo.INVALIDO
			while partida.turnos_jogados == t0 and not partida.concluida():
				if acoes >= limite:
					estourou = true
					break
				var d: Dictionary = perfil.decidir(partida, rng)
				if d["acao"] == "jogar":
					ultima = partida.jogar_silaba(d["carta"], d["palavra"], d["espaco"])
				else:
					ultima = partida.trocar_mao()
				acoes += 1
				if ultima == ResultadoJogada.Tipo.ACERTO:
					teve_acerto = true
					for k in range(partida.palavras.size()):
						if not completa_antes[k] and partida.palavras[k].completa():
							completa_antes[k] = true
							var reg2: Dictionary = palavras[partida.palavras[k].dados.texto]
							reg2["soma_turnos"] += turnos + 1
							reg2["completadas"] += 1
							if partida.concluida():
								reg2["ultima"] += 1
				elif ultima == ResultadoJogada.Tipo.INVALIDO:
					estourou = true
					break
			if estourou:
				break
			turnos += 1
			if teve_acerto or partida.concluida():
				pass
			elif ultima == ResultadoJogada.Tipo.TROCOU:
				sp += 1
				tr += 1
			else:
				sp += 1
				er += 1

		if estourou:
			continue
		terminadas += 1
		turnos_por_partida.append(turnos)
		total_turnos += turnos
		sem_ponto += sp
		por_troca += tr
		por_erro += er
		soma_turnos_mago += float(turnos) / float(partida.jogadores.size())
		var zerado: bool = false
		for j in partida.jogadores:
			soma_pontos += j.pontos
			if j.pontos == 0:
				zerado = true
		if zerado:
			zerados += 1

	turnos_por_partida.sort()
	var por_palavra: Dictionary = {}
	for t in palavras:
		var reg3: Dictionary = palavras[t]
		var media_c: float = 0.0
		if reg3["completadas"] > 0:
			media_c = float(reg3["soma_turnos"]) / float(reg3["completadas"])
		por_palavra[t] = {
			"aparicoes": reg3["aparicoes"],
			"turnos_ate_completar_media": media_c,
			"vezes_ultima": reg3["ultima"],
		}

	var tt: float = maxf(float(total_turnos), 1.0)
	var term: float = maxf(float(terminadas), 1.0)
	return {
		"n_magos": n_magos,
		"perfil": perfil.nome,
		"partidas": n_partidas,
		"terminadas": terminadas,
		"pct_terminadas": float(terminadas) / maxf(float(n_partidas), 1.0),
		"turnos_partida": {
			"media": float(total_turnos) / term,
			"mediana": _percentil(turnos_por_partida, 0.5),
			"p95": _percentil(turnos_por_partida, 0.95),
		},
		"turnos_por_mago_media": soma_turnos_mago / term,
		"pct_turnos_sem_ponto": float(sem_ponto) / tt,
		"pct_turnos_troca": float(por_troca) / tt,
		"pct_turnos_erro": float(por_erro) / tt,
		"pct_partidas_mago_zerado": float(zerados) / term,
		"pontos_medios_por_mago": float(soma_pontos) / (term * float(n_magos)),
		"por_palavra": por_palavra,
	}


static func _percentil(ordenado: Array, p: float) -> float:
	if ordenado.is_empty():
		return 0.0
	var idx: int = clampi(int(ceil(p * ordenado.size())) - 1, 0, ordenado.size() - 1)
	if p == 0.5:
		var n: int = ordenado.size()
		if n % 2 == 0:
			return (float(ordenado[n / 2 - 1]) + float(ordenado[n / 2])) / 2.0
	return float(ordenado[idx])
