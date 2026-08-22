#!/usr/bin/env zsh
# AppDimens Flutter — publica os pacotes pendentes da família 3.2.0
# (bloqueados em 22/08/2026 pelo limite diário de criação de pacotes no pub.dev)
#
# Uso:
#   ./scripts/publish_pending.sh          # valida (dry-run) os 3 pendentes
#   ./scripts/publish_pending.sh go       # publica fill → fit → bom (--force)

# Autossuficiente: garante flutter/dart mesmo fora do shell interativo
[[ -d "$HOME/development/flutter/bin" ]] && export PATH="$HOME/development/flutter/bin:$PATH"

ORDER=(appdimens_fill appdimens_fit appdimens_bom)
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODE="${1:-check}"
FAIL=()

for p in $ORDER; do
  echo "\n════════ $p ════════"
  if [[ "$MODE" == "go" ]]; then
    out=$(cd "$ROOT/packages/$p" && dart pub publish --force 2>&1)
    echo "$out" | grep -E "Successfully sent|Message from server" || true
    echo "$out" | grep -q "Successfully" || { FAIL+=("$p"); echo "✗ FALHOU: $p"; }
  else
    out=$(cd "$ROOT/packages/$p" && dart pub publish --dry-run 2>&1)
    echo "$out" | grep -E "Package has 0 warnings|too similar|error|Failed" | tail -1
    echo "$out" | grep -q "Package has 0 warnings." || FAIL+=("$p")
  fi
done

echo "\n──────────────────────────────"
if [[ ${#FAIL[@]} -eq 0 ]]; then
  [[ "$MODE" == "go" ]] && echo "✓ Família AppDimens 3.2.0 completa no pub.dev." \
                    || echo "✓ 3/3 pendentes validados (0 warnings). Rode './scripts/publish_pending.sh go'."
else
  echo "✗ Falharam: ${FAIL[*]}"
  echo "  Se foi rate limit ('blocked'), espere a cota diária liberar e rode novamente."
  exit 1
fi
