#!/bin/bash

if [[ "${0}" != "${BASH_SOURCE[0]}" ]]; then
  echo -e "\033[31mFatal\033[0m: Right usage: bash makefs.sh [cmd] [arg]"
  echo -e "You can run bash makefs.sh --help get more help"
  return 1 &>/dev/null
fi

# shellcheck disable=SC1091
source ".shared.sh"

_DEFAULT_SRC="project/src"
_DEFAULT_INC="project/inc"
_DEFAULT_TEST_SRC="project/test/src"
_DEFAULT_TEST_INC="project/test/inc"

# parsed state (extend here when adding options)
_OPT_PATH=""
_OPT_FILE=""
_OPT_TYPE=0    # --type : create test file
_OPT_NOT_H=0   # --not-h: create .c instead of .h
_OPT_HELP=0

function Welcome() {
  MsgInfo "[ WELCOME TO OUSIA PROJECT BUILD BASH SCRIPT ]"
}

function HelpIni() {
  local fname="makefs.sh"
  MsgInfo "[ THIS IS BASH SCRIPT '${fname}' HELP ]"
  MsgInfo "Warning:"
  MsgInfo "     If --path is not a parameter command, default use ${_DEFAULT_SRC} and ${_DEFAULT_INC}"
  MsgInfo "Command:"
  MsgInfo "     --path(--p)   : Create file path"
  MsgInfo "     --file(--f)   : Create file name"
  MsgInfo "                     File name can't provide file type suffix, this"
  MsgInfo "                     is script of work"
  MsgInfo "     --type(--t)   : Create test file"
  MsgInfo "     --not-h       : Create .c file only"
  MsgInfo "                     Without --not-h, create .h and paired .c"
  MsgInfo "     --help(-h)    : Show this help"
  MsgInfo "Usage:"
  MsgInfo "     bash ${fname} [cmd] [arg]"
  MsgInfo ""
  MsgInfo "E.g: [ Error Usage ]"
  MsgInfo "     bash ${fname} --path test/hello --file hi.c"
  MsgInfo "     or"
  MsgInfo "     bash ${fname} --path test/hello --file hi.h"
  MsgInfo "     ......"
  MsgInfo ""
  MsgInfo "E.g: [ Allow Usage ]"
  MsgInfo "     bash ${fname} --path test/hello --file hi"
  MsgInfo "     If you want a C file, please use parameter command --not-h"
  MsgInfo "     bash ${fname} --path test/hello --file hi --not-h"
  MsgInfo "     Create test header under default test inc:"
  MsgInfo "     bash ${fname} --type --file hi"
}

# Parse argv in any order. New options: add a case branch only.
function ParseArgs() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --path|--p)
        if [[ $# -lt 2 ]]; then
          MsgError "Option '$1' requires a value"
          return 1
        fi
        _OPT_PATH="$2"
        shift 2
        ;;
      --path=*)
        _OPT_PATH="${1#*=}"
        shift
        ;;
      --file|--f)
        if [[ $# -lt 2 ]]; then
          MsgError "Option '$1' requires a value"
          return 1
        fi
        _OPT_FILE="$2"
        shift 2
        ;;
      --file=*)
        _OPT_FILE="${1#*=}"
        shift
        ;;
      --type|--t)
        _OPT_TYPE=1
        shift
        ;;
      --not-h)
        _OPT_NOT_H=1
        shift
        ;;
      --help|-h)
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

function ResolveBaseDir() {
  local path="${_OPT_PATH}"

  if [[ -n "${path}" ]]; then
    path="${path#./}"
    if [[ "${path}" == /* || "${path}" == project/* ]]; then
      printf '%s\n' "${path}"
      return 0
    fi
    if [[ ${_OPT_TYPE} -eq 1 && "${path}" != test/* ]]; then
      printf 'project/test/%s\n' "${path}"
      return 0
    fi
    printf 'project/%s\n' "${path}"
    return 0
  fi

  if [[ ${_OPT_TYPE} -eq 1 ]]; then
    printf 'project/test\n'
  else
    printf 'project\n'
  fi
}

function ResolveIncDir() {
  local base
  base="$(ResolveBaseDir)"
  if [[ -n "${_OPT_PATH}" ]]; then
    printf '%s\n' "${base}"
    return 0
  fi
  if [[ ${_OPT_TYPE} -eq 1 ]]; then
    printf '%s\n' "${_DEFAULT_TEST_INC}"
  else
    printf '%s\n' "${_DEFAULT_INC}"
  fi
}

function ResolveSrcDir() {
  local base
  base="$(ResolveBaseDir)"
  if [[ -n "${_OPT_PATH}" ]]; then
    printf '%s\n' "${base}"
    return 0
  fi
  if [[ ${_OPT_TYPE} -eq 1 ]]; then
    printf '%s\n' "${_DEFAULT_TEST_SRC}"
  else
    printf '%s\n' "${_DEFAULT_SRC}"
  fi
}

function ValidateArgs() {
  if [[ -z "${_OPT_FILE}" ]]; then
    MsgError "Missing required option: --file"
    return 1
  fi

  if [[ "${_OPT_FILE}" == *.* ]]; then
    MsgError "File name must not include a type suffix: ${_OPT_FILE}"
    return 1
  fi

  if [[ ! "${_OPT_FILE}" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
    MsgError "Invalid file name: ${_OPT_FILE}"
    return 1
  fi

  return 0
}

function WriteSourceTemplate() {
  local target="$1"
  local suffix="$2"
  local guard

  if [[ -e "${target}" ]]; then
    MsgError "File already exists: ${target}"
    return 1
  fi

  mkdir -p "$(dirname "${target}")" || return 1

  if [[ "${suffix}" == ".h" ]]; then
    if [[ ${_OPT_TYPE} -eq 1 ]]; then
      guard="TEST_OUSIA_$(printf '%s' "${_OPT_FILE}" | tr '[:lower:]' '[:upper:]')_H"
    else
      guard="OUSIA_$(printf '%s' "${_OPT_FILE}" | tr '[:lower:]' '[:upper:]')_H"
    fi
    cat > "${target}" <<EOF
/* ${target} */
#pragma once
#ifndef ${guard}
#define ${guard}

#endif  // ${guard}
EOF
  else
    if [[ ${_OPT_NOT_H} -eq 1 ]]; then
      cat > "${target}" <<EOF
/* ${target} */
EOF
    else
      cat > "${target}" <<EOF
/* ${target} */
#include "${_OPT_FILE}.h"
EOF
    fi
  fi

  return 0
}

function initf() {
  local inc_dir src_dir target_h target_c

  ValidateArgs || return 1

  inc_dir="$(ResolveIncDir)"
  src_dir="$(ResolveSrcDir)"
  target_h="${inc_dir}/${_OPT_FILE}.h"
  target_c="${src_dir}/${_OPT_FILE}.c"

  # Preflight: avoid partial create when one of pair already exists
  if [[ ${_OPT_NOT_H} -eq 0 ]]; then
    if [[ -e "${target_h}" || -e "${target_c}" ]]; then
      MsgError "File already exists: ${target_h} or ${target_c}"
      return 1
    fi
  else
    if [[ -e "${target_c}" ]]; then
      MsgError "File already exists: ${target_c}"
      return 1
    fi
  fi

  if [[ ${_OPT_NOT_H} -eq 1 ]]; then
    WriteSourceTemplate "${target_c}" ".c" || return 1
    MsgDone "Created ${target_c}"
    return 0
  fi

  WriteSourceTemplate "${target_h}" ".h" || return 1
  WriteSourceTemplate "${target_c}" ".c" || return 1
  MsgDone "Created ${target_h}"
  MsgDone "Created ${target_c}"
  return 0
}

function Main() {
  Welcome

  ParseArgs "$@" || return 1

  if [[ ${_OPT_HELP} -eq 1 || $# -eq 0 ]]; then
    HelpIni
    return 0
  fi

  initf
}

Main "$@"
exit $?
