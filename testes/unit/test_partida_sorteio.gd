extends GutTest

var _bib: BibliotecaPalavras
var _dist: DistribuicaoBaralho
var _cfg: ConfigRegras


func before_each() -> void:
	_bib = load("res://dados/biblioteca_palavras.tres") as BibliotecaPalavras
	_dist = load("res://dados/distribuicao_baralho.tres") as DistribuicaoBaralho
	_cfg = ConfigRegras.new()


func _nova(semente: int, n_magos: int = 4) -> Partida:
	var r := RandomNumberGenerator.new()
	r.seed = semente
	return Partida.new(_cfg, _bib, _dist, n_magos, r)


func _textos(p: Partida) -> Array:
	var t: Array = []
	for w in p.palavras:
		t.append(w.dados.texto)
	return t


func _maos(p: Partida) -> Array:
	var m: Array = []
	for j in p.jogadores:
		m.append(j.mao.duplicate())
	return m


func test_quatro_palavras_distintas_da_biblioteca() -> void:
	for n in range(1, 5):
		var p := _nova(11, n)
		assert_eq(p.palavras.size(), 4)
		var vistos: Dictionary = {}
		for t in _textos(p):
			vistos[t] = true
			assert_not_null(_bib.buscar(t))
		assert_eq(vistos.size(), 4)
		assert_eq(p.jogadores.size(), n)


func test_mesma_semente_mesmo_resultado() -> void:
	var a := _nova(42)
	var b := _nova(42)
	var c := _nova(43)
	assert_eq(_textos(a), _textos(b))
	assert_eq(a.baralho.cartas, b.baralho.cartas)
	assert_eq(_maos(a), _maos(b))
	assert_true(_textos(a) != _textos(c) or _maos(a) != _maos(c))


func test_maos_e_cartas_totais_constantes() -> void:
	var p := _nova(7)
	var soma := 0
	for j in p.jogadores:
		assert_eq(j.mao.size(), _cfg.tamanho_mao)
		soma += j.mao.size()
	assert_eq(p.cartas_total, p.baralho.tamanho() + soma)


func test_alavancas_do_config() -> void:
	_cfg.quantidade_senhas = 3
	_cfg.tamanho_mao = 3
	var p := _nova(5)
	assert_eq(p.palavras.size(), 3)
	for j in p.jogadores:
		assert_eq(j.mao.size(), 3)


func test_sem_restricao_de_pares_ou_tres_silabas() -> void:
	var pato_pata := false
	var tres := false
	for s in range(1, 3001):
		var t := _textos(_nova(s))
		if t.has("PATO") and t.has("PATA"):
			pato_pata = true
		if t.has("TAPETE") or t.has("TOMATE"):
			tres = true
		if pato_pata and tres:
			break
	assert_true(pato_pata)
	assert_true(tres)


func test_baralho_minusculo_nao_perde_cartas() -> void:
	_cfg.tamanho_mao = 10
	_cfg.proporcao_distratoras = 0.0
	var p := _nova(9)
	var soma := 0
	for j in p.jogadores:
		soma += j.mao.size()
	assert_eq(soma + p.baralho.tamanho(), p.cartas_total)
	assert_true(p.jogadores[3].mao.size() <= 10)
	assert_true(p.cartas_total < 40 or p.jogadores[3].mao.size() == 10 or p.baralho.tamanho() == 0)


func test_n_magos_limitado() -> void:
	assert_eq(_nova(1, 9).jogadores.size(), 4)
	assert_eq(_nova(1, 0).jogadores.size(), 1)


func test_normaliza_config() -> void:
	_cfg.tamanho_mao = 99
	var p := _nova(1)
	assert_eq(p.cfg.tamanho_mao, 10)
	assert_eq(p.jogadores[0].mao.size(), 10)
	# WR-07: a config do chamador nao e alterada.
	assert_eq(_cfg.tamanho_mao, 99)
	assert_ne(p.cfg, _cfg)


func test_palavra_senha() -> void:
	var w := PalavraSenha.new(_bib.buscar("TAPETE"))
	assert_eq(w.total_espacos(), 3)
	assert_eq(w.silaba(1), "PE")
	assert_true(w.espaco_aberto(0))
	assert_false(w.completa())
	w.preencher(0, 2)
	assert_false(w.espaco_aberto(0))
	assert_eq(w.preenchido_por[0], 2)
	w.preencher(1, 0)
	w.preencher(2, 1)
	assert_true(w.completa())
