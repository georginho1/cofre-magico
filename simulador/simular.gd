extends SceneTree
## CLI do simulador. Uso (apos --): --config=res://x.tres --partidas=N --semente=N
## --saida=caminho --set=campo=valor (repetivel). Saida: 0 ok, 1 partida nao terminou, 2 argumento invalido.

const SEMENTE_FIXA: int = 12345


func _falhar(msg: String) -> void:
	printerr("simular: " + msg)
	quit(2)


func _initialize() -> void:
	var caminho_cfg: String = "res://dados/regras_padrao.tres"
	var n_partidas: int = 1000
	var semente_arg: int = -1
	var saida: String = "user://relatorio_simulador.md"
	var sets: Array = []

	for arg in OS.get_cmdline_user_args():
		var a: String = arg
		if not a.begins_with("--") or not a.contains("="):
			_falhar("argumento invalido: " + a)
			return
		var cut: int = a.find("=")
		var chave: String = a.substr(2, cut - 2)
		var valor: String = a.substr(cut + 1)
		match chave:
			"config":
				caminho_cfg = valor
			"partidas":
				if not valor.is_valid_int():
					_falhar("--partidas precisa ser inteiro")
					return
				n_partidas = clampi(valor.to_int(), 1, 100000)
			"semente":
				if not valor.is_valid_int():
					_falhar("--semente precisa ser inteiro")
					return
				semente_arg = maxi(valor.to_int(), 0)
			"saida":
				saida = valor
			"set":
				sets.append(valor)
			_:
				_falhar("opcao desconhecida: --" + chave)
				return

	if not caminho_cfg.begins_with("res://") or not caminho_cfg.ends_with(".tres"):
		_falhar("--config deve ser res://....tres")
		return
	var base: Resource = load(caminho_cfg)
	if base == null or not (base is ConfigRegras):
		_falhar("--config nao e um ConfigRegras: " + caminho_cfg)
		return
	var cfg: ConfigRegras = (base as ConfigRegras).duplicate() as ConfigRegras

	var validos: Dictionary = {}
	for p in cfg.get_property_list():
		if (p["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0:
			validos[p["name"]] = true
	for s in sets:
		var par: String = s
		if not par.contains("="):
			_falhar("--set precisa de campo=valor")
			return
		var cut2: int = par.find("=")
		var campo: String = par.substr(0, cut2)
		var txt: String = par.substr(cut2 + 1)
		if not validos.has(campo):
			_falhar("campo desconhecido em --set: " + campo)
			return
		var tipo: int = typeof(cfg.get(campo))
		match tipo:
			TYPE_INT:
				if not txt.is_valid_int():
					_falhar("valor nao inteiro para " + campo)
					return
				cfg.set(campo, txt.to_int())
			TYPE_FLOAT:
				if not txt.is_valid_float():
					_falhar("valor nao numerico para " + campo)
					return
				cfg.set(campo, txt.to_float())
			TYPE_BOOL:
				if txt != "true" and txt != "false":
					_falhar("valor deve ser true ou false para " + campo)
					return
				cfg.set(campo, txt == "true")
			_:
				_falhar("tipo nao suportado em --set: " + campo)
				return
	cfg.normalizar()

	var semente: int = semente_arg if semente_arg >= 0 else cfg.semente
	if semente == 0:
		semente = SEMENTE_FIXA
		print("semente 0: usando semente fixa %d" % semente)

	var bib := load("res://dados/biblioteca_palavras.tres") as BibliotecaPalavras
	var dist := load("res://dados/distribuicao_baralho.tres") as DistribuicaoBaralho
	var resultados: Array = []
	for n in range(1, 5):
		for perfil in [PerfilPerfeito.new(), PerfilAprendiz.new()]:
			resultados.append(Simulacao.rodar(cfg, bib, dist, n, perfil, n_partidas, semente))

	var texto: String = Relatorio.montar(cfg, semente, resultados, bib, dist)
	print(texto)
	var f := FileAccess.open(saida, FileAccess.WRITE)
	if f != null:
		f.store_string(texto)
		f.close()
	else:
		printerr("simular: nao foi possivel gravar " + saida)

	var todas: bool = true
	for r in resultados:
		if r["terminadas"] != r["partidas"]:
			todas = false
	quit(0 if todas else 1)
