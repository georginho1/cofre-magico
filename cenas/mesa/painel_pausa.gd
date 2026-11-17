class_name PainelPausa
extends Control
## Painel modal de pausa com confirmacao de saida (D-16, COFR-05).
## Nao usa get_tree().paused: o mouse_filter STOP bloqueia a mesa atras.

signal continuar
signal sair

@onready var _estado_pausa: Control = $Centro/Painel/Conteudo/EstadoPausa
@onready var _estado_confirmar: Control = $Centro/Painel/Conteudo/EstadoConfirmar


func _ready() -> void:
	($Centro/Painel/Conteudo/EstadoPausa/Continuar as Button).pressed.connect(_ao_continuar)
	($Centro/Painel/Conteudo/EstadoPausa/Sair as Button).pressed.connect(_ao_pedir_saida)
	($Centro/Painel/Conteudo/EstadoConfirmar/Sair as Button).pressed.connect(func() -> void: sair.emit())
	($Centro/Painel/Conteudo/EstadoConfirmar/ContinuarJogando as Button).pressed.connect(_ao_continuar)


func abrir() -> void:
	_estado_pausa.visible = true
	_estado_confirmar.visible = false
	visible = true


func fechar() -> void:
	visible = false


func esta_aberto() -> bool:
	return visible


## Voltar/Esc com o painel aberto equivale a Continuar, tambem na confirmacao.
func voltar() -> void:
	if not visible:
		return
	_ao_continuar()


func _ao_continuar() -> void:
	fechar()
	continuar.emit()


func _ao_pedir_saida() -> void:
	_estado_pausa.visible = false
	_estado_confirmar.visible = true
