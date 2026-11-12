# Pesquisa de Armadilhas (Pitfalls)

**Domínio:** jogo educativo cooperativo de cartas de sílabas, 2D, Godot/GDScript, pass-and-play em um aparelho, Android + PC, público de 7 a 9 anos
**Pesquisado em:** 2026-11-11
**Confiança geral:** MÉDIA-ALTA

- ALTA nos números do baralho: foram calculados e simulados a partir da lista de palavras e da distribuição de cartas do PROJECT.md.
- ALTA nos pontos de Godot conferidos na documentação oficial (estável = Godot 4.7 na data da pesquisa).
- MÉDIA em UX infantil (recomendações de NN/g e estudos de Anthony et al.; nenhum teste com crianças será feito neste projeto).
- BAIXA onde indicado no texto (comportamento do drag-and-drop nativo em toque, cobertura de ilustrações nos pacotes livres).

**Aviso de prazo:** hoje é 11/11/2026 e a entrega é em dezembro de 2026. Restam cerca de 3 a 5 semanas. Isso muda a prioridade de quase tudo abaixo: a armadilha mais provável não é técnica, é de escopo (Armadilha 10).

**Nomes de fase usados neste documento** (sugestão; o roadmap pode renomear):

| Fase | Conteúdo |
|------|----------|
| F0 — Fundação | Projeto Godot, renderer, resolução, repositório, exportação Android "hello world" |
| F1 — Núcleo de regras | Lógica pura (baralho, mãos, turnos, validação) sem interface, com simulador |
| F2 — Mesa jogável | Interface da partida, interação por toque/mouse, turnos pass-and-play |
| F3 — Conteúdo e arte | 30 ilustrações, cartas, magos, fontes, créditos/licenças |
| F4 — Feedback e polimento infantil | Feedback de acerto/erro, cofre, instruções, sons |
| F5 — Testes e entrega | Testes com adultos, ajuste de parâmetros, builds finais |

---

## Achados quantitativos sobre o baralho (base para as armadilhas 1 a 4)

Calculado sobre as 30 palavras e as 100 cartas. As regras de mão/compra ainda estão "em teste" no HCD, então a simulação usou regras hipotéticas (jogada gulosa: joga uma sílaba útil se tiver; senão troca cartas). Os números absolutos dependem da regra final; as tendências não.

| Fato | Valor | Consequência |
|------|-------|--------------|
| Sílabas no baralho sem uso nas palavras, ou vice-versa | nenhuma | A distribuição é coerente com o vocabulário |
| Espaços a preencher por partida | 8 (9 ou 10 se sair TAPETE e/ou TOMATE) | Há só 8 a 10 jogadas bem-sucedidas na partida inteira; com 4 jogadores, cerca de 2 por criança |
| Demanda máxima de uma sílaba em qualquer sorteio de 4 palavras contra cópias no baralho | sempre menor ou igual (ex.: CA 4 de 8, BO 4 de 6, SO 1 de 2) | Nenhum sorteio é impossível por falta de cartas, desde que nenhuma carta saia do jogo de forma permanente |
| Sílabas distintas necessárias por sorteio | 4 a 9 de 22 (típico: 6 a 8) | Cerca de 60% das cartas compradas são inúteis já no início, e a proporção piora a cada espaço preenchido |
| Mão inicial sem nenhuma carta útil | 21% (mão de 3), 8% (mão de 5), 3% (mão de 7) | Primeiro turno morto é comum com mão pequena |
| Sorteios que contêm ao menos uma palavra dependente de sílaba com só 2 cópias (PIPA, SAPO, SACO, SINO, SOPA, TATU, TAPETE) | cerca de 68% | A maioria das partidas termina esperando 1 de 2 cartas em 100 |
| Turnos mortos, regra "sem jogada: troca 1 carta" | 71% a 80% dos turnos; partidas de 28 a 41 turnos em média, cauda de 80 a 90 | Regra inviável para crianças |
| Turnos mortos, regra "sem jogada: troca 2 cartas" | 58% a 67%; 20 a 25 turnos | Ainda ruim |
| Turnos mortos, regra "sem jogada: troca a mão inteira" (mão 5 ou 6) | 41% a 47%; 14 a 16 turnos, máximo observado 23 a 27 | Melhor das três, mas ainda quase metade dos turnos sem jogada |
| Partidas de 4 jogadores em que alguém termina com zero ponto | 14% a 20% (troca 1), 10% a 14% (troca 2), 3% a 7% (troca a mão) | Colide com o objetivo de "senso de contribuição individual" |

Os scripts da simulação ficaram fora do projeto, em `C:\Users\super\AppData\Local\Temp\claude\c24e6d6e34d6d659\2165559f-e28a-4153-9d9f-454c090371e1\scratchpad\sim.py` e `C:\Users\super\AppData\Local\Temp\claude\c24e6d6e34d6d659\2165559f-e28a-4153-9d9f-454c090371e1\scratchpad\sim2.py` (Python, pasta temporária da sessão). Recomenda-se recriar o simulador dentro do projeto na F1 (ver Armadilha 2).

---

## Armadilhas Críticas

### Armadilha 1: Estados sem saída por carta que sai do jogo ou fica presa

**O que dá errado:**
A partida trava: falta uma sílaba e ela não pode mais chegar. O baralho em si não causa isso (a demanda nunca supera as cópias), então o travamento vem sempre de uma regra mal fechada:

- descarte permanente (pilha de descarte que nunca volta) de uma das 2 cópias de CO, PE, PI, PO, SI, SO ou TU;
- baralho esgotado sem reembaralhar o descarte;
- limite de mão combinado com "comprar sem descartar", que deixa o jogador sem ação possível;
- sílaba necessária na mão de um jogador que não percebe que ela serve (a carta existe, mas ninguém a joga);
- no modo de 1 jogador, mão cheia de cartas inúteis sem regra de troca.

**Por que acontece:**
O jogo físico tem um adulto que resolve impasses na hora ("pode trocar", "embaralha de novo"). No digital, toda saída precisa estar programada. As regras de mão/compra/troca ainda estão indefinidas no HCD.

**Como evitar:**
- Invariante de regra: nenhuma carta sai do jogo. Carta trocada vai para o descarte; baralho vazio reembaralha o descarte automaticamente.
- Em todo turno o jogador precisa ter ao menos uma ação legal (jogar ou trocar). Não existe "passar sem fazer nada" como único caminho.
- Detector de impasse no código: se passarem N rodadas completas sem nenhuma sílaba colocada, o jogo oferece ajuda (Armadilha 3) em vez de continuar girando.
- Teste automatizado: rodar milhares de partidas simuladas com cada conjunto de parâmetros e exigir 100% de término.

**Sinais de alerta:**
- A regra escrita contém "descarta" sem dizer para onde a carta vai.
- Não há teste que jogue uma partida do início ao fim sem interface.
- Em teste manual, alguém pergunta "e agora, o que eu faço?".

**Fase:** F1 (invariantes e simulador). Verificação repetida na F5 ao ajustar parâmetros.

---

### Armadilha 2: Turnos mortos em excesso (o problema real do baralho)

**O que dá errado:**
A criança olha a mão, não tem nada que sirva, troca uma carta e passa. Isso se repete em 40% a 80% dos turnos, conforme a regra. Uma partida com só 8 a 10 jogadas úteis se arrasta por 15 a 40 turnos. Para 7 a 9 anos, esperar três colegas jogarem para então não poder fazer nada é o fim do engajamento.

**Por que acontece:**
O baralho de 100 cartas foi dimensionado para as 30 palavras, mas cada partida usa só 4. De 22 sílabas, 6 a 8 servem; o resto é ruído. E quanto mais a partida avança, menos cartas servem: no último espaço, pode ser 2 cartas em 100.

**Como evitar:**
Tratar isto como o principal problema de design de regras e decidir com o simulador, não por intuição. Alavancas, da mais barata para a mais invasiva:

1. Troca generosa: sem jogada, o mago troca a mão inteira (ou até K cartas, com K parametrizado). É a alavanca de maior efeito medido.
2. Mão de 5 ou 6 cartas em vez de 3 ou 4.
3. Permitir jogar mais de uma sílaba útil por turno (parametrizado).
4. Compra "com sorte mágica": depois de N turnos mortos seguidos do grupo, a próxima compra garante uma sílaba útil (baralho levemente viciado, invisível para a criança). Elimina a cauda longa do fim de partida.
5. Baralho de partida: montar o baralho da partida só com um subconjunto que concentre as sílabas necessárias. Atenção: isto altera o requisito "baralho de 100 cartas com a distribuição do protótipo físico"; exige decisão da equipe.

Os parâmetros (tamanho da mão, K de troca, jogadas por turno, limiar da ajuda) devem ficar em um único recurso de configuração, como o requisito já pede.

**Sinais de alerta:**
- Simulação com mais de 30% a 35% de turnos mortos, ou partidas acima de 20 turnos.
- Em teste com adultos, alguém pega o celular enquanto espera a vez.
- O fim da partida demora mais que o resto todo (espera pela última sílaba rara).

**Fase:** F1 (simulador headless e escolha inicial de parâmetros). F5 (ajuste fino com pessoas).

---

### Armadilha 3: Um jogador domina e outro termina com zero ponto

**O que dá errado:**
Em um jogo cooperativo com pontos individuais e marcação por cor, duas distorções aparecem:

- Azar: com 8 a 10 jogadas para dividir por 4, é comum (3% a 20% das partidas, conforme a regra) alguém não colocar nenhuma sílaba. A tela final mostra três cores e deixa uma criança de fora.
- "Jogador alfa": a criança que lê melhor diz aos outros o que jogar, ou pega o aparelho e joga por eles. É o problema clássico de jogos cooperativos com informação aberta, agravado aqui porque há um único aparelho.

**Por que acontece:**
O ponto simbólico por sílaba foi pensado como reconhecimento, mas qualquer contagem individual visível vira placar. E o pass-and-play concentra o controle físico em quem segura o aparelho.

**Como evitar:**
- Mostrar a contribuição como cor nas sílabas das palavras, não como tabela de pontos ordenada. Nada de ranking, "melhor mago" ou comparação numérica na tela final.
- A recompensa do cofre é uma só, igual para todos, e cita os quatro magos.
- Reduzir a chance de zero ponto pelas regras (troca generosa, Armadilha 2) e, se necessário, com uma regra de equilíbrio parametrizada: quando um mago está sem nenhuma sílaba colocada perto do fim, a compra dele é favorecida.
- Tela de troca de turno com a cor e o nome do mago da vez em destaque, para marcar de quem é o aparelho agora.
- Aceitar que ajuda entre colegas é desejável (é um jogo cooperativo mediado por adulto). O que se evita é o jogo que premia quem toma a vez do outro.

**Sinais de alerta:**
- A tela final tem uma lista ordenada por pontos.
- Em teste, a mesma pessoa toca na tela em turnos que não são dela.
- Simulação com mais de 5% de partidas com jogador sem ponto.

**Fase:** F1 (métrica no simulador), F2 (tela de troca de turno), F4 (tela final e recompensa).

---

### Armadilha 4: Ambiguidade de colocação e validação mal definida

**O que dá errado:**
- A mesma sílaba cabe em várias palavras do sorteio (CA em CASA, CAMA, CANO, CARA e no segundo espaço de BOCA; TA e TO em seis palavras cada). Se o jogo decide sozinho onde a carta vai, tira a decisão da criança; se a criança decide, o código precisa aceitar qualquer destino válido. Tratar um destino válido como erro porque "não era o esperado" é um bug provável.
- Sete sílabas aparecem tanto na primeira quanto na segunda posição (CA, TA, TO, PA, MA, SA, RA). Validar só "a sílaba pertence à palavra" aceita TA no primeiro espaço de BOTA.
- O alvo do gesto (a palavra inteira ou o espaço específico) fica indefinido e muda no meio do desenvolvimento.

O que não é problema: nenhuma das 30 palavras repete a mesma sílaba, e não há escolha "estrategicamente errada", porque as cópias sempre cobrem a demanda do sorteio. Qualquer colocação correta é boa. Isso simplifica: não é preciso avisar a criança sobre "gastar" uma carta no lugar errado.

**Por que acontece:**
A regra do jogo físico é julgada por um humano. A versão digital precisa de uma definição exata do que é "correta para a posição escolhida".

**Como evitar:**
- Modelo de dados: cada palavra é uma lista ordenada de sílabas; cada espaço tem (palavra, índice, sílaba esperada, autor). A validação é `carta.silaba == espaco.silaba_esperada`, e nada mais.
- O alvo do gesto é o espaço, não a palavra. Espaços grandes o bastante para isso (Armadilha 7).
- Testes de unidade para os casos: mesma sílaba em duas palavras do sorteio; sílaba certa em posição errada; espaço já preenchido; palavra de três sílabas.
- Decisão de design a registrar: a palavra-senha aparece escrita por inteiro (tarefa de pareamento visual) ou só a imagem com espaços vazios (tarefa de análise silábica, mais difícil e dependente de a criança reconhecer a imagem)? Uma opção intermediária parametrizável cobre os dois casos. Isso afeta a dificuldade, a taxa de erro e a Armadilha 9.

**Sinais de alerta:**
- O código de validação compara textos de palavras em vez de índices de espaço.
- Não existe teste para "CA jogada em BOCA quando CASA também está na mesa".
- Discussão recorrente na equipe sobre "onde a carta deveria ir".

**Fase:** F1.

---

### Armadilha 5: Deixar a exportação Android para o final

**O que dá errado:**
O jogo funciona no editor durante semanas e, na véspera da entrega, o APK não gera, não instala ou abre em tela preta. Causas comuns:

- Ferramentas ausentes ou em versão errada. A documentação estável (Godot 4.7) pede OpenJDK 17, Android SDK Platform 35, Build-Tools 35.0.1, Platform-Tools 35 ou superior, Command-line Tools, e caminhos configurados em Editor Settings. Modelos de exportação precisam ser da mesma versão do editor.
- "Could not install to device": já existe no aparelho um app com o mesmo nome de pacote e outra assinatura (por exemplo, APK gerado no computador do outro integrante, com outro debug keystore). Solução: desinstalar antes.
- Arquitetura: aparelhos de entrada com Android de 32 bits não rodam APK só com arm64-v8a. A documentação diz que, ao marcar armeabi-v7a, é preciso manter arm64-v8a marcado também. Qual é o padrão do preset na versão usada não foi confirmado: conferir no próprio preset.
- Maiúsculas e minúsculas em caminhos: o Windows aceita `res://cartas/CA.png` carregado como `ca.png`; o pacote exportado no Android não. Funciona no editor, falha no aparelho.
- Recursos carregados por caminho montado em texto (`load("res://img/" + palavra + ".png")`) podem não entrar no pacote ou falhar por nome; com 30 palavras e 22 sílabas isso é tentador.
- Bloqueios do aparelho: instalação de fontes desconhecidas, aviso do Play Protect, depuração USB desativada.

**Por que acontece:**
Exportar parece uma etapa final. Na prática, é uma integração com ferramentas externas, com várias formas de falhar que nada têm a ver com o jogo.

**Como evitar:**
- Na F0, antes de qualquer regra: gerar um APK de depuração com uma cena vazia e instalar em pelo menos um aparelho real. Só então seguir.
- Fixar a versão do Godot para os dois integrantes e anotá-la no repositório.
- APK de depuração basta para a apresentação. Não gastar tempo com keystore de release, AAB ou Play Store (AAB exige build com Gradle e só serve para a loja).
- Convenção de nomes: tudo em minúsculas com sublinhado (`ca.png`, `gato.png`), sem acentos nem espaços em nomes de arquivo.
- Referenciar ilustrações e cartas por recursos (`preload` ou um Resource com o catálogo), não por caminhos montados.
- Exportar e testar no aparelho ao fim de cada fase, não só na última.
- Levar para a apresentação: build de PC, APK já instalado e um aparelho reserva.

**Sinais de alerta:**
- Fim da F1 sem nenhum APK instalado em aparelho.
- Só um dos dois integrantes consegue exportar.
- Imagem que aparece no editor e some no aparelho.

**Fase:** F0. Repetição ao fim de cada fase.

---

### Armadilha 6: Interação pensada para mouse (arrastar, hover, um ponteiro) em um jogo de toque com várias mãos

**O que dá errado:**
- Arrastar e soltar é a tradução óbvia de "colocar a carta na mesa", mas a literatura de interação infantil trata o arrasto como um dos gestos mais difíceis para crianças pequenas: o dedo levanta no meio, a carta volta, a criança acha que errou. NN/g recomenda permitir tocar no destino como alternativa ao arrasto.
- O sistema nativo de drag-and-drop dos nós Control (`_get_drag_data`, `_can_drop_data`, `_drop_data`) é dirigido por mouse. No toque ele depende da emulação de mouse a partir do toque, tem distância mínima de início de arrasto fixa e a pré-visualização é posicionada pelo motor. Relatos de fórum, sem confirmação oficial (confiança BAIXA): precisa ser testado em aparelho antes de ser adotado.
- Estados de hover (destacar ao passar o mouse, tooltips) não existem no toque. Se a indicação de "pode soltar aqui" depender de hover, some no Android.
- Várias mãos na tela: com quatro crianças em volta de um aparelho, é comum haver dedos apoiados na borda ou outro colega tocando ao mesmo tempo. A emulação de mouse segue um único toque; toques extras podem cancelar ou desviar o gesto.
- O botão "voltar" do Android fecha o jogo no meio da partida.

**Por que acontece:**
O desenvolvimento acontece no PC com mouse, que é preciso, único e tem hover. O teste em aparelho chega tarde.

**Como evitar:**
- Interação primária: tocar na carta (ela sobe e fica destacada) e tocar no espaço de destino. Funciona igual com mouse e toque, não exige manter o dedo pressionado e tolera imprecisão. Arrastar entra depois, como atalho opcional, se sobrar tempo.
- Tratar a entrada em um só lugar, com eventos de clique/toque equivalentes, em vez de espalhar `InputEventMouseButton` pelo código. Manter ligada a emulação de mouse a partir do toque e testar no PC com a emulação de toque a partir do mouse ligada.
- Ignorar toques adicionais enquanto há uma seleção em andamento; só as cartas do mago da vez respondem.
- Destaque dos destinos baseado em estado (carta selecionada), nunca em hover.
- Desativar o encerramento pelo botão voltar (`application/config/quit_on_go_back`) e tratar o pedido de voltar com uma confirmação simples, de preferência voltada ao adulto.
- Testar no aparelho com duas pessoas tocando ao mesmo tempo.

**Sinais de alerta:**
- Código de interação que só trata eventos de mouse.
- A carta "escapa" do dedo no aparelho, mas funciona no PC.
- Qualquer elemento que só reage a hover.

**Fase:** F2 (decisão de interação no início da fase; teste em aparelho na mesma fase).

---

### Armadilha 7: Layout que só funciona na resolução do editor

**O que dá errado:**
A mesa (4 palavras ilustradas, 8 a 10 espaços, mão de 5 ou 6 cartas, 4 indicadores de mago, baralho, cofre) é montada em 1920x1080 com posições fixas. Em um celular 20:9 sobram faixas ou cortam-se elementos; em um tablet 4:3 a mão sai da tela; no celular real as cartas ficam com 6 mm de largura. Recortes de câmera e cantos arredondados cobrem o indicador de turno.

**Por que acontece:**
Posições absolutas são mais rápidas que contêineres. O monitor do PC esconde o problema de tamanho físico.

**Como evitar:**
- Configuração recomendada pela documentação oficial para 2D móvel em paisagem: base 1280x720, stretch mode `canvas_items`, aspect `expand`, e âncoras/contêineres nos nós Control. Fixar orientação paisagem.
- Montar a mesa com contêineres (HBox/VBox/Grid, MarginContainer) desde a primeira versão, não "depois".
- Margem de segurança nas bordas; consultar `DisplayServer.get_display_safe_area()` se algum aparelho de teste tiver recorte.
- Orçamento de tela: decidir o tamanho mínimo físico dos alvos (Armadilha 8) e verificar se 4 palavras mais a mão cabem em um celular de cerca de 6 polegadas. Se não couber, a solução é de design (mostrar só a mão do mago da vez; palavras em grade 2x2), não de reduzir a fonte.
- Testar três proporções na janela do editor: 16:9, 20:9 e 4:3.
- Mão que cresce: se a regra permitir comprar sem descartar, a mão não tem limite e estoura o layout. Definir limite de mão nos parâmetros.
- Ilustrações em SVG (caso do OpenMoji) são rasterizadas na importação: importar em escala suficiente para o maior tamanho exibido, senão ficam borradas.

**Sinais de alerta:**
- Nós com posição digitada à mão em pixels.
- Ninguém redimensionou a janela do jogo durante o desenvolvimento.
- Texto de sílaba com menos de cerca de 5 mm de altura no aparelho.

**Fase:** F0 (configuração do projeto), F2 (layout com contêineres).

---

### Armadilha 8: Interface de adulto para quem está aprendendo a ler

**O que dá errado:**
- Instruções em texto: uma tela de "Como jogar" com parágrafos, para um público que está justamente em alfabetização. Ninguém lê; o adulto precisa explicar tudo.
- Alvos pequenos: NN/g recomenda alvos de cerca de 2 cm x 2 cm para crianças pequenas (o dobro do lado recomendado para adultos). Estudos de Anthony et al. mostram que os toques de crianças caem fora do alvo com muito mais frequência e, em geral, logo ao lado dele.
- Erro punitivo e público: som de buzina, X vermelho, tremor forte, contador de erros, perda de ponto. Em um aparelho compartilhado todo feedback é público; isso colide com a restrição ética do projeto ("sem exposição pública de erros").
- Identificação só por cor: vermelho e verde são exatamente o par confundido no daltonismo mais comum; o amarelo tem baixo contraste sobre o fundo azul-claro das cartas. A marcação de autoria por cor fica ilegível para parte dos usuários e em projetor.
- Tipografia: caixa mista ou fonte decorativa. Na alfabetização brasileira o início é em letra bastão maiúscula; as cartas físicas já são assim.

**Por que acontece:**
A equipe testa com adultos leitores (restrição ética legítima do projeto), então nenhum desses problemas aparece nos testes.

**Como evitar:**
- Instrução por demonstração: na primeira jogada, uma mão animada mostra "toque na carta, toque no espaço". Texto de apoio com no máximo uma frase curta em maiúsculas. Ícones para as ações (trocar, passar). Texto longo só na área do adulto.
- Alvo mínimo: definir em milímetros e converter para a resolução base. Meta: cartas e espaços com lado de 15 a 20 mm no celular de teste; área de toque maior que o desenho; espaçamento entre cartas; tolerância para toques logo fora do alvo.
- Erro neutro: a carta volta para a mão com uma animação suave e um som brando, sem palavra "errado", sem vermelho, sem contador, sem perda de ponto. Depois de duas tentativas erradas seguidas, um brilho discreto indica onde a carta serve (ou que ela não serve agora). O acerto é comemorado; o erro só não acontece.
- Cada mago com cor e um segundo sinal: forma ou símbolo (estrela, lua, sol, raio) e/ou chapéu diferente. A marca na sílaba colocada usa a cor e o símbolo. Ajustar o amarelo para um tom mais escuro ou usar contorno.
- Tudo em maiúsculas, fonte sem serifa de traço simples, alto contraste entre sílaba e fundo.
- Protocolo de teste com adultos que simule a restrição: o testador não lê nenhum texto da tela, usa a mão não dominante e joga no celular, não no PC.

**Sinais de alerta:**
- Qualquer tela com mais de uma linha de texto dirigida à criança.
- Feedback de erro com cor vermelha ou som grave.
- Captura de tela em tons de cinza em que não se distingue quem colocou cada sílaba.
- Botão que o adulto testador erra com o polegar.

**Fase:** F2 (tamanhos e identificação dos magos), F4 (feedback, instrução animada), F5 (protocolo de teste).

---

### Armadilha 9: Arte "grátis da internet" sem licença registrada e sem unidade visual

**O que dá errado:**
- Licenças diferentes tratadas como iguais. Kenney é CC0 (sem exigência de crédito). OpenMoji é CC BY-SA 4.0: crédito obrigatório, indicação de alterações, e adaptações (recolorir, recortar, combinar) precisam ser distribuídas sob a mesma licença. Se a obrigação alcança o jogo inteiro não está resolvido no FAQ do OpenMoji; para um protótipo acadêmico o risco é baixo, mas deve constar no relatório.
- Imagens de busca do Google, de bancos "grátis" com cadastro (em geral exigem crédito e proíbem redistribuir os arquivos, o que um repositório público faz), fontes "grátis para uso pessoal" e sons CC BY-NC entram no projeto sem registro. Na banca, a pergunta "de onde veio esta imagem?" fica sem resposta. (Confiança MÉDIA: termos de cada site precisam ser lidos no momento do uso.)
- Faltam ilustrações. São 30 substantivos, vários difíceis de achar em pacotes de jogos ou de emoji: CANO, GOLA, MOLA, MATO, PANO, SACO, TAPETE, CARA. Não foi verificada a cobertura real em nenhum pacote (confiança BAIXA); o levantamento precisa ser feito pela equipe.
- Ilustrações de fontes diferentes resultam em estilos misturados (emoji de contorno ao lado de pixel art ao lado de foto).
- Ambiguidade de imagem: PATO/PATA e GATO/GATA diferem só pelo gênero; PATA também é a pata do animal; CARA, MATO e GOLA são difíceis de desenhar de modo inequívoco. Se a palavra não estiver escrita, a criança não tem como saber qual é.
- As ilustrações do PDF do protótipo físico já existem, mas a origem e a licença delas não constam no PROJECT.md.

**Por que acontece:**
A busca por imagens acontece no fim, com pressa, e o registro de licença parece burocracia.

**Como evitar:**
- Primeira tarefa da F3: planilha das 30 palavras com fonte, autor, licença e link de cada imagem, antes de importar qualquer arquivo. Mesma planilha para fontes e sons.
- Descobrir de onde vieram as ilustrações do PDF físico. Se a licença permitir, reutilizá-las resolve cobertura e unidade de estilo de uma vez.
- Escolher uma única família visual para as 30 ilustrações. Lista permitida: CC0, CC BY, CC BY-SA, OFL (fontes). Fora: "uso pessoal", NC, origem desconhecida.
- Arquivo `CREDITOS.md` no repositório e tela de créditos no jogo, gerados da mesma planilha. Texto sugerido pelo OpenMoji: "All emojis designed by OpenMoji – the open-source emoji and icon project. License: CC BY-SA 4.0".
- Palavra sem imagem adequada: como o sorteio é sobre uma lista, uma palavra pode ser desativada no catálogo sem quebrar o jogo. É decisão da equipe (altera o conteúdo de 30 palavras), mas é a saída barata.
- Pares ambíguos (PATO/PATA, GATO/GATA): exibir a palavra escrita ou ao menos a sílaba final distinta; não sortear os dois do mesmo par na mesma partida.

**Sinais de alerta:**
- Arquivo de imagem no projeto sem linha correspondente na planilha.
- Imagens com marca-d'água ou vindas de captura de tela.
- Adulto testador que não reconhece a ilustração.

**Fase:** F3 (levantamento no primeiro dia da fase; pode começar em paralelo à F1, pois não depende de código).

---

### Armadilha 10: Escopo maior que o prazo

**O que dá errado:**
Com 3 a 5 semanas, duas pessoas e outras disciplinas no fim do semestre, o projeto chega à apresentação com menu bonito, animação de cofre e mago personalizado, mas sem uma partida que termine. Ou a partida termina no PC e o APK não abre.

**Por que acontece:**
- As partes visíveis (arte, animação, menus) são mais prazerosas que regras e exportação.
- "Regras parametrizadas" vira motor de regras genérico.
- Trabalho em paralelo nos mesmos arquivos de cena (`.tscn`) gera conflitos de merge difíceis de resolver. O diretório do projeto ainda não é um repositório git.
- Cada item do PROJECT.md parece pequeno; juntos, não cabem.

**Como evitar:**
- Ordem estrita por valor: (1) partida completa com retângulos e texto no PC; (2) a mesma partida em APK no aparelho; (3) regras ajustadas; (4) ilustrações e identidade dos magos; (5) feedback e cofre; (6) o resto. Cada etapa termina com algo demonstrável.
- Definir já a lista de corte, em ordem: arrastar e soltar, sons, animação elaborada do cofre, menu de opções, telas de instrução, modo de 1 jogador com tratamento especial. Cortar sem culpa.
- Parametrizar significa um arquivo com 4 ou 5 números (mão, troca, jogadas por turno, limiar de ajuda, palavras por partida), não um sistema.
- Criar o repositório git na F0, com `.gitignore` do Godot (pasta `.godot/`). Dividir o trabalho por cena: uma pessoa nas regras (scripts puros), outra na mesa (cenas). Cenas pequenas e instanciadas reduzem conflitos.
- Congelar funcionalidades uma semana antes da entrega; a última semana é só teste, correção e build.
- Reservar tempo para o relatório e os slides da disciplina; costumam consumir os últimos dias.

**Sinais de alerta:**
- Fim da primeira semana sem partida completa em versão "feia".
- Tarefas de arte ou animação iniciadas antes de existir condição de vitória.
- Conflito de merge em arquivo `.tscn`.
- Frase "depois a gente exporta".

**Fase:** todas; a ordem das fases do roadmap é a própria prevenção. F0 para repositório e corte de escopo.

---

## Armadilhas Moderadas

### Pass-and-play com mãos secretas
**O que dá errado:** copiar o jogo de mesa e esconder a mão de cada mago exige uma tela de "passe o aparelho" a cada turno, que dobra o número de toques e o tempo de espera. Em um jogo cooperativo, o segredo não tem função.
**Prevenção:** mostrar só a mão do mago da vez, sem segredo (quem está ao lado pode ver e ajudar). Uma transição curta com a cor e o símbolo do mago marca a troca de turno. Decidir na F2.

### Renderer errado na criação do projeto
**O que dá errado:** o projeto nasce em Forward+ (padrão para desktop), que a documentação declara inadequado para móveis; ou em Mobile, que exige Vulkan e é mais lento que Compatibility em aparelhos antigos.
**Prevenção:** criar o projeto com o renderer Compatibility (OpenGL). A documentação o recomenda para jogos 2D e é o que cobre a maior gama de aparelhos. Não usar efeitos que dependam dos outros renderers. F0.

### Fonte sem acentos ou com acento cortado
**O que dá errado:** as 30 palavras e as 22 sílabas não têm acento, então o problema não aparece nas cartas. Aparece na interface: "MÁGICO", "SÍLABA", "VOCÊ", "PARABÉNS", "VEZ DO MAGO". Fontes de pacotes de jogos muitas vezes só têm ASCII; o Godot troca os caracteres ausentes pela fonte padrão e o texto sai com dois desenhos de letra misturados. Em maiúsculas, o acento fica acima da altura normal e pode ser cortado por rótulos de altura apertada.
**Prevenção:** escolher uma fonte (licença OFL) com Latin estendido e testar na F0 uma tela com "MÁGICO SÍLABA VOCÊ PARABÉNS ÇÃO ÀÉÍÓÚÂÊÔÃÕ" em maiúsculas, no tamanho real de uso. Dar folga vertical aos rótulos. Evitar fontes em que I maiúsculo e L minúsculo se confundem, caso algum texto use caixa mista.

### Lógica de jogo dentro dos nós de interface
**O que dá errado:** as regras ficam espalhadas em scripts de cartas e botões. Não dá para simular partidas, testar regras ou trocar a interação sem reescrever.
**Prevenção:** estado e regras em scripts sem dependência de cena (classes/Resources: baralho, mão, palavra, partida), com sinais para a interface. É o que viabiliza o simulador das Armadilhas 1 a 3. F1.

### Aleatoriedade impossível de reproduzir
**O que dá errado:** um travamento aparece uma vez em teste e nunca mais.
**Prevenção:** um único gerador com semente registrada no log da partida; opção de depuração para iniciar com semente e palavras escolhidas. F1.

### Sorteio de palavras sem critério
**O que dá errado:** sorteio puro produz partidas muito desiguais: 4 palavras iniciadas por CA (fácil e monótono) ou duas palavras dependentes de sílabas de 2 cópias (fim arrastado); pares confundíveis juntos (PATO/PATA).
**Prevenção:** sorteio com restrições simples e parametrizadas: no máximo uma palavra que dependa de sílaba rara; no máximo uma de três sílabas; não sortear os dois de um par quase idêntico. Medir o efeito no simulador. F1.

### Sem áudio, a sílaba é só um desenho
**O que dá errado:** o objetivo pedagógico é consciência silábica, que é sonora. Um jogo mudo vira pareamento visual de formas.
**Prevenção:** é escopo opcional. Se houver tempo na F4, 22 gravações curtas das sílabas e 30 das palavras, feitas pela própria equipe (sem problema de licença), tocadas ao selecionar a carta e ao completar a palavra. Se não houver tempo, registrar como limitação e deixar a leitura em voz alta para o adulto mediador.

---

## Armadilhas Menores

### Tela apaga ou gira durante a partida
**Prevenção:** fixar orientação em paisagem e manter a tela ligada (opção de projeto do Godot) — crianças demoram para decidir. F0.

### Texto de um lado só em volta da mesa
**O que dá errado:** quatro crianças em volta de um tablet deitado veem a tela de lados diferentes.
**Prevenção:** assumir o aparelho em pé ou apoiado, todos do mesmo lado, e dizer isso nas orientações ao adulto. Não tentar girar a interface por jogador.

### Animações que bloqueiam o turno
**O que dá errado:** comemoração de 4 segundos a cada sílaba; toques durante a animação se perdem ou se acumulam.
**Prevenção:** animações curtas (menos de 1 segundo por sílaba, mais longa só na palavra completa e no cofre) e entrada bloqueada de forma explícita enquanto duram. F4.

### Partida perdida ao receber uma notificação
**O que dá errado:** o aparelho sai do jogo e a partida recomeça do zero.
**Prevenção:** fora de escopo salvar partida. Basta garantir que o jogo retome ao voltar do segundo plano; testar uma vez no aparelho. F5.

### Menos de 4 jogadores
**O que dá errado:** telas e textos assumem quatro magos; com 2 jogadores sobram painéis vazios, e com 1 a tela de troca de turno aparece sem sentido.
**Prevenção:** tela inicial com escolha de 1 a 4 magos (toque nos magos que vão jogar); layout e troca de turno derivados dessa lista. F2.

---

## Dívida Técnica

| Atalho | Benefício imediato | Custo depois | Quando é aceitável |
|--------|--------------------|--------------|--------------------|
| Posições fixas em pixels na mesa | Montagem rápida | Layout quebra em outras proporções | Nunca; contêineres desde o início |
| Regras dentro dos scripts das cartas | Menos arquivos | Sem simulador, sem testes, ajuste de regras caro | Nunca neste projeto (as regras ainda vão mudar) |
| Lista de palavras e baralho escritos no código | Rápido | Mudança de conteúdo exige mexer em lógica | Aceitável se estiver em um único arquivo de dados |
| Retângulos coloridos no lugar da arte | Partida jogável cedo | Nenhum, se a troca for por recurso | Recomendado até a F3 |
| Só APK de depuração | Sem keystore, sem Gradle | Não serve para a loja | Aceitável: a entrega é uma apresentação |
| Sem arrastar e soltar | Menos código e menos bugs de toque | Menos semelhança com o jogo físico | Aceitável; tocar e tocar é melhor para o público |
| Carregar imagem por caminho montado em texto | Uma linha de código | Falha só no Android | Nunca |
| Sem repositório git | Zero configuração | Perda de trabalho, sem volta atrás | Nunca |

## Pontos de Integração

| Integração | Erro comum | Abordagem correta |
|------------|-----------|-------------------|
| Android SDK / JDK | Instalar versões arbitrárias; SDK de repositório de distribuição | OpenJDK 17, Platform 35, Build-Tools 35.0.1, conforme a documentação da versão do Godot em uso; caminhos em Editor Settings |
| Modelos de exportação | Versão diferente da do editor | Baixar pelo próprio editor, mesma versão nos dois computadores |
| Instalação no aparelho | Assinaturas diferentes entre os dois integrantes | Desinstalar antes de instalar; ou compartilhar um único debug keystore |
| Arquiteturas do APK | Só arm64 em aparelho de 32 bits | Conferir o preset; marcar armeabi-v7a junto com arm64-v8a se o aparelho de teste exigir |
| OpenMoji | Usar sem crédito; recolorir sem indicar | Crédito na tela e no repositório, indicação de alterações, CC BY-SA 4.0 |
| Kenney | Presumir que todo pacote "grátis" é igual | CC0; conferir o arquivo de licença de cada pacote baixado |

## Armadilhas de Desempenho

Escala irrelevante (um aparelho, uma partida, dezenas de nós). Os riscos reais são poucos:

| Armadilha | Sintoma | Prevenção | Quando aparece |
|-----------|---------|-----------|----------------|
| Ilustrações enormes sem necessidade | APK grande, carregamento lento, falta de memória em aparelho de entrada | Importar no tamanho de exibição (cerca de 256 a 512 px) | 30 imagens de 2000 px ou mais |
| Renderer Forward+/Mobile em aparelho sem Vulkan | Tela preta ou travamento na abertura | Compatibility | Aparelhos antigos ou de entrada |
| Partículas e sombras na abertura do cofre | Queda de quadros no celular | Animação simples com Tween e sprites | Aparelhos de entrada |
| Simulador rodando na thread principal dentro do jogo | Editor congelado | Rodar o simulador como cena/ferramenta separada | Sempre que simular milhares de partidas |

## Segurança e Privacidade

| Erro | Risco | Prevenção |
|------|-------|-----------|
| Pedir nome da criança e gravá-lo | Dado pessoal de criança, contra a restrição ética do projeto | Magos identificados por cor e símbolo; nenhum campo de nome, ou nome só em memória durante a partida |
| Permissões Android desnecessárias no preset (internet, armazenamento) | Aviso na instalação; questionamento da banca | Nenhuma permissão marcada |
| Registro de erros por jogador em arquivo | Exposição de desempenho individual | Não gravar; estatística de teste só agregada e só em build de depuração |
| Links externos ou anúncios vindos de modelos prontos | Criança sai do jogo | Nenhum link clicável fora da área do adulto |

## Armadilhas de UX

| Armadilha | Impacto | Abordagem melhor |
|-----------|---------|------------------|
| Tela de instruções em texto | Criança não lê; adulto explica tudo | Demonstração animada na primeira jogada |
| Alvos pequenos e colados | Toque na carta vizinha, frustração | 15 a 20 mm, espaçamento, área de toque ampliada |
| Erro com vermelho, buzina ou contador | Vergonha diante do grupo | Carta volta suavemente; dica após duas tentativas |
| Magos só por cor | Daltônicos e projetor não distinguem | Cor e símbolo |
| Placar individual ordenado | Competição em jogo cooperativo | Cores nas sílabas; recompensa única |
| Turno morto sem explicação | "Não fiz nada" | Troca generosa apresentada como ação mágica ("trocar cartas"), com animação |
| Não saber de quem é a vez | Mão errada na tela | Faixa de turno com cor e símbolo; só a mão da vez visível |
| Fim de partida seco | Perda do clímax narrativo | Abertura do cofre com os quatro magos e recompensa coletiva, mesmo simples |

## Checklist "Parece pronto, mas não está"

- [ ] **Partida:** termina em 100% das simulações com os parâmetros finais — verificar com pelo menos 10 mil partidas por número de jogadores (1 a 4)
- [ ] **Turnos mortos:** proporção e duração medidas e aceitas pela equipe — verificar no relatório do simulador
- [ ] **Validação:** sílaba certa em posição errada é recusada; mesma sílaba em duas palavras é aceita em ambas — verificar com testes de unidade
- [ ] **Baralho:** soma 100 cartas e reembaralha o descarte ao esgotar — verificar com teste
- [ ] **Android:** APK instalado e partida completa jogada em aparelho real, não só no editor — verificar em pelo menos dois aparelhos, um deles de entrada
- [ ] **Toque:** partida completa jogada só com toque, com outra pessoa tocando na tela ao mesmo tempo
- [ ] **Proporções:** mesa íntegra em 16:9, 20:9 e 4:3
- [ ] **Imagens:** as 30 ilustrações aparecem no aparelho (maiúsculas/minúsculas nos caminhos)
- [ ] **Acentos:** todos os textos de interface em maiúsculas acentuadas renderizam com a mesma fonte e sem corte
- [ ] **1 a 4 jogadores:** cada quantidade jogada do início ao fim
- [ ] **Erro:** nenhum feedback de erro usa vermelho, som agressivo ou contagem
- [ ] **Cores:** captura de tela em tons de cinza ainda permite saber quem colocou cada sílaba
- [ ] **Licenças:** todo arquivo de arte, fonte e som tem linha na planilha; tela de créditos presente
- [ ] **Botão voltar:** não encerra a partida sem confirmação
- [ ] **Apresentação:** build de PC e APK testados na máquina e no aparelho que serão usados no dia

## Estratégias de Recuperação

| Armadilha | Custo | Passos |
|-----------|-------|--------|
| Partida trava em teste | BAIXO | Reproduzir pela semente; aplicar reembaralhamento do descarte e a ajuda após N rodadas sem jogada |
| Turnos mortos demais descobertos tarde | BAIXO se parametrizado; ALTO se não | Aumentar mão e troca; ligar a compra favorecida; em último caso reduzir o baralho de partida |
| APK não gera na última semana | MÉDIO | Apresentar no PC (plataforma já prevista); em paralelo refazer a configuração em uma máquina limpa seguindo a documentação |
| APK abre em tela preta | MÉDIO | `adb logcat`; conferir renderer (Compatibility), arquitetura e caminhos de recursos |
| Arrastar e soltar instável no toque | BAIXO | Desligar o arrasto e manter tocar e tocar |
| Layout quebrado em outro aparelho | MÉDIO | Trocar aspect para `keep` (faixas pretas) como contenção; refazer com contêineres se houver tempo |
| Imagem com licença inadequada | BAIXO | Substituir pela planilha; ou desativar a palavra no catálogo |
| Fonte sem acentos | BAIXO | Trocar a fonte no tema global (por isso usar um único tema) |
| Prazo estourando | — | Aplicar a lista de corte da Armadilha 10, de cima para baixo |

## Mapa Armadilha → Fase

| Armadilha | Fase de prevenção | Verificação |
|-----------|-------------------|-------------|
| 1. Estados sem saída | F1 | Simulação com 100% de término; teste de reembaralhamento |
| 2. Turnos mortos | F1, ajuste na F5 | Taxa de turnos mortos e duração no relatório do simulador; observação nos testes |
| 3. Dominância / zero ponto | F1 (métrica), F2, F4 | Percentual de partidas com jogador sem ponto; tela final sem ranking |
| 4. Ambiguidade de colocação | F1 | Testes de unidade dos casos de sílaba compartilhada e de posição |
| 5. Exportação Android tardia | F0, repetida a cada fase | APK instalado em aparelho real ao fim da F0 e de cada fase |
| 6. Interação de mouse no toque | F2 | Partida completa só com toque, no aparelho |
| 7. Layout fixo | F0 (configuração), F2 | Três proporções testadas; medida física dos alvos |
| 8. UX de adulto | F2, F4, F5 | Protocolo de teste sem leitura e com mão não dominante; checklist de erro e cor |
| 9. Licenças e arte | F3 (levantamento pode começar junto com a F1) | Planilha completa; tela de créditos |
| 10. Escopo | F0 e ordem do roadmap | Partida "feia" completa ao fim da primeira semana; congelamento uma semana antes da entrega |
| Renderer | F0 | Projeto criado em Compatibility |
| Fonte e acentos | F0 | Tela de teste de acentos no aparelho |
| Sorteio de palavras | F1 | Restrições cobertas por teste; efeito medido no simulador |

## Lacunas e pontos a validar

- **Regras definitivas de mão/compra/troca:** não existem ainda. Todos os números de simulação usam regras hipotéticas e jogador guloso (sempre joga uma carta útil quando tem). Jogadores reais, sobretudo crianças, deixam passar cartas úteis, o que piora os turnos mortos.
- **Drag-and-drop nativo de Control no Android:** apenas relatos de fórum; nenhum defeito confirmado na documentação. Testar em aparelho se a equipe quiser arrasto.
- **Arquiteturas padrão do preset Android na versão usada:** não confirmado.
- **Cobertura das 30 ilustrações em Kenney/OpenMoji:** não verificada.
- **Origem e licença das ilustrações do PDF do protótipo físico:** desconhecidas.
- **Alcance do share-alike do OpenMoji sobre o jogo como um todo:** o FAQ não resolve; remete à issue 462 do projeto.
- **Comportamento com crianças reais:** fora do escopo ético do projeto; todas as recomendações de UX infantil vêm de literatura, não de observação.
- **Versão do Godot:** a documentação "stable" consultada é a 4.7. Se a equipe usar outra versão, conferir os requisitos de SDK/JDK na documentação daquela versão.

## Fontes

Documentação oficial do Godot (confiança ALTA):
- Exportação para Android: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
- Múltiplas resoluções: https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html
- Renderers: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
- Coordenadas de entrada: https://docs.godotengine.org/en/stable/tutorials/inputs/mouse_and_input_coordinates.html

Licenças (confiança ALTA):
- OpenMoji FAQ (CC BY-SA 4.0): https://openmoji.org/faq/
- Kenney, suporte e licença (CC0): https://kenney.nl/support

UX infantil (confiança MÉDIA):
- NN/g, desenvolvimento físico e UX para crianças (alvos de 2 cm): https://www.nngroup.com/articles/children-ux-physical-development/
- Brown e Anthony, CHI 2012 (precisão de toque de crianças): https://lisa-anthony.com/wp-content/uploads/2012/03/brown-and-anthony-chi2012eist.pdf
- Anthony et al., IJHCS 2019 (arrasto difícil para crianças pequenas, citando estudos anteriores): https://init.cise.ufl.edu/wp-content/uploads/sites/378/2019/03/anthony-et-al-IJHCS2019-MTAGIC-final-preprint.pdf
- UXPA Magazine, Playful Interfaces (tolerância espacial e temporal): https://oldmagazine.uxpa.org/?p=11776

Comunidade Godot (confiança BAIXA, não confirmado oficialmente):
- Drag and drop em Godot 4.x: https://dev.to/pdeveloper/godot-4x-drag-and-drop-5g13
- Distância de início de arrasto: https://forum.godotengine.org/t/how-modify-drag-distance-reduce-it-under-10-pixels/119559
- Posição de soltura em dispositivos móveis: https://forum.godotengine.org/t/drop-data-position-on-mobile-devices/11760
- APK de release que não instala: https://forum.godotengine.org/t/release-apk-cant-be-installed/22281

Análise própria (confiança ALTA nos cálculos, MÉDIA na transposição para jogadores reais):
- Contagem de demanda e oferta de sílabas e simulação Monte Carlo (4 mil a 20 mil partidas por configuração) sobre a lista de palavras e a distribuição de cartas do PROJECT.md.

---
*Pesquisa de armadilhas para: jogo educativo cooperativo de cartas de sílabas em Godot (Cofre Mágico)*
*Pesquisado em: 2026-11-11*
