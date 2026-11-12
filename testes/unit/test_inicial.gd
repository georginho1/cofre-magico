extends GutTest


func test_botao_conta_toques() -> void:
	var cena: Control = load("res://cenas/inicial/inicial.tscn").instantiate()
	add_child_autofree(cena)
	var botao: Button = cena.get_node("Centro/Caixa/BotaoTocar")
	var rotulo: Label = cena.get_node("Centro/Caixa/RotuloContagem")
	botao.pressed.emit()
	botao.pressed.emit()
	assert_eq(rotulo.text, "Toques: 2")
