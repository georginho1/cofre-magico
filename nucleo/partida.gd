class_name Partida
extends RefCounted
## Estado de uma partida. Sem Node; RNG injetado.

var cfg: ConfigRegras
var rng: RandomNumberGenerator
var palavras: Array[PalavraSenha] = []
var jogadores: Array[Jogador] = []
var baralho: Baralho
var jogador_atual: int = 0
var turnos_jogados: int = 0
var jogadas_no_turno: int = 0
var cartas_total: int = 0

signal silaba_aceita(jogador: int, palavra: int, espaco: int, silaba: String)
signal jogada_recusada(jogador: int)
signal mao_trocada(jogador: int)
signal turno_iniciado(jogador: int)
signal cofre_aberto()


func _init(
	p_cfg: ConfigRegras,
	bib: BibliotecaPalavras,
	dist: DistribuicaoBaralho,
	n_magos: int,
	p_rng: RandomNumberGenerator
) -> void:
	cfg = p_cfg
	cfg.normalizar()
	rng = p_rng
	var n: int = clampi(n_magos, 1, 4)

	var indices: Array = []
	for k in range(bib.palavras.size()):
		indices.append(k)
	Baralho.misturar(indices, rng)
	var sorteadas: Array[DadosPalavra] = []
	for k in range(mini(cfg.quantidade_senhas, indices.size())):
		var d: DadosPalavra = bib.palavras[indices[k]]
		sorteadas.append(d)
		palavras.append(PalavraSenha.new(d))

	baralho = Baralho.montar(sorteadas, dist, cfg, rng)
	for i in range(n):
		var j := Jogador.new(i)
		j.mao = baralho.comprar(cfg.tamanho_mao)
		jogadores.append(j)

	var soma: int = 0
	for j in jogadores:
		soma += j.mao.size()
	cartas_total = baralho.tamanho() + soma


func concluida() -> bool:
	for w in palavras:
		if not w.completa():
			return false
	return true


func cartas_colocadas() -> int:
	var c: int = 0
	for w in palavras:
		for v in w.preenchido_por:
			if v != -1:
				c += 1
	return c


func existe_jogada() -> bool:
	if concluida():
		return false
	for carta in jogadores[jogador_atual].mao:
		for w in palavras:
			for e in range(w.total_espacos()):
				if w.espaco_aberto(e) and w.silaba(e) == carta:
					return true
	return false


func invariantes_ok() -> bool:
	if baralho.tamanho() + _soma_maos() + cartas_colocadas() != cartas_total:
		return false
	var circulacao: Dictionary = baralho.contagem()
	for j in jogadores:
		for c in j.mao:
			circulacao[c] = circulacao.get(c, 0) + 1
	var exigidas: Dictionary = {}
	for w in palavras:
		for e in range(w.total_espacos()):
			if w.espaco_aberto(e):
				exigidas[w.silaba(e)] = exigidas.get(w.silaba(e), 0) + 1
	for s in exigidas:
		if circulacao.get(s, 0) < exigidas[s]:
			return false
	return true


func jogar_silaba(indice_carta: int, palavra: int, espaco: int) -> ResultadoJogada.Tipo:
	if concluida():
		return ResultadoJogada.Tipo.INVALIDO
	var jog: Jogador = jogadores[jogador_atual]
	if indice_carta < 0 or indice_carta >= jog.mao.size():
		return ResultadoJogada.Tipo.INVALIDO
	if palavra < 0 or palavra >= palavras.size():
		return ResultadoJogada.Tipo.INVALIDO
	var w: PalavraSenha = palavras[palavra]
	if espaco < 0 or espaco >= w.total_espacos() or not w.espaco_aberto(espaco):
		return ResultadoJogada.Tipo.INVALIDO

	var carta: String = jog.mao[indice_carta]
	if carta == w.silaba(espaco):
		jog.mao.remove_at(indice_carta)
		w.preencher(espaco, jogador_atual)
		jog.pontos += 1
		jogadas_no_turno += 1
		silaba_aceita.emit(jogador_atual, palavra, espaco, carta)
		if cfg.repor_mao_apos_acerto:
			_repor(jog)
		if concluida():
			cofre_aberto.emit()
		elif jogadas_no_turno >= cfg.silabas_por_turno:
			_passar_a_vez()
		return ResultadoJogada.Tipo.ACERTO

	jogada_recusada.emit(jogador_atual)
	if cfg.erro_passa_a_vez:
		_passar_a_vez()
	return ResultadoJogada.Tipo.ERRO


func trocar_mao() -> ResultadoJogada.Tipo:
	if concluida():
		return ResultadoJogada.Tipo.INVALIDO
	var jog: Jogador = jogadores[jogador_atual]
	var devolvidas: Array[String] = []
	if cfg.cartas_por_troca == 0 or cfg.cartas_por_troca >= jog.mao.size():
		devolvidas.append_array(jog.mao)
		jog.mao.clear()
	else:
		var idx: Array = []
		for k in range(jog.mao.size()):
			idx.append(k)
		Baralho.misturar(idx, rng)
		var escolhidos: Array = idx.slice(0, cfg.cartas_por_troca)
		escolhidos.sort()
		escolhidos.reverse()
		for k in escolhidos:
			devolvidas.append(jog.mao[k])
			jog.mao.remove_at(k)
	baralho.devolver(devolvidas)
	baralho.embaralhar(rng)
	_repor(jog)
	mao_trocada.emit(jogador_atual)
	_passar_a_vez()
	return ResultadoJogada.Tipo.TROCOU


func _repor(jog: Jogador) -> void:
	var falta: int = cfg.tamanho_mao - jog.mao.size()
	if falta > 0:
		jog.mao.append_array(baralho.comprar(falta))


func _soma_maos() -> int:
	var s: int = 0
	for j in jogadores:
		s += j.mao.size()
	return s


func _passar_a_vez() -> void:
	jogador_atual = (jogador_atual + 1) % jogadores.size()
	jogadas_no_turno = 0
	turnos_jogados += 1
	turno_iniciado.emit(jogador_atual)
