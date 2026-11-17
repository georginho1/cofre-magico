extends GutTest

var _bib: BibliotecaPalavras
var _dist: DistribuicaoBaralho
var _cfg: ConfigRegras


func before_each() -> void:
	_bib = load("res://dados/biblioteca_palavras.tres") as BibliotecaPalavras
	_dist = load("res://dados/distribuicao_baralho.tres") as DistribuicaoBaralho
	_cfg = ConfigRegras.new()


func _nova(semente: int, n_magos: int = 2) -> Partida:
	var r := RandomNumberGenerator.new()
	r.seed = semente
	return Partida.new(_cfg, _bib, _dist, n_magos, r)


func _somar_mao(p: Partida) -> int:
	var s := 0
	for j in p.jogadores:
		s += j.mao.size()
	return s


## Acha uma silaba em circulacao que NAO e a do espaco (0,0) para provocar erro.
func _silaba_errada(p: Partida) -> String:
	var certa: String = p.palavras[0].silaba(0)
	for s in p.baralho.cartas:
		if s != certa:
			return s
	for j in p.jogadores:
		for s in j.mao:
			if s != certa:
				return s
	return ""


## Poe `silaba` na posicao 0 da mao trocando-a de lugar com uma carta real
## (da propria mao, do baralho ou de outra mao), para manter os totais (WR-08).
func _dar_carta(p: Partida, jogador: int, silaba: String) -> int:
	var mao: Array[String] = p.jogadores[jogador].mao
	var k: int = mao.find(silaba)
	if k != -1:
		mao[k] = mao[0]
		mao[0] = silaba
		return 0
	k = p.baralho.cartas.find(silaba)
	if k != -1:
		p.baralho.cartas[k] = mao[0]
		mao[0] = silaba
		return 0
	for j in p.jogadores:
		if j == p.jogadores[jogador]:
			continue
		k = j.mao.find(silaba)
		if k != -1:
			j.mao[k] = mao[0]
			mao[0] = silaba
			return 0
	fail_test("silaba %s fora de circulacao" % silaba)
	return 0


func _indice_palavra(p: Partida, texto: String) -> int:
	for k in range(p.palavras.size()):
		if p.palavras[k].dados.texto == texto:
			return k
	return -1


## Partida com PIPA e PATO: a silaba PA abre um espaco em cada palavra.
func _nova_pipa_pato(semente: int) -> Partida:
	var bib := BibliotecaPalavras.new()
	bib.palavras.append(_bib.buscar("PIPA"))
	bib.palavras.append(_bib.buscar("PATO"))
	_cfg.quantidade_senhas = 2
	var r := RandomNumberGenerator.new()
	r.seed = semente
	return Partida.new(_cfg, bib, _dist, 2, r)


func test_acerto() -> void:
	var p := _nova(1, 2)
	watch_signals(p)
	var s: String = p.palavras[0].silaba(0)
	_dar_carta(p, 0, s)
	var r := p.jogar_silaba(0, 0, 0)
	assert_eq(r, ResultadoJogada.Tipo.ACERTO)
	assert_eq(p.palavras[0].preenchido_por[0], 0)
	assert_eq(p.jogadores[0].pontos, 1)
	assert_eq(p.jogadores[0].mao.size(), _cfg.tamanho_mao)
	assert_eq(p.jogador_atual, 1)
	assert_eq(p.turnos_jogados, 1)
	assert_signal_emitted(p, "silaba_aceita")
	assert_true(p.invariantes_ok())


func test_acerto_em_qualquer_espaco_com_mesma_silaba() -> void:
	# PA e o espaco 1 de PIPA e o espaco 0 de PATO: os dois aceitam a mesma carta.
	var p := _nova_pipa_pato(2)
	var pipa: int = _indice_palavra(p, "PIPA")
	var pato: int = _indice_palavra(p, "PATO")
	assert_eq(p.palavras[pipa].silaba(1), "PA")
	assert_eq(p.palavras[pato].silaba(0), "PA")
	_dar_carta(p, 0, "PA")
	assert_eq(p.jogar_silaba(0, pipa, 1), ResultadoJogada.Tipo.ACERTO)
	assert_eq(p.palavras[pipa].preenchido_por[1], 0)
	assert_true(p.invariantes_ok())
	var q := _nova_pipa_pato(2)
	_dar_carta(q, 0, "PA")
	assert_eq(q.jogar_silaba(0, _indice_palavra(q, "PATO"), 0), ResultadoJogada.Tipo.ACERTO)
	assert_eq(q.palavras[_indice_palavra(q, "PATO")].preenchido_por[0], 0)
	assert_true(q.invariantes_ok())


func test_erro_devolve_carta_e_passa_a_vez() -> void:
	var p := _nova(3, 2)
	watch_signals(p)
	_dar_carta(p, 0, _silaba_errada(p))
	var antes: Array[String] = p.jogadores[0].mao.duplicate()
	var r := p.jogar_silaba(0, 0, 0)
	assert_eq(r, ResultadoJogada.Tipo.ERRO)
	assert_eq(p.jogadores[0].mao, antes)
	assert_true(p.palavras[0].espaco_aberto(0))
	assert_eq(p.jogadores[0].pontos, 0)
	assert_signal_emitted(p, "jogada_recusada")
	assert_eq(p.jogador_atual, 1)
	assert_true(p.invariantes_ok())


func test_erro_sem_passar_a_vez() -> void:
	_cfg.erro_passa_a_vez = false
	var p := _nova(4, 2)
	_dar_carta(p, 0, _silaba_errada(p))
	assert_eq(p.jogar_silaba(0, 0, 0), ResultadoJogada.Tipo.ERRO)
	assert_eq(p.jogador_atual, 0)
	var s: String = p.palavras[0].silaba(0)
	_dar_carta(p, 0, s)
	assert_eq(p.jogar_silaba(0, 0, 0), ResultadoJogada.Tipo.ACERTO)
	assert_eq(p.jogador_atual, 1)


func test_invalido_nao_altera_estado() -> void:
	var p := _nova(5, 2)
	watch_signals(p)
	var mao: Array[String] = p.jogadores[0].mao.duplicate()
	assert_eq(p.jogar_silaba(-1, 0, 0), ResultadoJogada.Tipo.INVALIDO)
	assert_eq(p.jogar_silaba(99, 0, 0), ResultadoJogada.Tipo.INVALIDO)
	assert_eq(p.jogar_silaba(0, 9, 0), ResultadoJogada.Tipo.INVALIDO)
	assert_eq(p.jogar_silaba(0, 0, 9), ResultadoJogada.Tipo.INVALIDO)
	assert_eq(p.jogar_silaba(0, 0, -1), ResultadoJogada.Tipo.INVALIDO)
	assert_eq(p.jogadores[0].mao, mao)
	assert_eq(p.turnos_jogados, 0)
	assert_eq(p.jogador_atual, 0)
	assert_eq(p.jogadores[0].pontos, 0)
	assert_true(p.palavras[0].espaco_aberto(0))
	# espaco ja preenchido
	_dar_carta(p, 0, p.palavras[0].silaba(0))
	p.jogar_silaba(0, 0, 0)
	p.jogador_atual = 0
	_dar_carta(p, 0, p.palavras[0].silaba(0))
	var turnos: int = p.turnos_jogados
	var mao_antes: Array[String] = p.jogadores[0].mao.duplicate()
	assert_eq(p.jogar_silaba(0, 0, 0), ResultadoJogada.Tipo.INVALIDO)
	assert_eq(p.turnos_jogados, turnos)
	assert_eq(p.jogador_atual, 0)
	assert_eq(p.jogadores[0].mao, mao_antes)
	assert_signal_not_emitted(p, "jogada_recusada")


func test_invalido_com_partida_concluida() -> void:
	var p := _nova(6, 1)
	_concluir_forcado(p)
	assert_true(p.concluida())
	var turnos: int = p.turnos_jogados
	assert_eq(p.jogar_silaba(0, 0, 0), ResultadoJogada.Tipo.INVALIDO)
	assert_eq(p.trocar_mao(), ResultadoJogada.Tipo.INVALIDO)
	assert_eq(p.turnos_jogados, turnos)


func _concluir_forcado(p: Partida) -> void:
	for w in p.palavras:
		for k in range(w.total_espacos()):
			w.preencher(k, 0)


func test_duas_silabas_por_turno() -> void:
	_cfg.silabas_por_turno = 2
	var p := _nova(7, 2)
	_dar_carta(p, 0, p.palavras[0].silaba(0))
	assert_eq(p.jogar_silaba(0, 0, 0), ResultadoJogada.Tipo.ACERTO)
	assert_eq(p.jogador_atual, 0)
	_dar_carta(p, 0, p.palavras[1].silaba(0))
	assert_eq(p.jogar_silaba(0, 1, 0), ResultadoJogada.Tipo.ACERTO)
	assert_eq(p.jogador_atual, 1)


func test_trocar_mao_inteira() -> void:
	var p := _nova(8, 2)
	watch_signals(p)
	var total: int = p.baralho.tamanho() + _somar_mao(p)
	assert_eq(p.trocar_mao(), ResultadoJogada.Tipo.TROCOU)
	assert_eq(p.baralho.tamanho() + _somar_mao(p), total)
	assert_eq(p.jogadores[0].mao.size(), _cfg.tamanho_mao)
	assert_eq(p.jogador_atual, 1)
	assert_signal_emitted(p, "mao_trocada")
	assert_true(p.invariantes_ok())


func test_trocar_mao_passa_a_vez_mesmo_com_jogada() -> void:
	var p := _nova(9, 2)
	_dar_carta(p, 0, p.palavras[0].silaba(0))
	assert_true(p.existe_jogada())
	assert_eq(p.trocar_mao(), ResultadoJogada.Tipo.TROCOU)
	assert_eq(p.jogador_atual, 1)


func test_trocar_compra_antes_de_devolver() -> void:
	var p := _nova(17, 2)
	var n: int = p.jogadores[0].mao.size()
	assert_true(p.baralho.tamanho() >= n)
	# comprar() tira do fim do baralho: a nova mao sao as ultimas n cartas, em ordem inversa.
	var esperadas: Array[String] = []
	for k in range(n):
		esperadas.append(p.baralho.cartas[p.baralho.tamanho() - 1 - k])
	assert_eq(p.trocar_mao(), ResultadoJogada.Tipo.TROCOU)
	assert_eq(p.jogadores[0].mao, esperadas)
	assert_true(p.invariantes_ok())


func test_trocar_parcial() -> void:
	_cfg.cartas_por_troca = 2
	var p := _nova(10, 2)
	var total: int = p.baralho.tamanho() + _somar_mao(p)
	assert_eq(p.trocar_mao(), ResultadoJogada.Tipo.TROCOU)
	assert_eq(p.jogadores[0].mao.size(), _cfg.tamanho_mao)
	assert_eq(p.baralho.tamanho() + _somar_mao(p), total)
	assert_eq(p.jogador_atual, 1)


func test_baralho_vazio_e_mao_vazia() -> void:
	var p := _nova(11, 2)
	p.baralho.cartas.clear()
	p.jogadores[0].mao.clear()
	p.cartas_total = _somar_mao(p) + p.baralho.tamanho() + p.cartas_colocadas()
	assert_eq(p.trocar_mao(), ResultadoJogada.Tipo.TROCOU)
	assert_eq(p.jogador_atual, 1)
	# baralho vazio: nada a comprar antes; a mao devolvida volta integralmente
	p.baralho.cartas.clear()
	assert_eq(p.trocar_mao(), ResultadoJogada.Tipo.TROCOU)
	assert_eq(p.jogadores[1].mao.size(), _cfg.tamanho_mao)


func test_acerto_com_baralho_vazio_nao_repoe() -> void:
	var p := _nova(12, 2)
	_dar_carta(p, 0, p.palavras[0].silaba(0))
	p.baralho.cartas.clear()
	assert_eq(p.jogar_silaba(0, 0, 0), ResultadoJogada.Tipo.ACERTO)
	assert_eq(p.jogadores[0].mao.size(), _cfg.tamanho_mao - 1)


func test_ordem_circular() -> void:
	var p := _nova(13, 3)
	watch_signals(p)
	var seq: Array = [p.jogador_atual]
	for k in range(3):
		p.trocar_mao()
		seq.append(p.jogador_atual)
	assert_eq(seq, [0, 1, 2, 0])
	assert_signal_emitted_with_parameters(p, "turno_iniciado", [0])
	var q := _nova(14, 1)
	q.trocar_mao()
	assert_eq(q.jogador_atual, 0)


func test_existe_jogada() -> void:
	var p := _nova(15, 2)
	_dar_carta(p, 0, p.palavras[0].silaba(0))
	assert_true(p.existe_jogada())
	for i in range(p.jogadores[0].mao.size()):
		p.jogadores[0].mao[i] = "ZZ"
	assert_false(p.existe_jogada())
	# carta que so casa com espaco ja preenchido nao conta
	var w: PalavraSenha = p.palavras[0]
	var s: String = w.silaba(0)
	for q in p.palavras:
		for k in range(q.total_espacos()):
			if q.silaba(k) == s:
				q.preencher(k, 1)
	p.jogadores[0].mao[0] = s
	assert_false(p.existe_jogada())


func test_conclusao_abre_cofre_sem_passar_a_vez() -> void:
	var p := _nova(16, 2)
	watch_signals(p)
	# Preenche tudo menos o ultimo espaco
	var ultimo: PalavraSenha = p.palavras[3]
	var k_ult: int = ultimo.total_espacos() - 1
	for w in p.palavras:
		for k in range(w.total_espacos()):
			if not (w == ultimo and k == k_ult):
				w.preencher(k, 1)
	_dar_carta(p, 0, ultimo.silaba(k_ult))
	assert_eq(p.jogar_silaba(0, 3, k_ult), ResultadoJogada.Tipo.ACERTO)
	assert_true(p.concluida())
	assert_signal_emit_count(p, "cofre_aberto", 1)
	assert_eq(p.jogador_atual, 0)


func test_partidas_completas_com_bot() -> void:
	var concluidas := 0
	for n in range(1, 5):
		for semente in range(1, 101):
			var p := _nova(semente * 7 + n, n)
			var acoes := 0
			while not p.concluida() and acoes < _cfg.limite_turnos_partida:
				_bot_agir(p)
				acoes += 1
				if not p.invariantes_ok():
					break
			assert_true(p.invariantes_ok(), "invariantes n=%d semente=%d" % [n, semente])
			if p.concluida():
				concluidas += 1
			else:
				fail_test("nao concluiu n=%d semente=%d" % [n, semente])
	gut.p("partidas concluidas: %d" % concluidas)
	assert_eq(concluidas, 400)


func _bot_agir(p: Partida) -> void:
	var mao: Array[String] = p.jogadores[p.jogador_atual].mao
	for i in range(mao.size()):
		for pi in range(p.palavras.size()):
			for e in range(p.palavras[pi].total_espacos()):
				if p.palavras[pi].espaco_aberto(e) and p.palavras[pi].silaba(e) == mao[i]:
					p.jogar_silaba(i, pi, e)
					return
	p.trocar_mao()
