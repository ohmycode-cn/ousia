#!/bin/bash

if [[ "${0}" != "${BASH_SOURCE[0]}" ]]; then
  echo -e "\033[31mFatal\033[0m: Right usage: bash compile.sh [cmd] [arg]"
  echo -e "You can run bash compile.sh --help get more help"
  return 1 &>/dev/null
fi

readonly __LOGS__="logs/compilation/log.txt"
readonly __BUILD_DIR__="build"
readonly __BIN__="output/bin/ousia"

# shellcheck disable=SC1091
source ".shared.sh"

# parsed state (extend here when adding options)
_OPT_STATIC=0      # --static       : link with -static
_OPT_OFF_UNIT=0    # --off-unit-test: UNIT_TEST=OFF (production binary)
_OPT_REBUILD=0     # --rebuild      : rm -rf build/ then configure/build
_OPT_HELP=0        # --help(-h)     : show help

function Welcome() {
  MsgInfo "[ WELCOME TO OUSIA PROJECT COMPILE BASH SCRIPT ]"
}

function HelpIni() {
  local fname="compile.sh"
  MsgInfo "[ THIS IS BASH SCRIPT '${fname}' HELP ]"
  MsgInfo "Warning:"
  MsgInfo "     Option order is free (switch-case parsing)."
  MsgInfo "     Logs are written to: ${__LOGS__}"
  MsgInfo "     Binary is written to: ${__BIN__}"
  MsgInfo "     Default build keeps UNIT_TEST=ON."
  MsgInfo "Command:"
  MsgInfo "     --static"
  MsgInfo "                     Static link (pass -static to the linker)"
  MsgInfo "     --off-unit-test"
  MsgInfo "                     Configure UNIT_TEST=OFF (production binary only)"
  MsgInfo "     --rebuild"
  MsgInfo "                     Delete ${__BUILD_DIR__}/ then reconfigure and build"
  MsgInfo "     --help(-h)"
  MsgInfo "                     Show this help"
  MsgInfo "Usage:"
  MsgInfo "     bash ${fname} [cmd] [arg]"
  MsgInfo ""
  MsgInfo "E.g: [ Error Usage ]"
  MsgInfo "     bash ${fname} --staticx"
  MsgInfo "     bash ${fname} --unknown"
  MsgInfo "     ......"
  MsgInfo ""
  MsgInfo "E.g: [ Allow - Build ]"
  MsgInfo "     bash ${fname}"
  MsgInfo "     bash ${fname} --static"
  MsgInfo "     bash ${fname} --off-unit-test"
  MsgInfo "     bash ${fname} --static --off-unit-test"
  MsgInfo "     bash ${fname} --rebuild"
  MsgInfo "     bash ${fname} --rebuild --static --off-unit-test"
}

# Parse argv in any order. New options: add a case branch only.
function ParseArgs() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --static)
      _OPT_STATIC=1
      shift
      ;;
    --off-unit-test)
      _OPT_OFF_UNIT=1
      shift
      ;;
    --rebuild)
      _OPT_REBUILD=1
      shift
      ;;
    --help | -h)
      _OPT_HELP=1
      shift
      ;;
    *)
      MsgError "Unknown option: $1"
      HelpIni
      return 1
      ;;
    esac
  done
  return 0
}

function PrepareLogs() {
  mkdir -p "$(dirname "${__LOGS__}")" || return 1
  : >"${__LOGS__}" || return 1
  return 0
}

function CleanBuildDir() {
  if [[ ! -d "${__BUILD_DIR__}" ]]; then
    MsgInfo "Build directory not found, skip remove: ${__BUILD_DIR__}"
    return 0
  fi
  MsgWarning "Removing build directory: ${__BUILD_DIR__}"
  rm -rf -- "${__BUILD_DIR__}" || {
    MsgError "Failed to remove ${__BUILD_DIR__}"
    return 1
  }
  MsgDone "Removed ${__BUILD_DIR__}"
  return 0
}

function ConfigureProject() {
  local unit_test="ON"
  local linker_flags=()
  local cmake_args=()

  if [[ ${_OPT_OFF_UNIT} -eq 1 ]]; then
    unit_test="OFF"
  fi

  cmake_args+=(
    -S .
    -B "${__BUILD_DIR__}"
    -DUNIT_TEST="${unit_test}"
  )

  if [[ ${_OPT_STATIC} -eq 1 ]]; then
    linker_flags+=(-static)
  fi

  if [[ ${#linker_flags[@]} -gt 0 ]]; then
    cmake_args+=(-DCMAKE_EXE_LINKER_FLAGS="${linker_flags[*]}")
  fi

  MsgInfo "Configure: UNIT_TEST=${unit_test} static=${_OPT_STATIC}"
  cmake "${cmake_args[@]}" >>"${__LOGS__}" 2>&1
  local ret="${?}"
  if [[ "${ret}" != "0" ]]; then
    MsgError "Configure failed ! Please check your log file for: ${__LOGS__}"
    return 1
  fi
  MsgDone "Configure successful"
  return 0
}

function BuildProject() {
  local ret
  MsgInfo "Building with: cmake --build ${__BUILD_DIR__}"
  cmake --build "${__BUILD_DIR__}" >>"${__LOGS__}" 2>&1
  ret="${?}"
  if [[ "${ret}" != "0" ]]; then
    MsgError "Compile failed ! Please check your log file for: ${__LOGS__}"
    return 1
  fi
  MsgDone "Compiled successful"
  return 0
}

function RunBinary() {
  local ret
  if [[ ! -x "${__BIN__}" ]]; then
    MsgError "Binary not found: ${__BIN__}"
    return 1
  fi
  MsgInfo "Try run ${__BIN__} please wait ..."
  "${__BIN__}"
  ret="${?}"
  MsgInfo "ousia execute ret-code is: ${ret}"
  return 0
}

function Main() {
  Welcome

  ParseArgs "$@" || return 1

  if [[ ${_OPT_HELP} -eq 1 ]]; then
    HelpIni
    return 0
  fi

  PrepareLogs || return 1

  if [[ ${_OPT_REBUILD} -eq 1 ]]; then
    CleanBuildDir || return 1
  fi

  ConfigureProject || return 1
  BuildProject || return 1
  RunBinary || return 1

  return 0
}

Main "$@"
exit $?
