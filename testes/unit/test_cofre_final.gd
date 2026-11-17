extends GutTest

const CAM_SENHAS := "Margem/Coluna/Senhas"
const CAM_MAGOS := "Margem/Coluna/Magos"


## Completa a partida so pela API do nucleo. Se `so_indice_zero`, forca a vez no jogador 0.
func _completar_partida(so_indice_zero: bool = false) -> void:
	var ids: Array[int] = [0, 2]
	Sessao.ativar_magos(ids)
	Sessao.nova_partida()
	var p: Partida = Sessao.partida
	var guarda: int = 0
	while not p.concluida() and guarda < 200:
		guarda += 1
		if so_indice_zero:
			p.jogador_atual = 0
		var achou: bool = false
		for pi in range(p.palavras.size()):
			for e in range(p.palavras[pi].total_espacos()):
				if not achou and p.palavras[pi].espaco_aberto(e):
					p.jogadores[p.jogador_atual].mao[0] = p.palavras[pi].silaba(e)
					p.jogar_silaba(0, pi, e)
					achou = true
		if not achou:
			break


func _final() -> Control:
	var f: Control = load("res://cenas/final/final.tscn").instantiate() as Control
	add_child_autofree(f)
	await wait_frames(2)
	return f


func test_final_mostra_quatro_senhas_e_magos_em_ordem() -> void:
	_completar_partida()
	var f: Control = await _final()
	assert_eq(f.get_node(CAM_SENHAS).get_child_count(), 4)
	assert_eq(f.get_node(CAM_MAGOS).get_child_count(), 2)
	var simbolos: Array = []
	for bloco in f.get_node(CAM_MAGOS).get_children():
		simbolos.append((bloco.get_child(0) as SimboloMago).id)
	assert_eq(simbolos, [0, 2])


func test_mago_sem_acerto_aparece_sem_icones() -> void:
	_completar_partida(true)
	assert_eq(Sessao.partida.jogadores[1].pontos, 0)
	var f: Control = await _final()
	var blocos: Array = f.get_node(CAM_MAGOS).get_children()
	assert_eq(blocos.size(), 2)
	assert_eq((blocos[1].get_child(1) as IconesPonto).qtd, 0)
	assert_eq(blocos[1].get_child_count(), blocos[0].get_child_count())


func test_cofre_so_avanca_apos_animacao() -> void:
	_completar_partida()
	var c: Control = load("res://cenas/cofre/cofre.tscn").instantiate() as Control
	add_child_autofree(c)
	await wait_seconds(0.5)
	assert_false(c._pode_avancar)
	await wait_seconds(2.0)
	assert_true(c._pode_avancar)
