extends GutTest


func _nova() -> Node:
	return autofree(load("res://sessao.gd").new())


func test_ativar_magos_ordena_e_filtra() -> void:
	var s: Node = _nova()
	var ids: Array[int] = [3, 0, 0, 2, 7]
	s.ativar_magos(ids)
	assert_eq(s.magos_ativos, [0, 2, 3] as Array[int])


func test_id_do_indice() -> void:
	var s: Node = _nova()
	var ids: Array[int] = [2, 0]
	s.ativar_magos(ids)
	assert_eq(s.id_do_indice(0), 0)
	assert_eq(s.id_do_indice(1), 2)


func test_nova_partida() -> void:
	var s: Node = _nova()
	var ids: Array[int] = [1, 3]
	s.ativar_magos(ids)
	s.nova_partida()
	assert_not_null(s.partida)
	assert_eq(s.partida.jogadores.size(), 2)
	assert_eq(s.partida.palavras.size(), 4)
