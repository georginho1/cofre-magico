extends GutTest

var _regras: ConfigRegras


func before_each() -> void:
	_regras = load("res://dados/regras_padrao.tres") as ConfigRegras


func test_valores_iniciais_do_arquivo() -> void:
	assert_not_null(_regras)
	assert_eq(_regras.tamanho_mao, 5, "D-01")
	assert_eq(_regras.silabas_por_turno, 1, "D-02")
	assert_eq(_regras.cartas_por_troca, 0, "D-03")
	assert_true(_regras.erro_passa_a_vez, "D-04")
	assert_true(_regras.repor_mao_apos_acerto, "D-05")
	assert_eq(_regras.proporcao_distratoras, 0.4, "D-09, D-22 (decisao exigir-2-a-4)")
	assert_eq(_regras.quantidade_senhas, 4, "D-15")


func test_normalizar_limita_faixas() -> void:
	var c := ConfigRegras.new()
	c.tamanho_mao = 99
	c.quantidade_senhas = 0
	c.taxa_erro_aprendiz = -1.0
	c.proporcao_distratoras = 9.0
	c.normalizar()
	assert_eq(c.tamanho_mao, 10)
	assert_eq(c.quantidade_senhas, 1)
	assert_eq(c.taxa_erro_aprendiz, 0.0)
	assert_eq(c.proporcao_distratoras, 5.0)


func test_normalizar_limita_troca_ao_tamanho_da_mao() -> void:
	var c := ConfigRegras.new()
	c.tamanho_mao = 3
	c.cartas_por_troca = 8
	c.normalizar()
	assert_eq(c.cartas_por_troca, 3)
