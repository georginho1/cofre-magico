extends GutTest

var _bib: BibliotecaPalavras
var _dist: DistribuicaoBaralho
var _cfg: ConfigRegras


func before_each() -> void:
	_bib = load("res://dados/biblioteca_palavras.tres") as BibliotecaPalavras
	_dist = load("res://dados/distribuicao_baralho.tres") as DistribuicaoBaralho
	_cfg = ConfigRegras.new()


func _rng(semente: int) -> RandomNumberGenerator:
	var r := RandomNumberGenerator.new()
	r.seed = semente
	return r


func _palavras() -> Array[DadosPalavra]:
	var lista: Array[DadosPalavra] = []
	for t in ["CASA", "CAMA", "BOLA", "TOMATE"]:
		lista.append(_bib.buscar(t))
	return lista


func _uteis() -> Array:
	return ["CA", "SA", "MA", "BO", "LA", "TO", "TE"]


func test_misturar_reproduzivel() -> void:
	var a: Array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
	var b: Array = a.duplicate()
	var c: Array = a.duplicate()
	Baralho.misturar(a, _rng(5))
	Baralho.misturar(b, _rng(5))
	Baralho.misturar(c, _rng(6))
	assert_eq(a, b)
	assert_ne(a, c)
	var ordenada := a.duplicate()
	ordenada.sort()
	assert_eq(ordenada, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10])


func test_montar_proporcao_1() -> void:
	var bar := Baralho.montar(_palavras(), _dist, _cfg, _rng(1))
	assert_eq(bar.tamanho(), 90)
	var cont := bar.contagem()
	var uteis := 0
	for s in _uteis():
		assert_eq(cont.get(s, 0), _dist.copias_de(s), "todas as copias de " + s)
		uteis += cont.get(s, 0)
	assert_eq(uteis, 45)


func test_distratoras_sem_silaba_util_e_dentro_das_copias() -> void:
	var bar := Baralho.montar(_palavras(), _dist, _cfg, _rng(2))
	var cont := bar.contagem()
	for s in cont:
		assert_true(cont[s] <= _dist.copias_de(s))


func test_proporcao_zero_e_meia() -> void:
	_cfg.proporcao_distratoras = 0.0
	assert_eq(Baralho.montar(_palavras(), _dist, _cfg, _rng(1)).tamanho(), 45)
	_cfg.proporcao_distratoras = 0.5
	assert_eq(Baralho.montar(_palavras(), _dist, _cfg, _rng(1)).tamanho(), 45 + 23)


func test_pool_limita_distratoras() -> void:
	_cfg.proporcao_distratoras = 5.0
	var bar := Baralho.montar(_palavras(), _dist, _cfg, _rng(1))
	assert_eq(bar.tamanho(), 100)


func test_teto_so_corta_distratoras() -> void:
	_cfg.tamanho_baralho_partida = 50
	assert_eq(Baralho.montar(_palavras(), _dist, _cfg, _rng(1)).tamanho(), 50)
	_cfg.tamanho_baralho_partida = 30
	var bar := Baralho.montar(_palavras(), _dist, _cfg, _rng(1))
	assert_eq(bar.tamanho(), 45)


func test_comprar_alem_do_baralho() -> void:
	var bar := Baralho.montar(_palavras(), _dist, _cfg, _rng(1))
	var tirou := bar.comprar(1000)
	assert_eq(tirou.size(), 90)
	assert_eq(bar.tamanho(), 0)


func test_devolver_e_embaralhar_mantem_contagem() -> void:
	var bar := Baralho.montar(_palavras(), _dist, _cfg, _rng(1))
	var antes := bar.contagem()
	var mao := bar.comprar(5)
	assert_eq(bar.tamanho(), 85)
	bar.devolver(mao)
	bar.embaralhar(_rng(3))
	assert_eq(bar.tamanho(), 90)
	assert_eq(bar.contagem(), antes)
