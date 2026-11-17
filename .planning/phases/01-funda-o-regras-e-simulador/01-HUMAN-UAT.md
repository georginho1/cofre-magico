---
status: partial
phase: 01-funda-o-regras-e-simulador
source: [01-VERIFICATION.md]
started: 2026-11-17T15:58:55Z
updated: 2026-11-17T15:58:55Z
---

## Current Test

[awaiting human testing]

## Tests

### 1. APK oficial (arm64-v8a) em aparelho Android físico (FUND-02)
expected: instalar build/android/CofreMagico.apk com `adb install -r` num aparelho real; a cena inicial abre em paisagem, mostra "COFRE MÁGICO" e "Mão: 5 cartas", o botão TOCAR aumenta o contador e o logcat mostra `COFRE_MAGICO_INICIAL tamanho_mao=5`. Registrar modelo, ABI e API do aparelho; depois marcar FUND-02 em REQUIREMENTS.md.
result: [pending]

## Summary

total: 1
passed: 0
issues: 0
pending: 1
skipped: 0
blocked: 0

## Gaps
