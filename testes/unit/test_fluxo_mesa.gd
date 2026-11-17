extends GutTest


func test_acerto_concluida_vai_ao_cofre() -> void:
	assert_eq(FluxoMesa.proxima_etapa(ResultadoJogada.Tipo.ACERTO, true, true), FluxoMesa.Etapa.COFRE)


func test_acerto_nao_concluida_vai_a_faixa() -> void:
	assert_eq(FluxoMesa.proxima_etapa(ResultadoJogada.Tipo.ACERTO, false, true), FluxoMesa.Etapa.FAIXA_VEZ)


func test_erro_vai_a_faixa() -> void:
	assert_eq(FluxoMesa.proxima_etapa(ResultadoJogada.Tipo.ERRO, false, true), FluxoMesa.Etapa.FAIXA_VEZ)


func test_troca_vai_a_faixa() -> void:
	assert_eq(FluxoMesa.proxima_etapa(ResultadoJogada.Tipo.TROCOU, false, true), FluxoMesa.Etapa.FAIXA_VEZ)


func test_invalido_nao_faz_nada() -> void:
	assert_eq(FluxoMesa.proxima_etapa(ResultadoJogada.Tipo.INVALIDO, false, false), FluxoMesa.Etapa.NADA)


func test_acerto_sem_passar_a_vez_nao_faz_nada() -> void:
	assert_eq(FluxoMesa.proxima_etapa(ResultadoJogada.Tipo.ACERTO, false, false), FluxoMesa.Etapa.NADA)


func test_erro_sem_passar_a_vez_nao_faz_nada() -> void:
	assert_eq(FluxoMesa.proxima_etapa(ResultadoJogada.Tipo.ERRO, false, false), FluxoMesa.Etapa.NADA)


func test_acerto_concluida_vai_ao_cofre_mesmo_sem_passar_a_vez() -> void:
	assert_eq(FluxoMesa.proxima_etapa(ResultadoJogada.Tipo.ACERTO, true, false), FluxoMesa.Etapa.COFRE)
