---
phase: 01-funda-o-regras-e-simulador
reviewed: 2026-11-17T15:25:32Z
depth: standard
files_reviewed: 33
files_reviewed_list:
  - cenas/inicial/inicial.gd
  - cenas/inicial/inicial.tscn
  - dados/biblioteca_palavras.tres
  - dados/distribuicao_baralho.tres
  - dados/regras_padrao.tres
  - dados/tipos/biblioteca_palavras.gd
  - dados/tipos/config_regras.gd
  - dados/tipos/dados_palavra.gd
  - dados/tipos/distribuicao_baralho.gd
  - dados/variantes/regras_mao3_senhas3.tres
  - export_presets.cfg
  - nucleo/baralho.gd
  - nucleo/jogador.gd
  - nucleo/palavra_senha.gd
  - nucleo/partida.gd
  - nucleo/resultado_jogada.gd
  - project.godot
  - simulador/perfil_aprendiz.gd
  - simulador/perfil_perfeito.gd
  - simulador/perfis.gd
  - simulador/relatorio.gd
  - simulador/simulacao.gd
  - simulador/simular.gd
  - simulador/simular.ps1
  - testes/rodar.ps1
  - testes/rodar.sh
  - testes/unit/test_baralho.gd
  - testes/unit/test_config.gd
  - testes/unit/test_conteudo.gd
  - testes/unit/test_inicial.gd
  - testes/unit/test_partida_sorteio.gd
  - testes/unit/test_partida_turnos.gd
  - testes/unit/test_simulacao.gd
findings:
  critical: 1
  warning: 8
  info: 7
  total: 16
status: issues_found
---

# Phase 01: Code Review Report

**Reviewed:** 2026-11-17T15:25:32Z
**Depth:** standard
**Files Reviewed:** 33
**Status:** issues_found

## Narrative Findings (AI reviewer)

## Summary

The rules core (`nucleo/`) is small, typed and deterministic. I traced it through hand trades, empty decks, `silabas_por_turno > 1` and conclusion paths and found no state-corruption bugs. I also checked that every syllable's total demand across all 30 words fits within its copy count, so no word draw can make a match unwinnable.

The main problems are in the simulator's metrics and in rule levers the API cannot express:

- The "Erro (aprendiz)" metric, which the team used to compare D-04 true against false, is always 0% when `erro_passa_a_vez=false`. I confirmed this by running `simular.gd --set=erro_passa_a_vez=false` (every row shows 0.0%).
- With `silabas_por_turno > 1`, the only way to end a turn is to trade the whole hand.
- The Android export drops `armeabi-v7a`, which goes against the stack guidance for low-end devices.
- Both exports ship the test, simulator and GUT code.

## Critical Issues

### CR-01: Learner error rate always reports 0% when `erro_passa_a_vez=false`, so the D-04 comparison is invalid

**File:** `simulador/simulacao.gd:47-84`
**Issue:** A turn is labelled only by the result of its last action (`ultima`). An error is counted only when the turn ends on `ERRO` (`else: sp += 1; er += 1`). With `erro_passa_a_vez=false`, an `ERRO` never ends the turn: the learner tries again until it scores or trades, so the turn always ends on `ACERTO` or `TROCOU`. As a result, `pct_turnos_erro` is structurally 0 for that configuration. Running the simulator with `--partidas=50 --semente=3 --set=erro_passa_a_vez=false` prints `Erro (aprendiz) 0.0%` on every row of "Comparação perfeito x aprendiz".

There is a second effect. A turn with errors followed by a hit counts as a scoring turn, so the turns the learner spends on errors disappear from the sem-ponto metric as well. Plan 01-08 explicitly asked for this measurement (D-04 true vs false) as input to a team decision, and `relatorio.gd:113-124` presents it as that comparison. The number shown to the team is wrong, not just imprecise.
**Fix:** Count errors per action and record whether a turn had any error, independent of how the turn ended:
```gdscript
var teve_erro: bool = false
...
if ultima == ResultadoJogada.Tipo.ERRO:
    teve_erro = true
    erros_acoes += 1
...
if teve_erro:
    er += 1          # turnos com pelo menos um erro
```
Report both "turnos com erro" and "erros por turno". Then rerun the D-04 comparison in `01-SIMULACAO.md`.

## Warnings

### WR-01: With `silabas_por_turno > 1` there is no way to end the turn except trading the whole hand

**File:** `nucleo/partida.gd:124-125, 134-158`
**Issue:** After the first hit, the turn passes only when `jogadas_no_turno >= cfg.silabas_por_turno`. The only actions are `jogar_silaba` and `trocar_mao`. A player who scores once and has no second match must trade the whole hand (D-03 `cartas_por_troca=0`), or deliberately make a mistake, to give up the turn. The `silabas_por_turno` lever is exposed in `ConfigRegras` (clamped 1..5) and in `--set`, so any simulation run with it measures a rule that penalises players for scoring. `test_duas_silabas_por_turno` covers only the case where the player has two matches.
**Fix:** Add `func encerrar_turno() -> ResultadoJogada.Tipo` that is valid only when `jogadas_no_turno > 0` and calls `_passar_a_vez()`. Have `PerfilPerfeito`/`PerfilAprendiz` call it instead of `trocar` when `jogadas_no_turno > 0` and no match exists.

### WR-02: A trade can draw back the cards just returned, so it does not refresh the hand

**File:** `nucleo/partida.gd:153-155`
**Issue:** `trocar_mao` returns the cards to the deck, shuffles, and only then draws. When the deck is small (late game, low `proporcao_distratoras`, `tamanho_baralho_partida` cap), the player is likely to get the same cards back. When the deck is empty, the "trade" returns the identical hand, as `test_baralho_vazio_e_mao_vazia` line 179-182 itself documents. That wastes a turn and inflates the "sem ponto"/"troca" numbers the calibration (D-18/D-22) relies on. The usual physical-game rule is to draw first and then return the discarded cards.
**Fix:** Draw the replacements before returning the discarded cards:
```gdscript
var novas := baralho.comprar(devolvidas.size())
jog.mao.append_array(novas)
baralho.devolver(devolvidas)
baralho.embaralhar(rng)
_repor(jog)  # caso o baralho tenha tido menos cartas
```
This is a rule change, so confirm it with the team and rerun the simulator.

### WR-03: Android preset excludes `armeabi-v7a`

**File:** `export_presets.cfg:63`
**Issue:** `architectures/armeabi-v7a=false`. CLAUDE.md ("Stack Patterns by Variant") prescribes checking `armeabi-v7a` in addition to `arm64-v8a` because many old entry-level devices, the likely school/family hardware, cannot run 64-bit binaries. On those devices the APK will fail to install.
**Fix:** Set `architectures/armeabi-v7a=true`.

### WR-04: Exports ship tests, simulator and the GUT addon

**File:** `export_presets.cfg:9-11, 44-46`
**Issue:** Both presets use `export_filter="all_resources"` with an empty `exclude_filter`. `testes/`, `simulador/` and `addons/gut/` (including its editor plugin scripts) are packed into the APK and EXE. This bloats a child-facing build, ships dev-only code paths such as `simular.gd`, which writes files and calls `quit()`, and risks export errors from editor-only GUT scripts.
**Fix:** `exclude_filter="testes/*, simulador/*, addons/gut/*"` in both presets.

### WR-05: D-18 and D-19 report PASS vacuously when no match finishes

**File:** `simulador/simulacao.gd:116-134`, `simulador/relatorio.gd:36-49`
**Issue:** When every match hits the action limit, `terminadas == 0`. Because `tt` and `term` are clamped to 1, `pct_turnos_sem_ponto = 0/1 = 0` and `pct_partidas_mago_zerado = 0/1 = 0`, so both D-18 and D-19 print "PASS" for a configuration where nobody ever opened the vault. `metas_ok` is still false because of D-20, but the per-goal lines are misleading.
**Fix:** If `r["terminadas"] == 0`, mark D-18 and D-19 as `ok: false` with the description "sem partidas terminadas". Alternatively, return `NAN` and treat it as a failure in `avaliar_metas`.

### WR-06: Per-word stats mix in aborted matches while every other metric excludes them

**File:** `simulador/simulacao.gd:33-36, 63-70, 86-87`
**Issue:** `aparicoes`, `soma_turnos` and `completadas` are updated during the match, before the `if estourou: continue` filter. Every other metric counts only finished matches. "Impacto por palavra" (D-14) can therefore include words from matches that ran thousands of actions, which skews `turnos_ate_completar_media`. It also makes `aparicoes` disagree with `terminadas * quantidade_senhas`.
**Fix:** Collect per-word data in a local dictionary per match and merge it into `palavras` only after the `estourou` check.

### WR-07: `Partida` and the initial scene mutate the shared, cached `ConfigRegras`

**File:** `nucleo/partida.gd:29-30`, `cenas/inicial/inicial.gd:11-12`
**Issue:** `Partida._init` calls `cfg.normalizar()` on the caller's object. Any `ConfigRegras` obtained with `load("res://dados/regras_padrao.tres")` is the ResourceLoader-cached instance, so normalising it silently rewrites the in-memory resource for every other user. In the editor, it can also be saved back clamped. `inicial.gd` does the same. `simular.gd:56` correctly uses `duplicate()`, which shows the intended pattern. `test_normaliza_config` asserts the mutation (`assert_eq(_cfg.tamanho_mao, 10)`), which locks in the side effect.
**Fix:** In `Partida._init`, use `cfg = p_cfg.duplicate() as ConfigRegras; cfg.normalizar()`. Do the same in `inicial.gd`, and update the test to assert on `p.cfg`.

### WR-08: Tests that do not verify what their names claim

**File:** `testes/unit/test_partida_turnos.gd:57-63, 93-112`
**Issue:**
- `test_acerto_em_qualquer_espaco_com_mesma_silaba` plays word 1, slot 0 with that slot's own syllable. It is a second copy of `test_acerto`. The comment "Forca a palavra 1 a ter a mesma silaba" is false, and nothing tests a duplicated syllable across slots (e.g. TATU's TA/TU, PIPA's PI/PA, or PATO+PATA sharing PA).
- In `test_invalido_nao_altera_estado`, the final check `assert_eq(mao.size(), _cfg.tamanho_mao)` asserts on the copy taken before the calls, so it can never fail. The five INVALIDO calls on lines 97-101 are never checked for leaving the hand, `turnos_jogados` or `jogador_atual` unchanged.
- `_dar_carta` overwrites `mao[0]` with an arbitrary syllable without removing it from the deck, so `invariantes_ok()` in those tests runs on artificially inflated circulation.

**Fix:** Build a match with two open slots that share a syllable (inject `DadosPalavra` such as PIPA and PATA) and assert that either slot accepts it. In the invalid-move test, compare `p.jogadores[0].mao` with `mao` right after lines 97-101 and assert `turnos_jogados`/`jogador_atual` there. In `_dar_carta`, swap the card with one taken from `p.baralho.cartas` so the totals stay real.

## Info

### IN-01: `limite_turnos_partida` counts actions, not turns, and invalid moves are reported as overflow

**File:** `simulador/simulacao.gd:16, 52-54, 71-73`
**Issue:** The limit is compared against `acoes`. When `erro_passa_a_vez=false`, actions greatly exceed turns. If a bot returns an invalid move (`INVALIDO`), the match is silently counted as "not finished", indistinguishable from a real livelock.
**Fix:** Rename the setting to `limite_acoes_partida` (or count turns). Track `invalidas` separately and report it, or fail loudly.

### IN-02: `semente` comment says "0 = aleatoria", but the simulator uses a fixed seed; `mostrar_palavra_escrita` is unused

**File:** `dados/tipos/config_regras.gd:16, 19-20`, `simulador/simular.gd:95-98`
**Issue:** The documented meaning of `semente=0` does not match the only consumer, which substitutes 12345. `mostrar_palavra_escrita` is not read anywhere.
**Fix:** Correct the comment (e.g. "0 = padrao do consumidor"), or implement real randomness. Mark `mostrar_palavra_escrita` as reserved for the UI phase.

### IN-03: The PowerShell runners change the caller's working directory and ignore import failures

**File:** `testes/rodar.ps1:4-5`, `simulador/simular.ps1:5-6`
**Issue:** `Set-Location` inside a script persists in the calling PowerShell session. The output of `--import` is discarded and its exit code is never checked.
**Fix:** Use `Push-Location $raiz` and `try { ... } finally { Pop-Location }`. Check `$LASTEXITCODE` after `--import`.

### IN-04: Debug `print` and an unchecked `load` in the shipped main scene

**File:** `cenas/inicial/inicial.gd:11-14`
**Issue:** `print("COFRE_MAGICO_INICIAL ...")` is a smoke-test artifact in the main scene. If the `load(...) as ConfigRegras` call returns null, the next line crashes with a null dereference.
**Fix:** Guard with `if regras == null: push_error(...); return`. Drop the print, or keep it behind `OS.is_debug_build()`.

### IN-05: `Partida` does not validate word count or syllable supply

**File:** `nucleo/partida.gd:39-44`
**Issue:** If the library has fewer words than `quantidade_senhas`, the match silently starts with fewer passwords. With zero words, `concluida()` is immediately true. Nothing checks that the drawn words' syllable demand is ≤ `dist.copias_de`. The current content is safe because every syllable's total demand across all 30 words fits, but an edit to the `.tres` files could create unwinnable matches that the UI would never end.
**Fix:** In `_init`, call `push_error`/`assert` when `sorteadas.size() < cfg.quantidade_senhas` or when demand exceeds copies.

### IN-06: `pontos_medios_por_mago` divides by the requested `n_magos`, not the actual player count

**File:** `simulador/simulacao.gd:134`
**Issue:** `Partida` clamps the player count to 1..4, but the average divides by the raw argument. A caller passing 0 or 9 gets wrong numbers. The `turnos_por_mago` line already uses `partida.jogadores.size()`.
**Fix:** Clamp `n_magos` at the top of `rodar`, or divide by the actual player count.

### IN-07: `simular.gd` silently clamps arguments and writes to any path

**File:** `simulador/simular.gd:35, 40, 109`
**Issue:** `--partidas=0` becomes 1 and `--semente=-5` becomes 0 (which then becomes 12345), with no message. `--saida` accepts any absolute path. This is acceptable for a dev tool, but surprising.
**Fix:** Reject out-of-range values with `_falhar`, and document that `--saida` overwrites without asking.

---

_Reviewed: 2026-11-17T15:25:32Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
