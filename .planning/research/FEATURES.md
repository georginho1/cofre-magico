# Pesquisa de Features

**Domínio:** jogo digital educativo cooperativo de cartas para alfabetização (sílabas CV), 7 a 9 anos, pass-and-play em um aparelho, Godot (Android + PC)
**Pesquisado em:** 2026-11-11
**Confiança geral:** MÉDIA

> Como ler a confiança: ALTA = documentação oficial ou fonte primária lida; MÉDIA = várias fontes concordam ou fonte oficial lida de forma indireta; BAIXA = fonte única, cobertura secundária ou conhecimento de treino não verificado.
>
> Limite importante: quase toda a pesquisa de interação infantil encontrada trata de pré-escolares (3 a 6 anos) ou de pares de crianças em tablets. Para 7 a 9 anos as recomendações são extrapolação. Como o protótipo só será testado com adultos, nenhuma destas features poderá ser validada com o público real neste ciclo; isso deve aparecer como limitação no relatório da disciplina.

## Três achados que mudam os requisitos

1. **A partida mínima é muito curta.** Com 28 palavras de duas sílabas e 2 de três, quatro senhas exigem só 8 a 10 jogadas corretas. Com 4 jogadores, cada mago coloca em média 2 sílabas. A duração real da partida vai depender quase inteiramente de quantas vezes a mão não tem carta útil. Consequência: o número de senhas por partida (ou de cofres em sequência) precisa ser parâmetro, junto com tamanho de mão e regras de compra/troca. (Cálculo próprio sobre o conteúdo do PROJECT.md; confiança ALTA na conta, sem dado sobre a duração real.)
2. **"Sem exposição pública de erro" é difícil em tela compartilhada.** Todos veem a mesma tela, então o erro não pode ser escondido, só pode ser tratado de forma neutra. A solução do gênero é a carta voltar para a mão com animação suave, sem X vermelho, sem som de buzina, sem contador de erros e sem perda de turno punitiva.
3. **Vermelho e verde são o par mais problemático para daltonismo**, e são dois dos quatro magos. Cor sozinha não pode identificar o autor da sílaba; cada mago precisa de um símbolo próprio.

## Panorama de Features

### Table stakes (o usuário espera)

Faltando qualquer uma, o jogo parece quebrado ou inadequado para o público.

| Feature | Por que é esperada | Complexidade | Notas |
|---------|--------------------|--------------|-------|
| Tela de preparação mínima: escolher 1 a 4 jogadores e começar | Todo jogo hot-seat tem; o sorteio automático das senhas dispensa o resto | BAIXA | Um toque por mago para ativá-lo; sem digitar nomes (digitar é barreira para quem está aprendendo a ler) |
| Indicador de turno persistente e inequívoco | Em pass-and-play a pergunta "de quem é a vez?" é a principal fonte de confusão | BAIXA | Mago ativo grande, com cor + símbolo; a moldura da mão adota a identidade do mago |
| Passagem de vez explícita ("Vez do Mago Azul" + toque para começar) | Padrão do gênero; evita que o jogador anterior toque por engano na vez do próximo | BAIXA | Não precisa ser tela de privacidade: o jogo é cooperativo, as mãos podem ficar abertas. Ver anti-features |
| Jogar carta por toque-toque (toca a carta, toca a posição) | Funciona igual com dedo e mouse; é o gesto mais robusto para crianças | BAIXA | Deve ser o modo primário. Posições válidas ficam destacadas depois de selecionar a carta |
| Alvos de toque grandes e espaçados | Motricidade fina ainda em desenvolvimento; celulares têm tela pequena | BAIXA | Meta prática: cartas e posições com pelo menos 9 a 12 mm físicos e folga entre elas. Em celular, isso limita a mão a cerca de 5 cartas visíveis; valor a calibrar em aparelho real (número é regra prática, confiança BAIXA) |
| Validação automática com retorno imediato | Já é requisito; crianças esperam resposta imediata ao toque | BAIXA | Resposta em menos de ~200 ms, com som e animação |
| Feedback de acerto positivo e multimodal | Padrão em todo app do gênero | BAIXA | Carta encaixa, brilho, som curto, marca do mago aparece |
| Feedback de erro neutro, sem vergonha | Requisito ético do projeto e prática recomendada | BAIXA | Carta volta à mão com balanço suave e som neutro. Sem X, sem vermelho, sem texto "errado", sem contador. O jogador pode tentar de novo no mesmo turno (parametrizável) |
| Saída para mão sem carta útil (comprar/trocar) sempre visível | Sem isso o jogador trava e a partida empaca | MÉDIA | Já é requisito. O botão precisa ser óbvio e, quando a mão não tem jogada possível, deve pulsar. É o principal ponto de ajuste de balanceamento |
| Palavras-senha com ilustração grande e posições vazias visíveis | É o que dá sentido à tarefa para quem ainda não lê com fluência | BAIXA | Ilustração acima, uma caixa por sílaba (como no protótipo físico). O progresso é o próprio preenchimento |
| Tipografia de alfabetização: caixa alta, sem serifa, grande | Convenção brasileira dos anos iniciais (letra bastão); o baralho físico já é assim | BAIXA | Uma fonte só, com formas simples e licença livre. Sílaba como maior elemento da carta |
| Alto contraste em texto e cartas | Requisito do projeto; leitura letra a letra depende de legibilidade | BAIXA | Texto escuro sobre carta clara; conferir contraste de pelo menos 4,5:1 (referência WCAG) |
| Identidade dos magos não dependente só de cor | Vermelho/verde é o par clássico de confusão; cerca de 1 em 12 meninos tem alguma deficiência de visão de cores | BAIXA | Cor + símbolo por mago (por exemplo estrela, lua, folha, sol) em todo lugar onde a cor aparece: indicador de turno, marca na sílaba, placar. Ligado por padrão, não como "modo daltônico" |
| Efeitos sonoros básicos com botão de mudo | Som confirma que o toque foi registrado; sala de aula exige poder silenciar | BAIXA | Poucos sons: selecionar, encaixar, voltar, palavra completa, cofre |
| Celebração coletiva ao abrir o cofre | É o clímax da narrativa e a recompensa do grupo | MÉDIA | Animação do cofre + som + mensagem de grupo. Deve dar para ver em poucos segundos e ser reiniciável |
| Tela de fim com "jogar de novo" | Padrão; partidas curtas pedem repetição | BAIXA | Novo sorteio de senhas, mesmos jogadores |
| Pausa/sair com confirmação | Toques acidentais são comuns; adulto precisa poder interromper | BAIXA | Botão pequeno em canto superior, longe da mão de cartas |
| Orientação paisagem fixa e layout que escala (celular, tablet, PC) | Grupo em volta de um aparelho; builds para Android e PC | MÉDIA | Definir resolução-base e modo de stretch cedo; testar no menor celular disponível |
| Funcionamento totalmente offline, sem contas, sem anúncios, sem coleta | Requisito ético; escolas têm rede instável | BAIXA | É ausência de feature, mas precisa ser declarada como requisito |

### Diferenciais (onde o jogo se destaca)

O valor central do projeto é cooperação com contribuição individual visível. É aí que vale diferenciar; o resto é opcional.

| Feature | Proposta de valor | Complexidade | Notas |
|---------|-------------------|--------------|-------|
| Autoria visível: sílaba marcada com cor + símbolo do mago | É o diferencial do conceito. Apps de sílabas do mercado são individuais; aqui cada criança vê o que contribuiu para o grupo | BAIXA | Já é requisito. A marca precisa sobreviver até a tela final |
| Tela final "o que cada mago fez" sem ranking | Dá senso de contribuição sem transformar em competição | BAIXA | Mostrar as quatro palavras com as marcas e o total do grupo em destaque. Não ordenar os magos por pontos |
| Áudio da palavra ao completar a senha | Liga grafia, imagem e som; é o que apps de alfabetização como GraphoGame e Lele Sílabas fazem e o que falta em um baralho físico | BAIXA | 30 clipes gravados. No gênero é table stakes; aqui é o primeiro diferencial a entrar. Ver nota sobre TTS abaixo |
| Áudio da sílaba ao tocar na carta | Apoia quem ainda não decodifica; reforça consciência silábica | BAIXA | 22 clipes gravados. Toque na carta fala a sílaba e seleciona |
| Tocar na ilustração para ouvir a palavra-alvo | Resolve imagem ambígua (PANO, GOLA, MATO, CANO são difíceis de ilustrar) sem revelar a grafia | BAIXA | Reaproveita os 30 clipes. Reduz o risco de ícones de licença livre pouco reconhecíveis |
| Arrastar e soltar com encaixe generoso | Mais próximo do jogo físico de cartas; crianças de 6 a 8 anos lidam bem com arrastar | MÉDIA | Complemento ao toque-toque, nunca substituto. Zona de encaixe maior que a caixa; soltar fora devolve a carta sem penalidade |
| Dica por inatividade | Evita travamento sem depender do adulto | MÉDIA | Depois de N segundos parado, pulsar uma carta jogável ou o botão de troca. N parametrizável; pode ser desligado |
| "Como jogar" ilustrado em 3 passos + primeiro turno guiado | Instrução curta, visual, sem depender de leitura | MÉDIA | Três quadros com imagem e uma frase cada; reabrível pelo botão "?". Primeiro turno com destaque pulsante no que tocar |
| Painel do adulto com as regras parametrizadas | Professor ajusta dificuldade; a equipe ajusta balanceamento nos testes | MÉDIA | Tamanho da mão, número de senhas, regras de compra/troca, tentativas por turno, dica ligada/desligada, som. Já é requisito ter os parâmetros; expô-los em tela é o diferencial |
| Vários cofres em sequência (sessão de N cofres) | Controla duração da sessão, já que uma partida mínima tem 8 a 10 jogadas | BAIXA | Parâmetro simples: ao abrir o cofre, novo sorteio sem repetir palavras |
| Resumo da partida para o teste (tempo, turnos, trocas, tentativas devolvidas, totais do grupo) | Fornece dados para o relatório acadêmico sobre tempo de partida e equilíbrio do baralho | BAIXA | Somente em memória ou arquivo local, agregado por partida, nunca por criança. Atrás de uma opção do painel do adulto |

**Nota sobre áudio: gravar, não sintetizar.** O Godot 4 tem TTS nativo (`DisplayServer.tts_speak`), mas a documentação oficial avisa que no Android as vozes dependem do que está instalado no aparelho e algumas dependem de serviço web. Há ainda um relato isolado de travamento ao consultar vozes em Android sem TTS instalado (fonte única, BAIXA). Além disso, sintetizadores tendem a ler sílabas isoladas de forma estranha (afirmação de conhecimento geral, não verificada). São só 52 clipes curtos (22 sílabas + 30 palavras): gravar com celular é mais rápido e mais confiável que integrar TTS. Confiança MÉDIA.

### Anti-features (parecem boas, mas atrapalham)

| Feature | Por que pedem | Por que é problema | Alternativa |
|---------|---------------|--------------------|-------------|
| Feedback de erro "claro" (X vermelho, buzina, tremor forte, "Errado!") | Parece didático | Expõe a criança diante do grupo; contraria o requisito ético. Auditorias de apps infantis mostram que som/X de erro não ensina nada sozinho | Devolver a carta de forma neutra e destacar as posições ainda abertas |
| Ranking, pódio ou "mago vencedor" no final | Pontos individuais sugerem placar | Converte o jogo cooperativo em competição e expõe quem contribuiu menos (com 8 a 10 jogadas, alguém pode ficar com zero) | Mostrar contribuições sem ordem e o total do grupo em destaque |
| Cronômetro por turno ou por partida visível | Aumenta tensão e controla duração | Pressão de tempo prejudica quem decodifica devagar e incentiva colegas a tomarem o aparelho | Controlar duração pelo número de senhas/cofres; dica por inatividade em vez de limite |
| Vidas, derrota, "game over" | Padrão de jogos | Não há condição de derrota no conceito; punição não combina com prática de leitura mediada | Partida sempre termina com o cofre aberto; dificuldade vem do baralho |
| Tela de privacidade para esconder a mão entre turnos | Padrão de hot-seat competitivo | No cooperativo, esconder a mão impede ajuda entre colegas e adiciona um toque a cada turno | Mãos abertas ou só a do mago ativo em destaque; faixa "Vez do Mago X" com toque para começar |
| Somente arrastar e soltar | É o gesto "natural" de cartas | Dedo que levanta no meio do arrasto perde a jogada; pior em celular pequeno e inconsistente com mouse | Toque-toque como base; arrastar como complemento |
| Tutorial longo em texto ou narrado obrigatório | Explica todas as regras | Leitores iniciantes não leem; narração completa custa gravação e roteiro; adulto está presente | 3 quadros ilustrados puláveis + primeiro turno guiado |
| Perfis, contas, progresso salvo entre sessões, nuvem | "Acompanhar a evolução" | Coleta de dados de crianças (vedada), complexidade de persistência, nenhum ganho para partidas de poucos minutos | Sem persistência além das configurações do adulto |
| Moedas, loja, itens desbloqueáveis, sequência diária | Aumenta retenção | Escopo grande, desloca a motivação para a recompensa externa e não será avaliado na disciplina | Recompensa única e coletiva: abrir o cofre |
| Dificuldade adaptativa automática | Padrão em apps como GraphoGame | Exige modelo de desempenho por jogador e dados; inviável com vocabulário fechado de 30 palavras e prazo curto | Parâmetros manuais no painel do adulto |
| Portão parental (conta matemática, segurar botão) elaborado | Padrão de lojas de apps | Não há compras, links nem dados a proteger | Painel do adulto atrás de um toque longo no ícone de engrenagem |
| TTS do sistema para ler sílabas | Evita gravar áudio | Depende de vozes instaladas no aparelho; comportamento inconsistente no Android | 52 clipes gravados |
| Animações longas e não puláveis a cada jogada | Dá "magia" | Em pass-and-play, cada segundo de espera é multiplicado por 4 jogadores ociosos | Animações de jogada abaixo de ~1 s; só o cofre recebe animação longa |
| Elementos decorativos interativos (toque no cenário faz barulho) | Encanta | Distrai da tarefa e gera toques acidentais; Sesame Workshop recomenda que adultos possam desligar esse tipo de coisa | Cenário estático |
| Mais de um aparelho, rede, IA adversária, habilidades por mago | Enriquecem o jogo | Já estão fora de escopo no PROJECT.md | Manter fora |

## Dependências entre Features

```
[Modelo de partida: baralho, mãos, senhas, turno]
    ├──requer──> [Dados de conteúdo: 30 palavras + 22 sílabas + distribuição]
    ├──habilita──> [Jogar carta por toque-toque]
    │                  ├──requer──> [Layout paisagem escalável + alvos grandes]
    │                  ├──habilita──> [Validação + feedback de acerto/erro neutro]
    │                  │                  └──habilita──> [Autoria: cor + símbolo na sílaba]
    │                  │                                     └──habilita──> [Tela final de contribuições]
    │                  └──habilita──> [Arrastar e soltar] (complemento)
    ├──habilita──> [Comprar/trocar] ──requer──> [Parâmetros de regra]
    ├──habilita──> [Indicador de turno + passagem de vez]
    │                  └──requer──> [Identidade dos magos: cor + símbolo]
    └──habilita──> [Detecção de fim] ──> [Abertura do cofre] ──> [Jogar de novo / próximo cofre]

[Parâmetros de regra (recurso de configuração)]
    └──habilita──> [Painel do adulto] ──habilita──> [Resumo da partida para teste]

[Barramento de áudio + efeitos sonoros + mudo]
    └──habilita──> [Clipes gravados: 30 palavras, 22 sílabas]
                       ├──> [Palavra falada ao completar]
                       ├──> [Sílaba falada ao tocar]
                       └──> [Tocar na ilustração para ouvir]

[Detecção de "há jogada possível na mão?"]
    ├──habilita──> [Botão de troca pulsando quando a mão está travada]
    └──habilita──> [Dica por inatividade]

[Dica por inatividade] ──conflita──> [Cronômetro de turno] (anti-feature)
[Tela de privacidade da mão] ──conflita──> [Cooperação com mãos abertas]
[Ranking final] ──conflita──> [Tela final de contribuições sem ordem]
```

### Notas de dependência

- **Tudo depende do modelo de partida e do conteúdo em dados.** As 30 palavras e a distribuição das 100 cartas devem estar em um recurso/arquivo de dados, não espalhadas no código, para permitir ajuste de balanceamento.
- **Identidade dos magos (cor + símbolo) vem antes de qualquer tela que mostre turno ou autoria.** Decidir os quatro símbolos e as quatro cores logo no início evita retrabalho em todas as telas.
- **Parâmetros de regra vêm antes do painel do adulto.** Primeiro um recurso de configuração editado no editor; a tela é uma camada fina por cima, que pode entrar depois.
- **A função "há jogada possível?" serve a duas features** (troca pulsando e dica). Implementar uma vez, na lógica, e também usá-la em testes automatizados de balanceamento do baralho.
- **Áudio falado depende só do barramento de áudio e de um mapa texto → clipe.** É independente do restante e pode ser feito em paralelo pelo segundo integrante.
- **Toque-toque antes de arrastar.** O arrastar reutiliza as mesmas zonas de destino e a mesma validação; só entra se sobrar tempo.
- **Vários cofres em sequência depende de "jogar de novo" funcionar** e de o sorteio aceitar uma lista de palavras já usadas.

## Definição de MVP

O prazo é dezembro de 2026 e hoje é 11/11/2026: restam poucas semanas para duas pessoas. O corte abaixo é deliberadamente duro.

### Lançar com (v1, para a apresentação)

- [ ] Preparação: escolher 1 a 4 magos e começar — sem isso não há partida
- [ ] Modelo de partida completo com conteúdo em dados e regras parametrizadas (inclui número de senhas) — núcleo do valor central
- [ ] Layout paisagem escalável com alvos grandes, caixa alta e alto contraste — requisito do público
- [ ] Jogar por toque-toque com posições destacadas — interação mínima robusta em Android e PC
- [ ] Validação automática com feedback de acerto e erro neutro (carta volta à mão) — requisito ético
- [ ] Comprar/trocar, com botão pulsando quando não há jogada possível — evita travamento
- [ ] Magos com cor + símbolo; autoria marcada em cada sílaba — diferencial central e acessibilidade
- [ ] Indicador de turno + faixa de passagem de vez — clareza do pass-and-play
- [ ] Abertura do cofre + tela final de contribuições sem ranking + jogar de novo — fecha o ciclo
- [ ] Efeitos sonoros básicos com mudo; pausa/sair com confirmação
- [ ] Palavra falada ao completar a senha (30 clipes) — último item do v1; é o primeiro a cortar se o cronograma apertar
- [ ] Builds Android (APK) e PC

### Adicionar depois que o núcleo funcionar (v1.x, ainda antes da entrega se houver folga)

- [ ] Sílaba falada ao tocar + tocar na ilustração para ouvir — quando os 30 clipes de palavra já estiverem integrados
- [ ] "Como jogar" em 3 quadros + botão "?" — quando os testes com adultos mostrarem que a primeira partida confunde
- [ ] Painel do adulto em tela — quando for cansativo recompilar para mudar parâmetros durante os testes
- [ ] Resumo da partida para teste — quando os testes de usabilidade começarem
- [ ] Vários cofres em sequência — se as partidas medidas ficarem abaixo de ~5 minutos
- [ ] Dica por inatividade — se os testes mostrarem jogadores parados sem saber o que fazer
- [ ] Arrastar e soltar — só com tudo acima pronto

### Consideração futura (v2+)

- [ ] Primeiro turno guiado interativo — exige máquina de estados de tutorial
- [ ] Sílabas não canônicas e vocabulário ampliado — fora de escopo declarado
- [ ] Habilidades por mago — ideia já registrada para o futuro
- [ ] Testes com crianças e ajuste de alvos, tempos e áudio com dados reais — depende de comitê de ética
- [ ] Relatório para professor entre sessões — só faz sentido com persistência e política de dados

## Matriz de Priorização

| Feature | Valor para o usuário | Custo de implementação | Prioridade |
|---------|----------------------|------------------------|------------|
| Modelo de partida + conteúdo em dados + parâmetros | ALTO | MÉDIO | P1 |
| Jogar por toque-toque com destaque de posições | ALTO | BAIXO | P1 |
| Validação + feedback de acerto/erro neutro | ALTO | BAIXO | P1 |
| Comprar/trocar + aviso de mão travada | ALTO | MÉDIO | P1 |
| Magos com cor + símbolo e autoria na sílaba | ALTO | BAIXO | P1 |
| Indicador de turno + passagem de vez | ALTO | BAIXO | P1 |
| Layout paisagem escalável, caixa alta, contraste, alvos grandes | ALTO | MÉDIO | P1 |
| Cofre + tela final sem ranking + jogar de novo | ALTO | MÉDIO | P1 |
| Preparação 1 a 4 jogadores | ALTO | BAIXO | P1 |
| Efeitos sonoros + mudo, pausa/sair | MÉDIO | BAIXO | P1 |
| Palavra falada ao completar | ALTO | BAIXO | P1 (primeiro a cortar) |
| Sílaba falada ao tocar / ouvir pela ilustração | ALTO | BAIXO | P2 |
| "Como jogar" em 3 quadros | MÉDIO | BAIXO | P2 |
| Painel do adulto em tela | MÉDIO | MÉDIO | P2 |
| Resumo da partida para teste | MÉDIO (para a equipe) | BAIXO | P2 |
| Vários cofres em sequência | MÉDIO | BAIXO | P2 |
| Dica por inatividade | MÉDIO | MÉDIO | P2 |
| Arrastar e soltar | MÉDIO | MÉDIO | P3 |
| Primeiro turno guiado | MÉDIO | ALTO | P3 |

**Legenda:** P1 = obrigatório para a entrega; P2 = entra se houver folga, nesta ordem; P3 = futuro.

## Análise de Produtos Semelhantes

Os detalhes de cada produto vêm de descrições de terceiros (reportagens, artigos, lojas), não de uso direto. Confiança MÉDIA para a existência das features, BAIXA para detalhes de implementação.

| Aspecto | GraphoGame Brasil | Lele Sílabas / Silabando / Formar Palavras | Jogo das Sílabas (acadêmico, Unity) | Nossa abordagem |
|---------|-------------------|--------------------------------------------|--------------------------------------|-----------------|
| Jogadores | Individual | Individual | Individual | Cooperativo, 1 a 4 no mesmo aparelho; é o diferencial |
| Conteúdo | Correspondência fonema-grafema, progressivo | Montagem de palavras a partir de sílabas; Lele Sílabas relata 30 fases e mais de 90 palavras | Vogais, consoantes, separação silábica, imagem-palavra | 30 palavras ilustradas, 22 sílabas CV, sorteio de 4 |
| Áudio | Central ao método (jogo baseado em ouvir e escolher) | Criança escuta os sons silábicos ao montar | Som da palavra ao completar corretamente | Palavra falada ao completar (P1); sílaba ao tocar (P2) |
| Interação | Toque em alvos | Montagem por toque/arrasto | Módulo "Arrastasílabas" com arrastar até o local | Toque-toque; arrastar como complemento |
| Progressão | Níveis adaptativos e perfis | Fases | Módulos | Sem progressão persistente; parâmetros manuais |
| Papel do adulto | Complementa o professor; uso recomendado de até 15 min/dia segundo reportagem | Não identificado | Não identificado | Adulto mediador presente; painel de parâmetros |
| Sessão | Curta (cerca de 15 min/dia) | Não identificado | Não identificado | Alvo de 5 a 15 min por sessão, ajustável por número de senhas/cofres |

O que não encontrei: um app brasileiro de sílabas cooperativo em aparelho compartilhado. A busca não foi exaustiva, então "não existe" não está demonstrado; mas a combinação cooperação + autoria visível pode ser defendida como diferencial do projeto com essa ressalva.

## Recomendações específicas por tema da pergunta

| Tema | Recomendação | Confiança |
|------|--------------|-----------|
| Onboarding para leitores iniciantes | 3 quadros ilustrados com uma frase curta cada, puláveis e reabríveis; contar com o adulto mediador; nada de tutorial textual longo | MÉDIA |
| Feedback sem vergonha | Acerto: som + animação + marca do mago. Erro: carta volta, som neutro, nova tentativa. Nada de contadores de erro visíveis | MÉDIA |
| Áudio | Clipes gravados para 30 palavras e 22 sílabas; efeitos curtos; botão de mudo. Evitar TTS do sistema | MÉDIA |
| Arrastar x tocar | Toque-toque como base (robusto, igual no mouse). Arrastar é viável para 6 a 8 anos e esperado em jogos de carta, mas exige encaixe generoso; fica como complemento | MÉDIA (estudos são de faixas etárias vizinhas) |
| Passagem de vez | Faixa de tela cheia com mago, cor e símbolo + toque para começar. Sem esconder mãos. Estudos com tablets compartilhados mostram que costuma haver uma criança dominante e que turnos rígidos sem atenção conjunta excluem colegas; manter as senhas sempre visíveis para todos ajuda | MÉDIA |
| Progresso e recompensa | Progresso = caixas preenchidas nas quatro senhas. Recompensa = cofre aberto, coletiva. Pontos individuais só como contribuição, sem ordem | MÉDIA |
| Cores dos magos | Tons próximos da paleta Okabe-Ito: vermelhão `#D55E00`, azul `#0072B2`, verde-azulado `#009E73`, amarelo `#F0E442`, sempre com símbolo e contorno escuro. O amarelo some sobre a carta azul-clara sem contorno. Conferir com simulador (Color Oracle) | MÉDIA (paleta verificada; adequação ao fundo do jogo a testar) |
| Tipo e contraste | Caixa alta, sem serifa, sílaba como maior elemento; contraste mínimo 4,5:1 | MÉDIA |
| Configurações do adulto | Tamanho da mão, número de senhas/cofres, regra de compra/troca, tentativas por turno, dica, som. Acesso por toque longo na engrenagem | MÉDIA |
| Duração da sessão | Alvo de 5 a 15 min. Medir nos testes; a partida mínima tem só 8 a 10 jogadas corretas | BAIXA para o alvo, ALTA para a conta |
| Posição dos controles | Estudos com pré-escolares indicam que a criança apoia a mão na borda inferior. A mão de cartas fica naturalmente embaixo; manter botões destrutivos (sair, configurações) no topo | BAIXA para 7 a 9 anos |

## Lacunas

- Nenhuma fonte encontrada trata diretamente de crianças de 7 a 9 anos em jogo de cartas digital cooperativo; as recomendações são extrapoladas.
- Não li o PDF completo do guia do Sesame Workshop (2012); usei a página do Joan Ganz Cooney Center e cobertura secundária. O guia é antigo e voltado a pré-escolares.
- Tamanhos de alvo em milímetros são regra prática, não medida verificada para esta faixa etária.
- Não verifiquei se há voz pt-BR por padrão no TTS do Android nem reproduzi o relato de travamento; a recomendação de gravar áudio evita a questão.
- A reconhecibilidade das 30 ilustrações de licença livre (PANO, GOLA, MATO, CANO, MOLA são candidatas a problema) não foi pesquisada; precisa de checagem na fase de arte.
- A frequência de "mão sem jogada" com a distribuição de 100 cartas não foi simulada. Vale uma simulação simples na fase de regras para escolher tamanho de mão e regra de troca.

## Fontes

- [Joan Ganz Cooney Center: Best Practices: Designing Touch Tablet Experiences for Preschoolers (Sesame Workshop, 2012)](https://joanganzcooneycenter.org/?p=19607) — gestos, paisagem, borda inferior, áudio, controles para adultos (lida diretamente; MÉDIA para 7 a 9 anos)
- [AppleInsider: Sesame Workshop developer guidelines](https://appleinsider.com/articles/12/12/24/sesame-workshop-wants-to-improve-ipad-apps-for-kids-with-free-developer-guidelines) — feedback incremental e encorajador, som para confirmar toque (secundária)
- [UXPA Magazine: Playful Interfaces: Designing Interactive Experiences for Children](https://oldmagazine.uxpa.org/?p=11776) — arrastar x toque-toque, alvos maiores para mais novos
- [Children may expect drag-and-drop instead of point-and-click (TU/e, 2011)](https://research.tue.nl/en/publications/children-may-expect-drag-and-drop-instead-of-point-and-click/) — expectativa de arrastar
- [Documentação do Godot: Text to speech](https://docs.godotengine.org/pt-br/4.x/tutorials/audio/text_to_speech.html) — dependência de vozes do sistema e de serviços web no Android
- [Godot Forums: tts_get_voices crash on Android without TTS](https://godotforums.org/d/42556-displayservertts-get-voices-crashes-on-android-without-tts) — relato único
- [Okabe-Ito palette hex codes reference](https://conceptviz.app/es/blog/okabe-ito-palette-hex-codes-complete-reference) e [ggokabeito manual](https://malcolmbarrett.r-universe.dev/ggokabeito/doc/manual.html) — valores hexadecimais
- [Bugnet: Colorblind-friendly game design](https://bugnet.io/blog/colorblind-friendly-game-design) — cor + forma por padrão (blog; BAIXA isoladamente, coerente com WCAG 1.4.1)
- [Tablet for two: How do children collaborate around single player tablet games? (Univ. Birmingham)](https://research.birmingham.ac.uk/en/publications/tablet-for-two-how-do-children-collaborate-around-single-player-t/) — turnos, atenção conjunta, exclusão
- [Songs of Conquest: pedido de tela de transição em hot-seat](https://songsofconquest.featureupvote.com/suggestions/301088/local-hotseat-multiplayer-needs-a-transition-screen-to-stop-players-seeing-each-) e [Tabletopia: Hotseat mode](https://tabletopia.com/news/hotseat-mode) — padrões de passagem de vez
- [Outhwaite et al. 2023 (UCL): feedback em apps educativos](https://discovery.ucl.ac.uk/10170561/1/Outhwaite%20et%20al.%202023.pdf) e [Observatório Tec de Monterrey: apps pré-escolares](https://observatory.tec.mx/?p=862) — feedback de erro só com som/X não orienta
- [GraphoGame Brasil na App Store](https://apps.apple.com/BR/app/id1540637587) e [Educa Mais Brasil: GraphoGame](https://www.educamaisbrasil.com.br/educacao/escolas/graphogame-aplicativo-gratuito-auxilia-na-alfabetizacao) — público 4 a 9 anos, uso curto diário, complemento ao professor
- [Catraca Livre: 9 aplicativos que ajudam na alfabetização infantil](https://catracalivre.com.br/educacao/aplicativos-alfabetizacao-infantil-2/) — Lele Sílabas, Silabando, Formar Palavras
- [SBGames 2018: Jogo das Sílabas](https://www.sbgames.org/sbgames2018/files/papers/EducacaoFull/187658.pdf) — módulo Arrastasílabas e som da palavra
- [Companhia das Letrinhas: livros em letra bastão](https://www.companhiadasletras.com.br/blogDaLetrinhas/Post/4192/5-dicas-de-livros-literarios-em-letra-bastao) — convenção de caixa alta na alfabetização

---
*Pesquisa de features para: jogo digital educativo cooperativo de cartas de sílabas (Cofre Mágico)*
*Pesquisado em: 2026-11-11*
