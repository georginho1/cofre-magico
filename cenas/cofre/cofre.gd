extends Control
## Tela do cofre: porta abre por Tween, confete nas cores dos magos, toque tardio avanca.

const VIOLETA := Color("#B388FF")
const DURACAO_PORTA := 1.2
const ESPERA_MINIMA := 1.5

var _pode_avancar: bool = false
var _indo: bool = false

@onready var _porta: Control = $Centro/Caixa/Corpo/Porta
@onready var _confete: CPUParticles2D = $Centro/Caixa/Corpo/Confete
@onready var _titulo: Label = $Centro/Caixa/Titulo
@onready var _dica: Label = $Centro/Caixa/Dica
@onready var _toque: Button = $Toque


func _ready() -> void:
	if Sessao.partida == null:
		Sessao.ir_para(Sessao.CENA_MENU)
		return
	var grad := Gradient.new()
	var cores := PackedColorArray()
	for id in Sessao.magos_ativos:
		cores.append(Magos.COR[id])
	cores.append(VIOLETA)
	var offsets := PackedFloat32Array()
	for i in range(cores.size()):
		offsets.append(float(i) / maxf(cores.size() - 1, 1.0))
	grad.offsets = offsets
	grad.colors = cores
	_confete.color_ramp = grad
	_toque.pressed.connect(_avancar)
	var tw: Tween = create_tween()
	tw.tween_property(_porta, "scale:x", 0.0, DURACAO_PORTA)
	tw.tween_callback(func() -> void: _confete.emitting = true)
	tw.tween_property(_titulo, "modulate:a", 1.0, 0.3)
	tw.tween_interval(ESPERA_MINIMA - DURACAO_PORTA - 0.3 + 0.1)
	tw.tween_property(_dica, "modulate:a", 1.0, 0.3)
	tw.tween_callback(func() -> void: _pode_avancar = true)


func _avancar() -> void:
	if not _pode_avancar or _indo:
		return
	_indo = true
	Sessao.ir_para(Sessao.CENA_FINAL)


func ao_voltar() -> void:
	_avancar()
