extends Control

var _contador: int = 0

@onready var _rotulo_mao: Label = $Centro/Caixa/RotuloMao
@onready var _botao: Button = $Centro/Caixa/BotaoTocar
@onready var _rotulo_contagem: Label = $Centro/Caixa/RotuloContagem


func _ready() -> void:
	_botao.pressed.connect(_ao_tocar)
	_atualizar_contagem()
	var base: ConfigRegras = load("res://dados/regras_padrao.tres") as ConfigRegras
	if base == null:
		push_error("regras_padrao.tres ausente ou invalido")
		return
	var regras: ConfigRegras = base.duplicate() as ConfigRegras
	regras.normalizar()
	_rotulo_mao.text = "Mão: %d cartas" % regras.tamanho_mao
	print("COFRE_MAGICO_INICIAL tamanho_mao=%d" % regras.tamanho_mao)


func _ao_tocar() -> void:
	_contador += 1
	_atualizar_contagem()


func _atualizar_contagem() -> void:
	_rotulo_contagem.text = "Toques: %d" % _contador
