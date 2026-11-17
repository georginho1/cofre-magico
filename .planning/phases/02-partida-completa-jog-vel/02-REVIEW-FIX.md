---
phase: 02-partida-completa-jog-vel
fixed_at: 2026-11-17T00:00:00Z
review_path: .planning/phases/02-partida-completa-jog-vel/02-REVIEW.md
iteration: 1
findings_in_scope: 4
fixed: 4
skipped: 0
status: all_fixed
---

# Phase 02: Code Review Fix Report

**Source review:** .planning/phases/02-partida-completa-jog-vel/02-REVIEW.md
**Suite:** `testes/rodar.ps1` passou (92 testes) apos cada correcao.

## Fixed Issues

### WR-01: FluxoMesa.proxima_etapa ignora se a vez realmente passou
**Files modified:** `cenas/comum/fluxo_mesa.gd`, `cenas/mesa/mesa.gd`, `testes/unit/test_fluxo_mesa.gd`
**Commit:** c289176
**Applied fix:** novo parametro `vez_passou`; retorna NADA quando a vez nao passou. A mesa calcula `vez_passou` comparando `turnos_jogados` antes/depois (funciona tambem com 1 mago) e reconstroi a mao no ramo NADA. Testes novos: ACERTO sem passar, ERRO sem passar, ACERTO concluido sem passar (COFRE). Requer verificacao humana (logica).

### WR-02: Voltar/Esc na tela de erro da mesa
**Files modified:** `cenas/mesa/mesa.gd`
**Commit:** e7f0798
**Applied fix:** `ao_voltar` vai direto ao menu quando `_partida == null`.

### WR-03: Animacao de troca pode travar com mao vazia
**Files modified:** `cenas/mesa/mesa.gd`
**Commit:** 1058696
**Applied fix:** tween so e criado se ha cartas; resultado INVALIDO de `trocar_mao()` reconstroi a mao e libera `_ocupado`. Requer verificacao humana (logica).

### WR-04: Falha em nova_partida
**Files modified:** `sessao.gd`, `cenas/final/final.gd`, `cenas/selecao/selecao.gd`
**Commit:** 3c83930
**Applied fix:** `nova_partida() -> bool`, `partida = null` no inicio/falha; chamadores vao ao menu em falha; `id_do_indice` checa limites (push_error e retorna 0).

## Skipped Issues

None in scope. IN-01 e IN-02 fora do escopo (critical_warning).

---

_Fixer: Claude (gsd-code-fixer)_
