---
phase: 02-partida-completa-jog-vel
depth: standard
files_reviewed: 26
findings:
  critical: 0
  warning: 4
  info: 2
  total: 6
status: issues_found
---

# Fase 02 — Code Review

Revisados em profundidade: mesa.gd, fluxo_mesa.gd, sessao.gd, cofre.gd, final.gd, selecao.gd, painel_pausa.gd, faixa_vez.gd, senha_visual.gd, magos.gd, menu.gd (e regras em nucleo/partida.gd). Cenas .tscn e a maior parte dos testes não foram lidos em detalhe.

## Critical

Nenhum.

## Warnings

### WR-01: FluxoMesa.proxima_etapa ignora se a vez realmente passou
**Arquivo:** `cenas/comum/fluxo_mesa.gd:8-13` (usado em `cenas/mesa/mesa.gd:220`)
**Problema:** Todo resultado que não é INVALIDO nem conclusão vira FAIXA_VEZ. Com `silabas_por_turno > 1` (ACERTO que não encerra o turno) ou `erro_passa_a_vez = false` (ERRO), a faixa "Vez do Mago X" aparece para o mesmo mago e a mão é refeita. Com a config padrão não aparece. O teste `test_fluxo_mesa.gd` codifica o comportamento errado.
**Correção:** Passar `vez_passou: bool` (comparar `jogador_atual` antes/depois) e retornar NADA quando a vez não passou; ajustar testes.

### WR-02: Voltar/Esc na tela de erro da mesa abre pausa cujo "Sair" não faz nada
**Arquivo:** `cenas/mesa/mesa.gd:33-40, 54, 133-137`
**Problema:** Com `Sessao.partida == null`, `_ready` retorna antes de conectar os sinais do painel; `ao_voltar()` ainda abre o painel, e "Sair" não tem ouvinte.
**Correção:** Em `ao_voltar`, `if _partida == null: Sessao.ir_para(Sessao.CENA_MENU); return`.

### WR-03: Animação de troca pode travar com mão vazia
**Arquivo:** `cenas/mesa/mesa.gd:274-293`
**Problema:** Tween sem tweeners quando `_cartas` está vazio — `await tw.finished` pode não resolver, deixando `_ocupado` e o Bloqueio ativos. Resultado de `trocar_mao()` (INVALIDO) é ignorado.
**Correção:** Pular o tween se a mão estiver vazia; tratar INVALIDO liberando `_ocupado`.

### WR-04: Falha em nova_partida deixa partida obsoleta/nula e o chamador segue
**Arquivo:** `sessao.gd:27-40`; chamadores `cenas/final/final.gd:51-53`, `cenas/selecao/selecao.gd:59-62`
**Problema:** Em falha de carga, `nova_partida` só faz `push_error`; "Jogar de novo" abre a partida já concluída; `magos_ativos` vazio pode estourar índice em `id_do_indice`.
**Correção:** `nova_partida() -> bool`, `partida = null` em falha, chamadores voltam ao menu; checar limites em `id_do_indice`.

## Info

### IN-01: Tweens concorrentes na mesma propriedade
**Arquivo:** `cenas/mesa/mesa.gd:171-173`, `86-89`
**Problema:** `_elevar` cria Tween novo em `position:y` a cada toque sem matar o anterior; fade-in da mão não é guardado.
**Correção:** Um Tween por carta, matando o anterior.

### IN-02: Overrides de cor de fonte não são limpos ao reabrir espaço
**Arquivo:** `cenas/comum/senha_visual.gd:109-116`
**Problema:** `_desenhar_aberto` não remove os overrides `font_*` de `_desenhar_preenchido`. Inofensivo hoje.
**Correção:** Remover overrides de fonte em `_desenhar_aberto`.

_Reviewer: Claude (gsd-code-reviewer), depth: standard_
