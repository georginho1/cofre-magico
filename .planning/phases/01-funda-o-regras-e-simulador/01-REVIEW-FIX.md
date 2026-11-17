---
phase: 01-funda-o-regras-e-simulador
fixed_at: 2026-11-17T16:10:00Z
review_path: .planning/phases/01-funda-o-regras-e-simulador/01-REVIEW.md
iteration: 1
findings_in_scope: 12
fixed: 10
skipped: 2
status: partial
---

# Phase 01: Code Review Fix Report

**Fixed at:** 2026-11-17T16:10:00Z
**Source review:** .planning/phases/01-funda-o-regras-e-simulador/01-REVIEW.md
**Iteration:** 1

**Scope:** CR-01, todos os Warnings, e os Info triviais IN-02, IN-04 e IN-06. WR-01 e WR-03 entram no escopo, mas foram pulados por decisão do orquestrador. IN-01, IN-03, IN-05 e IN-07 ficaram fora do escopo e não foram tocados.

**Summary:**
- Findings in scope: 12
- Fixed: 10
- Skipped: 2

Testes: `testes/rodar.ps1` passa com 60/60 (antes eram 56/56; 4 testes novos e nenhum script deixou de ser carregado). Exportação Windows e Android sem erros; `build/windows/CofreMagico.console.exe --quit-after 5` imprime `COFRE_MAGICO_INICIAL tamanho_mao=5` e sai com 0.

## Fixed Issues

### CR-01: Learner error rate always reports 0% when `erro_passa_a_vez=false`

**Files modified:** `simulador/simulacao.gd`, `simulador/relatorio.gd`, `testes/unit/test_simulacao.gd`
**Commit:** 7b6953c
**Applied fix:** Os erros agora são contados por ação. `pct_turnos_erro` passou a medir os turnos com pelo menos um erro, qualquer que seja o fim do turno, e a nova chave `erros_por_turno` dá as jogadas erradas divididas pelos turnos. "Troca" continua sendo a fatia dos turnos sem ponto que terminaram em troca. As duas métricas aparecem no relatório. Teste novo: `test_erro_contado_sem_passar_a_vez`. A comparação D-04 foi refeita e está em 01-SIMULACAO.md.
**Status:** fixed: requires human verification (definição de métrica)

### WR-02: A trade can draw back the cards just returned

**Files modified:** `nucleo/partida.gd`, `testes/unit/test_partida_turnos.gd`
**Commit:** 5bfc118
**Applied fix:** `trocar_mao` compra as cartas novas antes de devolver as descartadas. Depois embaralha e chama `_repor` para completar a mão com as cartas que voltaram, caso o baralho tivesse menos cartas que o descarte. Teste novo: `test_trocar_compra_antes_de_devolver`.
**Status:** fixed: requires human verification. É uma mudança de regra que a equipe precisa confirmar. Ela baixa os turnos sem ponto do perfil perfeito em cerca de 2 pontos percentuais.

### WR-04: Exports ship tests, simulator and the GUT addon

**Files modified:** `export_presets.cfg`
**Commit:** 52922b2
**Applied fix:** `exclude_filter="testes/*, simulador/*, addons/gut/*"` nos dois presets. Nenhuma outra chave foi alterada. Conferido: as exportações Windows e Android saem com 0, o APK não tem nenhuma entrada de testes, simulador ou GUT, e o executável só mantém o caminho do plugin vindo de `project.godot`. O plugin GUT habilitado em `project.godot` não quebra o jogo exportado, porque a fumaça imprime `COFRE_MAGICO_INICIAL tamanho_mao=5` e sai com 0.

### WR-05: D-18 and D-19 report PASS vacuously when no match finishes

**Files modified:** `simulador/relatorio.gd`, `testes/unit/test_simulacao.gd`
**Commit:** 3aa167c
**Applied fix:** Linha com `terminadas == 0` gera D-18/D-19 com `ok: false` e a descrição "sem partidas terminadas". A média de D-18 também falha quando alguma linha exigida não tem partidas terminadas. Teste novo: `test_d18_d19_falham_sem_partidas_terminadas`.

### WR-06: Per-word stats mix in aborted matches

**Files modified:** `simulador/simulacao.gd`, `testes/unit/test_simulacao.gd`
**Commit:** 6d083d7
**Applied fix:** Os dados por palavra ficam em um dicionário local de cada partida e só entram no total depois da checagem `estourou`. `test_limite_de_turnos_nao_terminada` agora verifica que `por_palavra` fica vazio.

### WR-07: `Partida` and the initial scene mutate the shared, cached `ConfigRegras`

**Files modified:** `nucleo/partida.gd`, `cenas/inicial/inicial.gd`, `simulador/simulacao.gd`, `testes/unit/test_partida_sorteio.gd`
**Commit:** 805b001
**Applied fix:** `Partida._init`, `inicial.gd` e `Simulacao.rodar`, que tinha o mesmo `cfg.normalizar()` sobre o objeto do chamador, passaram a trabalhar sobre `duplicate()`. `test_normaliza_config` verifica `p.cfg` e confirma que o `_cfg` do chamador continua igual.

### WR-08: Tests that do not verify what their names claim

**Files modified:** `testes/unit/test_partida_turnos.gd`
**Commit:** 3e5818e
**Applied fix:** `_dar_carta` troca a carta de lugar com uma carta real (da própria mão, do baralho ou da mão de outro jogador), então os totais continuam corretos. `_silaba_errada` escolhe uma sílaba que está em circulação. `test_acerto_em_qualquer_espaco_com_mesma_silaba` usa uma partida só com PIPA e PATO e verifica que PA é aceito nas duas palavras. `test_invalido_nao_altera_estado` confere mão, turnos, jogador e pontos logo depois das cinco jogadas inválidas. `test_acerto_com_baralho_vazio_nao_repoe` dá a carta antes de esvaziar o baralho.

### IN-02: `semente` comment / unused `mostrar_palavra_escrita`

**Files modified:** `dados/tipos/config_regras.gd`
**Commit:** 4159655
**Applied fix:** O comentário de `semente` agora diz "0 = padrao do consumidor (o simulador usa uma semente fixa)", e `mostrar_palavra_escrita` foi marcado como reservado para a fase de interface. Nenhum código foi alterado.

### IN-04: Unchecked `load` in the shipped main scene

**Files modified:** `cenas/inicial/inicial.gd`
**Commit:** b541a0a
**Applied fix:** O código verifica se `load` devolveu null e chama `push_error` antes de usar as regras. O botão é ligado antes de carregar as regras. O `print` COFRE_MAGICO_INICIAL foi mantido de propósito, porque é o marcador do teste de fumaça da exportação.

### IN-06: `pontos_medios_por_mago` divides by the requested `n_magos`

**Files modified:** `simulador/simulacao.gd`, `testes/unit/test_simulacao.gd`
**Commit:** 8590912
**Applied fix:** A média é calculada por partida, dividindo por `partida.jogadores.size()`. Teste novo: `test_pontos_por_mago_usa_magos_reais`.

## Skipped Issues

### WR-01: No way to end the turn except trading when `silabas_por_turno > 1`

**File:** `nucleo/partida.gd:124-125, 134-158`
**Reason:** É uma decisão de design e ficou para a Fase 2 (orientação do orquestrador). O valor padrão é `silabas_por_turno = 1`, e nenhuma ação nova foi adicionada.
**Original issue:** Com mais de uma sílaba por turno, um jogador que acertou uma vez só consegue encerrar o turno trocando a mão inteira.

### WR-03: Android preset excludes `armeabi-v7a`

**File:** `export_presets.cfg:63`
**Reason:** Aguarda decisão da equipe (orientação do orquestrador). Não foi alterado.
**Original issue:** `architectures/armeabi-v7a=false` impede a instalação em aparelhos antigos de 32 bits.

## Simulação refeita (01-SIMULACAO.md, commit 01ecc52)

O relatório final foi gerado com `--partidas=5000 --semente=2026` e `regras_padrao.tres` inalterado. Resultado: D-18 PASS para 2, 3 e 4 magos (31.2 / 28.3 / 26.6%) e na média (28.7%); D-18 com 1 mago, que é só relatada, agora passa (33.8%, antes 36.4%); D-19 PASS (0.5%); D-20 PASS. A comparação D-04 foi refeita com proporção 1.0 (como na seção (c)) e com 0.40, 3000 partidas e semente 2026. Com `erro_passa_a_vez=false` o aprendiz agora aparece com 13 a 19% de turnos com erro, em vez de 0.0%.

---

_Fixed: 2026-11-17T16:10:00Z_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
