# Stack Research

**Domain:** Jogo de cartas 2D educativo cooperativo (formação de palavras por sílabas, 7 a 9 anos), pass-and-play em um aparelho, Godot + GDScript, exportado para Android (APK) e PC desktop
**Researched:** 2026-11-11
**Confidence:** HIGH para motor, renderizador, exportação Android e ajustes de tela (documentação oficial consultada hoje); MEDIUM para framework de testes e fontes de arte/áudio/tipografia (parte vem de conhecimento prévio, não reverificado)

## Recommended Stack

### Core Technologies

| Technology | Version | Purpose | Why Recommended | Confiança |
|------------|---------|---------|-----------------|-----------|
| Godot Engine (build padrão, sem .NET) | **4.7.2-stable** (18/08/2026) | Motor, editor, exportação | É a versão estável mais recente no arquivo oficial de downloads. A 4.8 está em beta (4.8-beta3, 09/11/2026) e não deve ser usada com entrega em dezembro. Fixar a 4.7.2 nas duas máquinas da equipe: o `project.godot` e os `.tscn` são regravados pela versão do editor e versões diferentes geram diffs e conflitos. | HIGH |
| GDScript | o da 4.7 | Toda a lógica do jogo | Já decidido pela equipe; é o caminho com menos atrito para Android (o build .NET exige outra cadeia de exportação). Usar tipagem estática (`var mao: Array[Carta]`) para pegar erros no editor. | HIGH |
| Renderizador **Compatibility** (OpenGL) | definido na criação do projeto | Renderização 2D | A documentação oficial indica Compatibility para aparelhos móveis antigos ou de baixo custo e afirma que ele normalmente basta para jogos 2D; é o que suporta a maior variedade de hardware, incluindo aparelhos sem Vulkan. O Mobile exige Vulkan/D3D12/Metal e só entrega recursos de que um jogo de cartas não precisa. | HIGH |
| Modelos de exportação (export templates) | **4.7.2** (mesma versão exata do editor) | Gerar APK e executável | Instalar por *Editor > Manage Export Templates*. Templates de outra versão não funcionam. | HIGH |
| OpenJDK | **17** | Assinar e empacotar o APK | A página oficial de exportação para Android (docs da 4.7) pede OpenJDK 17; versões mais novas funcionam, mas a 17 é a recomendada por estabilidade. | HIGH |
| Android SDK | Platform-Tools >= 35.0.0, Build-Tools **35.0.1**, Platform **API 35**, Command-line Tools (latest), CMake 3.10.2.4988404, NDK r28b (28.1.13356709) | Exportação Android | Lista exata da documentação oficial da 4.7. Pode ser instalada pelo Android Studio (Iguana 2023.2.1 ou mais novo) ou só com `sdkmanager`. | HIGH |

### Configurações de projeto (prescritivas)

| Ajuste (Project Settings) | Valor | Por quê | Confiança |
|---------------------------|-------|---------|-----------|
| `display/window/size/viewport_width` x `height` | **1280 x 720** | Valor que a documentação oficial recomenda para jogo mobile em paisagem. 1920x1080 é a alternativa oficial, mas exige arte em resolução maior e tema maior; para aparelhos modestos e arte de terceiros, 1280x720 é suficiente. | HIGH |
| `display/window/stretch/mode` | **canvas_items** | Recomendação oficial para 2D que não é pixel art: a interface e o texto são redesenhados na resolução real do aparelho, mantendo as sílabas nítidas. | HIGH |
| `display/window/stretch/aspect` | **expand** | Recomendação oficial para suportar várias proporções (16:9, 18:9, 20:9, tablets 4:3) sem barras pretas. Exige que os nós `Control` estejam ancorados (menu *Layout*) e que o layout seja feito com containers. | HIGH |
| `display/window/handheld/orientation` | **sensor_landscape** | O padrão do Godot já é paisagem; `sensor_landscape` permite girar 180 graus, útil com crianças em volta do aparelho. O nome exato da opção deve ser conferido no editor. | MEDIUM |
| `rendering/textures/vram_compression/import_etc2_astc` | **ligado** | Exigido pelo exportador Android quando há texturas comprimidas em VRAM; o editor acusa erro na exportação se estiver desligado. | MEDIUM |
| Importação das texturas 2D | compressão **Lossless**, sem mipmaps | Padrão para sprites 2D; evita artefatos em letras e contornos. | MEDIUM |
| Tamanho mínimo de alvo de toque | cartas e botões com pelo menos ~96 px de lado na base 1280x720 | Diretriz de projeto para dedos de criança e pass-and-play, não uma regra do motor; validar nos testes de usabilidade. | LOW |

### Exportação Android (passo a passo resumido)

1. Instalar OpenJDK 17 e os componentes do SDK listados acima.
2. *Editor Settings > Export > Android*: preencher **Java SDK Path** e **Android SDK Path** (a pasta do SDK precisa conter `platform-tools/adb`).
3. Instalar os export templates 4.7.2.
4. Criar o preset Android. Manter a exportação **sem Gradle** (template pré-compilado): o jogo não usa plugins Android, então o build Gradle só acrescenta tempo e pontos de falha.
5. Arquiteturas: manter **arm64-v8a** e marcar também **armeabi-v7a** para cobrir aparelhos de entrada de 32 bits (APK maior, mas mais compatível). (MEDIUM)
6. Gerar a keystore de release com o comando da documentação:
   `keytool -v -genkey -keystore cofremagico.keystore -alias cofremagico -keyalg RSA -validity 10000`
   No preset: *Release* (caminho), *Release User* (alias), *Release Password*. A documentação avisa que a senha da chave precisa ser igual à senha da keystore. Desmarcar *Export With Debug* no build final.
7. Para testes internos, o APK de debug instalado por USB (botão de deploy em um toque do editor, com depuração USB ativa) é suficiente.

A keystore e as senhas ficam **fora do repositório** (o `export_presets.cfg` não guarda as credenciais; elas ficam em `.godot/export_credentials.cfg`, que já é ignorado junto com `.godot/`). Guardar uma cópia da keystore em local seguro compartilhado pelos dois integrantes.

### Exportação desktop

Preset **Windows Desktop** (x86_64), com *Embed PCK* ligado para entregar um único `.exe` na apresentação. Preset Linux é opcional. Não há requisito adicional além dos export templates. (HIGH para o fluxo; o ícone do `.exe` exige `rcedit`, que é opcional.)

### Supporting Libraries

| Library | Version | Purpose | When to Use | Confiança |
|---------|---------|---------|-------------|-----------|
| **GUT** (Godot Unit Test, bitwes/Gut) | **9.7.1** (linha 9.7.x traz "Compatibility changes for Godot 4.7") | Testes unitários da lógica de regras | Testar o que é puro dado e regra: composição do baralho (100 cartas, 22 sílabas), sorteio das 4 palavras, validação de sílaba por posição, compra/troca, condição de vitória. Não testar interface. | MEDIUM |
| Recursos nativos do Godot (`Tween`, `Control`/containers, `Theme`, `Resource`, `AudioStreamPlayer`) | 4.7 | Animação de cartas, layout, tema infantil, dados, som | Tudo o que o jogo precisa já está no motor. Nenhum addon de cartas é necessário. | HIGH |

Observação sobre o GUT: na página de releases, o selo "Latest" do GitHub está na 9.6.1 (publicada um dia antes da 9.7.1), mas as notas indicam que a linha 9.7.x é a destinada à Godot 4.7. Confirmar na instalação (README ou AssetLib) antes de fixar a versão.

### Arte, áudio e fontes de licença livre

| Fonte | Licença | Uso sugerido | Obrigações | Confiança |
|-------|---------|--------------|------------|-----------|
| **Kenney** (kenney.nl) | CC0 (domínio público) | Interface (botões, painéis), cartas, ícones, efeitos sonoros, possivelmente o cofre | Nenhuma; crédito opcional. Não usar o logotipo Kenney isolado. | HIGH (página de suporte consultada) |
| **OpenMoji** (openmoji.org) | **CC BY-SA 4.0** | Ilustrações das palavras-senha (casa, cama, bola, bolo, bota, pato, pipa, gato, galo, gota, mala, moto, rato, sapo, sino, sopa, tomate etc.) | Crédito obrigatório com indicação de alterações; texto sugerido: "All emojis designed by OpenMoji – the open-source emoji and icon project. License: CC BY-SA 4.0". Versões modificadas dos emojis precisam ser distribuídas sob a mesma licença. | HIGH (FAQ consultado) |
| Twemoji | CC BY 4.0 (gráficos) | Alternativa a OpenMoji sem cláusula de compartilhamento pela mesma licença | Crédito | MEDIUM (não reverificado) |
| Noto Emoji | Apache 2.0 (imagens) | Outra alternativa de emoji | Manter aviso de licença | MEDIUM (não reverificado) |
| Openclipart | CC0 | Palavras sem emoji correspondente | Nenhuma | MEDIUM (não reverificado) |
| ARASAAC (arasaac.org) | CC BY-NC-SA 4.0 | Pictogramas pedagógicos, com vocabulário em português, para palavras difíceis de ilustrar | Crédito, uso não comercial, mesma licença. Aceitável para trabalho acadêmico, mas impede uso comercial futuro. | MEDIUM (não reverificado) |
| Google Fonts: **Andika** (SIL, feita para alfabetização) ou **Lexend** | SIL OFL 1.1 | Fonte única do jogo; as formas de letra da Andika são desenhadas para leitores iniciantes | Incluir o arquivo `OFL.txt` junto da fonte | MEDIUM (não reverificado) |
| Kenney Audio / Freesound filtrado por CC0 | CC0 | Efeitos (carta, acerto, cofre abrindo) e música | Nenhuma em CC0; anotar a URL de cada arquivo | MEDIUM |

**Lacuna conhecida:** nem todas as 30 palavras têm emoji evidente (por exemplo CANO, MOLA, GOLA, TAPETE, TATU, MATO, PANO, SACO). É preciso um levantamento palavra a palavra logo no início; onde faltar, recorrer a Openclipart ou ARASAAC. Misturar estilos visuais é um risco para o reconhecimento das imagens pelas crianças.

**Como registrar as licenças (obrigatório pelo PROJECT.md):**

- Arquivo `CREDITS.md` (ou `assets/LICENCAS.md`) na raiz, com uma linha por recurso: caminho do arquivo no projeto, autor, URL de origem, licença, data de download, se foi modificado e como.
- Dentro de cada pasta de pacote em `assets/`, manter o arquivo de licença original que veio no download (`License.txt` do Kenney, `OFL.txt` da fonte).
- Registrar no momento em que o arquivo entra no repositório, nunca ao final.
- Tela "Créditos" dentro do jogo, com o texto de atribuição da OpenMoji e das demais fontes que exigem crédito. A cláusula SA da OpenMoji vale para os emojis e suas adaptações, não para o código do jogo; em caso de dúvida, tratar toda arte derivada de OpenMoji como CC BY-SA 4.0.

### Development Tools

| Tool | Purpose | Notes |
|------|---------|-------|
| Git + GitHub | Versionamento entre os dois integrantes | `.gitignore` com `.godot/`, `*.keystore`, `*.apk`, `*.aab`, `build/`. Combinar que cada um edita cenas diferentes: conflitos em `.tscn` são difíceis de resolver. |
| Editor do Godot 4.7.2 | Edição, depuração, deploy em um toque para Android | Mesma versão exata nas duas máquinas. |
| `adb` (Platform-Tools) | Instalar APK e ler logs (`adb logcat`) | Já vem no SDK. |
| GUT por linha de comando | Rodar testes sem abrir o editor | `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://test -gexit` (conferir as opções na documentação da versão instalada). |
| gdtoolkit (`gdformat`, `gdlint`) | Formatação e lint de GDScript | Opcional. Compatibilidade com a sintaxe da 4.7 não foi verificada (LOW); se falhar, dispensar. |

## Installation

```bash
# 1. Godot 4.7.2-stable (build padrão, não .NET): https://godotengine.org/download/archive/
# 2. No editor: Editor > Manage Export Templates > baixar 4.7.2

# 3. OpenJDK 17 (Windows)
winget install EclipseAdoptium.Temurin.17.JDK

# 4. Componentes do Android SDK (comando da documentação oficial)
sdkmanager --sdk_root=<caminho_do_sdk> "platform-tools" "build-tools;35.0.1" "platforms;android-35" "cmdline-tools;latest" "cmake;3.10.2.4988404" "ndk;28.1.13356709"

# 5. Keystore de release (guardar fora do repositório)
keytool -v -genkey -keystore cofremagico.keystore -alias cofremagico -keyalg RSA -validity 10000

# 6. GUT 9.7.x: pela AssetLib do editor ou copiando addons/gut do release no GitHub;
#    ativar em Project Settings > Plugins
```

O identificador do pacote `winget` é o habitual do Temurin, mas não foi conferido nesta pesquisa.

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| Godot 4.7.2 | Godot 4.6.3 (20/05/2026) | Só se algum addon indispensável não suportar a 4.7. Não é o caso com a pilha proposta. |
| Godot 4.7.2 | Godot 4.8 beta | Nunca neste projeto; reavaliar apenas depois da entrega. |
| Compatibility | Mobile | Se o jogo precisasse de efeitos que só existem no RenderingDevice. Desde a 4.4 o motor recua para Compatibility quando não há Vulkan, mas depender desse recuo é risco sem ganho para 2D. |
| GUT 9.7.x | gdUnit4 6.2.3 (01/11/2026) | Se a equipe quiser testes de cena com simulação de entrada, asserções fluentes e relatórios para CI. É mais completo e ativamente mantido, porém maior do que o necessário para testar regras puras em um protótipo de um mês. |
| 1280x720 + canvas_items + expand | 1920x1080 de base | Se a arte escolhida for de alta resolução e os aparelhos de teste forem intermediários ou melhores. |
| Exportação sem Gradle | Gradle build | Se for preciso plugin Android, permissões especiais ou AAB para a Play Store. |
| OpenMoji | Twemoji / Noto Emoji | Se a equipe quiser evitar a cláusula de compartilhamento pela mesma licença. |
| Dados em `Resource` (`.tres`) ou dicionário GDScript | JSON externo | Se alguém de fora da equipe for editar a lista de palavras sem abrir o Godot. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| Godot 4.8 beta ou builds dev | Instável e sem garantia de compatibilidade de projeto; prazo é dezembro | 4.7.2-stable |
| Godot 3.x | Linha antiga em manutenção; tutoriais e addons atuais são para a 4.x | 4.7.2-stable |
| Build .NET/C# do Godot | Fora da decisão da equipe; exportação Android mais trabalhosa; misturar linguagens em equipe de dois não compensa | Build padrão com GDScript |
| Renderizadores Forward+ e Mobile | Forward+ é só para desktop; ambos exigem Vulkan/D3D12/Metal e não trazem benefício para 2D | Compatibility |
| Stretch mode `viewport` | Renderiza na resolução base e amplia; texto e contornos ficam borrados em telas maiores. Serve para pixel art, não para cartas com letras grandes | `canvas_items` |
| Stretch aspect `keep` | Barras pretas em telas 20:9 e em tablets | `expand` com âncoras e containers |
| Posicionamento absoluto de nós de interface | Quebra em proporções diferentes | Containers e âncoras |
| Addons ou frameworks de jogo de cartas | Dependência a aprender e depurar para um jogo com regras simples (mão, baralho, 4 palavras); risco de incompatibilidade com a 4.7 | `Control` + `Tween` + arrastar ou tocar implementados diretamente |
| Arrastar e soltar como única forma de jogar | Gesto difícil para crianças pequenas em telas pequenas | Toque para selecionar a carta e toque no espaço de destino; arrastar como opcional (decisão de design, validar nos testes) |
| Gradle build, AAB, publicação na Play Store | Fora do escopo; a Play Store ainda impõe regras específicas para apps infantis | APK instalado diretamente |
| Plugins de anúncios, analytics, login ou qualquer SDK de rede | Restrição ética do projeto: sem coleta de dados de crianças; manter o APK sem permissão de internet | Nada; jogo totalmente offline |
| Recursos sem licença explícita (busca de imagens, Pinterest, "free" sem termos) e imagens geradas ou baixadas sem origem rastreável | Impossível registrar a licença, que é requisito do projeto | Kenney, OpenMoji, Openclipart, fontes OFL |
| Recursos CC BY-NC ou CC BY-ND sem decisão consciente | NC impede uso comercial futuro; ND impede recortar ou recolorir | CC0, CC BY, CC BY-SA, OFL |
| Mistura de fontes de sites como DaFont | Licenças variam e muitas são "uso pessoal" | Google Fonts sob OFL |
| Keystore ou senhas no repositório | Vazamento de credenciais; perda da chave impede atualizar o app com a mesma assinatura | Arquivo fora do Git, com cópia de segurança |

## Stack Patterns by Variant

**Se os aparelhos de teste forem muito antigos (32 bits):**
- Marcar `armeabi-v7a` além de `arm64-v8a` no preset Android
- Porque muitos aparelhos de entrada antigos não rodam binários de 64 bits

**Se a apresentação for em PC com projetor:**
- Exportar Windows Desktop com *Embed PCK* e testar em tela cheia a 1920x1080 e em janela
- Porque `canvas_items` + `expand` precisa ser conferido em 16:9 e 16:10 antes do dia

**Se sobrar tempo para testes de interface:**
- Avaliar gdUnit4 apenas para testes de cena
- Porque o GUT cobre bem a lógica, e a lógica é onde estão os erros que comprometem a partida

**Se uma palavra não tiver ilustração consistente com as demais:**
- Preferir trocar o estilo de todo o conjunto a misturar fontes, ou registrar a exceção no `CREDITS.md`
- Porque o reconhecimento da imagem é o apoio de leitura do jogo

## Version Compatibility

| Componente | Compatível com | Notas |
|------------|----------------|-------|
| Godot 4.7.2 | Export templates 4.7.2 | Precisa ser a mesma versão exata |
| Godot 4.7 (exportação Android) | OpenJDK 17; Build-Tools 35.0.1; Platform API 35; NDK r28b | Conforme a documentação oficial da 4.7; JDK mais novo funciona, mas 17 é o recomendado |
| Godot 4.7 | GUT 9.7.x | A 9.7.0 declara mudanças de compatibilidade para a 4.7; a 9.6.x é da 4.6 |
| Godot 4.7 | gdUnit4 6.2.x | A 6.2.3 cita correção para o editor 4.7; a tabela oficial de versões suportadas não foi consultada |
| Renderizador Compatibility | Aparelhos Android com OpenGL ES 3.0 | A página de renderizadores não cita a versão do OpenGL ES; o requisito de ES 3.0 vem de conhecimento prévio (MEDIUM) |
| Projeto salvo na 4.7 | Editores 4.6 ou anteriores | Não abrir o projeto em versão mais antiga |

## Itens não verificados nesta pesquisa

- Versão mínima de Android (min SDK) do template de exportação da 4.7.
- Nome exato da opção de orientação `sensor_landscape` e comportamento da keystore de debug automática na 4.7.
- Licenças atuais de Twemoji, Noto Emoji, Openclipart, ARASAAC, Andika e Lexend (afirmadas a partir de conhecimento prévio; conferir na página de cada recurso ao baixar).
- Compatibilidade do gdtoolkit com a 4.7.
- Cobertura real de ilustrações para as 30 palavras.
- O Context7 não foi consultado; as verificações foram feitas direto na documentação oficial e nas páginas de release.

## Sources

- https://godotengine.org/download/archive/ — versões estáveis e pré-lançamentos (4.7.2 estável em 18/08/2026; 4.8-beta3 em 09/11/2026) — HIGH
- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html — JDK 17, componentes do SDK, keystore, ajustes do editor (docs da 4.7) — HIGH
- https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html — comparação Compatibility / Mobile / Forward+ — HIGH
- https://docs.godotengine.org/en/stable/tutorials/rendering/multiple_resolutions.html — 1280x720, `canvas_items`, `expand`, âncoras, paisagem como padrão — HIGH
- https://github.com/bitwes/Gut/releases — GUT 9.7.x para Godot 4.7 (página sem ano nas datas) — MEDIUM
- https://github.com/godot-gdunit-labs/gdUnit4/releases — gdUnit4 6.2.3 — MEDIUM
- https://kenney.nl/support — recursos em CC0, crédito opcional — HIGH
- https://openmoji.org/faq/ — CC BY-SA 4.0 e texto de atribuição — HIGH

---
*Stack research for: jogo de cartas 2D educativo em Godot para Android e desktop*
*Researched: 2026-11-11*
