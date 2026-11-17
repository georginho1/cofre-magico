class_name BibliotecaPalavras
extends Resource
## As 30 palavras do prototipo fisico. Somente leitura (nunca mutar o resultado de load()).

@export var palavras: Array[DadosPalavra] = []


func buscar(texto: String) -> DadosPalavra:
	for p in palavras:
		if p.texto == texto:
			return p
	return null


func silabas_distintas() -> PackedStringArray:
	var vistas: Dictionary = {}
	var saida: PackedStringArray = PackedStringArray()
	for p in palavras:
		for s in p.silabas:
			if not vistas.has(s):
				vistas[s] = true
				saida.append(s)
	return saida
