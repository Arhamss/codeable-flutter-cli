const codeQualityScriptTemplate = r'''
#!/bin/bash
# ============================================================================
# Codeable Flutter Code Quality Checker
# ============================================================================
# Enforces project-specific coding standards beyond flutter analyze.
# Designed for CI but runnable locally: ./scripts/code_quality_check.sh
#
# Modes:
#   CHECK_ALL=true  → scan entire lib/ (full audit)
#   default         → scan only files changed vs base branch (PR mode)
#
# GitHub Actions annotations:
#   Set GITHUB_ACTIONS=true (auto-set in CI) to emit ::error/::warning
# ============================================================================

set -uo pipefail

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

VIOLATIONS=0
WARNINGS=0

# ── Preflight ───────────────────────────────────────────────────────────────

if [ ! -d "lib" ]; then
  echo -e "${RED}Error: lib/ directory not found. Run from project root.${NC}"
  exit 1
fi

# ── Collect files to check ──────────────────────────────────────────────────

EXCLUDE_RE='\.(g|freezed|gen)\.dart$|l10n/gen/|\.dart_tool|build/'

FILES=()

if [ "${CHECK_ALL:-false}" = "true" ]; then
  while IFS= read -r line; do
    FILES+=("$line")
  done < <(find lib -name "*.dart" | grep -vE "$EXCLUDE_RE" | sort)
else
  BASE="${BASE_REF:-origin/develop}"
  if git rev-parse "$BASE" >/dev/null 2>&1; then
    while IFS= read -r line; do
      [ -n "$line" ] && FILES+=("$line")
    done < <(git diff --name-only --diff-filter=ACMR "$BASE"...HEAD -- 'lib/**.dart' 2>/dev/null | grep -vE "$EXCLUDE_RE" | sort)
  else
    echo -e "${YELLOW}Base ref '$BASE' not found — falling back to full scan${NC}"
    while IFS= read -r line; do
      FILES+=("$line")
    done < <(find lib -name "*.dart" | grep -vE "$EXCLUDE_RE" | sort)
  fi
fi

if [ ${#FILES[@]} -eq 0 ]; then
  echo -e "${GREEN}No Dart files to check.${NC}"
  exit 0
fi

echo -e "${CYAN}${BOLD}Checking ${#FILES[@]} file(s)...${NC}"
echo ""

# ── Helpers ─────────────────────────────────────────────────────────────────

violation() {
  local file="$1" line="$2" rule="$3" msg="$4"
  echo -e "  ${RED}VIOLATION${NC} [$rule] $file:$line"
  echo -e "    $msg"
  # GitHub Actions inline annotation
  if [ "${GITHUB_ACTIONS:-}" = "true" ] && [ "$line" != "-" ]; then
    echo "::error file=$file,line=$line,title=$rule::$msg"
  fi
  VIOLATIONS=$((VIOLATIONS + 1))
}

warning() {
  local file="$1" line="$2" rule="$3" msg="$4"
  echo -e "  ${YELLOW}WARNING${NC}  [$rule] $file:$line"
  echo -e "    $msg"
  if [ "${GITHUB_ACTIONS:-}" = "true" ] && [ "$line" != "-" ]; then
    echo "::warning file=$file,line=$line,title=$rule::$msg"
  fi
  WARNINGS=$((WARNINGS + 1))
}

check_pattern() {
  local file="$1" pattern="$2" rule="$3" msg="$4" severity="${5:-violation}"
  while IFS=: read -r line_num content; do
    [ -z "$line_num" ] && continue
    $severity "$file" "$line_num" "$rule" "$msg: $(echo "$content" | xargs)"
  done < <(grep -nE "$pattern" "$file" 2>/dev/null || true)
}

count_grep() {
  local result
  result=$(grep -cE "$1" "$2" 2>/dev/null) || result=0
  echo "$result"
}

is_view_file() {
  [[ "$1" == *_screen.dart ]] || [[ "$1" == *_view.dart ]] || [[ "$1" == *_page.dart ]]
}

is_cubit_file() {
  [[ "$1" == *cubit.dart ]] && [[ "$1" == *presentation/cubit/* ]]
}

is_state_file() {
  [[ "$1" == *state.dart ]] && [[ "$1" == *presentation/cubit/* ]]
}

is_repo_file() {
  [[ "$1" == *repository_impl.dart ]] || { [[ "$1" == *_repository.dart ]] && [[ "$1" == *data/repository/* ]]; }
}

is_widget_file() {
  [[ "$1" == *presentation/widgets/* ]]
}

# ════════════════════════════════════════════════════════════════════════════
# CHECKS
# ════════════════════════════════════════════════════════════════════════════

# ── Category: State Management ──────────────────────────────────────────────

echo -e "${BOLD}State Management${NC}"

for f in "${FILES[@]}"; do
  # SM-001: No setState() — allowed in core_widgets/, bottom_sheet, and stripe files (ephemeral UI)
  if [[ "$f" != *core_widgets* ]] && [[ "$f" != *bottom_sheet* ]] && [[ "$f" != *stripe_payment* ]]; then
    check_pattern "$f" '\bsetState\s*\(' "SM-001" "Use Cubit state management — no setState()"
  fi

  # SM-002: No try-catch in cubit files
  if is_cubit_file "$f"; then
    check_pattern "$f" '^\s*try\s*\{' "SM-002" "No try-catch in cubits — error handling belongs in repositories"
    check_pattern "$f" '^\s*\}\s*catch\s*\(' "SM-002" "No try-catch in cubits — error handling belongs in repositories"
  fi

  # SM-003: BlocBuilder without buildWhen
  if grep -q 'BlocBuilder<' "$f" 2>/dev/null; then
    bb_count=$(count_grep '\bBlocBuilder<' "$f")
    bw_count=$(count_grep 'buildWhen' "$f")
    if [ "$bb_count" -gt "$bw_count" ]; then
      violation "$f" "-" "SM-003" "BlocBuilder used without buildWhen ($bb_count BlocBuilder vs $bw_count buildWhen)"
    fi
  fi

  # SM-004: BlocListener without listenWhen
  if grep -q 'BlocListener<' "$f" 2>/dev/null; then
    bl_count=$(count_grep '\bBlocListener<' "$f")
    lw_count=$(count_grep 'listenWhen' "$f")
    if [ "$bl_count" -gt "$lw_count" ]; then
      violation "$f" "-" "SM-004" "BlocListener used without listenWhen ($bl_count BlocListener vs $lw_count listenWhen)"
    fi
  fi
done

# ── Category: View & Widget Rules ───────────────────────────────────────────

echo ""
echo -e "${BOLD}View & Widget Rules${NC}"

for f in "${FILES[@]}"; do
  if is_view_file "$f" && [[ "$f" != *core_widgets* ]]; then
    # VW-001: No _buildXyz() methods in views
    check_pattern "$f" '^\s*Widget\s+_build[A-Z]' "VW-001" "No _buildXyz() methods in views — extract to separate StatelessWidget"
    check_pattern "$f" '^\s*[A-Za-z<>,?\s]+\s+_build[A-Z][a-zA-Z]*\s*\(' "VW-001" "No _buildXyz() in views — extract to separate StatelessWidget"

    # VW-002: No private widget classes in view files
    while IFS=: read -r line_num content; do
      [ -z "$line_num" ] && continue
      if ! echo "$content" | grep -qE '_\w+State\b'; then
        violation "$f" "$line_num" "VW-002" "No private classes in view files — extract to own file: $(echo "$content" | xargs)"
      fi
    done < <(grep -nE '^\s*class\s+_[A-Z]' "$f" 2>/dev/null || true)

    # VW-003: View files exceeding 1000 lines
    line_count=$(wc -l < "$f" | xargs)
    if [ "$line_count" -gt 1000 ]; then
      violation "$f" "$line_count" "VW-003" "View file exceeds 1000 lines ($line_count lines) — refactor and extract widgets"
    fi

    # VW-006: Business logic in views (data transformations)
    check_pattern "$f" '\.\(where\|firstWhere\|indexWhere\|fold\|reduce\|sort\)\s*\(' "VW-006" "Data transformation in view — move to cubit or helper" "warning"
    # More specific: chained .map().toList() patterns (data transformation, not UI mapping)
    check_pattern "$f" '\.(map|where)\(.*\)\.(toList|toSet|length|isEmpty|isNotEmpty|fold)' "VW-006" "Data transformation in view — move to cubit or helper" "warning"
  fi

  # VW-004: Cubit files exceeding 800 lines
  if is_cubit_file "$f"; then
    line_count=$(wc -l < "$f" | xargs)
    if [ "$line_count" -gt 700 ]; then
      warning "$f" "$line_count" "VW-004" "Cubit file exceeds 700 lines ($line_count lines) — consider splitting"
    fi
  fi

  # VW-005: State files exceeding 500 lines
  if is_state_file "$f"; then
    line_count=$(wc -l < "$f" | xargs)
    if [ "$line_count" -gt 700 ]; then
      warning "$f" "$line_count" "VW-005" "State file exceeds 700 lines ($line_count lines) — consider splitting the feature"
    fi
  fi

  # VW-007: Widget files exceeding 400 lines (sign of doing too much)
  if is_widget_file "$f"; then
    line_count=$(wc -l < "$f" | xargs)
    if [ "$line_count" -gt 600 ]; then
      warning "$f" "$line_count" "VW-007" "Widget file exceeds 600 lines ($line_count lines) — consider decomposing"
    fi
  fi
done

# ── Category: Resource Disposal ─────────────────────────────────────────────

echo ""
echo -e "${BOLD}Resource Disposal${NC}"

for f in "${FILES[@]}"; do
  # RD-001: Controllers/FocusNodes declared without a dispose() method
  # Only applies to StatefulWidget files — StatelessWidgets receive controllers via constructor (no ownership)
  if is_view_file "$f" || is_widget_file "$f"; then
    if grep -qE 'extends\s+State<|extends\s+StatefulWidget' "$f" 2>/dev/null; then
      has_controller=$(count_grep 'TextEditingController|ScrollController|AnimationController|TabController|FocusNode|PageController|Timer\b' "$f")
      if [ "$has_controller" -gt 0 ]; then
        has_dispose=$(count_grep '@override\s|void\s+dispose' "$f")
        if [ "$has_dispose" -eq 0 ]; then
          violation "$f" "-" "RD-001" "Declares controllers/timers ($has_controller) but no dispose() method — will leak resources"
        fi
      fi
    fi
  fi
done

# ── Category: Architecture ──────────────────────────────────────────────────

echo ""
echo -e "${BOLD}Architecture${NC}"

# AR-001: Multiple cubits per feature
while IFS= read -r cubit_dir; do
  [ -z "$cubit_dir" ] && continue
  cubit_count=$(find "$cubit_dir" -maxdepth 1 -name "*cubit.dart" 2>/dev/null | wc -l | xargs)
  if [ "$cubit_count" -gt 1 ]; then
    feature_name=$(echo "$cubit_dir" | sed 's|.*/features/||' | sed 's|/presentation/cubit||')
    warning "$cubit_dir" "-" "AR-001" "Feature '$feature_name' has $cubit_count cubits — consider splitting into separate features"
  fi
done < <(find lib/features -type d -name "cubit" -path "*/presentation/cubit" 2>/dev/null || true)

# AR-002: Duplicate widget file names across features (sign of duplication)
declare -A widget_names
while IFS= read -r widget_file; do
  base=$(basename "$widget_file")
  if [ -n "${widget_names[$base]:-}" ]; then
    warning "$widget_file" "-" "AR-002" "Duplicate widget name '$base' — also exists at ${widget_names[$base]}. Consider consolidating into core_widgets/"
  else
    widget_names["$base"]="$widget_file"
  fi
done < <(find lib/features -name "*.dart" -path "*/widgets/*" 2>/dev/null | sort)

# ── Category: Enums & Type Safety ───────────────────────────────────────────

echo ""
echo -e "${BOLD}Enums & Type Safety${NC}"

for f in "${FILES[@]}"; do
  # Skip model files with fromJson/fromString (these are where enums are defined)
  [[ "$f" == *enum* ]] && continue

  # ET-001: String comparisons that should be enums (in views, widgets, cubits)
  if is_view_file "$f" || is_widget_file "$f" || is_cubit_file "$f"; then
    # Match patterns like: == 'active', == "pending", == 'full'
    # Exclude: import statements, comment lines, route paths, URLs, package names
    while IFS=: read -r line_num content; do
      [ -z "$line_num" ] && continue
      # Skip lines that are comments, imports, routes, or asset paths
      if echo "$content" | grep -qE '^\s*//|^\s*import|route|path|asset|url|http|package:|/|\.dart'; then
        continue
      fi
      violation "$f" "$line_num" "ET-001" "Use enum instead of string comparison: $(echo "$content" | xargs)"
    done < <(grep -nE "==\s*['\"][a-z][a-zA-Z_]*['\"]" "$f" 2>/dev/null | grep -vE 'fromString|fromJson|toJson|parse|Key\b|key\b|locale|lang|route|path|\.name\b' || true)
  fi

  # ET-002: Empty catch blocks (swallowing errors)
  check_pattern "$f" 'catch\s*\([^)]*\)\s*\{\s*\}' "ET-002" "Empty catch block — at minimum log the error with AppLogger" "warning"
done

# ── Category: Custom Components ─────────────────────────────────────────────

echo ""
echo -e "${BOLD}Custom Components${NC}"

for f in "${FILES[@]}"; do
  # Skip core widget definitions and helper definitions themselves
  [[ "$f" == *core_widgets* ]] && continue
  [[ "$f" == *custom_confirmation_dialog* ]] && continue
  [[ "$f" == *custom_button* ]] && continue
  [[ "$f" == *custom_outline_button* ]] && continue
  [[ "$f" == *custom_bottom_sheet* ]] && continue
  [[ "$f" == *toast_helper* ]] && continue
  [[ "$f" == *custom_app_bar* ]] && continue
  [[ "$f" == *custom_text_field* ]] && continue

  # CC-001: No raw AlertDialog
  check_pattern "$f" '\bAlertDialog\s*\(' "CC-001" "Use CustomConfirmationDialog — no raw AlertDialog"

  # CC-002: No raw ElevatedButton
  check_pattern "$f" '\bElevatedButton\s*\(' "CC-002" "Use CustomButton — no raw ElevatedButton"
  check_pattern "$f" '\bElevatedButton\.icon\s*\(' "CC-002" "Use CustomButton — no raw ElevatedButton.icon"

  # CC-003: No raw OutlinedButton
  check_pattern "$f" '\bOutlinedButton\s*\(' "CC-003" "Use CustomOutlineButton — no raw OutlinedButton"

  # CC-004: No raw SnackBar / ScaffoldMessenger
  check_pattern "$f" '\bSnackBar\s*\(' "CC-004" "Use ToastHelper — no raw SnackBar"
  check_pattern "$f" '\bScaffoldMessenger\b' "CC-004" "Use ToastHelper — no raw ScaffoldMessenger"

  # CC-005: No raw DateFormat (except in DateTimeHelper)
  if [[ "$f" != *date_time_helper* ]] && [[ "$f" != *datetime_helper* ]]; then
    check_pattern "$f" '\bDateFormat\s*\(' "CC-005" "Use DateTimeHelper — no raw DateFormat"
  fi

  # CC-006: No print/debugPrint (except in AppLogger)
  if [[ "$f" != *logger* ]] && [[ "$f" != *app_logger* ]]; then
    check_pattern "$f" '^\s*print\s*\(' "CC-006" "Use AppLogger — no print()"
    check_pattern "$f" '^\s*debugPrint\s*\(' "CC-006" "Use AppLogger — no debugPrint()"
  fi

  # CC-007: No hardcoded colors (except in AppColors, theme files)
  if [[ "$f" != *app_colors* ]] && [[ "$f" != *theme* ]] && [[ "$f" != *color* ]]; then
    check_pattern "$f" '\bColor\(0x' "CC-007" "Use AppColors — no hardcoded Color(0x...)"
    check_pattern "$f" '\bColors\.[a-z]' "CC-007" "Use AppColors — no hardcoded Colors.xxx"
  fi

  # CC-008: No raw Image.network (use cached image widget)
  if [[ "$f" != *cached_image* ]] && [[ "$f" != *image_widget* ]]; then
    check_pattern "$f" '\bImage\.network\s*\(' "CC-008" "Use CachedNetworkImage — no raw Image.network" "warning"
  fi
done

# ── Category: Code Quality ──────────────────────────────────────────────────

echo ""
echo -e "${BOLD}Code Quality${NC}"

for f in "${FILES[@]}"; do
  # CQ-001: No // ignore: suppressions
  check_pattern "$f" '//\s*ignore:' "CQ-001" "Fix the underlying issue — no // ignore: suppressions"

  # CQ-002: No TODO comments
  check_pattern "$f" '//\s*TODO' "CQ-002" "Resolve TODOs before committing" "warning"

  # CQ-004: Multiple classes per file (skip state files)
  if ! is_state_file "$f"; then
    class_count=$(count_grep '^\s*class\s+[A-Z]' "$f")
    if [ "$class_count" -gt 1 ]; then
      non_state_classes=$(grep -E '^\s*class\s+[A-Z]' "$f" 2>/dev/null | grep -vcE 'State\b|Exception\b') || non_state_classes=0
      if [ "$non_state_classes" -gt 1 ]; then
        violation "$f" "-" "CQ-004" "Multiple classes in one file ($class_count classes) — one class per file"
      fi
    fi
  fi

  # CQ-005: Commented-out code
  while IFS=: read -r line_num content; do
    [ -z "$line_num" ] && continue
    if echo "$content" | grep -qE '//\s*(final |var |const |return |if\s*\(|for\s*\(|while\s*\(|class |void |await |import )'; then
      warning "$f" "$line_num" "CQ-005" "Possible commented-out code — delete it: $(echo "$content" | head -c 100 | xargs)"
    fi
  done < <(grep -nE '^\s*//' "$f" 2>/dev/null | grep -vE '///|// ignore:|// TODO|// MARK:|// coverage:|// ignore_for_file' || true)

  # CQ-006: Repository files should use execute(), not manual try-catch
  if is_repo_file "$f"; then
    check_pattern "$f" '^\s*try\s*\{' "CQ-006" "Use execute() wrapper — no manual try-catch in repositories"
  fi

  # CQ-007: Inconsistent border radius — flag very large values (100+)
  if is_view_file "$f" || is_widget_file "$f"; then
    check_pattern "$f" 'BorderRadius\.circular\(\s*[1-9][0-9]{2,}\s*\)' "CQ-007" "Unusually large border radius — use a standardized constant" "warning"
  fi
done

# ── Category: Import Rules ──────────────────────────────────────────────────

echo ""
echo -e "${BOLD}Import Rules${NC}"

for f in "${FILES[@]}"; do
  # IM-001: No relative imports
  while IFS=: read -r line_num content; do
    [ -z "$line_num" ] && continue
    violation "$f" "$line_num" "IM-001" "Use package import instead of relative: $(echo "$content" | xargs)"
  done < <(grep -nE "^import\s+'" "$f" 2>/dev/null | grep -vE "^[0-9]+:import\s+'package:" | grep -vE "^[0-9]+:import\s+'dart:" || true)

  # IM-002: Importing another feature's internal widgets (not _shared, not core_widgets)
  # Cubits are globally registered in app_page.dart, so cross-cubit imports are expected
  if [[ "$f" == *features/* ]]; then
    this_feature=$(echo "$f" | sed -n 's|.*features/\([^/]*/[^/]*\)/.*|\1|p')
    while IFS=: read -r line_num content; do
      [ -z "$line_num" ] && continue
      imported_path=$(echo "$content" | sed -n "s|.*features/\([^/]*/[^/]*\)/.*|\1|p")
      if [ -n "$imported_path" ] && [ "$imported_path" != "$this_feature" ]; then
        if echo "$content" | grep -qE 'presentation/widgets/' && ! echo "$content" | grep -q '_shared'; then
          warning "$f" "$line_num" "IM-002" "Importing another feature's widgets — move to _shared/ or core_widgets/: $(echo "$content" | xargs)"
        fi
      fi
    done < <(grep -nE "^import\s+'package:.*features/.*presentation/widgets/" "$f" 2>/dev/null || true)
  fi
done

# ── Category: Naming Conventions ────────────────────────────────────────────

echo ""
echo -e "${BOLD}Naming Conventions${NC}"

for f in "${FILES[@]}"; do
  # NC-001: Non-snake_case file names
  basename_f=$(basename "$f" .dart)
  if echo "$basename_f" | grep -qE '[A-Z]'; then
    violation "$f" "-" "NC-001" "File name not snake_case: $basename_f.dart"
  fi

  # NC-002: File name doesn't match primary class name (heuristic)
  # Skip barrel files, exports, main files
  if [[ "$f" != *exports* ]] && [[ "$f" != *main_* ]] && [[ "$f" != *app_* ]]; then
    primary_class=$(grep -oE '^\s*class\s+([A-Z][a-zA-Z0-9]+)' "$f" 2>/dev/null | head -1 | sed 's/.*class\s*//')
    if [ -n "$primary_class" ]; then
      # Convert PascalCase to snake_case
      expected_file=$(echo "$primary_class" | sed -E 's/([A-Z])/_\L\1/g' | sed 's/^_//')
      if [ "$basename_f" != "$expected_file" ]; then
        # Don't flag minor differences (e.g., abbreviations)
        if [ ${#basename_f} -gt 5 ] && [ ${#expected_file} -gt 5 ]; then
          : # Skip — too many false positives for a grep-based check
        fi
      fi
    fi
  fi
done

# ── Summary ─────────────────────────────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $VIOLATIONS -gt 0 ]; then
  echo -e "${RED}${BOLD}FAILED${NC}: $VIOLATIONS violation(s), $WARNINGS warning(s)"
  echo ""
  echo "Fix all violations before merging."
  echo "Run locally: ./scripts/code_quality_check.sh"
  echo "Full audit:  CHECK_ALL=true ./scripts/code_quality_check.sh"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 1
elif [ $WARNINGS -gt 0 ]; then
  echo -e "${YELLOW}${BOLD}PASSED with warnings${NC}: $WARNINGS warning(s)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
else
  echo -e "${GREEN}${BOLD}PASSED${NC}: All checks clean"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  exit 0
fi
''';
