extends GutTest


func test_cores_na_ordem() -> void:
	assert_eq(Magos.COR.size(), 4)
	assert_eq(Magos.COR[0], Color("#E03C3C"))
	assert_eq(Magos.COR[1], Color("#2F7BFF"))
	assert_eq(Magos.COR[2], Color("#2EAD5E"))
	assert_eq(Magos.COR[3], Color("#F2C200"))


func test_cor_texto_e_nomes() -> void:
	assert_eq(Magos.COR_TEXTO[0], Color.WHITE)
	assert_eq(Magos.COR_TEXTO[1], Color.WHITE)
	assert_eq(Magos.COR_TEXTO[2], Color.WHITE)
	assert_eq(Magos.COR_TEXTO[3], Color("#14213D"))
	assert_eq(Magos.NOME, ["Vermelho", "Azul", "Verde", "Amarelo"] as Array[String])


func test_id_do_indice() -> void:
	var ativos: Array[int] = [0, 2]
	assert_eq(Magos.id_do_indice(ativos, 1), 2)
