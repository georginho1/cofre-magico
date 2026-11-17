---
phase: 01-funda-o-regras-e-simulador
verified: 2026-11-17T18:00:00Z
status: human_needed
score: 4/5 must-haves verified (1 pendente de aparelho fisico)
overrides_applied: 0
human_verification:
  - test: "Instalar build/android/CofreMagico.apk (preset arm64-v8a) em um aparelho Android fisico e abrir a cena inicial"
    expected: "O app abre em paisagem e mostra a cena inicial (esqueleto) sem travar"
    why_human: "Nao ha aparelho fisico. A verificacao foi feita apenas em emulador x86_64 (API 35) com um APK x86_64 exportado a parte; o APK arm64 entregue nunca rodou em hardware real. FUND-02 segue desmarcado em REQUIREMENTS.md."
---

# Fase 1: Verificacao

**Objetivo:** Projeto rodando em Android real e no PC; partida inteira jogada pelo nucleo sem tela; regras medidas e ajustadas por simulacao.
**Status:** human_needed (nenhuma falha encontrada; so a checagem em aparelho real esta aberta)

## Verdades observaveis

| # | Verdade | Status | Evidencia |
|---|---------|--------|-----------|
| 1 | Projeto abre no Godot 4.7.2, Compatibility, 1280x720, paisagem, e roda no PC | VERIFICADO | project.godot: viewport 1280x720, stretch canvas_items/expand, orientation=4, gl_compatibility. Usuario confirmou o build de PC. Existe build/windows/CofreMagico.exe. |
| 2 | APK instalado e executado em aparelho Android real | INCERTO (WARNING) | build/android/CofreMagico.apk existe. Rodou so em emulador x86_64 (APK separado). Sem hardware fisico. Dispensado pelo usuario na aprovacao do 01-08, mas nao comprovado. |
| 3 | Dados de conteudo: 30 palavras com silabas explicitas e ilustracao; 100 cartas / 22 silabas | VERIFICADO | biblioteca_palavras.tres tem 30 entradas com silabas e `imagem` (placeholder; ilustracoes reais sao CONT-03, Fase 3). distribuicao_baralho.tres presente. testes test_conteudo passam. |
| 4 | Partida completa pelo nucleo sem tela (sorteio de 4 senhas, recorte do baralho, maos, jogada valida/invalida sem punicao, compra/troca, rodizio de vez, sempre concluivel) | VERIFICADO | nucleo/ tem baralho, partida, jogador, palavra_senha, resultado_jogada (RefCounted). GUT: 60/60 testes, 850 asserts, executado por mim via testes/rodar.ps1. Simulador roda partidas completas (100% terminam). Sem marcadores TODO/FIXME/TBD no codigo. |
| 5 | Regras ajustaveis sem alterar codigo e medidas por simulador sem interface | VERIFICADO | dados/regras_padrao.tres (ConfigRegras) com todos os parametros. simulador/simular.ps1 executado e produziu relatorio. 01-SIMULACAO.md documenta a varredura e a escolha proporcao_distratoras=0.40 (D-18 PASS para 2-4 magos, D-19 e D-20 PASS), aprovada pela equipe, com atualizacao apos revisao de codigo. |

**Pontuacao:** 4/5 verificadas; 1 incerta (aparelho fisico).

## Cobertura de requisitos

Todos os 16 IDs dos PLANs aparecem em REQUIREMENTS.md e na tabela de rastreio. Nenhum requisito orfao da Fase 1 (PART-01 e CONT-03/04 pertencem as Fases 2 e 3).

| Requisito | Plano | Status | Evidencia |
|-----------|-------|--------|-----------|
| FUND-01 | 01-01 | SATISFEITO | project.godot, cena inicial, build PC confirmado |
| FUND-02 | 01-02 | NECESSITA HUMANO | so emulador; checkbox corretamente desmarcado |
| FUND-03 | 01-01 | SATISFEITO | build/windows/CofreMagico.exe, executado pelo usuario |
| FUND-04 | 01-03 | SATISFEITO | testes/rodar.ps1: 60/60 |
| CONT-01 | 01-04 | SATISFEITO | 30 palavras com silabas e imagem (placeholder) |
| CONT-02 | 01-04 | SATISFEITO | distribuicao_baralho.tres, test_conteudo |
| PART-02..04 | 01-05 | SATISFEITO | test_partida_sorteio, test_baralho |
| PART-05..08 | 01-06 | SATISFEITO | test_partida_turnos |
| PART-09 | 01-06, 01-08 | SATISFEITO | 100% das partidas simuladas terminam |
| PART-10 | varios | SATISFEITO | regras_padrao.tres, test_config |
| PART-11 | 01-07, 01-08 | SATISFEITO | simulador/simular.ps1 executado |

## Anti-padroes

Nenhum TODO/FIXME/TBD em nucleo, simulador, cenas ou dados. Itens da revisao: WR-01 e WR-03 foram pulados como decisoes de equipe/design (registrados em 01-REVIEW-FIX.md); WR-02 aprovado pela equipe em 2026-11-17. Sem bloqueadores.

## Verificacao humana necessaria

1. **APK em aparelho Android fisico.** Instalar build/android/CofreMagico.apk (arm64-v8a), abrir e confirmar que a cena inicial aparece em paisagem. Motivo: so houve teste em emulador x86_64 com APK distinto. Ao confirmar, marcar FUND-02 em REQUIREMENTS.md.

## Resumo

Nao ha lacunas de codigo. Nucleo, dados, testes e simulador estao implementados e funcionando (testes re-executados: 60/60; simulador re-executado). A unica pendencia e a execucao em hardware Android real, que o usuario dispensou por ora e que permanece registrada como item humano, nao como sucesso.

_Verificador: Claude (gsd-verifier)_
