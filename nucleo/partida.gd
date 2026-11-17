class_name Partida
extends RefCounted
## Estado de uma partida. Sem Node; RNG injetado.

var cfg: ConfigRegras
var rng: RandomNumberGenerator
var palavras: Array[PalavraSenha] = []
var jogadores: Array[Jogador] = []
var baralho: Baralho
var jogador_atual: int = 0
var turnos_jogados: int = 0
var jogadas_no_turno: int = 0
var cartas_total: int = 0


func _init(
	p_cfg: ConfigRegras,
	bib: BibliotecaPalavras,
	dist: DistribuicaoBaralho,
	n_magos: int,
	p_rng: RandomNumberGenerator
) -> void:
	cfg = p_cfg
	cfg.normalizar()
	rng = p_rng
	var n: int = clampi(n_magos, 1, 4)

	var indices: Array = []
	for k in range(bib.palavras.size()):
		indices.append(k)
	Baralho.misturar(indices, rng)
	var sorteadas: Array[DadosPalavra] = []
	for k in range(mini(cfg.quantidade_senhas, indices.size())):
		var d: DadosPalavra = bib.palavras[indices[k]]
		sorteadas.append(d)
		palavras.append(PalavraSenha.new(d))

	baralho = Baralho.montar(sorteadas, dist, cfg, rng)
	for i in range(n):
		var j := Jogador.new(i)
		j.mao = baralho.comprar(cfg.tamanho_mao)
		jogadores.append(j)

	var soma: int = 0
	for j in jogadores:
		soma += j.mao.size()
	cartas_total = baralho.tamanho() + soma
