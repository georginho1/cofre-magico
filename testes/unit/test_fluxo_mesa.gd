extends GutTest


func test_acerto_concluida_vai_ao_cofre() -> void:
	assert_eq(FluxoMesa.proxima_etapa(ResultadoJogada.Tipo.ACERTO, true), FluxoMesa.Etapa.COFRE)


func test_acerto_nao_concluida_vai_a_faixa() -> void:
	assert_eq(FluxoMesa.proxima_etapa(ResultadoJogada.Tipo.ACERTO, false), FluxoMesa.Etapa.FAIXA_VEZ)


func test_erro_vai_a_faixa() -> void:
	assert_eq(FluxoMesa.proxima_etapa(ResultadoJogada.Tipo.ERRO, false), FluxoMesa.Etapa.FAIXA_VEZ)


func test_troca_vai_a_faixa() -> void:
	assert_eq(FluxoMesa.proxima_etapa(ResultadoJogada.Tipo.TROCOU, false), FluxoMesa.Etapa.FAIXA_VEZ)


func test_invalido_nao_faz_nada() -> void:
	assert_eq(FluxoMesa.proxima_etapa(ResultadoJogada.Tipo.INVALIDO, false), FluxoMesa.Etapa.NADA)
