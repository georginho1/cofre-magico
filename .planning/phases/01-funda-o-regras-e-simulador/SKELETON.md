# Walking Skeleton — Cofre Mágico

**Phase:** 1
**Generated:** 2026-11-12

## Capability Proven End-to-End

Uma pessoa instala o APK em um Android real (ou abre o executável no PC), vê a cena inicial que lê o valor `tamanho_mao` do arquivo `dados/regras_padrao.tres` e toca em um botão cujo contador responde ao toque; em seguida, o mesmo núcleo de regras sem tela (`Partida`) é exercitado por testes GUT e pelo simulador (planos 01-03 a 01-08).

## Architectural Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Engine / linguagem | Godot 4.7.2-stable (build padrão, sem .NET), GDScript tipado | Decisão do HCD e do CLAUDE.md; menor atrito para exportar Android |
| Renderizador | Compatibility (OpenGL), 1280x720, stretch `canvas_items`, aspect `expand`, `sensor_landscape` | Jogo 2D de cartas; maior alcance de hardware; letras nítidas em qualquer proporção |
| Camadas | Dados (`Resource` .tres) -> Núcleo (`RefCounted`, sem Node) -> Apresentação (cenas, Fase 2) | Núcleo testável sem cena; a mesma API `Partida` serve testes, simulador e Mesa |
| Dados / configuração | `ConfigRegras`, `BibliotecaPalavras`, `DistribuicaoBaralho` em `.tres`; sem banco | Jogo offline sem persistência; equipe edita texto e roda de novo |
| Aleatoriedade | `RandomNumberGenerator` injetado; Fisher-Yates próprio; nenhum `shuffle()`/`randi()` global | Partidas reproduzíveis por semente em testes e simulador |
| Testes | GUT 9.7.1 em `addons/gut`, comando único `testes/rodar.ps1` (e `.sh`) | FUND-04; GUT cobre bem lógica pura |
| Simulador | Script `extends SceneTree` via `godot --headless -s`, argumentos `--config --partidas --semente --set --saida` | PART-11; sem autoload |
| Entrega | APK de depuração (sem Gradle, sem permissão INTERNET) assinado com keystore fora do Git; `.exe` Windows com PCK embutido | Sem Play Store; sem coleta de dados de crianças |
| Layout de pastas | `nucleo/`, `dados/` (+ `dados/tipos/`, `dados/variantes/`), `simulador/`, `testes/unit/`, `cenas/`, `arte/provisoria/`, `addons/gut/`; identificadores em português sem acento, arquivos em minúsculas | Convenção registrada no CLAUDE.md |

## Stack Touched in Phase 1

- [x] Project scaffold (Godot 4.7.2, GUT, scripts de execução) — planos 01-01 e 01-03
- [x] Cena: uma cena real (`cenas/inicial/inicial.tscn`) definida como `main_scene` — plano 01-01
- [x] Dados: leitura real de `dados/regras_padrao.tres` na cena inicial e carga das 30 palavras / 100 cartas — planos 01-01 e 01-04 (não há escrita: jogo offline sem persistência)
- [x] Interação: botão que responde ao toque no Android real e no PC — planos 01-01 e 01-02
- [x] Deployment: APK em aparelho Android real e executável de PC — planos 01-01, 01-02 e 01-08

## Out of Scope (Deferred to Later Slices)

- Qualquer tela de jogo (mesa, seleção de magos, cofre, menu) — Fase 2
- Ilustrações definitivas, tela de créditos, áudio — Fase 3
- Protocolo de testes com adultos e APK de release assinado — Fase 4
- Keystore de release, Gradle, AAB, Play Store, rede, contas, analytics (fora do escopo do projeto)
- Garantia de carta útil na mão, restrições de sorteio, distratoras por semelhança, evitar repetir palavras entre partidas (adiados no CONTEXT)

## Subsequent Slice Plan

Cada fase seguinte acrescenta uma fatia vertical sobre este esqueleto sem alterar suas decisões:

- Phase 2: até quatro magos jogam do menu à abertura do cofre usando a API `Partida` desta fase (visual provisório)
- Phase 3: ilustrações de licença livre, créditos e efeitos sonoros com mudo
- Phase 4: testes com adultos, ajuste de regras no arquivo de configuração e builds finais na máquina da apresentação
