# Project Research Summary

**Project:** Cofre Mágico
**Domain:** jogo educativo cooperativo de cartas de sílabas, 2D, pass-and-play em um aparelho (Godot 4 / GDScript, Android + PC), para crianças de 7 a 9 anos em alfabetização
**Researched:** 2026-11-11
**Confidence:** MEDIUM (alta em motor, exportação e números do baralho; média em UX infantil; regras de mão/compra/troca ainda não decididas)

## Executive Summary

Cofre Mágico é a tradução digital de um jogo de cartas analógico: até quatro magos, em um único aparelho, colocam sílabas CV em quatro palavras-senha ilustradas até abrir um cofre. As quatro pesquisas convergem em uma mesma forma de construir: Godot 4.7.2 com renderizador Compatibility, interface inteira em nós `Control` com contêineres, regras em objetos `RefCounted` puros (sem cena) alimentados por Resources `.tres`, e interação por dois toques (carta, depois espaço) em vez de arrastar. Essa separação entre núcleo e tela não é preciosismo: é o que permite simular milhares de partidas sem interface, e a simulação é a única ferramenta disponível para fechar as regras, porque o projeto não testará com crianças.

O achado que mais pesa no roteiro é de design de regras, não de tecnologia. Uma partida tem só 8 a 10 jogadas corretas (cerca de 2 por criança com 4 jogadores), e de 22 sílabas apenas 6 a 8 servem em cada sorteio. A simulação preliminar da pesquisa de armadilhas mostra 41% a 80% de turnos mortos conforme a regra de troca, e 3% a 20% de partidas em que um mago termina sem nenhuma sílaba. Nenhuma das três regras simuladas atinge o limite de alerta que a própria pesquisa propõe (30% a 35% de turnos mortos). Ou seja: mão maior e troca generosa ajudam, mas provavelmente não bastam; será preciso avaliar jogadas múltiplas por turno, compra favorecida ou sorteio com restrições. Isso precisa ser decidido com um simulador dentro do projeto antes de investir em tela.

O segundo risco é de prazo: hoje é 11/11/2026 e a entrega é em dezembro, com duas pessoas (3 a 5 semanas úteis). A recomendação é uma ordem estrita por valor: APK vazio em aparelho real na primeira fase, partida completa "feia" (retângulos e texto) o quanto antes, e só depois arte, cofre animado e áudio. Arte, animação e áudio são a parte elástica do roteiro; exportação Android, término garantido da partida e legibilidade não são. O levantamento das 30 ilustrações e de suas licenças não depende de código e deve começar em paralelo desde o primeiro dia, pois a cobertura real nos pacotes livres não foi verificada por nenhuma das pesquisas.

## Key Findings

### Recommended Stack

Detalhes em `STACK.md`. A pilha é toda nativa do Godot, sem addons de jogo de cartas e sem qualquer SDK de rede (o APK não deve pedir permissão de internet).

**Core technologies:**
- **Godot 4.7.2-stable (build padrão, sem .NET)**: motor e editor — estável mais recente; a 4.8 está em beta e não deve ser usada. Fixar a mesma versão exata nas duas máquinas.
- **GDScript com tipagem estática**: toda a lógica — já decidido pela equipe; caminho de menor atrito para Android.
- **Renderizador Compatibility (OpenGL)**: recomendado pela documentação para 2D e aparelhos de entrada; Forward+ e Mobile exigem Vulkan sem ganho para um jogo de cartas.
- **Projeto em 1280x720, stretch `canvas_items`, aspect `expand`, paisagem**: configuração oficial para 2D móvel; mantém as sílabas nítidas e evita barras pretas. Exige contêineres e âncoras desde a primeira cena.
- **Exportação Android sem Gradle**: OpenJDK 17, Platform API 35, Build-Tools 35.0.1, export templates 4.7.2. APK instalado direto; nada de AAB ou Play Store.
- **GUT 9.7.x**: testes unitários das regras e base para a simulação headless. Confirmar a versão exata na instalação (o selo "Latest" do GitHub está na 9.6.1).
- **Arte e fontes de licença livre**: Kenney (CC0) para interface e sons; OpenMoji (CC BY-SA 4.0, crédito obrigatório) para ilustrações; fonte OFL com Latin estendido (Andika ou Lexend). Licenças de Twemoji, Noto, Openclipart, ARASAAC e das fontes não foram reverificadas.

**Pontos em que as pesquisas divergem sobre a pilha:**
- **Keystore de release:** `STACK.md` descreve gerar keystore de release para o build final; `PITFALLS.md` diz que o APK de depuração basta para a apresentação e que não se deve gastar tempo com keystore de release. Recomendação desta síntese: APK de depuração como padrão, com um único debug keystore compartilhado entre os dois integrantes (evita o erro de assinatura ao reinstalar); keystore de release só se sobrar tempo.
- **Arquitetura armeabi-v7a:** `STACK.md` manda marcar sempre; `PITFALLS.md` manda conferir o preset e marcar se o aparelho de teste exigir. Decidir na Fase 1 conforme os aparelhos disponíveis.
- **Nomes de pastas e arquivos:** testes em `res://test` (`STACK.md`) ou `testes/` (`ARCHITECTURE.md`); créditos em `CREDITS.md`, `assets/LICENCAS.md`, `arte/LICENCAS.md` ou `CREDITOS.md`. Fixar uma convenção na Fase 1, junto com o idioma dos identificadores.

### Expected Features

Detalhes em `FEATURES.md`. O diferencial defensável do projeto é cooperação com autoria individual visível; os apps de sílabas comparados (GraphoGame, Lele Sílabas, Silabando) são individuais.

**Must have (table stakes):**
- Preparação mínima: tocar nos magos que vão jogar (1 a 4), sem digitar nomes
- Modelo de partida completo com conteúdo em dados e regras parametrizadas, incluindo número de senhas
- Jogar por dois toques (carta, depois espaço), com alvos grandes e espaçados
- Validação automática com acerto comemorado e erro neutro (carta volta à mão; sem X, vermelho, buzina ou contador)
- Comprar/trocar sempre visível, com destaque quando a mão não tem jogada
- Magos identificados por cor e símbolo; autoria marcada em cada sílaba
- Indicador de turno e passagem de vez explícita
- Palavras-senha com ilustração grande e um espaço por sílaba (2 ou 3)
- Caixa alta, sem serifa, alto contraste (referência 4,5:1)
- Abertura do cofre, tela final de contribuições sem ranking, jogar de novo
- Efeitos sonoros básicos com mudo; pausa/sair com confirmação
- Paisagem, layout que escala, totalmente offline, sem contas nem coleta
- Builds Android (APK) e PC

**Should have (diferenciais, nesta ordem se houver folga):**
- Palavra falada ao completar a senha (30 clipes gravados pela equipe, não TTS)
- Sílaba falada ao tocar na carta; tocar na ilustração para ouvir a palavra
- "Como jogar" ilustrado e curto
- Painel do adulto com os parâmetros em tela
- Resumo agregado da partida para os testes (tempo, turnos, trocas)
- Vários cofres em sequência, se as partidas medidas ficarem curtas
- Dica por inatividade

**Defer (v2+):**
- Arrastar e soltar (só depois de teste em aparelho real)
- Primeiro turno guiado interativo
- Sílabas não canônicas, vocabulário ampliado, habilidades por mago
- Testes com crianças; relatório para professor

**Anti-features confirmadas por mais de uma pesquisa:** ranking ou "mago vencedor", cronômetro, vidas ou derrota, feedback de erro punitivo, perfis e progresso salvo, TTS do sistema, tutorial longo em texto, animações longas a cada jogada.

**Pontos em que as pesquisas divergem sobre features:**

| Tema | Posições | Situação |
|------|----------|----------|
| **Mãos dos outros magos visíveis durante o turno** | `FEATURES.md`: as mãos podem ficar abertas, ou só a do mago ativo em destaque; esconder impede ajuda entre colegas. `PITFALLS.md`: mostrar só a mão do mago da vez (sem segredo, quem está ao lado vê), também por orçamento de tela. `ARCHITECTURE.md`: deixa como pergunta aberta; a arquitetura suporta os dois. | **Não resolvido.** Todas concordam que não há segredo nem tela de privacidade. A divergência é se as outras mãos aparecem na tela. O espaço em celular de cerca de 6 polegadas pesa a favor de mostrar só a mão da vez; decidir na fase da mesa, com protótipo em aparelho. |
| **Passagem de vez** | `FEATURES.md`: faixa de tela cheia com toque para começar. `PITFALLS.md`: transição curta; tela de "passe o aparelho" a cada turno dobra toques e espera. `ARCHITECTURE.md`: overlay que bloqueia toques, com confirmação, ligado por parâmetro (`mostrar_tela_de_passagem`). | Divergência sobre exigir ou não um toque de confirmação. Implementar como parâmetro e decidir nos testes. |
| **Destacar os espaços válidos ao selecionar a carta** | `FEATURES.md`: posições válidas destacadas após selecionar (table stakes). `ARCHITECTURE.md`: `destacar_slots_validos` desligado por padrão. `PITFALLS.md`: brilho discreto só depois de duas tentativas erradas. | **Não resolvido**, e tem peso pedagógico: destacar sempre entrega a resposta. Parametrizar e decidir com a equipe. |
| **Tamanho mínimo dos alvos de toque** | `STACK.md`: cerca de 96 px na base 1280x720 (LOW). `ARCHITECTURE.md`: carta de cerca de 110x150 px. `FEATURES.md`: 9 a 12 mm físicos (BAIXA). `PITFALLS.md`: 15 a 20 mm, com base em NN/g (2 cm para crianças pequenas). | Números incompatíveis entre si. Medir em milímetros no aparelho de teste; a faixa mais alta tem a melhor fonte, mas pode não caber com 4 palavras e mão de 5 a 6 cartas. |
| **Áudio** | `FEATURES.md`: efeitos sonoros são table stakes e a palavra falada é P1 (primeiro item a cortar). `PITFALLS.md`: áudio falado é escopo opcional e "sons" estão na lista de corte. `ARCHITECTURE.md`: áudio e animações são os primeiros cortes da etapa de apresentação. | Concordam que é o primeiro a cortar; divergem sobre contar como obrigatório. Tratar efeitos básicos como desejáveis e áudio falado como condicional ao prazo. |
| **Instrução inicial** | `FEATURES.md`: 3 quadros ilustrados (P2); turno guiado fica para v2+. `PITFALLS.md`: demonstração animada na primeira jogada (mão mostrando onde tocar). | Formatos diferentes para o mesmo objetivo. Escolher o mais barato quando a fase chegar. |
| **Placar individual** | `ARCHITECTURE.md`: barra de magos com pontos e placar por mago na cena do cofre. `FEATURES.md` e `PITFALLS.md`: contribuição mostrada pelas marcas nas sílabas, sem lista ordenada nem comparação numérica. | O requisito do PROJECT.md pede ponto simbólico. Mostrar pontos sem ordenar é o mínimo comum; a forma exata fica para a fase do cofre. |
| **Modo de 1 jogador** | PROJECT.md e `FEATURES.md`: 1 a 4 jogadores é requisito. `PITFALLS.md`: "modo de 1 jogador com tratamento especial" está na lista de corte. | Manter 1 jogador funcionando com as mesmas regras (sem overlay de passagem), sem regras próprias. |
| **Palavra escrita ou só a imagem** | `FEATURES.md` supõe ilustração com espaços vazios, sem revelar a grafia. `PITFALLS.md` levanta a decisão em aberto e sugere exibir a palavra para pares ambíguos (PATO/PATA, GATO/GATA). | **Decisão de design pendente**; afeta dificuldade e dependência da qualidade das ilustrações. Parametrizar. |
| **Simulação do baralho** | `FEATURES.md` registra que a frequência de mão sem jogada não foi simulada. `PITFALLS.md` simulou (4 mil a 20 mil partidas por configuração). | Não é contradição de conteúdo, mas de estado: os scripts estão em pasta temporária da sessão (`sim.py`, `sim2.py`, fora do repositório) e usam regras hipotéticas. Recriar o simulador dentro do projeto. |

### Architecture Approach

Detalhes em `ARCHITECTURE.md`. Três camadas com dependência em um só sentido: Apresentação → Núcleo → Dados. O núcleo nunca conhece cenas; a cena `Mesa` é um controlador fino que traduz toques em chamadas e sinais em visual ("chamada desce, sinal sobe"). O modelo muda de forma instantânea; a tela anima depois e pode ser reconstruída inteira a partir do estado (`_sincronizar_tudo()`).

**Major components:**
1. **Dados (`.tres`)** — `BibliotecaPalavras` (30 palavras com sílabas explícitas e ilustração), `DistribuicaoBaralho` (22 sílabas, 100 cartas), `ConfigRegras` (todos os parâmetros em teste), `PaletaMagos`. Somente leitura.
2. **Núcleo (`RefCounted`)** — `Partida` como única porta de entrada das regras e máquina de estados do turno; `Baralho`, `Jogador`, `PalavraSenha`. RNG injetado com semente; sem `await`, timers ou tweens.
3. **`Sessao` (único autoload)** — jogadores escolhidos, configuração ativa e resultado entre cenas. A `Partida` não é autoload.
4. **`Mesa` e componentes visuais** — `CartaView`, `SlotView`, `PalavraView`, `MaoView`, overlay de passagem de vez, camada de animação para a carta "fantasma".
5. **Telas** — Menu, Configuração de jogadores, Mesa, Cofre, trocadas com `change_scene_to_file()`.
6. **Testes e simulação** — GUT sobre a mesma API pública que a `Mesa` usa; script que joga N partidas sem tela.

Regras de estrutura que valem como critério de revisão: nada em `nucleo/` estende `Node`; nenhuma posição absoluta em tela; sílabas explícitas por palavra (nunca cortar a string de dois em dois); validação por índice de espaço (`carta == sílaba esperada do espaço`); imagens referenciadas por Resource, nunca por caminho montado em texto; nomes de arquivo em minúsculas sem acento.

### Critical Pitfalls

Detalhes em `PITFALLS.md` (dez armadilhas críticas, com checklist final). As cinco que mais afetam o roteiro:

1. **Turnos mortos em excesso** — 41% a 80% dos turnos sem jogada nas regras simuladas. Decidir tamanho de mão, troca, jogadas por turno e eventual compra favorecida com simulador próprio, antes da interface. A alavanca "baralho reduzido por partida" contraria o requisito das 100 cartas e exige decisão da equipe.
2. **Estados sem saída** — sete sílabas têm só 2 cópias (CO, PE, PI, PO, SI, SO, TU). Invariante: nenhuma carta sai do jogo; descarte reembaralha; todo turno tem ao menos uma ação legal; simulação exige 100% de término.
3. **Exportação Android deixada para o fim** — APK de cena vazia em aparelho real antes de qualquer regra; repetir ao fim de cada fase; levar build de PC e aparelho reserva para a apresentação.
4. **Escopo maior que o prazo** — partida "feia" completa primeiro; lista de corte definida de antemão (arrastar, sons, animação elaborada do cofre, menu de opções, telas de instrução); congelar funcionalidades uma semana antes da entrega; reservar tempo para relatório e slides.
5. **Arte sem licença registrada e sem unidade visual** — planilha das 30 palavras com fonte, autor, licença e link antes de importar qualquer arquivo; descobrir a origem das ilustrações do PDF físico; uma única família visual; palavra sem imagem adequada pode ser desativada no catálogo (decisão da equipe).

Também relevantes: interface testada só por adultos leitores (usar protocolo sem leitura, mão não dominante, no celular); identidade dos magos só por cor (vermelho/verde é o par clássico de daltonismo; amarelo some no fundo azul-claro); um jogador que termina com zero ponto; fonte sem acentos em textos de interface ("MÁGICO", "SÍLABA"); botão voltar do Android encerrando a partida.

**Correção de informação desatualizada:** `PITFALLS.md` afirma que o diretório do projeto ainda não é um repositório git. Isso não vale mais: o repositório já existe, com commits na branch `master`. Da recomendação original permanece válido apenas o `.gitignore` do Godot (`.godot/`, `*.keystore`, `*.apk`, `build/`) e a divisão do trabalho por cena para evitar conflitos em `.tscn`.

## Implications for Roadmap

Sugestão: **6 fases**, alinhadas às fases F0 a F5 de `PITFALLS.md` e às 9 etapas de `ARCHITECTURE.md` (agrupadas). Com o prazo de dezembro, as três primeiras fases são o caminho crítico e deveriam ocupar no máximo a metade do tempo disponível.

### Phase 1: Fundação e exportação Android
**Rationale:** exportar é integração com ferramentas externas e falha de formas que nada têm a ver com o jogo; descobrir isso na última semana é o risco mais caro e mais evitável.
**Delivers:** projeto Godot 4.7.2 em Compatibility; 1280x720 + `canvas_items` + `expand` + paisagem; tela ligada; `.gitignore`; estrutura de pastas e convenções (idioma dos identificadores, nomes em minúsculas, pasta de testes, arquivo de créditos); GUT instalado com um teste passando; tela de teste de acentos em maiúsculas com a fonte escolhida; **APK de cena vazia instalado em aparelho real** e executável de PC.
**Uses:** toda a seção de exportação de `STACK.md`.
**Avoids:** Armadilhas 5 (exportação tardia), 7 (configuração de layout), renderer errado, fonte sem acentos.
**Em paralelo desde já:** levantamento das 30 ilustrações e licenças (ver Fase 5), que não depende de código.

### Phase 2: Dados, núcleo de regras e simulador
**Rationale:** tudo depende do modelo de partida; e o maior risco do projeto (turnos mortos, travamento, mago sem ponto) só se resolve medindo. Não depende de nenhuma tela, então pode correr em paralelo com protótipos visuais feitos pelo outro integrante com dados falsos.
**Delivers:** Resources das 30 palavras, 100 cartas e `ConfigRegras`; teste de integridade (soma 100; toda sílaba de toda palavra existe no baralho); `Baralho`, `Jogador`, `PalavraSenha`, `Partida` com testes GUT (sorteio, validação por posição, sílaba compartilhada entre palavras, palavra de três sílabas, compra/troca, reembaralhamento, ordem de turno 1 a 4, vitória); função "há jogada possível?"; simulador headless com relatório (turnos mortos, duração, partidas com mago sem ponto, 100% de término); **escolha inicial dos parâmetros de regra registrada como decisão**.
**Addresses:** modelo de partida, conteúdo em dados, regras parametrizadas, validação automática.
**Avoids:** Armadilhas 1, 2, 3 (métrica), 4; aleatoriedade não reproduzível; sorteio sem critério.

### Phase 3: Mesa jogável pass-and-play
**Rationale:** é o marco do Core Value: uma partida completa para até quatro magos em um aparelho, com retângulos e texto. A partir daqui tudo é incremento e o projeto já é apresentável.
**Delivers:** seleção de 1 a 4 magos; `Mesa` com contêineres; jogar por dois toques; comprar/trocar; indicador de turno e passagem de vez; magos com cor e símbolo; autoria nos espaços; erro neutro básico; detecção de fim; partida completa jogada só com toque em aparelho real e verificada em 16:9, 20:9 e 4:3.
**Implements:** `Mesa`, `MaoView`, `PalavraView`, `SlotView`, `CartaView`, overlay de passagem, `Sessao`.
**Avoids:** Armadilhas 6 (interação de mouse), 7 (layout fixo), 8 (alvos e identificação), menos de 4 jogadores.
**Decisões a tomar nesta fase:** visibilidade das mãos dos outros magos; confirmação na passagem de vez; destaque de espaços válidos; tamanho físico dos alvos; palavra escrita ou só imagem.

### Phase 4: Fluxo completo e cofre
**Rationale:** fecha o ciclo narrativo e permite repetir partidas, o que os testes exigem; depende de a mesa detectar o fim.
**Delivers:** Menu → Configuração → Mesa → Cofre → jogar de novo; abertura do cofre com recompensa coletiva; tela final de contribuições sem ranking; pausa/sair com confirmação; botão voltar do Android tratado (`quit_on_go_back` desligado); retomada ao voltar do segundo plano.
**Addresses:** celebração coletiva, tela de fim, jogar de novo, pausa.
**Avoids:** Armadilha 3 (tela final como placar), fim de partida seco, estado sujo entre partidas (a `Partida` é recriada pela `Mesa`).

### Phase 5: Conteúdo, arte e feedback infantil
**Rationale:** é a fase mais elástica e a que mais atrai trabalho antes da hora; vem depois de existir partida completa. O levantamento de imagens, porém, começa na Fase 1.
**Delivers:** planilha de licenças completa; 30 ilustrações em uma única família visual, importadas em 256 a 512 px; tema único com fonte de alfabetização; cartas e magos; animação de carta por camada "fantasma" (menos de 1 s); feedback de acerto; efeitos sonoros com mudo; tela de créditos e arquivo de créditos no repositório; área segura. Condicionais ao prazo, nesta ordem: palavra falada ao completar, instrução curta, sílaba falada, painel do adulto.
**Uses:** Kenney, OpenMoji, fonte OFL, `Tween`, `Theme`, `AudioStreamPlayer`.
**Avoids:** Armadilha 9 (licenças e unidade visual), animações que bloqueiam o turno, SVG borrado, caminhos com maiúsculas no Android.

### Phase 6: Testes com adultos, ajuste de regras e entrega
**Rationale:** os parâmetros escolhidos por simulação com jogador "guloso" precisam ser confrontados com pessoas; e a entrega inclui relatório e slides.
**Delivers:** sessões de teste com protocolo que simula o público (sem ler a tela, mão não dominante, no celular, duas pessoas tocando); variantes de `ConfigRegras` comparadas; nova rodada de simulação com os parâmetros finais; checklist "parece pronto, mas não está" de `PITFALLS.md` cumprido; APK e executável finais testados no aparelho e na máquina da apresentação; limitações registradas no relatório (sem testes com crianças, recomendações extrapoladas de outras faixas etárias).
**Avoids:** Armadilhas 2 e 8 (verificação), 10 (congelamento uma semana antes).

### Phase Ordering Rationale

- **Dependência técnica:** Dados → Núcleo → Mesa → Fluxo de telas → Polimento, como em `ARCHITECTURE.md`; `FEATURES.md` chega à mesma árvore de dependências pelo lado das features.
- **Risco primeiro:** exportação (Fase 1) e viabilidade das regras (Fase 2) são os dois riscos que podem inviabilizar a entrega, e ambos são baratos de atacar cedo.
- **Trabalho em paralelo para duas pessoas:** Fase 2 (scripts puros) não toca em cenas; o outro integrante pode adiantar componentes visuais com dados falsos e o levantamento de arte. As frentes se encontram na Fase 3. Isso também reduz conflitos em `.tscn`.
- **Valor demonstrável a cada fase:** ao fim da Fase 3 já existe o que o Core Value pede; Fases 4 a 6 podem ser cortadas de trás para a frente sem perder a entrega.
- **Exportar ao fim de cada fase**, não só na primeira e na última.

### Research Flags

Fases que provavelmente precisam de pesquisa mais funda durante o planejamento:
- **Phase 2:** as regras de mão/compra/troca não existem e nenhuma regra simulada atinge a meta de turnos mortos. O que falta não é pesquisa externa, é experimento: definir as alavancas a comparar e os critérios de aceitação antes de planejar as tarefas. Depende também de decisões da equipe (alterar ou não o baralho de 100 cartas; restringir o sorteio).
- **Phase 5:** cobertura real das 30 ilustrações em pacotes livres, origem e licença das imagens do PDF físico, licenças não reverificadas (Twemoji, Noto, Openclipart, ARASAAC, Andika, Lexend) e alcance do share-alike do OpenMoji.
- **Phase 3 (pontual):** unidades de `get_display_safe_area()` com `canvas_items` + `expand`; comportamento de toques simultâneos. Arrastar por toque só precisa ser pesquisado se a equipe decidir incluí-lo.

Fases com padrões bem documentados (dispensam pesquisa de fase):
- **Phase 1:** requisitos de exportação e configurações conferidos na documentação oficial da 4.7.
- **Phase 4:** troca de cena simples, autoload mínimo, `Tween`; padrões estabelecidos.
- **Phase 6:** execução do checklist e do protocolo já descritos em `PITFALLS.md`.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Motor, renderizador, exportação Android e ajustes de tela vêm da documentação oficial consultada no dia. MEDIUM para GUT, min SDK do template, nome exato da opção de orientação e licenças não reverificadas. |
| Features | MEDIUM | Estudos de interação infantil encontrados tratam de pré-escolares ou de faixas vizinhas; para 7 a 9 anos é extrapolação. Dados sobre produtos semelhantes vêm de descrições de terceiros. Nada será validado com o público real neste ciclo. |
| Architecture | MEDIUM-HIGH | APIs do Godot conferidas na documentação; organização em camadas vem de prática da comunidade. Trechos de GDScript são ilustrativos e não foram executados. Arrastar por toque no Android não foi verificado (LOW). |
| Pitfalls | MEDIUM-HIGH | Números do baralho calculados e simulados (HIGH na conta), mas com regras hipotéticas e jogador que nunca deixa passar carta útil; jogadores reais devem ter resultado pior. UX infantil MEDIUM; cobertura de ilustrações e drag-and-drop LOW. |

**Overall confidence:** MEDIUM

A tecnologia está bem estabelecida. A incerteza está no design das regras e na adequação ao público, e nenhuma das duas pode ser eliminada por pesquisa: a primeira pede simulação e teste, a segunda fica como limitação declarada do projeto.

### Gaps to Address

- **Regras definitivas de mão/compra/troca:** decidir na Fase 2 com simulador dentro do projeto; registrar a decisão no PROJECT.md.
- **Requisito das 100 cartas contra viabilidade:** se as alavancas baratas não bastarem, a equipe precisa decidir se aceita baralho reduzido por partida ou compra favorecida. Levar à equipe antes do fim da Fase 2.
- **Sorteio com restrições:** limitar palavras com sílaba rara ou pares quase idênticos altera o "sorteio automático entre 30"; confirmar com a equipe.
- **Scripts de simulação da pesquisa:** estão em pasta temporária da sessão, fora do repositório, e podem deixar de existir. Não contar com eles; recriar em GDScript.
- **Divergências listadas em Key Findings** (mãos visíveis, passagem de vez, destaque de espaços, tamanho de alvo, palavra escrita): resolver na Fase 3 com protótipo em aparelho; deixar parametrizado o que for barato.
- **Cobertura e licença das ilustrações:** levantamento palavra a palavra desde a Fase 1; candidatas a problema: CANO, GOLA, MOLA, MATO, PANO, SACO, TAPETE, TATU, CARA.
- **Origem das ilustrações do PDF do protótipo físico:** perguntar à equipe; se a licença permitir, resolve cobertura e unidade de estilo.
- **Itens de Godot não verificados:** min SDK do template 4.7, arquiteturas padrão do preset, nome da opção `sensor_landscape`, compatibilidade do gdtoolkit. Conferir no editor na Fase 1.
- **Duração real da partida:** alvo de 5 a 15 minutos é estimativa de baixa confiança; medir na Fase 6 e usar número de senhas ou cofres em sequência como ajuste.
- **Tempo disponível:** as pesquisas falam em "poucas semanas" e "3 a 5 semanas"; a data exata da entrega não consta no PROJECT.md e deve ser confirmada antes de fechar o roteiro.
- **Público real:** nenhum teste com crianças; registrar como limitação no relatório da disciplina.

## Sources

### Primary (HIGH confidence)
- https://godotengine.org/download/archive/ — versões (4.7.2 estável; 4.8 em beta)
- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html — JDK, SDK, keystore
- https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html — escolha do renderizador
- https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html — resolução base, stretch, âncoras
- https://docs.godotengine.org/en/stable/tutorials/best_practices/autoloads_versus_regular_nodes.html — riscos de estado global
- https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html — Resources, cache de `load()`
- https://docs.godotengine.org/en/stable/classes/class_control.html e class_displayserver.html — API de drag-and-drop e área segura (a documentação não trata de toque nem de unidades)
- https://kenney.nl/support — CC0
- https://openmoji.org/faq/ — CC BY-SA 4.0 e texto de atribuição
- Análise própria da pesquisa de armadilhas: contagem de oferta e demanda de sílabas e simulação Monte Carlo sobre o conteúdo do PROJECT.md (alta na conta, média na transposição para jogadores reais)

### Secondary (MEDIUM confidence)
- https://github.com/bitwes/Gut — GUT 9.7.x para Godot 4.7
- https://www.nngroup.com/articles/children-ux-physical-development/ — alvos de 2 cm, alternativa ao arrasto
- Brown e Anthony (CHI 2012); Anthony et al. (IJHCS 2019) — precisão de toque e arrasto em crianças
- Joan Ganz Cooney Center / Sesame Workshop (2012) — boas práticas de toque para pré-escolares
- Univ. Birmingham, "Tablet for two" — colaboração em tablet compartilhado
- Outhwaite et al. 2023 (UCL) — feedback em apps educativos
- Paleta Okabe-Ito — cores seguras para daltonismo
- GraphoGame Brasil, Lele Sílabas, Silabando, Jogo das Sílabas (SBGames 2018) — produtos semelhantes, por descrições de terceiros
- Documentação do Godot sobre TTS — dependência de vozes do sistema no Android

### Tertiary (LOW confidence)
- Relatos de fórum sobre drag-and-drop de `Control` com toque no Android — não reproduzidos
- Relato único de travamento de `tts_get_voices` em Android sem TTS
- Tutorial comunitário sobre lógica de baralho em `RefCounted`
- Licenças de Twemoji, Noto Emoji, Openclipart, ARASAAC, Andika e Lexend — de conhecimento prévio, a conferir no download
- Tamanhos de alvo em pixels e em milímetros para 7 a 9 anos — regra prática

---
*Research completed: 2026-11-11*
*Ready for roadmap: yes*
