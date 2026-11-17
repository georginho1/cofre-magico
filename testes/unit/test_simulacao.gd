extends GutTest
## Sanidade do simulador (PART-11). Usa so a API publica da Partida.

var _bib: BibliotecaPalavras
var _dist: DistribuicaoBaralho
var _cfg: ConfigRegras


class PerfilSoTroca:
	extends Perfil

	func decidir(_partida: Partida, _rng: RandomNumberGenerator) -> Dictionary:
		return {"acao": "trocar"}


func before_each() -> void:
	_bib = load("res://dados/biblioteca_palavras.tres") as BibliotecaPalavras
	_dist = load("res://dados/distribuicao_baralho.tres") as DistribuicaoBaralho
	_cfg = ConfigRegras.new()


func _rodar(n_magos: int, perfil: Perfil, n: int, semente: int) -> Dictionary:
	return Simulacao.rodar(_cfg, _bib, _dist, n_magos, perfil, n, semente)


func test_perfeito_termina_e_sem_ponto_plausivel() -> void:
	for n_magos in range(1, 5):
		var r := _rodar(n_magos, PerfilPerfeito.new(), 200, 7)
		assert_eq(r["terminadas"], r["partidas"], "D-20 com %d magos" % n_magos)
		assert_between(r["pct_turnos_sem_ponto"], 0.20, 0.55, "sem ponto %d magos" % n_magos)
		gut.p("magos=%d sem_ponto=%.3f zerado=%.3f" % [n_magos, r["pct_turnos_sem_ponto"], r["pct_partidas_mago_zerado"]])


func test_determinismo() -> void:
	var a := _rodar(3, PerfilAprendiz.new(), 50, 11)
	var b := _rodar(3, PerfilAprendiz.new(), 50, 11)
	var c := _rodar(3, PerfilAprendiz.new(), 50, 12)
	assert_eq(var_to_str(a), var_to_str(b))
	assert_ne(var_to_str(a), var_to_str(c))


func test_aprendiz_erra_e_demora_mais() -> void:
	_cfg.taxa_erro_aprendiz = 0.3
	_cfg.erro_passa_a_vez = true
	var per := _rodar(2, PerfilPerfeito.new(), 200, 3)
	var apr := _rodar(2, PerfilAprendiz.new(), 200, 3)
	assert_eq(per["pct_turnos_erro"], 0.0)
	assert_gt(apr["pct_turnos_erro"], 0.0)
	assert_gt(apr["turnos_partida"]["media"], per["turnos_partida"]["media"])


func test_erro_contado_sem_passar_a_vez() -> void:
	# CR-01: com erro_passa_a_vez=false o turno nunca termina em ERRO, mas os erros contam.
	_cfg.taxa_erro_aprendiz = 0.3
	_cfg.erro_passa_a_vez = false
	var per := _rodar(2, PerfilPerfeito.new(), 200, 3)
	var apr := _rodar(2, PerfilAprendiz.new(), 200, 3)
	assert_eq(per["pct_turnos_erro"], 0.0)
	assert_eq(per["erros_por_turno"], 0.0)
	assert_gt(apr["pct_turnos_erro"], 0.0)
	assert_gte(apr["erros_por_turno"], apr["pct_turnos_erro"])


func test_distratoras_alavanca() -> void:
	_cfg.proporcao_distratoras = 0.0
	var sem := _rodar(2, PerfilPerfeito.new(), 200, 5)
	_cfg.proporcao_distratoras = 1.0
	var com := _rodar(2, PerfilPerfeito.new(), 200, 5)
	assert_lt(sem["pct_turnos_sem_ponto"], com["pct_turnos_sem_ponto"])


func test_config_muda_metricas() -> void:
	var base := _rodar(2, PerfilPerfeito.new(), 100, 5)
	_cfg.tamanho_mao = 3
	var mao3 := _rodar(2, PerfilPerfeito.new(), 100, 5)
	assert_ne(base["pct_turnos_sem_ponto"], mao3["pct_turnos_sem_ponto"])
	_cfg.tamanho_mao = 5
	_cfg.quantidade_senhas = 3
	var s3 := _rodar(2, PerfilPerfeito.new(), 100, 5)
	assert_lt(s3["turnos_partida"]["media"], base["turnos_partida"]["media"])


func test_limite_de_turnos_nao_terminada() -> void:
	_cfg.limite_turnos_partida = 100
	var r := _rodar(2, PerfilSoTroca.new(), 3, 1)
	assert_eq(r["partidas"], 3)
	assert_lt(r["terminadas"], r["partidas"])
	assert_eq(r["terminadas"], 0)


func test_por_palavra_soma_aparicoes() -> void:
	var r := _rodar(2, PerfilPerfeito.new(), 50, 9)
	var soma := 0
	for t in r["por_palavra"]:
		var d: Dictionary = r["por_palavra"][t]
		assert_gt(d["aparicoes"], 0)
		soma += d["aparicoes"]
	assert_eq(soma, 50 * _cfg.quantidade_senhas)


func test_mago_zerado_com_4_magos() -> void:
	var r := _rodar(4, PerfilPerfeito.new(), 200, 13)
	assert_between(r["pct_partidas_mago_zerado"], 0.0, 0.10)


func test_chaves_do_retorno() -> void:
	var r := _rodar(1, PerfilPerfeito.new(), 10, 1)
	for k in ["n_magos", "perfil", "partidas", "terminadas", "pct_terminadas", "turnos_partida",
			"turnos_por_mago_media", "pct_turnos_sem_ponto", "pct_turnos_troca", "pct_turnos_erro", "erros_por_turno",
			"pct_partidas_mago_zerado", "pontos_medios_por_mago", "por_palavra"]:
		assert_true(r.has(k), k)
	for k in ["media", "mediana", "p95"]:
		assert_true(r["turnos_partida"].has(k), k)


func _res(n: int, sem_ponto: float) -> Dictionary:
	return {"n_magos": n, "perfil": "perfeito", "partidas": 10, "terminadas": 10,
			"pct_turnos_sem_ponto": sem_ponto, "pct_partidas_mago_zerado": 0.0}


func test_d18_um_mago_so_relatado() -> void:
	var rs: Array = [_res(1, 0.362), _res(2, 0.331), _res(3, 0.30), _res(4, 0.27)]
	var metas := Relatorio.avaliar_metas(rs)
	assert_true(Relatorio.metas_ok(rs))
	assert_eq(Relatorio.rotulo_meta(metas[0]), "RELATADO (falha)")
	assert_eq(Relatorio.rotulo_meta(metas[1]), "PASS")


func test_d18_exigida_falha_em_2_magos() -> void:
	var rs: Array = [_res(1, 0.30), _res(2, 0.36), _res(3, 0.30), _res(4, 0.27)]
	assert_false(Relatorio.metas_ok(rs))


func test_d18_d19_falham_sem_partidas_terminadas() -> void:
	# WR-05: taxa 0/1 nao pode passar por vacuidade.
	var rs: Array = [_res(1, 0.0), _res(2, 0.0), _res(3, 0.0), _res(4, 0.0)]
	for r in rs:
		r["terminadas"] = 0
	for m in Relatorio.avaliar_metas(rs):
		if m["exigida"]:
			assert_false(m["ok"], m["descricao"])
	assert_false(Relatorio.metas_ok(rs))
