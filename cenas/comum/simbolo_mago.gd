class_name SimboloMago
extends Control
## Desenha o simbolo de um mago (sol, lua, folha, estrela), com fundo circular opcional.

const CINZA := Color("#5C6C91")

var id: int = 0
var cor: Color = Color.WHITE
var com_fundo: bool = false
var apagado: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func configurar(novo_id: int, nova_cor: Color, novo_fundo: bool = false, novo_apagado: bool = false) -> void:
	id = novo_id
	cor = nova_cor
	com_fundo = novo_fundo
	apagado = novo_apagado
	queue_redraw()


func _draw() -> void:
	var lado: float = minf(size.x, size.y)
	var c: Vector2 = size / 2.0
	var r: float = lado / 2.0
	if com_fundo:
		draw_circle(c, r, CINZA if apagado else Magos.COR[id])
	var tom: Color = CINZA if apagado else cor
	if com_fundo and apagado:
		tom = Color("#14213D")
	var u: float = r * (0.6 if com_fundo else 1.0)
	match id:
		Magos.Simbolo.SOL:
			draw_circle(c, u * 0.5, tom)
			for i in range(8):
				var a: float = TAU * i / 8.0
				var d := Vector2(cos(a), sin(a))
				draw_line(c + d * u * 0.68, c + d * u, tom, maxf(2.0, u * 0.12))
		Magos.Simbolo.LUA:
			var pts := PackedVector2Array()
			var n: int = 16
			for i in range(n + 1):
				var a: float = -PI * 0.5 + PI * i / n
				pts.append(c + Vector2(cos(a), sin(a)) * u * 0.9)
			for i in range(n + 1):
				var a2: float = PI * 0.5 - PI * i / n
				pts.append(c + Vector2(cos(a2) * 0.45 + 0.0, sin(a2)) * u * 0.9)
			draw_colored_polygon(pts, tom)
		Magos.Simbolo.FOLHA:
			var f := PackedVector2Array([
				c + Vector2(-u * 0.8, u * 0.8), c + Vector2(-u * 0.5, -u * 0.2),
				c + Vector2(u * 0.2, -u * 0.8), c + Vector2(u * 0.8, -u * 0.8),
				c + Vector2(u * 0.5, u * 0.2), c + Vector2(-u * 0.2, u * 0.8)
			])
			draw_colored_polygon(f, tom)
			var fundo_nervura: Color = Color("#14213D") if not com_fundo else Magos.COR[id]
			draw_line(c + Vector2(-u * 0.8, u * 0.8), c + Vector2(u * 0.6, -u * 0.6), fundo_nervura, maxf(2.0, u * 0.08))
		Magos.Simbolo.ESTRELA:
			var e := PackedVector2Array()
			for i in range(10):
				var a: float = -PI * 0.5 + TAU * i / 10.0
				var rr: float = u if i % 2 == 0 else u * 0.4
				e.append(c + Vector2(cos(a), sin(a)) * rr)
			draw_colored_polygon(e, tom)
