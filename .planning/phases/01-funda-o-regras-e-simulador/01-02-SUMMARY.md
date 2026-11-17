---
phase: 01-funda-o-regras-e-simulador
plan: 02
subsystem: infra
tags: [android, export, godot, apk, emulator]
requires:
  - phase: 01-01
    provides: esqueleto Godot com cena inicial e preset Windows
provides:
  - Preset Android (arm64-v8a, Gradle desligado, sem INTERNET) em export_presets.cfg
  - APK de depuracao exportavel (build/android/CofreMagico.apk, ignorado pelo Git)
  - Cadeia de exportacao Android (JDK, SDK, NDK, templates 4.7.2) funcionando
affects: [todas as fases que exportam APK]
tech-stack:
  added: [Android SDK (build-tools 35.0.1, android-35, cmake, NDK r28b), JDK 21, templates Android 4.7.2, Android Emulator + AVD CofreMagico_API35]
  patterns: [keystore de depuracao fora do repo via variaveis GODOT_ANDROID_KEYSTORE_DEBUG_*]
key-files:
  created: [.planning/phases/01-funda-o-regras-e-simulador/01-02-SUMMARY.md]
  modified: [export_presets.cfg]
key-decisions:
  - "Preset Android fica somente arm64-v8a; armeabi-v7a pendente de decisao da equipe"
  - "Keystore de depuracao em %USERPROFILE%\\.cofremagico\\debug.keystore, fora do Git"
requirements-completed: []
duration: n/a
completed: 2026-11-17
---

# Phase 1 Plan 02: Exportacao Android Summary

**Cadeia de exportacao Android configurada (Godot 4.7.2, Gradle desligado, sem permissao INTERNET); APK instalado e executado em emulador x86_64, mas NAO em aparelho fisico.**

## Accomplishments
- SDK/NDK/JDK/templates Android configurados; o Godot exporta APK sem erro (commit f68f4b9 do preset Android).
- Preset Android: Gradle desligado, permissions/internet desligado, arm64-v8a, credenciais por variaveis de ambiente (sem caminho/senha no `export_presets.cfg`).
- Verificacao em emulador (ver abaixo): instala, abre a cena inicial em paisagem, botao responde ao toque.

## Verificacao (DESVIO: emulador, nao aparelho fisico)
O usuario nao tem aparelho Android fisico. A verificacao foi feita em emulador, em 2026-11-17:
- AVD `CofreMagico_API35` (pixel_6), imagem `system-images;android-35;default;x86_64`, aceleracao WHPX.
- A imagem so executa x86_64 (sem traducao ARM). Por isso foi exportado um APK de teste separado, `build/android/CofreMagico-emu.apk` (~58,5 MB, gitignored), habilitando temporariamente `architectures/x86_64` e restaurando o `export_presets.cfg` com `git checkout`. O preset do repositorio continua so arm64-v8a.
- `adb install -r` com sucesso; logcat: `COFRE_MAGICO_INICIAL tamanho_mao=5`; renderizador OpenGL ES 3.1 Compatibility.
- Activity `com.cofremagico.jogo/com.godot.game.GodotAppLauncher` em paisagem, tela cheia (2400x1080), sem barras pretas. Titulo "COFRE MAGICO", "Mao: 5 cartas", botao "TOCAR"; toques via `adb input tap` incrementaram "Toques: N" (8 -> 11).
- O usuario tambem rodou o projeto no PC (Godot 4.7.2, janela) e confirmou.
- O APK arm64-v8a que o preset realmente gera NAO foi executado em hardware real.

## Itens em aberto
1. Instalar `build/android/CofreMagico.apk` (arm64-v8a) em um aparelho Android fisico quando houver um (confirmacao real de FUND-02).
2. Decisao da equipe: habilitar `armeabi-v7a` (CLAUDE.md recomenda para aparelhos antigos). Nao tomada aqui.
3. Segundo integrante precisa receber o keystore de depuracao por canal privado e definir as variaveis `GODOT_ANDROID_KEYSTORE_DEBUG_*`.

## Deviations from Plan
- **Emulador no lugar de aparelho fisico** (acima); ABI do aparelho real nao pode ser consultada, arm64-v8a mantido por padrao.
- 01-01 instalou so os templates Windows; os templates Android foram adicionados neste plano.
- JDK 21 usado em vez do JDK 17 recomendado.
- NDK r28b baixado diretamente (nao registrado no sdkmanager).
- Avisos de exportacao nao bloqueantes: "Cannot set object script" e aapt2 `themed_icon`.
- Padroes de minSdk 24 / targetSdk 36 mantidos.
- Keystore em `%USERPROFILE%\.cofremagico\debug.keystore` com variaveis `GODOT_ANDROID_KEYSTORE_DEBUG_*`.

## Task Commits
- f68f4b9: preset Android em `export_presets.cfg`
- Tarefas 2-4 (instalar/verificar): sem alteracao de codigo; resultado registrado aqui.

## Self-Check: PASSED
