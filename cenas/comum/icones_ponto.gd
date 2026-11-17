class_name IconesPonto
extends Control
## Mostra uma quantidade de pontos como circulos, sem texto nem numero.

const POR_LINHA := 8
const SEPARACAO := 4

var qtd: int = 0
var cor: Color = Color.WHITE
var lado: int = 24


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func configurar(nova_qtd: int, nova_cor: Color, novo_lado: int = 24) -> void:
	qtd = maxi(nova_qtd, 0)
	cor = nova_cor
	lado = novo_lado
	if qtd == 0:
		custom_minimum_size = Vector2(0, lado)
	else:
		var linhas: int = ceili(float(qtd) / POR_LINHA)
		custom_minimum_size = Vector2(mini(qtd, POR_LINHA) * (lado + SEPARACAO), linhas * (lado + SEPARACAO))
	queue_redraw()


func _draw() -> void:
	for i in range(qtd):
		var col: int = i % POR_LINHA
		var lin: int = i / POR_LINHA
		var centro := Vector2(col * (lado + SEPARACAO) + lado / 2.0, lin * (lado + SEPARACAO) + lado / 2.0)
		draw_circle(centro, lado / 2.0, cor)
