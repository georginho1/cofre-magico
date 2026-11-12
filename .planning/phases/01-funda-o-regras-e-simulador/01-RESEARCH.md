# Phase 1: Fundação, regras e simulador - Research

**Researched:** 2026-11-12
**Domain:** Godot 4.7.2 / GDScript — bootstrap de projeto, exportação Android+Windows, núcleo de regras `RefCounted`, testes GUT, simulador headless
**Confidence:** MEDIUM-HIGH (docs oficiais conferidas hoje; opções de preset Android e comportamento de `-s` headless não conferidos em editor)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
Todos os valores numéricos abaixo são valores **iniciais** e devem existir como parâmetros no arquivo de configuração (PART-10), não como constantes no código.

- **D-01:** Cada mago tem mão de **5 cartas**.
- **D-02:** O mago coloca **no máximo uma sílaba por turno**. Um acerto encerra o turno.
- **D-03:** O botão comprar/trocar **troca a mão inteira**: as 5 cartas voltam ao baralho da partida, o baralho é reembaralhado e o mago compra 5 novas. Não há seleção de cartas individuais.
- **D-04:** Tentativa em espaço errado: a carta **volta para a mão e a vez passa** para o próximo mago. Não há marcação de erro, contador nem perda de carta. (Parametrizar: `erro_passa_a_vez` ou equivalente; efeito deve aparecer no relatório do perfil aprendiz.)
- **D-05 (suposição aceita):** Após um acerto, o mago compra até voltar ao tamanho da mão (5).
- **D-06 (suposição aceita):** A troca de mão encerra o turno e é permitida mesmo quando o mago tem jogada.
- **D-07:** O baralho da partida contém **sílabas úteis e distratoras**.
- **D-08:** Sílabas úteis entram com **todas as cópias do baralho físico**.
- **D-09:** Proporção inicial de distratoras: **cerca de metade** do baralho da partida (uma distratora para cada carta útil).
- **D-10:** As distratoras são **sorteadas entre as cartas das demais sílabas** do baralho de 100, respeitando a quantidade de cópias.
- **D-11:** Distribuição das mãos e compras são **sorteio puro**, sem garantia de carta útil.
- **D-12 (suposição aceita):** A carta colocada permanece na senha e sai de circulação; cartas trocadas voltam ao baralho e são reembaralhadas; se o baralho esvaziar, o mago fica com as cartas que tem. Nenhuma carta necessária pode ficar inalcançável (PART-09).
- **D-13:** **Sorteio puro** entre as 30 palavras (pares PATO+PATA, GATO+GATA podem sair juntos).
- **D-14:** **Nenhuma restrição** para palavras de 3 sílabas nem para sílabas de 2 cópias. O simulador deve reportar o impacto por palavra.
- **D-15:** **Sempre 4 senhas**, para 1 a 4 magos (parametrizado).
- **D-16 (suposição aceita):** Sem palavra repetida dentro da partida; sorteio com semente.
- **D-17:** Dois perfis simulados: **perfeito** (joga a sílaba certa sempre que tem; senão troca a mão) e **aprendiz** (erra o espaço com probabilidade configurável). Relatório mostra os dois.
- **D-18:** Meta de **turnos sem ponto ≤ 35%** (turnos que terminam em troca ou tentativa errada), perfil perfeito.
- **D-19:** Meta de **partidas em que um mago termina sem nenhuma sílaba ≤ 5%**, com 4 magos e perfil perfeito.
- **D-20:** 100% das partidas simuladas terminam, para 1, 2, 3 e 4 magos.
- **D-21:** Se a configuração inicial não cumprir as metas, a primeira alavanca é **reduzir a proporção de distratoras**. Mão e D-04 só depois, com aprovação da equipe.
- **D-22:** Valores finais registrados como decisão no PROJECT.md.

### Claude's Discretion
- Idioma dos identificadores (sugestão: português sem acento, arquivos em minúsculas) e convenção de pastas; fixar e registrar no CLAUDE.md.
- APK de depuração com debug keystore compartilhado fora do repositório; release só se sobrar tempo.
- Arquiteturas do preset Android (`arm64-v8a`, `armeabi-v7a` conforme aparelho).
- Formato do relatório do simulador e do arquivo de configuração (`.tres` de `ConfigRegras`).
- Número de partidas por configuração e taxa de erro padrão do perfil aprendiz.
- Duração da partida: só medir e reportar.

### Deferred Ideas (OUT OF SCOPE)
- Evitar repetir palavras da partida anterior.
- Distratoras por semelhança com as úteis.
- Restrições no sorteio (pares, limite de palavras difíceis).
- Garantia de carta útil na mão inicial ou em toda compra.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FUND-01 | Projeto 4.7.2 Compatibility 1280x720 paisagem roda no PC | Seção "Project settings"; criar projeto com renderer Compatibility |
| FUND-02 | APK em Android real | Seção "Exportação Android" + Environment Availability (SDK ausente) |
| FUND-03 | Executável PC | Seção "Exportação Windows" |
| FUND-04 | GUT com um comando | Seção "GUT" (`gut_cmdln.gd`, `.gutconfig.json`, wrapper) |
| CONT-01 | 30 palavras com sílabas explícitas + ilustração | "Dados" — tabela das 30 palavras abaixo; imagem provisória |
| CONT-02 | 100 cartas / 22 sílabas | Tabela verificada contra o PDF (100 total) |
| PART-02..09 | Sorteio, recorte, mãos, validação, devolução, troca, turno, término | "Núcleo `Partida`" + invariantes |
| PART-10 | Regras em arquivo de config | `ConfigRegras` `.tres` + override por argumento |
| PART-11 | Simulador sem interface | "Simulador headless" + resultados preliminares |
</phase_requirements>

## Summary

A fase tem três blocos independentes: (1) bootstrap + exportação (risco de ambiente, não de código), (2) dados + núcleo `RefCounted` + GUT, (3) simulador headless que fecha os parâmetros. A máquina atual **não tem Godot nem Android SDK instalados**, apenas JDK 21 e Python; portanto o primeiro plano é instalação e prova de ponta a ponta (APK vazio num aparelho). Os blocos 2 e 3 podem ser desenvolvidos em paralelo ao bloco 1 por outra pessoa, mas só rodam depois do Godot instalado.

O núcleo deve ser `RefCounted` puro com RNG injetado; os testes GUT e o simulador usam a **mesma API** (`Partida`). O simulador é um script `extends SceneTree` executado com `godot --headless -s` que lê `ConfigRegras` (por argumento de linha de comando), roda N partidas por nº de magos (1–4) e perfil (perfeito/aprendiz) e imprime um relatório (texto + CSV/JSON em `user://` ou stdout).

Fiz uma simulação rápida em Python (descartável, fora do repositório) das regras D-01..D-12 com perfil perfeito: com a configuração inicial (distratoras = 50%) os turnos sem ponto ficam em ~39% (1 mago), 36% (2), 33% (3), 31% (4) e mago sem sílaba em ~1,1% com 4 magos; 100% terminam. Ou seja, **a meta D-18 (≤35%) provavelmente falha com 1–2 magos e passa com 3–4 com o valor inicial**; reduzir distratoras para 25% dá 23–32%. O planejador deve definir de antemão com qual nº de magos D-18 é medida (ver Open Questions).

**Primary recommendation:** Plano 1 = instalar toolchain e provar APK vazio + exe PC; Plano 2 = dados + núcleo + GUT; Plano 3 = simulador + relatório + varredura de distratoras + registro no PROJECT.md.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Dados das palavras/cartas | Dados (Resources `.tres`) | — | Somente leitura, tipados |
| Regras de turno, validação, baralho | Núcleo (`RefCounted`) | — | Testável sem cena |
| Parâmetros de regra | Dados (`ConfigRegras.tres`) | — | PART-10 |
| Simulador | Ferramenta headless (`SceneTree` script) | Núcleo | Usa a API pública de `Partida` |
| Testes | GUT sobre o Núcleo | — | FUND-04 |
| Cena inicial | Apresentação (1 `Control` com Label) | — | Só prova de exportação |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Godot (padrão, sem .NET) | 4.7.2-stable | Motor/editor/export | Decisão do projeto [CITED: CLAUDE.md, godotengine.org/download/archive] |
| GDScript tipado | 4.7 | Toda a lógica | Decisão do projeto |
| GUT | 9.7.1 | Testes | 9.7.0 declara "Compatibility changes for Godot 4.7"; 9.7.1 é a mais nova [VERIFIED: github.com/bitwes/Gut/releases]. Atenção: a página marca 9.6.1 como "Latest", mas 9.7.x é a linha da 4.7. 9.7.0 avisa que a 4.7 tem checagem de tipo de retorno mais restritiva (doubles podem falhar) — evitar doubles |
| OpenJDK | 17 recomendado; 21 presente na máquina | Assinar APK | Docs: versões maiores são suportadas, 17 recomendada [CITED: docs.godotengine.org exporting_for_android] |
| Android SDK | platform-tools ≥35.0.0, build-tools 35.0.1, platforms;android-35, cmdline-tools latest, cmake 3.10.2.4988404, NDK 28.1.13356709 | Export APK | [CITED: docs 4.7] |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| GUT | gdUnit4 | Decisão do projeto é GUT; não reabrir |
| JDK 21 existente | instalar Temurin 17 | 21 "deve funcionar" segundo a doc; só instalar 17 se o export falhar |

**Installation (GUT):** AssetLib do editor ou copiar `addons/gut` do release 9.7.1 do GitHub; ativar em Project Settings > Plugins. Não há pacote npm/pip nesta fase, portanto não há auditoria slopcheck.

## Package Legitimacy Audit

Nenhum pacote npm/PyPI/crates é instalado. GUT vem do repositório GitHub oficial `bitwes/Gut` (listado na CLAUDE.md). Baixar o zip do release (ou AssetLib) e conferir que o `plugin.cfg` indica versão 9.7.x. **Packages removed:** nenhum. **Flagged [SUS]:** nenhum. slopcheck não aplicável.

## Architecture Patterns

### Fluxo de dados (Fase 1, sem tela)

```
ConfigRegras.tres ─┐  (--config=... no simulador; padrão no teste)
biblioteca_palavras.tres ─┼─> Partida.new(config, biblioteca, distribuicao, n_magos, rng)
distribuicao_baralho.tres ┘        │ sorteia 4 palavras (rng, sem repetir)
                                   │ monta baralho: úteis (todas cópias) + distratoras (D-09/D-10), embaralha
                                   │ distribui mãos (tamanho_mao)
        ┌──────────────────────────┴───────────────────────┐
  testes GUT chamam                                simulador (SceneTree script)
  jogar_silaba / trocar_mao                        loop: perfil.decidir(partida) -> ação
        └──────────────────────────┬───────────────────────┘
                              resultado + sinais/estado
                                   │
                    Relatório: turnos sem ponto, duração, mago sem ponto,
                    impacto por palavra, perfeito vs aprendiz
```

### Estrutura recomendada (fixar e registrar em CLAUDE.md)
```
res://
├── project.godot
├── .gutconfig.json
├── nucleo/            # partida.gd baralho.gd jogador.gd palavra_senha.gd resultado_jogada.gd
├── dados/tipos/       # dados_palavra.gd biblioteca_palavras.gd distribuicao_baralho.gd config_regras.gd
├── dados/             # biblioteca_palavras.tres distribuicao_baralho.tres regras_padrao.tres (+ variantes)
├── simulador/         # simular.gd perfis.gd relatorio.gd
├── testes/unit/       # test_*.gd
├── cenas/inicial/     # inicial.tscn (+ .gd)
├── arte/provisoria/   # placeholders
└── addons/gut/
```
Decisão: pasta de testes `res://testes/unit` (alinha com ARCHITECTURE.md; CLAUDE.md citou `res://test` só como exemplo). Arquivo de créditos `CREDITOS.md` na raiz (a fase 3 o usa).

### Pattern 1: Resources de dados, mutável só em objetos de partida
`DadosPalavra { texto, silabas: PackedStringArray, imagem: Texture2D }` (imagem pode ser `null`/placeholder na Fase 1; CONT-01 exige a *existência* da referência, ilustração definitiva é Fase 3). `DistribuicaoBaralho { copias: Dictionary[String,int] }` (tipado, sem aninhar — suportado [CITED: docs static_typing]). `load()` devolve instância em cache: nunca mutar.

### Pattern 2: `ConfigRegras` com todas as alavancas (PART-10)
Campos mínimos (nomes sugeridos, pt sem acento):
`tamanho_mao=5`, `silabas_por_turno=1`, `troca_mao_inteira=true`, `troca_encerra_turno=true`, `erro_passa_a_vez=true`, `repor_mao_apos_acerto=true`, `quantidade_senhas=4`, `proporcao_distratoras=1.0` (distratoras por carta útil; 1.0 = metade do baralho), `tamanho_baralho_partida=0` (0 = derivado; >0 = teto), `semente=0` (0=aleatória), `mostrar_palavra_escrita=false` (PART-10 lista "palavra escrita"; só é lido na Fase 2), `taxa_erro_aprendiz=0.3`. Arquivo `.tres` é texto: a equipe edita a linha e roda de novo (critério 4).

### Pattern 3: API de `Partida` (mesma para teste, simulador e Mesa da Fase 2)
```gdscript
# Source: padrão de ARCHITECTURE.md (adaptado); não executado
class_name Partida extends RefCounted
signal silaba_aceita(jogador: int, palavra: int, espaco: int, silaba: String)
signal jogada_recusada(jogador: int)
signal mao_trocada(jogador: int)
signal turno_iniciado(jogador: int)
signal cofre_aberto()
func _init(cfg: ConfigRegras, bib: BibliotecaPalavras, dist: DistribuicaoBaralho,
		n_magos: int, rng: RandomNumberGenerator) -> void: pass
func jogar_silaba(indice_carta: int, palavra: int, espaco: int) -> int: return 0  # ResultadoJogada
func trocar_mao() -> int: return 0
func existe_jogada() -> bool: return false     # base do "turno sem ponto" e de PART-09
func concluida() -> bool: return false
```
`jogar_silaba` correta: consome a carta, preenche, `jogador.pontos += 1`, repõe a mão, passa a vez. Errada: estado inalterado, `jogada_recusada`, vez passa se `erro_passa_a_vez`. Validação: `mao[indice] == palavra.silabas[espaco]` e espaço vazio. Erros nunca incrementam contador (restrição ética).

### Pattern 4: Recorte do baralho (PART-03, D-07..D-10)
1. `uteis` = conjunto de sílabas dos 4 senhas; cartas úteis = todas as cópias de cada (soma de `copias[s]`).
2. `n_distr = round(len(uteis_cartas) * proporcao_distratoras)`; `pool` = cartas das demais sílabas (com cópias) embaralhado com o RNG; pegar `n_distr` (limitar ao tamanho do pool).
3. Embaralhar baralho com o RNG injetado (`Array.shuffle()` usa RNG global — **implementar Fisher-Yates com `rng.randi_range`** para reprodutibilidade).
4. Invariante D-12/PART-09: contagem total de cartas (baralho + mãos + colocadas) é constante; trocar mão devolve as cartas ao baralho antes de reembaralhar.

### Anti-Patterns to Avoid
- `Array.shuffle()`/`randi()` globais no núcleo (não reproduzível).
- Cortar string da palavra em pares de letras (usar `silabas` explícitas).
- Constantes de regra no código; `Node`/`await`/`Timer` em `nucleo/`.
- Depender de autoload no simulador (ver Pitfall 2).

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Runner de testes | script próprio de asserts | GUT 9.7.1 `gut_cmdln.gd` | Exit code 0/1 já documentado |
| Parse de config | parser de INI/JSON próprio | `ConfigRegras extends Resource` `.tres` | Tipado, versionável |
| Parse de argumentos | regex manual | `OS.get_cmdline_user_args()` após `--` | [CITED: docs command_line_tutorial] |
| Embaralhar | `shuffle()` global | Fisher-Yates com `RandomNumberGenerator` injetado | Semente determinística |
| Assinatura APK | keytool/jarsigner manual | export do Godot com debug keystore | Padrão |

## Runtime State Inventory
Não é fase de rename/migração — seção omitida.

## Common Pitfalls

### Pitfall 1: Cache de classes globais em clone novo / CI
**What goes wrong:** `class_name` não resolve ao rodar `godot --headless -s ...` ou GUT num checkout limpo (sem `.godot/`, que está no `.gitignore`).
**How to avoid:** o comando único de teste deve rodar antes `godot --headless --import --path .` (doc: `--import` abre o editor, importa e sai [CITED: command_line_tutorial]). [ASSUMED] que o cache `global_script_class_cache.cfg` é gerado nesse passo — validar na primeira execução. Encapsular em `testes/rodar.ps1`/`rodar.sh` (o "único comando").

### Pitfall 2: Autoloads e `-s`
Em scripts `extends SceneTree` passados por `-s`, o acesso a autoloads pelo nome global é pouco confiável [ASSUMED]. O núcleo e o simulador não usam autoloads (`Sessao` só existe na Fase 2).

### Pitfall 3: Saída e código de retorno do simulador
Use `quit(codigo)` no `_initialize()`/`_process`; `--headless` desliga janela e áudio [CITED]. Sem `--quit`, o processo não termina. Escrever relatório com `print()`/`FileAccess` em `user://` ou caminho absoluto de `ProjectSettings.globalize_path`. Um laço de milhares de partidas em GDScript é rápido o bastante (centenas de milhares de operações simples), mas limitar turnos por partida (ex. 5000) como guarda contra laço infinito e contar como "não terminou".

### Pitfall 4: Meta mal definida (D-18)
"Turnos sem ponto" = turnos que terminam em troca ou erro. A meta de 35% é medida com perfil perfeito; defina no relatório o nº de magos (ver Open Questions). Calcule também a média sobre 1–4.

### Pitfall 5: Deck vazio / mão incompleta
Com poucos distratores o baralho pode esvaziar e a troca de mão devolve cartas, mas se baralho < tamanho_mao o mago compra menos. Teste explícito (D-12). Também: carta útil duplicada na mão do mesmo mago contra espaços já preenchidos (cartas "mortas") — o `existe_jogada()` deve olhar apenas espaços abertos.

### Pitfall 6: Export Android
- Instalar o *mesmo* build de export templates 4.7.2 (Editor > Manage Export Templates) [CITED: CLAUDE.md].
- "Could not install to device": desinstalar o app com o mesmo pacote assinado por outra chave [CITED: docs]. Por isso **um debug keystore compartilhado** (variáveis `GODOT_ANDROID_KEYSTORE_DEBUG_PATH/USER/PASSWORD` ou campos `keystore/debug*` do preset) [CITED: docs + class reference]; guardar fora do repo.
- Não habilitar Gradle; manter `permissions/internet` desligado [CITED: propriedade existe; default não confirmado].
- Opções `architectures/arm64-v8a`, `armeabi-v7a` existem no preset [CITED: class_editorexportplatformandroid]; defaults e min SDK **não** estão na doc lida — conferir no editor (STATE.md já lista). Aparelho com ≥2017 normalmente é arm64 [ASSUMED]; marcar `armeabi-v7a` só se `adb shell getprop ro.product.cpu.abi` indicar 32-bit.
- `export_presets.cfg` deve ser versionado; senhas do keystore não (preset pode gravá-las em `.godot/export_credentials.cfg`, ignorado) [ASSUMED].
- Ativar "Opções do desenvolvedor > Depuração USB" no aparelho e usar o botão de deploy remoto (Android) do editor [ASSUMED: não coberto pela doc de export].

### Pitfall 7: Windows
Export Windows Desktop x86_64 (padrão); gera `.exe` + `.pck` — para um único arquivo habilitar a opção "Embed PCK" no preset (nome exato a confirmar no editor; a doc lida só cita o limite de 3,89 GB) [CITED: exporting_for_windows]. Ícone vem do `application/config/icon`.

## Code Examples

### Comando único de testes (padrão a encapsular)
```
godot --headless --import --path .
godot --headless -s addons/gut/gut_cmdln.gd --path . -gdir=res://testes/unit -ginclude_subdirs -gexit
```
Source: GUT docs (gut.readthedocs.io Command-Line): forma `godot -s addons/gut/gut_cmdln.gd -d --path "$PWD"`; exit 0 = tudo passou, 1 = falha. `-gexit` sai ao terminar; `-gexit_on_success` só sai se não falhar. A doc da GUT não cita `--headless`, mas é flag do motor [CITED: command_line_tutorial]. Config alternativa `res://.gutconfig.json` com `{"dirs":["res://testes/unit/"],"include_subdirs":true,"should_exit":true,"log_level":1}` [CITED].

### Simulador headless
```gdscript
# simulador/simular.gd  — godot --headless --path . -s res://simulador/simular.gd -- --config=res://dados/regras_padrao.tres --partidas=2000
extends SceneTree
func _initialize() -> void:
	var args := OS.get_cmdline_user_args()   # [CITED: command_line_tutorial]
	# ler --config=, --partidas=, --semente=; load(config); criar RandomNumberGenerator com seed
	# para n in 1..4, perfil in [perfeito, aprendiz]: rodar N partidas via Partida API; agregar
	print("relatorio...")
	quit(0)   # quit(1) se alguma partida não terminou
```
(Estrutura de `-s` com `SceneTree`/`MainLoop` e `--` para args: [CITED: command_line_tutorial]; corpo ilustrativo, não executado.)

### Métricas do relatório
Por (nº de magos × perfil): partidas, % terminadas, turnos médios/mediana/p95 (duração), % turnos sem ponto (troca + erro, separados), % partidas com algum mago em zero, pontos médios por mago, **tabela por palavra** (partidas em que a palavra apareceu, turnos até completar, % que ficou a última a completar) para D-14, e linha de comparação perfeito vs aprendiz. Também imprimir o `ConfigRegras` usado e a semente.

### Dados — 30 palavras (sílabas explícitas) e 100 cartas
Cartas verificadas contra o PDF (contagem por extração de texto = 100): CA8 TA8 TO8 LA7 PA7 BO6 MA6 SA6 GA5 NO5 GO4 LO4 MO4 RA4 TE4 CO2 PE2 PI2 PO2 SI2 SO2 TU2 [VERIFIED: pdftotext do PDF do repositório]. Palavras (lista PROJECT.md; sílabas por derivação óbvia, a conferir em teste): CA-SA, CA-MA, CA-NO, CA-RA, BO-CA, BO-LA, BO-LO, BO-TA, PA-TO, PA-TA, PA-NO, PI-PA, GA-TO, GA-TA, GA-LO, GO-LA, GO-TA, MA-LA, MA-TO, MO-TO, MO-LA, RA-TO, SA-PO, SA-CO, SA-LA, SI-NO, SO-PA, TA-TU, TA-PE-TE, TO-MA-TE.
Teste de integridade: soma=100; 22 chaves; 30 palavras, 28 com 2 sílabas e 2 com 3; toda sílaba de toda palavra existe na distribuição; nenhuma palavra repetida; demanda de espaços de cada sílaba ≤ cópias (para qualquer sorteio de 4 palavras distintas — verificar no pior caso).

## State of the Art

| Old | Current | Impact |
|-----|---------|--------|
| GUT 9.6.x | 9.7.x para 4.7 | Usar 9.7.1; evitar doubles |
| Dicionário não tipado | `Dictionary[String,int]` tipado (4.4+) | Usar na `DistribuicaoBaralho`; sem aninhar |

## Resultados preliminares de simulação (referência para o planejador)

Simulação Python descartável (scratchpad, não faz parte do repo), perfil perfeito, D-01..D-12, 3000 partidas por célula, `erro_passa_a_vez` irrelevante para o perfeito [VERIFIED: executada nesta sessão; ignora esgotamento extremo do baralho]:

| distratoras (por útil) | magos | turnos/partida | turnos sem ponto | mago sem sílaba | não terminaram |
|---|---|---|---|---|---|
| 1.0 (D-09) | 1 / 2 / 3 / 4 | 13,6 / 13,0 / 12,3 / 11,9 | 39% / 36% / 33% / 31% | 0 / 0 / 0 / 1,1% | 0% |
| 0.5 | 4 | ~11,3 (interp.) | — | — | 0% |
| 0.25 | 1 / 2 / 3 / 4 | 12,1 / 11,5 / 11,1 / 10,7 | 32% / 28% / 25% / 23% | 0 / 0 / 0 / 0,4% | 0% |
| 0 | 1 / 2 / 3 / 4 | 10,7 / 10,3 / 9,9 / 9,6 | 23% / 20% / 17% / 14% | ≈0 | 0% |
| (100 cartas inteiras, ref.) | 4 | 14,6 | 43% | 3,2% | 0% |

Leituras: (a) D-19 (≤5%) já passa com 1.0; (b) D-18 (≤35%) falha com 1–2 magos no valor inicial e passa com 3–4; (c) a alavanca D-21 funciona e é monotônica; (d) o nº de turnos é baixo (~12 turnos totais), logo o relatório deve também reportar turnos *por mago*. Os números do simulador GDScript devem coincidir aproximadamente com estes — usar como teste de sanidade do port. O perfil aprendiz com `erro_passa_a_vez=true` aumentará turnos e zerados; medir.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `godot --headless --import` regenera o cache de `class_name` em checkout limpo | Pitfall 1 | Teste/simulador falham em máquina nova; ajustar o script `rodar` |
| A2 | Autoloads não confiáveis em `-s` SceneTree | Pitfall 2 | Nenhum (evitamos) |
| A3 | Aparelho moderno é arm64; checar com `adb` | Pitfall 6 | APK não instala; marcar `armeabi-v7a` |
| A4 | Credenciais do preset ficam em `.godot/` ignorado | Pitfall 6 | Vazamento de senha no Git; revisar `export_presets.cfg` antes do commit |
| A5 | Deploy remoto/Depuração USB no editor | Pitfall 6 | Instalar via `adb install` |
| A6 | Sílabas das 30 palavras por derivação direta | Dados | Erro de dados; coberto por teste contra PDF |

## Open Questions

1. **Com quantos magos a meta D-18 (≤35%) é avaliada?**
   - Sabemos: perfeito dá 39/36/33/31% (1–4 magos) no valor inicial.
   - Falta: CONTEXT diz só "perfil perfeito"; D-19 especifica 4 magos, D-18 não.
   - Recomendação: avaliar D-18 para cada nº de magos e exigir ≤35% em todos (mais rigoroso); relatório mostra os quatro. Se a equipe aceitar só 2–4, registrar no PROJECT.md. Com isso, o valor inicial D-09 provavelmente será reduzido (~0.5–0.75 distratoras por útil) pela alavanca D-21.
2. **Min SDK e defaults de arquitetura do preset 4.7.2** — conferir no editor.
3. **Aparelho Android de teste** — qual modelo/ABI? Bloqueia FUND-02.
4. **Duração alvo** — apenas reportar (decidido).

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Godot 4.7.2 | tudo | ✗ | — | Baixar do arquivo oficial (build padrão; export templates 4.7.2) |
| Export templates 4.7.2 | FUND-02/03 | ✗ | — | Instalar pelo editor |
| JDK | Export Android | ✓ | 21.0.2 | Doc recomenda 17; 21 deve servir; instalar Temurin 17 se falhar |
| Android SDK / sdkmanager | FUND-02 | ✗ (`%LOCALAPPDATA%\Android` ausente) | — | Command-line tools + comando sdkmanager da doc |
| adb | deploy/logcat | ✗ (vem do platform-tools) | — | Instalado com o SDK |
| Aparelho Android + cabo USB | FUND-02 | desconhecido | — | Nenhum — bloqueante |
| Python 3 | opcional (script de checagem) | ✓ | 3.12 | — |
| pdftotext | conferir PDF | ✓ | — | — |

**Missing sem fallback:** aparelho Android real (confirmar com a equipe). **Missing com fallback:** Godot, templates, SDK (instalação).

## Validation Architecture
Desativada (`workflow.nyquist_validation=false`). Nota prática: framework GUT 9.7.1, config `.gutconfig.json`, comando único via `testes/rodar.(ps1|sh)`; todos os testes do critério 2 vão em `testes/unit/` (test_conteudo, test_baralho, test_partida_sorteio, test_partida_turnos, test_config).

## Security Domain
Jogo offline, sem rede, sem dados de crianças. ASVS aplicável mínimo: V5 (validação de entrada) só para o `ConfigRegras` (usar `@export_range`/clamp no carregamento). Controles do projeto: sem permissão de internet no APK, keystore e senhas fora do Git (`.gitignore`: `.godot/`, `*.keystore`, `*.apk`, `*.aab`, `build/`), sem contadores de erro por criança.

## Project Constraints (from CLAUDE.md)
- Godot 4.7.2 padrão (sem .NET), GDScript tipado; renderer Compatibility; 1280x720, `canvas_items`, `expand`, `sensor_landscape` (nome a conferir), `import_etc2_astc` ligado.
- Sem addons de cartas; sem Gradle/AAB; APK sem internet; sem SDK de rede/analytics.
- GUT 9.7.x; export templates da mesma versão exata; mesma versão do editor nas duas máquinas.
- Keystore/senhas fora do repositório; `.gitignore` conforme acima; cada pessoa edita cenas diferentes.
- Registrar licenças (Fase 3; imagens provisórias da Fase 1 devem ser CC0/próprias e anotadas em `CREDITOS.md`).
- Fixar convenção de idioma/pastas e registrar no CLAUDE.md (discricionário).
- Edições via fluxo GSD.

## Sources

### Primary (HIGH)
- docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html — JDK 17, lista exata do SDK, env vars de keystore, aviso de reinstalação
- docs.godotengine.org/en/stable/tutorials/editor/command_line_tutorial.html — `--headless`, `-s` (SceneTree/MainLoop), `--import`, `--export-debug/release`, `OS.get_cmdline_user_args()`
- docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html — preset x86_64, limite de PCK embutido
- docs.godotengine.org/en/stable/classes/class_editorexportplatformandroid.html — propriedades `architectures/*`, `keystore/debug*`, `permissions/internet` (defaults não listados)
- docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html — `Dictionary[String,int]`, sem aninhar
- gut.readthedocs.io (Command-Line) — opções e exit codes
- github.com/bitwes/Gut/releases — 9.7.0/9.7.1
- PDF das cartas do repositório (pdftotext) — distribuição de 100 cartas

### Secondary (MEDIUM)
- Simulação Python própria desta sessão (modelo simplificado)

### Tertiary (LOW)
- Itens `[ASSUMED]` acima

## Metadata
**Confidence breakdown:**
- Standard stack: HIGH — versões e comandos de fontes oficiais
- Architecture: MEDIUM-HIGH — segue ARCHITECTURE.md; detalhes de `-s` não executados
- Pitfalls: MEDIUM — export Android depende do aparelho e de opções de preset não vistas
**Research date:** 2026-11-12
**Valid until:** 2026-12-12 (prazo do projeto é anterior)
