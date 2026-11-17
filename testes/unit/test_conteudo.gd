extends GutTest

var _bib: BibliotecaPalavras
var _dist: DistribuicaoBaralho


func before_each() -> void:
	_bib = load("res://dados/biblioteca_palavras.tres") as BibliotecaPalavras
	_dist = load("res://dados/distribuicao_baralho.tres") as DistribuicaoBaralho


func test_distribuicao_100_cartas_22_silabas() -> void:
	assert_not_null(_dist)
	assert_eq(_dist.total(), 100)
	assert_eq(_dist.copias.size(), 22)
	assert_eq(_dist.copias_de("CA"), 8)
	assert_eq(_dist.copias_de("TU"), 2)
	assert_eq(_dist.copias_de("XX"), 0)


func test_biblioteca_30_palavras_distintas() -> void:
	assert_not_null(_bib)
	assert_eq(_bib.palavras.size(), 30)
	var vistos: Dictionary = {}
	for p in _bib.palavras:
		vistos[p.texto] = true
	assert_eq(vistos.size(), 30)


func test_28_com_duas_silabas_e_2_com_tres() -> void:
	var duas := 0
	var tres := 0
	for p in _bib.palavras:
		if p.silabas.size() == 2:
			duas += 1
		elif p.silabas.size() == 3:
			tres += 1
	assert_eq(duas, 28)
	assert_eq(tres, 2)
	assert_eq(_bib.buscar("TAPETE").silabas.size(), 3)
	assert_eq(_bib.buscar("TOMATE").silabas.size(), 3)


func test_texto_e_juncao_das_silabas_cv() -> void:
	for p in _bib.palavras:
		assert_eq("".join(p.silabas), p.texto, p.texto)
		for s in p.silabas:
			assert_eq(s.length(), 2, "%s: silaba %s" % [p.texto, s])


func test_toda_silaba_existe_na_distribuicao() -> void:
	for s in _bib.silabas_distintas():
		assert_gt(_dist.copias_de(s), 0, "silaba %s" % s)


func test_toda_palavra_tem_imagem() -> void:
	for p in _bib.palavras:
		assert_not_null(p.imagem, p.texto)


func test_buscar() -> void:
	var casa := _bib.buscar("CASA")
	assert_not_null(casa)
	assert_eq(casa.silabas, PackedStringArray(["CA", "SA"]))
	assert_null(_bib.buscar("XXXX"))


func test_nenhuma_combinacao_de_4_palavras_e_impossivel() -> void:
	var n := _bib.palavras.size()
	var combos := 0
	var violacoes: Array[String] = []
	for a in range(n):
		for b in range(a + 1, n):
			for c in range(b + 1, n):
				for d in range(c + 1, n):
					combos += 1
					var demanda: Dictionary = {}
					for i in [a, b, c, d]:
						for s in _bib.palavras[i].silabas:
							demanda[s] = demanda.get(s, 0) + 1
					for s in demanda:
						if demanda[s] > _dist.copias_de(s):
							violacoes.append("%s %s %s %s (%s)" % [_bib.palavras[a].texto, _bib.palavras[b].texto, _bib.palavras[c].texto, _bib.palavras[d].texto, s])
	gut.p("combinacoes verificadas: %d" % combos)
	assert_eq(combos, 27405)
	assert_eq(violacoes.size(), 0, "violacoes: %s" % str(violacoes.slice(0, 5)))
