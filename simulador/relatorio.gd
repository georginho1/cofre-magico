class_name Relatorio
extends RefCounted
## Formatacao do relatorio do simulador e avaliacao das metas D-18, D-19, D-20.

const META_SEM_PONTO: float = 0.35
const META_MAGO_ZERADO: float = 0.05


static func _pct(v: float) -> String:
	return "%.1f%%" % (v * 100.0)


static func _campos(cfg: ConfigRegras) -> Array:
	var nomes: Array = []
	for p in cfg.get_property_list():
		if (p["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0:
			nomes.append(p["name"])
	return nomes


static func _achar(resultados: Array, n_magos: int, perfil: String) -> Dictionary:
	for r in resultados:
		if r["n_magos"] == n_magos and r["perfil"] == perfil:
			return r
	return {}


static func avaliar_metas(resultados: Array) -> Array:
	## Lista de {id, descricao, ok}.
	var saida: Array = []
	var soma: float = 0.0
	var cont: int = 0
	for n in range(1, 5):
		var r := _achar(resultados, n, "perfeito")
		if r.is_empty():
			continue
		saida.append({"id": "D-18", "descricao": "turnos sem ponto <= 35%% com %d mago(s), perfeito (%s)" % [n, _pct(r["pct_turnos_sem_ponto"])], "ok": r["pct_turnos_sem_ponto"] <= META_SEM_PONTO})
		soma += r["pct_turnos_sem_ponto"]
		cont += 1
	if cont > 0:
		saida.append({"id": "D-18", "descricao": "media de turnos sem ponto 1 a 4 magos <= 35%% (%s)" % _pct(soma / cont), "ok": soma / cont <= META_SEM_PONTO})
	var r4 := _achar(resultados, 4, "perfeito")
	if not r4.is_empty():
		saida.append({"id": "D-19", "descricao": "partidas com mago sem silaba <= 5%% com 4 magos, perfeito (%s)" % _pct(r4["pct_partidas_mago_zerado"]), "ok": r4["pct_partidas_mago_zerado"] <= META_MAGO_ZERADO})
	var todas: bool = true
	for r in resultados:
		if r["terminadas"] != r["partidas"]:
			todas = false
	saida.append({"id": "D-20", "descricao": "100% das partidas terminam, todas as linhas", "ok": todas})
	return saida


static func metas_ok(resultados: Array) -> bool:
	for m in avaliar_metas(resultados):
		if not m["ok"]:
			return false
	return true


static func montar(
	cfg: ConfigRegras,
	semente: int,
	resultados: Array,
	bib: BibliotecaPalavras = null,
	dist: DistribuicaoBaralho = null
) -> String:
	var t: PackedStringArray = PackedStringArray()
	var n_partidas: int = 0
	if not resultados.is_empty():
		n_partidas = resultados[0]["partidas"]
	t.append("# Relatório do simulador Cofre Mágico")
	t.append("")
	t.append("Semente: %d | Partidas por linha: %d" % [semente, n_partidas])
	t.append("")
	t.append("## Configuração (ConfigRegras)")
	t.append("")
	for nome in _campos(cfg):
		t.append("- %s = %s" % [nome, str(cfg.get(nome))])
	t.append("")

	t.append("## Resultados por magos x perfil")
	t.append("")
	t.append("| Magos | Perfil | Terminadas | Turnos (média/mediana/p95) | Turnos por mago | Sem ponto | Troca | Erro | Partidas com mago sem sílaba | Pontos médios por mago |")
	t.append("|---|---|---|---|---|---|---|---|---|---|")
	for r in resultados:
		var tp: Dictionary = r["turnos_partida"]
		t.append("| %d | %s | %s | %.1f / %.1f / %.1f | %.1f | %s | %s | %s | %s | %.2f |" % [
			r["n_magos"], r["perfil"], _pct(r["pct_terminadas"]),
			tp["media"], tp["mediana"], tp["p95"], r["turnos_por_mago_media"],
			_pct(r["pct_turnos_sem_ponto"]), _pct(r["pct_turnos_troca"]), _pct(r["pct_turnos_erro"]),
			_pct(r["pct_partidas_mago_zerado"]), r["pontos_medios_por_mago"]])
	t.append("")

	t.append("## Metas")
	t.append("")
	for m in avaliar_metas(resultados):
		t.append("- %s %s: %s" % ["PASS" if m["ok"] else "FAIL", m["id"], m["descricao"]])
	t.append("")

	t.append("## Comparação perfeito x aprendiz")
	t.append("")
	t.append("Regra em vigor (D-04): erro_passa_a_vez = %s; taxa_erro_aprendiz = %s" % [str(cfg.erro_passa_a_vez), str(cfg.taxa_erro_aprendiz)])
	t.append("")
	t.append("| Magos | Dif. turnos médios (aprendiz - perfeito) | Erro (aprendiz) | Mago sem sílaba (perfeito) | Mago sem sílaba (aprendiz) |")
	t.append("|---|---|---|---|---|")
	for n in range(1, 5):
		var pf := _achar(resultados, n, "perfeito")
		var ap := _achar(resultados, n, "aprendiz")
		if pf.is_empty() or ap.is_empty():
			continue
		t.append("| %d | %+.2f | %s | %s | %s |" % [
			n, ap["turnos_partida"]["media"] - pf["turnos_partida"]["media"],
			_pct(ap["pct_turnos_erro"]), _pct(pf["pct_partidas_mago_zerado"]), _pct(ap["pct_partidas_mago_zerado"])])
	t.append("")

	t.append("## Impacto por palavra")
	t.append("")
	t.append("Perfil perfeito, ordenado por turnos até completar (decrescente). [3 síl.] = palavra de 3 sílabas; [2 cópias] = contém sílaba com 2 cópias no baralho.")
	for n in range(1, 5):
		var pf2 := _achar(resultados, n, "perfeito")
		if pf2.is_empty():
			continue
		t.append("")
		t.append("### %d mago(s)" % n)
		t.append("")
		t.append("| Palavra | Aparições | Turnos até completar | Vezes última | Marcas |")
		t.append("|---|---|---|---|---|")
		var chaves: Array = pf2["por_palavra"].keys()
		chaves.sort_custom(func(a, b):
			var da: float = pf2["por_palavra"][a]["turnos_ate_completar_media"]
			var db: float = pf2["por_palavra"][b]["turnos_ate_completar_media"]
			if da == db:
				return str(a) < str(b)
			return da > db)
		for k in chaves:
			var d: Dictionary = pf2["por_palavra"][k]
			t.append("| %s | %d | %.2f | %d | %s |" % [k, d["aparicoes"], d["turnos_ate_completar_media"], d["vezes_ultima"], _marcas(k, bib, dist)])
	t.append("")
	return "\n".join(t)


static func _marcas(texto: String, bib: BibliotecaPalavras, dist: DistribuicaoBaralho) -> String:
	if bib == null:
		return ""
	var m: PackedStringArray = PackedStringArray()
	for d in bib.palavras:
		if d.texto != texto:
			continue
		if d.silabas.size() >= 3:
			m.append("[3 síl.]")
		if dist != null:
			for s in d.silabas:
				if dist.copias_de(s) <= 2:
					m.append("[2 cópias]")
					break
	return " ".join(m)
