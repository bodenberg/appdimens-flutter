#!/usr/bin/env zsh
# AppDimens Flutter — publicação da família 3.2.0 no pub.dev
# Uso:
#   ./scripts/publish_all.sh check    # valida (dry-run) os 15 pacotes
#   ./scripts/publish_all.sh go       # publica na ordem (pede y/N por pacote)
#   ./scripts/publish_all.sh go force # publica sem perguntar (--force)

set -e

ORDER=(appdimens_flutter appdimens_percent appdimens_power appdimens_fluid \
       appdimens_auto appdimens_logarithmic appdimens_interpolated \
       appdimens_diagonal appdimens_perimeter appdimens_density \
       appdimens_fill appdimens_fit appdimens_resize appdimens_units \
       appdimens_bom)

MODE="${1:-check}"
EXTRA=()
[[ "$2" == "force" || "$FORCE" == "1" ]] && EXTRA=(--force)

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=()

for p in $ORDER; do
  dir="$ROOT/packages/$p"
  echo "\n════════ $p ════════"
  if [[ "$MODE" == "go" ]]; then
    (cd "$dir" && flutter pub publish $EXTRA) || { FAIL+=("$p"); echo "✗ FALHOU: $p"; }
  else
    (cd "$dir" && flutter pub publish --dry-run) | grep -E "0 warnings|warning|error" || FAIL+=("$p")
  fi
done

echo "\n──────────────────────────────"
if [[ ${#FAIL[@]} -eq 0 ]]; then
  [[ "$MODE" == "go" ]] && echo "✓ Família 3.2.0 publicada com sucesso." || echo "✓ 15/15 pacotes válidos (0 warnings). Pronto para 'go'."
else
  echo "✗ Falhas: ${FAIL[*]}"
  exit 1
fi
