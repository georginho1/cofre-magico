extends Control

@onready var _botao_jogar: Button = $Centro/Caixa/BotaoJogar


func _ready() -> void:
	_botao_jogar.pressed.connect(_ao_jogar)


func _ao_jogar() -> void:
	Sessao.limpar()
	Sessao.ir_para(Sessao.CENA_SELECAO)


func ao_voltar() -> void:
	get_tree().quit()
