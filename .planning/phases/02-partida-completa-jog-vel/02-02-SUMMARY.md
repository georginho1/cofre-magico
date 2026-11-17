---
phase: 02-partida-completa-jog-vel
plan: 02
subsystem: ui
tags: [godot, gdscript, mesa, cartas, tween]
requires: [02-01]
provides:
  - FluxoMesa.proxima_etapa
  - SenhaVisual (cartao de senha reutilizavel, modo compacto)
  - FaixaVez (passagem de vez)
  - Cena Mesa jogavel (dois toques, acerto, erro, troca)
affects: [02-03, 02-04]
tech-stack:
  added: []
  patterns: [fantasma de carta na CamadaFantasma, flag _ocupado + overlay Bloqueio, lambda por senha para conectar sinais]
key-files:
  created: [cenas/comum/fluxo_mesa.gd, cenas/comum/senha_visual.gd, cenas/comum/senha_visual.tscn, cenas/mesa/faixa_vez.gd, cenas/mesa/faixa_vez.tscn, cenas/mesa/mesa.gd, cenas/mesa/mesa.tscn, testes/unit/test_fluxo_mesa.gd, testes/unit/test_mesa.gd]
  modified: []
key-decisions:
  - "Pulso de escala do espaco aceito vive em SenhaVisual.marcar_aceito (a mesa so aguarda 0,2 s antes de checar completa())"
  - "Estilos de espaco preenchido/destacado e bordas da faixa via StyleBoxFlat override (excecao ao Theme: cor depende do mago)"
requirements-completed: [MESA-01, MESA-02, MESA-03, MESA-04, MESA-05, MESA-08, MESA-09]
duration: 25min
completed: 2026-11-17
---

# Phase 2 Plan 02: Mesa jogavel Summary

Mesa com faixa "Vez do Mago X", mao so do mago da vez, jogo em dois toques, acerto marcado com cor e simbolo do autor, erro sem feedback de punicao e troca de cartas, tudo sobre Partida sem regra nova na interface.

## Commits
- 0a39745: FluxoMesa e SenhaVisual
- 75246ae: faixa de vez e cena da mesa
- 561dff1: mesa.gd e test_mesa

## Deviations from Plan
None - plan executed as written. Detalhes de implementacao: o handler `_ao_tocar_espaco(p, e)` e conectado por lambda (em vez de bind) para manter a ordem dos argumentos; `mouse_filter = 0` foi gravado explicitamente em faixa_vez.tscn para atender ao criterio de aceite.

## Verification
Suite GUT completa: 75 testes passam (inclui test_fluxo_mesa com 5 e test_mesa com 5). Verificacao visual em 16:9/20:9/4:3 nao foi feita (headless); orcamento de layout segue o plano (1208x680).

## Known Stubs
Ilustracao das senhas usa placeholder_palavra.svg com o nome da palavra (D-12, previsto). Pausa, icones de ponto (plano 02-03) e cenas COFRE/FINAL (plano 02-04) ainda nao existem; Sessao.ir_para(CENA_COFRE) aponta para cena futura.

## Self-Check: PASSED
