#!/usr/bin/env bash
#
# Dotfiles installer.
#
#   curl -fsSL https://dots.hemantapkh.com | bash
#
# Pass options through the pipe with `bash -s --`:
#
#   curl -fsSL https://dots.hemantapkh.com | bash -s -- --yes
#
# Installs the dotfiles into $HOME with yadm and runs ~/.config/yadm/bootstrap
# (submodules + Brewfile), installing Homebrew and yadm first if needed.
#
# Everything is defined in functions and `main` is called on the last line, so a
# partially downloaded script never runs half-way.

# Plain POSIX so it runs (and explains itself) even when piped into sh.
if [ -z "${BASH_VERSION:-}" ]; then
  echo "This installer needs bash: curl -fsSL https://dots.hemantapkh.com | bash" >&2
  exit 1
fi

set -Eeuo pipefail

DOTS_REPO="${DOTS_REPO:-https://github.com/hemantapkh/dotfiles.git}"
DOTS_SSH_REPO="git@github.com:hemantapkh/dotfiles.git"
BREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

ASSUME_YES="${DOTS_YES:-0}"
RUN_BOOTSTRAP=ask
BOOTSTRAP=none # what happened to the bootstrap: none | skipped | ran
CHANGED=false  # whether anything was installed or updated this run
HAS_TTY=false
LOG=""
SPIN_PID=""

setup_colors() {
  if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-dumb}" != dumb ]; then
    BOLD=$'\033[1m' DIM=$'\033[2m' RESET=$'\033[0m'
    RED=$'\033[31m' GREEN=$'\033[32m' YELLOW=$'\033[33m'
    BLUE=$'\033[34m' MAGENTA=$'\033[35m' CYAN=$'\033[36m'
  else
    BOLD="" DIM="" RESET="" RED="" GREEN="" YELLOW="" BLUE="" MAGENTA="" CYAN=""
  fi
}

banner() {
  printf '\n%s' "$MAGENTA$BOLD"
  cat <<'EOF'
       __      __
  ____/ /___  / /______
 / __  / __ \/ __/ ___/
/ /_/ / /_/ / /_(__  )
\__,_/\____/\__/____/
EOF
  printf '%s' "$RESET"
  printf '  %shemantapkh/dotfiles%s\n' "$DIM" "$RESET"
}

step()  { printf '\n%s%s==>%s %s%s%s\n' "$BOLD" "$BLUE" "$RESET" "$BOLD" "$*" "$RESET"; }
info()  { printf '  %s•%s %s\n' "$CYAN" "$RESET" "$*"; }
ok()    { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
warn()  { printf '  %s!%s %s\n' "$YELLOW" "$RESET" "$*" >&2; }
fail()  { printf '  %s✗%s %s\n' "$RED" "$RESET" "$*" >&2; }
die()   { printf '\n%s%s✗ %s%s\n' "$RED" "$BOLD" "$*" "$RESET" >&2; exit 1; }

# One row of the requirements table: <✓|✗> <name> <detail>
req_row() {
  local mark
  if [ "$1" = ok ]; then mark="$GREEN✓$RESET"; else mark="$RED✗$RESET"; fi
  printf '  %s %s%-10s%s %s\n' "$mark" "$BOLD" "$2" "$RESET" "$3"
}

# stdin is the script itself when piped from curl, so prompts read /dev/tty.
detect_tty() {
  if (exec </dev/tty) 2>/dev/null; then HAS_TTY=true; fi
}

# confirm <question> [default y|n]
confirm() {
  local question=$1 default=${2:-y} hint reply
  if [ "$ASSUME_YES" = 1 ]; then
    info "$question ${DIM}(yes, --yes)${RESET}"
    return 0
  fi
  $HAS_TTY || die "Can't ask \"$question\" without a terminal. Re-run with: bash -s -- --yes"
  if [ "$default" = y ]; then hint="Y/n"; else hint="y/N"; fi
  printf '  %s?%s %s %s[%s]%s ' "$MAGENTA" "$RESET" "$question" "$DIM" "$hint" "$RESET" >/dev/tty
  read -r reply </dev/tty || reply=""
  case "${reply:-$default}" in
    [yY] | [yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

# Stdin for interactive child processes (sudo prompts, brew bundle, ...).
tty_or_null() { if $HAS_TTY; then echo /dev/tty; else echo /dev/null; fi; }

# spin <label> <command...>
# Runs a non-interactive command with a spinner; output goes to $LOG and is
# shown if the command fails.
spin() {
  local label=$1 status=0 i=0
  shift
  printf '\n$ %s\n' "$*" >>"$LOG"

  if [ ! -t 1 ]; then
    info "$label"
    "$@" >>"$LOG" 2>&1 </dev/null || status=$?
  else
    local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    "$@" >>"$LOG" 2>&1 </dev/null &
    SPIN_PID=$!
    while kill -0 "$SPIN_PID" 2>/dev/null; do
      printf '\r  %s%s%s %s' "$CYAN" "${frames[i % 10]}" "$RESET" "$label"
      i=$((i + 1))
      sleep 0.1
    done
    wait "$SPIN_PID" || status=$?
    SPIN_PID=""
    printf '\r\033[K'
  fi

  if [ "$status" -eq 0 ]; then
    ok "$label"
  else
    fail "$label (exit $status)"
    printf '%s' "$DIM" >&2
    tail -n 20 "$LOG" | sed 's/^/    /' >&2
    printf '%s' "$RESET" >&2
    return "$status"
  fi
}

cleanup() {
  if [ -n "$SPIN_PID" ]; then kill "$SPIN_PID" 2>/dev/null || true; fi
  if [ -n "$LOG" ] && [ -f "$LOG" ]; then rm -f "$LOG"; fi
}

on_error() {
  local code=$? line=$1
  fail "Unexpected error on line $line (exit $code)"
  [ -n "$LOG" ] && [ -s "$LOG" ] && cp "$LOG" "${LOG}.keep" && fail "Log saved to ${LOG}.keep"
  exit "$code"
}

usage() {
  cat <<EOF
Usage: curl -fsSL https://dots.hemantapkh.com | bash -s -- [options]

Options:
  -y, --yes          Answer yes to every prompt (also: DOTS_YES=1)
      --bootstrap    Run the yadm bootstrap without asking
      --no-bootstrap Skip the yadm bootstrap
  -h, --help         Show this help

Environment:
  DOTS_REPO   Repository to clone (default: $DOTS_REPO)
EOF
}

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      -y | --yes) ASSUME_YES=1 ;;
      --bootstrap) RUN_BOOTSTRAP=yes ;;
      --no-bootstrap) RUN_BOOTSTRAP=no ;;
      -h | --help) usage; exit 0 ;;
      *) usage >&2; die "Unknown option: $1" ;;
    esac
    shift
  done
}

detect_os() {
  step "Checking system"
  OS=$(uname -s)
  ARCH=$(uname -m)
  case "$OS" in
    Darwin)
      ok "macOS $(sw_vers -productVersion 2>/dev/null || echo '?') ($ARCH)"
      ;;
    Linux)
      ok "Linux ($ARCH)"
      warn "These dotfiles target macOS. On Linux the bootstrap only initialises"
      warn "submodules; Brewfile apps and macOS app configs won't be installed."
      confirm "Continue anyway?" n || die "Aborted."
      ;;
    *)
      die "Unsupported OS: $OS"
      ;;
  esac

  [ "$(id -u)" -ne 0 ] || die "Don't run this as root; Homebrew refuses to install as root."
  $HAS_TTY || [ "$ASSUME_YES" = 1 ] ||
    die "No terminal detected for prompts. Re-run with: bash -s -- --yes"
}

# Put an already-installed brew on PATH (fresh installs aren't on it yet).
load_brew() {
  local candidate
  command -v brew >/dev/null 2>&1 && return 0
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    if [ -x "$candidate" ]; then
      eval "$("$candidate" shellenv)"
      return 0
    fi
  done
  return 1
}

# On macOS /usr/bin/git is a stub until the Command Line Tools exist, and
# calling it pops a GUI dialog, so check for the tools first.
have_git() {
  if [ "$OS" = Darwin ] && ! xcode-select -p >/dev/null 2>&1; then
    return 1
  fi
  command -v git >/dev/null 2>&1 && git --version >/dev/null 2>&1
}

show_requirements() {
  if have_git; then
    req_row ok git "$(git --version | awk '{print $3}')"
  elif [ "$OS" = Darwin ]; then
    req_row missing git "${DIM}Command Line Tools missing (Homebrew installs them)${RESET}"
  else
    req_row missing git "not installed"
  fi

  if load_brew; then
    req_row ok brew "$(brew --version 2>/dev/null | awk 'NR==1{print $2}')  ${DIM}$(command -v brew)${RESET}"
  else
    req_row missing brew "not installed"
  fi

  if command -v yadm >/dev/null 2>&1; then
    req_row ok yadm "$(yadm version 2>/dev/null | awk '/^yadm/{print $3}')  ${DIM}$(command -v yadm)${RESET}"
  else
    req_row missing yadm "not installed"
  fi
}

install_brew() {
  load_brew && return 0

  printf '\n'
  info "Homebrew is required to install yadm and the apps in the Brewfile."
  confirm "Install Homebrew now?" y || die "Homebrew is required. Install it from https://brew.sh and re-run."

  step "Installing Homebrew"
  info "Running the official installer; it may ask for your password."
  local brew_env=()
  if [ "$ASSUME_YES" = 1 ] || ! $HAS_TTY; then brew_env=(NONINTERACTIVE=1); fi
  env ${brew_env[@]+"${brew_env[@]}"} /bin/bash -c "$(curl -fsSL "$BREW_INSTALL_URL")" <"$(tty_or_null)" ||
    die "Homebrew installation failed."

  load_brew || die "Homebrew installed, but 'brew' wasn't found in the usual locations."
  ok "Homebrew $(brew --version | awk 'NR==1{print $2}')"
  CHANGED=true
}

install_yadm() {
  command -v yadm >/dev/null 2>&1 && return 0

  printf '\n'
  info "yadm manages these dotfiles directly in \$HOME."
  confirm "Install yadm with Homebrew?" y || die "yadm is required. Install it with 'brew install yadm' and re-run."
  spin "Installing yadm" brew install yadm || die "Couldn't install yadm."
  CHANGED=true
}

ensure_requirements() {
  step "Requirements"
  show_requirements

  install_brew
  install_yadm

  have_git || die "git is still unavailable. Install it (macOS: xcode-select --install) and re-run."
}

yadm_repo_exists() {
  local repo
  repo=$(yadm introspect repo 2>/dev/null) && [ -d "$repo" ]
}

clone_or_update() {
  step "Dotfiles"

  if yadm_repo_exists; then
    local remote
    remote=$(yadm remote get-url origin 2>/dev/null || echo "none")
    ok "yadm repo already exists ${DIM}(origin: $remote)${RESET}"

    if [ -n "$(yadm status --porcelain --untracked-files=no 2>/dev/null)" ]; then
      warn "You have local changes; not pulling. Review them with 'yadm status'."
    elif confirm "Pull the latest changes?" y; then
      local before
      before=$(yadm rev-parse HEAD 2>/dev/null || true)
      if GIT_TERMINAL_PROMPT=0 spin "Pulling latest changes" yadm pull --ff-only; then
        if [ "$(yadm rev-parse HEAD 2>/dev/null || true)" = "$before" ]; then
          info "Already up to date."
        else
          CHANGED=true
        fi
      else
        warn "Pull failed; continuing with what's already checked out."
      fi
    fi
    return 0
  fi

  info "Cloning $DOTS_REPO into \$HOME"
  # Bootstrap is run separately below so its prompts can reach the terminal.
  GIT_TERMINAL_PROMPT=0 spin "Cloning dotfiles" yadm clone --no-bootstrap "$DOTS_REPO" ||
    die "Clone failed. Check your network and that $DOTS_REPO is reachable."
  CHANGED=true

  # yadm never overwrites existing files; it leaves them as local modifications.
  local changed
  changed=$(yadm diff --name-only 2>/dev/null || true)
  if [ -n "$changed" ]; then
    warn "These existing files differ from the repo and were left untouched:"
    printf '%s\n' "$changed" | sed "s/^/      ${DIM}~\//; s/\$/${RESET}/" >&2
    warn "Review with 'yadm diff'; take the repo version with 'yadm checkout -- <file>'."
  fi
}

run_bootstrap() {
  step "Bootstrap"

  local bootstrap="$HOME/.config/yadm/bootstrap"
  if [ ! -x "$bootstrap" ]; then
    warn "No executable bootstrap found at $bootstrap; skipping."
    return 0
  fi

  case "$RUN_BOOTSTRAP" in
    no)
      info "Skipped (--no-bootstrap)."
      BOOTSTRAP=skipped
      return 0
      ;;
    ask)
      info "Initialises submodules and installs everything in the Brewfile. This can take a while."
      if ! confirm "Run 'yadm bootstrap' now?" y; then
        info "Skipped."
        BOOTSTRAP=skipped
        return 0
      fi
      ;;
  esac

  printf '\n'
  yadm bootstrap <"$(tty_or_null)" ||
    die "Bootstrap failed. Fix the error above and re-run 'yadm bootstrap' (it's safe to repeat)."
  ok "Bootstrap finished"
  BOOTSTRAP=ran
  CHANGED=true
}

summary() {
  local todo=() item n=1

  [ "$BOOTSTRAP" = skipped ] &&
    todo+=("Run ${BOLD}yadm bootstrap${RESET} to init submodules and install the Brewfile apps")
  $CHANGED &&
    todo+=("Restart your terminal, or run ${BOLD}exec zsh${RESET}")
  [ -f "$HOME/.ssh/id_ed25519.pub" ] ||
    todo+=("Add your SSH key ${BOLD}~/.ssh/id_ed25519.pub${RESET} (.gitconfig signs commits with it)")
  if command -v gh >/dev/null 2>&1 && ! gh auth token >/dev/null 2>&1; then
    todo+=("Log in to GitHub: ${BOLD}gh auth login${RESET}")
  fi
  case "$(yadm remote get-url origin 2>/dev/null || true)" in
    https://*)
      todo+=("Switch the dotfiles remote to SSH once your key is on GitHub:"$'\n'"       ${DIM}yadm remote set-url origin $DOTS_SSH_REPO${RESET}")
      ;;
  esac

  if [ "$BOOTSTRAP" = skipped ]; then
    step "Dotfiles are in place ${YELLOW}(bootstrap skipped)${RESET}"
  elif $CHANGED; then
    step "All set ${GREEN}✓${RESET}"
  else
    step "Already up to date ${GREEN}✓${RESET}"
  fi

  if [ ${#todo[@]} -eq 0 ]; then
    ok "Nothing left to do."
    printf '\n'
    return 0
  fi

  printf '\n  %sNext steps%s\n' "$BOLD" "$RESET"
  for item in "${todo[@]}"; do
    printf '    %s%d.%s %s\n' "$CYAN" "$n" "$RESET" "$item"
    n=$((n + 1))
  done
  printf '\n'
}

main() {
  setup_colors
  parse_args "$@"
  detect_tty

  cd "$HOME"
  LOG=$(mktemp "${TMPDIR:-/tmp}/dots-install.XXXXXX")
  trap cleanup EXIT
  trap 'on_error $LINENO' ERR
  trap 'printf "\n"; die "Interrupted."' INT TERM

  banner
  detect_os
  ensure_requirements
  clone_or_update
  run_bootstrap
  summary
}

main "$@"
