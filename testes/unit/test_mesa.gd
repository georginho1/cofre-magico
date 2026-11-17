extends GutTest

const CAMINHO_LINHA := "Margem/Coluna/CentroSenhas/LinhaSenhas"
const CAMINHO_MAO := "Margem/Coluna/FaixaMao/Mao"


func _criar_mesa() -> Control:
	var ids: Array[int] = [0]
	Sessao.ativar_magos(ids)
	Sessao.nova_partida()
	var mesa: Control = load("res://cenas/mesa/mesa.tscn").instantiate() as Control
	add_child_autofree(mesa)
	await wait_frames(2)
	return mesa


func _abrir_mao(mesa: Control) -> void:
	(mesa.get_node("FaixaVez") as Button).pressed.emit()
	await wait_frames(2)


func test_mesa_inicia_com_quatro_senhas_e_faixa() -> void:
	var mesa: Control = await _criar_mesa()
	assert_eq(mesa.get_node(CAMINHO_LINHA).get_child_count(), 4)
	assert_true(mesa.get_node("FaixaVez").visible)
	assert_eq(mesa.get_node(CAMINHO_MAO).get_child_count(), 0)


func test_faixa_tocada_mostra_mao() -> void:
	var mesa: Control = await _criar_mesa()
	await _abrir_mao(mesa)
	assert_false(mesa.get_node("FaixaVez").visible)
	assert_eq(mesa.get_node(CAMINHO_MAO).get_child_count(), Sessao.partida.cfg.tamanho_mao)


func test_acerto_preenche_espaco_e_pontua() -> void:
	var mesa: Control = await _criar_mesa()
	var p: Partida = Sessao.partida
	p.jogadores[0].mao[0] = p.palavras[0].silaba(0)
	await _abrir_mao(mesa)
	var carta: Button = mesa.get_node(CAMINHO_MAO).get_child(0).get_child(0) as Button
	carta.pressed.emit()
	var senha: SenhaVisual = mesa.get_node(CAMINHO_LINHA).get_child(0) as SenhaVisual
	senha.espaco_tocado.emit(0)
	await wait_seconds(0.8)
	assert_eq(p.palavras[0].preenchido_por[0], 0)
	assert_eq(p.jogadores[0].pontos, 1)


func test_erro_nao_preenche_e_volta_a_faixa() -> void:
	var mesa: Control = await _criar_mesa()
	var p: Partida = Sessao.partida
	p.jogadores[0].mao[0] = "ZZ"
	await _abrir_mao(mesa)
	var carta: Button = mesa.get_node(CAMINHO_MAO).get_child(0).get_child(0) as Button
	carta.pressed.emit()
	var senha: SenhaVisual = mesa.get_node(CAMINHO_LINHA).get_child(0) as SenhaVisual
	senha.espaco_tocado.emit(0)
	await wait_seconds(0.8)
	assert_eq(p.palavras[0].preenchido_por[0], -1)
	assert_true(mesa.get_node("FaixaVez").visible)


func test_toque_no_espaco_sem_selecao_nao_altera_nucleo() -> void:
	var mesa: Control = await _criar_mesa()
	var p: Partida = Sessao.partida
	await _abrir_mao(mesa)
	var senha: SenhaVisual = mesa.get_node(CAMINHO_LINHA).get_child(0) as SenhaVisual
	senha.espaco_tocado.emit(0)
	await wait_seconds(0.5)
	assert_eq(p.palavras[0].preenchido_por[0], -1)
	assert_eq(p.jogadores[0].pontos, 0)
	assert_false(mesa.get_node("FaixaVez").visible)


func test_pontos_mostra_icone_do_mago_da_vez_apos_acerto() -> void:
	var mesa: Control = await _criar_mesa()
	var p: Partida = Sessao.partida
	p.jogadores[0].mao[0] = p.palavras[0].silaba(0)
	await _abrir_mao(mesa)
	var carta: Button = mesa.get_node(CAMINHO_MAO).get_child(0).get_child(0) as Button
	carta.pressed.emit()
	(mesa.get_node(CAMINHO_LINHA).get_child(0) as SenhaVisual).espaco_tocado.emit(0)
	await wait_seconds(0.8)
	var faixa: Button = mesa.get_node("FaixaVez") as Button
	if faixa.visible:
		faixa.pressed.emit()
		await wait_frames(2)
	var pontos: IconesPonto = mesa.get_node("Margem/Coluna/Barra/Indicador/Caixa/Pontos") as IconesPonto
	assert_eq(pontos.qtd, 1)


func test_pulso_do_botao_trocar_so_sem_jogada() -> void:
	var mesa: Control = await _criar_mesa()
	var p: Partida = Sessao.partida
	var mao: Array[String] = p.jogadores[0].mao
	for i in range(mao.size()):
		mao[i] = "ZZ"
	assert_false(p.existe_jogada())
	await _abrir_mao(mesa)
	var botao: Button = mesa.get_node("Margem/Coluna/FaixaMao/BotaoTrocar") as Button
	assert_eq(botao.theme_type_variation, &"BotaoPrimario")
	assert_false(botao.disabled)
	p.jogadores[0].mao[0] = p.palavras[0].silaba(0)
	assert_true(p.existe_jogada())
	mesa.call("_ao_faixa_tocada")
	await wait_frames(2)
	assert_eq(botao.theme_type_variation, &"BotaoSecundario")


func test_voltar_abre_e_fecha_pausa_e_confirmacao_volta() -> void:
	var mesa: Control = await _criar_mesa()
	var painel: PainelPausa = mesa.get_node("PainelPausa") as PainelPausa
	assert_false(painel.esta_aberto())
	mesa.call("ao_voltar")
	assert_true(painel.esta_aberto())
	mesa.call("ao_voltar")
	assert_false(painel.esta_aberto())
	mesa.call("ao_voltar")
	(painel.get_node("Centro/Painel/Conteudo/EstadoPausa/Sair") as Button).pressed.emit()
	assert_true(painel.get_node("Centro/Painel/Conteudo/EstadoConfirmar").visible)
	mesa.call("ao_voltar")
	assert_false(painel.esta_aberto())
	assert_not_null(Sessao.partida)


func test_sair_emite_sinal_do_painel() -> void:
	var mesa: Control = await _criar_mesa()
	var painel: PainelPausa = mesa.get_node("PainelPausa") as PainelPausa
	painel.sair.disconnect(mesa.get("_ao_sair"))
	watch_signals(painel)
	painel.abrir()
	(painel.get_node("Centro/Painel/Conteudo/EstadoPausa/Sair") as Button).pressed.emit()
	(painel.get_node("Centro/Painel/Conteudo/EstadoConfirmar/Sair") as Button).pressed.emit()
	assert_signal_emitted(painel, "sair")
