extends Node
## Autoload Sessao: estado compartilhado entre cenas (magos ativos e partida).

const CENA_MENU := "res://cenas/menu/menu.tscn"
const CENA_SELECAO := "res://cenas/selecao/selecao.tscn"
const CENA_MESA := "res://cenas/mesa/mesa.tscn"
const CENA_COFRE := "res://cenas/cofre/cofre.tscn"
const CENA_FINAL := "res://cenas/final/final.tscn"

var magos_ativos: Array[int] = []
var partida: Partida = null


func ativar_magos(ids: Array[int]) -> void:
	var limpos: Array[int] = []
	for id in ids:
		if id >= 0 and id <= 3 and not limpos.has(id):
			limpos.append(id)
	limpos.sort()
	magos_ativos = limpos


func id_do_indice(indice: int) -> int:
	return magos_ativos[indice]


func nova_partida() -> void:
	var cfg: ConfigRegras = load("res://dados/regras_padrao.tres") as ConfigRegras
	var bib: BibliotecaPalavras = load("res://dados/biblioteca_palavras.tres") as BibliotecaPalavras
	var dist: DistribuicaoBaralho = load("res://dados/distribuicao_baralho.tres") as DistribuicaoBaralho
	if cfg == null or bib == null or dist == null:
		push_error("recursos de dados ausentes ou invalidos")
		return
	var rng := RandomNumberGenerator.new()
	if cfg.semente > 0:
		rng.seed = cfg.semente
	else:
		rng.randomize()
	partida = Partida.new(cfg, bib, dist, magos_ativos.size(), rng)


func limpar() -> void:
	partida = null


func ir_para(caminho: String) -> void:
	get_tree().change_scene_to_file(caminho)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_voltar()


func _unhandled_input(ev: InputEvent) -> void:
	if ev.is_action_pressed("ui_cancel"):
		_voltar()


func _voltar() -> void:
	var cena: Node = get_tree().current_scene
	if cena != null and cena.has_method("ao_voltar"):
		cena.call("ao_voltar")
