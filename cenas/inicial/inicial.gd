extends Control

var _contador: int = 0

@onready var _rotulo_mao: Label = $Centro/Caixa/RotuloMao
@onready var _botao: Button = $Centro/Caixa/BotaoTocar
@onready var _rotulo_contagem: Label = $Centro/Caixa/RotuloContagem


func _ready() -> void:
	var regras: ConfigRegras = load("res://dados/regras_padrao.tres") as ConfigRegras
	regras.normalizar()
	_rotulo_mao.text = "Mão: %d cartas" % regras.tamanho_mao
	print("COFRE_MAGICO_INICIAL tamanho_mao=%d" % regras.tamanho_mao)
	_botao.pressed.connect(_ao_tocar)
	_atualizar_contagem()


func _ao_tocar() -> void:
	_contador += 1
	_atualizar_contagem()


func _atualizar_contagem() -> void:
	_rotulo_contagem.text = "Toques: %d" % _contador
