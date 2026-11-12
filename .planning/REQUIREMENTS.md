# Requirements: Cofre Mágico

**Defined:** 2026-11-11
**Core Value:** Um grupo de até quatro jogadores, em um único aparelho, consegue jogar uma partida completa: formar as quatro palavras-senha colocando sílabas corretas, ver quem contribuiu com cada sílaba e abrir o cofre juntos.

## v1 Requirements

Requisitos do protótipo de dezembro de 2026. Cada um é mapeado para uma fase do roadmap.

### Fundação

- [ ] **FUND-01**: A equipe abre o projeto no Godot 4.7.2 (renderizador Compatibility, base 1280×720, paisagem) e executa a cena inicial no PC
- [ ] **FUND-02**: Um APK do projeto é instalado e executado em um aparelho Android real
- [ ] **FUND-03**: Um executável de PC do projeto é gerado e executado
- [ ] **FUND-04**: Os testes automatizados das regras (GUT) rodam com um único comando

### Conteúdo

- [ ] **CONT-01**: As 30 palavras-senha existem como dados, cada uma com suas sílabas explícitas e sua ilustração
- [ ] **CONT-02**: A distribuição das 100 cartas de sílabas (22 distintas) existe como dados, igual à do protótipo físico
- [ ] **CONT-03**: Cada palavra tem uma ilustração de licença livre, com fonte, autor e licença registrados em um arquivo de créditos
- [ ] **CONT-04**: O jogador pode abrir uma tela de créditos com as atribuições exigidas pelas licenças

### Partida (regras)

- [ ] **PART-01**: Os jogadores escolhem quais magos participam (1 a 4) tocando neles, sem digitar nomes
- [ ] **PART-02**: A cada partida o jogo sorteia 4 palavras-senha entre as 30
- [ ] **PART-03**: O baralho de cada partida é um recorte do baralho de 100 cartas, concentrado nas sílabas das senhas sorteadas
- [ ] **PART-04**: Cada mago recebe uma mão de cartas de sílabas no início da partida
- [ ] **PART-05**: No seu turno, o mago coloca uma sílaba da mão em um espaço de uma palavra-senha, e o jogo aceita apenas se for a sílaba daquele espaço exato
- [ ] **PART-06**: Quando a sílaba não serve, a carta volta para a mão sem punição nem marcação de erro
- [ ] **PART-07**: O mago pode comprar ou trocar cartas no seu turno quando não tem jogada
- [ ] **PART-08**: Após a ação, a vez passa para o próximo mago na ordem
- [ ] **PART-09**: Toda partida pode ser concluída: nenhuma carta necessária fica inalcançável e todo turno tem ao menos uma ação possível
- [ ] **PART-10**: A equipe ajusta as regras (tamanho da mão, troca, número de senhas, tamanho do baralho da partida, palavra escrita) em um arquivo de configuração, sem alterar código
- [ ] **PART-11**: A equipe executa um simulador sem interface que mede turnos sem jogada, duração da partida e partidas em que um mago não pontua

### Mesa (interface)

- [ ] **MESA-01**: Os jogadores veem as 4 palavras-senha, cada uma com ilustração grande e um espaço por sílaba (2 ou 3)
- [ ] **MESA-02**: A palavra escrita aparece ou não junto da ilustração conforme a configuração
- [ ] **MESA-03**: A mesa mostra apenas a mão do mago da vez, com indicação clara de quem está jogando
- [ ] **MESA-04**: O mago joga com dois toques: toca na carta e depois no espaço
- [ ] **MESA-05**: Cada sílaba colocada fica marcada com a cor e o símbolo do mago que a colocou
- [ ] **MESA-06**: Cada mago vê seus pontos simbólicos, sem ranking nem comparação entre jogadores
- [ ] **MESA-07**: O botão de comprar/trocar fica sempre visível e ganha destaque quando a mão não tem jogada
- [ ] **MESA-08**: A mesa é usável em celular, tablet e PC (proporções 16:9, 20:9 e 4:3) sem elementos cortados
- [ ] **MESA-09**: Sílabas e palavras aparecem em letras maiúsculas grandes, sem serifa e com alto contraste

### Cofre e fluxo

- [ ] **COFR-01**: Ao completar todas as senhas, o cofre se abre com uma celebração coletiva
- [ ] **COFR-02**: A tela final mostra a contribuição de cada mago sem ordenar nem declarar vencedor
- [ ] **COFR-03**: Os jogadores iniciam uma nova partida a partir da tela final
- [ ] **COFR-04**: O jogo abre em um menu inicial com um botão para jogar
- [ ] **COFR-05**: Os jogadores pausam ou saem da partida com confirmação, e o botão voltar do Android não encerra a partida sem perguntar

### Áudio

- [ ] **AUDI-01**: O jogo toca efeitos sonoros ao acertar uma sílaba, comprar cartas e abrir o cofre
- [ ] **AUDI-02**: Os jogadores ligam e desligam o som por um botão de mudo

### Testes e entrega

- [ ] **TEST-01**: A equipe aplica um protocolo de teste com adultos e registra os resultados observados
- [ ] **TEST-02**: As builds finais de Android e PC são testadas no aparelho e na máquina da apresentação

## v2 Requirements

Adiados para uma versão futura. Registrados, mas fora do roadmap atual.

### Áudio falado

- **AUDI-03**: A palavra é falada quando a senha é completada (clipes gravados pela equipe)
- **AUDI-04**: A sílaba é falada quando o jogador toca na carta

### Apoio ao jogador e ao adulto

- **APOI-01**: O jogador vê um "como jogar" ilustrado e curto
- **APOI-02**: O adulto ajusta os parâmetros de regra em uma tela dentro do jogo
- **APOI-03**: O jogo mostra uma dica após um período de inatividade
- **APOI-04**: O jogo mostra um resumo da partida para os testes (tempo, turnos, trocas)

### Jogo

- **JOGO-01**: Os jogadores abrem vários cofres em sequência
- **JOGO-02**: O jogador arrasta a carta até o espaço como alternativa aos dois toques
- **JOGO-03**: Cada mago tem uma habilidade própria

## Out of Scope

| Feature | Reason |
|---------|--------|
| Multiplayer em rede | Complexidade incompatível com o prazo; o jogo é presencial em um aparelho |
| Mestre dentro do app | A validação é automática e as senhas são sorteadas |
| Testes com crianças | Exigem aprovação do comitê de ética, fora do prazo |
| Sílabas não canônicas e vocabulário ampliado | O protótipo usa só sílabas CV e as 30 palavras |
| Ranking, mago vencedor, cronômetro, vidas | Contrariam o caráter cooperativo e a regra de não expor erros |
| Perfis, contas, progresso salvo, coleta de dados | Público infantil; o jogo é totalmente offline |
| Voz sintetizada do sistema (TTS) | Depende das vozes instaladas em cada Android |
| Publicação na Play Store | A entrega é um APK instalado direto |
| Arte original da equipe | Serão usados recursos de licença livre |
| Validação pedagógica empírica | Fora do alcance do protótipo |

## Traceability

Preenchida na criação do roadmap.

| Requirement | Phase | Status |
|-------------|-------|--------|

**Coverage:**
- v1 requirements: 37 total
- Mapped to phases: 0
- Unmapped: 37 ⚠️

---
*Requirements defined: 2026-11-11*
*Last updated: 2026-11-11 after initial definition*
