class_name Baralho
extends RefCounted
## Baralho da partida. Cada carta e a sua silaba. RNG sempre injetado.

var cartas: Array[String] = []


## Fisher-Yates com RNG injetado; unico embaralhador do nucleo.
static func misturar(lista: Array, rng: RandomNumberGenerator) -> void:
	var i: int = lista.size() - 1
	while i > 0:
		var j: int = rng.randi_range(0, i)
		var tmp: Variant = lista[i]
		lista[i] = lista[j]
		lista[j] = tmp
		i -= 1


static func montar(
	palavras: Array[DadosPalavra],
	dist: DistribuicaoBaralho,
	cfg: ConfigRegras,
	rng: RandomNumberGenerator
) -> Baralho:
	var uteis: Dictionary = {}
	for p in palavras:
		for s in p.silabas:
			uteis[s] = true
	var cartas_uteis: Array[String] = []
	for s in uteis:
		for k in range(dist.copias_de(s)):
			cartas_uteis.append(s)
	var n_distr: int = roundi(cartas_uteis.size() * cfg.proporcao_distratoras)
	if cfg.tamanho_baralho_partida > 0:
		n_distr = mini(n_distr, maxi(0, cfg.tamanho_baralho_partida - cartas_uteis.size()))
	var pool: Array[String] = []
	for s in dist.copias:
		if uteis.has(s):
			continue
		for k in range(dist.copias_de(s)):
			pool.append(s)
	misturar(pool, rng)
	var b := Baralho.new()
	b.cartas.append_array(cartas_uteis)
	for k in range(mini(n_distr, pool.size())):
		b.cartas.append(pool[k])
	misturar(b.cartas, rng)
	return b


func tamanho() -> int:
	return cartas.size()


func comprar(n: int) -> Array[String]:
	var saida: Array[String] = []
	var q: int = mini(maxi(n, 0), cartas.size())
	for k in range(q):
		saida.append(cartas.pop_back())
	return saida


func devolver(lista: Array[String]) -> void:
	cartas.append_array(lista)


func embaralhar(rng: RandomNumberGenerator) -> void:
	misturar(cartas, rng)


func contagem() -> Dictionary:
	var c: Dictionary = {}
	for s in cartas:
		c[s] = c.get(s, 0) + 1
	return c
