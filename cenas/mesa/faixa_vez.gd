class_name FaixaVez
extends Button
## Sobreposicao de passagem de vez. O proprio Button emite `pressed` ao ser tocado.

@onready var _painel: PanelContainer = $Painel
@onready var _simbolo: SimboloMago = $Painel/Caixa/Simbolo
@onready var _titulo: Label = $Painel/Caixa/Textos/Titulo


func configurar(id_mago: int) -> void:
	_titulo.text = "Vez do Mago %s" % Magos.NOME[id_mago]
	_simbolo.configurar(id_mago, Magos.COR_TEXTO[id_mago], true, false)
	# Excecao documentada ao Theme: a cor das bordas depende do mago da vez.
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.133333, 0.2, 0.360784, 0.95)
	sb.border_color = Magos.COR[id_mago]
	sb.border_width_top = 8
	sb.border_width_bottom = 8
	_painel.add_theme_stylebox_override("panel", sb)
