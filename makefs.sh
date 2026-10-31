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
_OPT_TYPE_SET=0  # 1 if --type was provided
_OPT_TYPE=""     # --type value: "" | default | test
_OPT_NOT_H=0   # --not-h: create .c instead of .h
_OPT_RMS=""    # --rms  : delete paired .h and .c (no suffix)
_OPT_RM=""     # --rm   : delete single file (with .h/.c suffix)
_OPT_HELP=0

function Welcome() {
  MsgInfo "[ WELCOME TO OUSIA PROJECT BUILD BASH SCRIPT ]"
}

# type mode: test -> project/test; ""/default/absent -> production
function UseTestDirs() {
  [[ "${_OPT_TYPE}" == "test" ]]
}

function ValidateTypeValue() {
  case "${_OPT_TYPE}" in
    ""|default|test)
      return 0
      ;;
    *)
      MsgError "Invalid --type value: '${_OPT_TYPE}' (use \"\", default, or test)"
      return 1
      ;;
  esac
}

function HelpIni() {
  local fname="makefs.sh"
  MsgInfo "[ THIS IS BASH SCRIPT '${fname}' HELP ]"
  MsgInfo "Warning:"
  MsgInfo "     Option order is free (switch-case parsing)."
  MsgInfo "     File name never includes .h/.c; the script adds the suffix."
  MsgInfo "     Create refuses an existing target (no overwrite)."
  MsgInfo "     Delete refuses missing files (no silent success)."
  MsgInfo "     Production dirs: ${_DEFAULT_INC} (.h) / ${_DEFAULT_SRC} (.c)"
  MsgInfo "     Test dirs:       ${_DEFAULT_TEST_INC} (.h) / ${_DEFAULT_TEST_SRC} (.c)"
  MsgInfo "Command:"
  MsgInfo "     --path(-p) <dir>"
  MsgInfo "                     Target directory under project/"
  MsgInfo "                     Create: if --type test and path is not test/*,"
  MsgInfo "                     it is prefixed as project/test/<path>"
  MsgInfo "                     Delete (--rms/--rm): --path wins, --type is ignored"
  MsgInfo "     --file(-f) <name>"
  MsgInfo "                     Create file base name, no suffix"
  MsgInfo "     --type(-t) <value>"
  MsgInfo "                     Layout selector for create and delete:"
  MsgInfo "                       \"\" or default -> production (non-test dirs)"
  MsgInfo "                       test           -> project/test/..."
  MsgInfo "                     Bare --type is treated as --type test"
  MsgInfo "                     Invalid values are rejected"
  MsgInfo "                     --rms/--rm require --type or --path"
  MsgInfo "     --not-h"
  MsgInfo "                     Create .c only (no paired .h)"
  MsgInfo "                     Without --not-h: create .h + paired .c"
  MsgInfo "                     Cannot combine with --rms/--rm"
  MsgInfo "     --rms <file>  : Delete paired <file>.h and <file>.c"
  MsgInfo "                     Name has no suffix"
  MsgInfo "                     Needs --type (any value) or --path"
  MsgInfo "     --rm <file>   : Delete a single file"
  MsgInfo "                     Suffix must be .h or .c"
  MsgInfo "                     Needs --type or --path"
  MsgInfo "                     Cannot combine with --rms"
  MsgInfo "     --help(-h)    : Show this help"
  MsgInfo "Usage:"
  MsgInfo "     bash ${fname} [cmd] [arg]"
  MsgInfo ""
  MsgInfo "E.g: [ Error Usage ]"
  MsgInfo "     bash ${fname} --path test/hello --file hi.c"
  MsgInfo "     bash ${fname} --path test/hello --file hi.h"
  MsgInfo "     bash ${fname} --file hi.c"
  MsgInfo "     bash ${fname} --rms hi"
  MsgInfo "     bash ${fname} --rm hi"
  MsgInfo "     bash ${fname} --rm hi.txt"
  MsgInfo "     bash ${fname} --type test --rms hi --rm hi.h"
  MsgInfo "     bash ${fname} --type bogus --rms hi"
  MsgInfo "     bash ${fname} --type test --not-h --rms hi"
  MsgInfo "     ......"
  MsgInfo ""
  MsgInfo "E.g: [ Allow - Create ]"
  MsgInfo "     bash ${fname} --file hi"
  MsgInfo "     bash ${fname} --file hi --not-h"
  MsgInfo "     bash ${fname} --type test --file hi"
  MsgInfo "     bash ${fname} --type default --file hi"
  MsgInfo "     bash ${fname} --type \"\" --file hi"
  MsgInfo "     bash ${fname} --type test --file hi --not-h"
  MsgInfo "     bash ${fname} --path test/hello --file hi"
  MsgInfo "     bash ${fname} --path test/hello --file hi --not-h"
  MsgInfo ""
  MsgInfo "E.g: [ Allow - Delete ]"
  MsgInfo "     # production match (non-test dirs)"
  MsgInfo "     bash ${fname} --type default --rms hi"
  MsgInfo "     bash ${fname} --type \"\" --rms hi"
  MsgInfo "     bash ${fname} --type default --rm hi.h"
  MsgInfo "     bash ${fname} --type \"\" --rm hi.c"
  MsgInfo "     # test match"
  MsgInfo "     bash ${fname} --type test --rms hi"
  MsgInfo "     bash ${fname} --type test --rm hi.h"
  MsgInfo "     bash ${fname} --type test --rm hi.c"
  MsgInfo "     # explicit path (ignores --type)"
  MsgInfo "     bash ${fname} --path test/hello --rms hi"
  MsgInfo "     bash ${fname} --path test/hello --rm hi.c"
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
        if [[ $# -ge 2 && "$2" != -* ]]; then
          _OPT_TYPE="$2"
          _OPT_TYPE_SET=1
          shift 2
        else
          # bare --type: backward-compatible alias for --type test
          _OPT_TYPE="test"
          _OPT_TYPE_SET=1
          shift
        fi
        ;;
      --type=*)
        _OPT_TYPE="${1#*=}"
        _OPT_TYPE_SET=1
        shift
        ;;
      --not-h)
        _OPT_NOT_H=1
        shift
        ;;
      --rms)
        if [[ $# -lt 2 ]]; then
          MsgError "Option '$1' requires a value"
          return 1
        fi
        _OPT_RMS="$2"
        shift 2
        ;;
      --rms=*)
        _OPT_RMS="${1#*=}"
        shift
        ;;
      --rm)
        if [[ $# -lt 2 ]]; then
          MsgError "Option '$1' requires a value"
          return 1
        fi
        _OPT_RM="$2"
        shift 2
        ;;
      --rm=*)
        _OPT_RM="${1#*=}"
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
    if UseTestDirs && [[ "${path}" != test/* ]]; then
      printf 'project/test/%s\n' "${path}"
      return 0
    fi
    printf 'project/%s\n' "${path}"
    return 0
  fi

  if UseTestDirs; then
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
  if UseTestDirs; then
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
  if UseTestDirs; then
    printf '%s\n' "${_DEFAULT_TEST_SRC}"
  else
    printf '%s\n' "${_DEFAULT_SRC}"
  fi
}

# Delete target dirs. If --path is set, --type is ignored.
# --type ""/default -> production; --type test -> test.
function ResolveDeleteIncDir() {
  local saved_type="${_OPT_TYPE}" saved_set="${_OPT_TYPE_SET}"
  if [[ -n "${_OPT_PATH}" ]]; then
    _OPT_TYPE=""
    _OPT_TYPE_SET=0
  fi
  ResolveIncDir
  _OPT_TYPE="${saved_type}"
  _OPT_TYPE_SET="${saved_set}"
}

function ResolveDeleteSrcDir() {
  local saved_type="${_OPT_TYPE}" saved_set="${_OPT_TYPE_SET}"
  if [[ -n "${_OPT_PATH}" ]]; then
    _OPT_TYPE=""
    _OPT_TYPE_SET=0
  fi
  ResolveSrcDir
  _OPT_TYPE="${saved_type}"
  _OPT_TYPE_SET="${saved_set}"
}

function ValidateDeleteArgs() {
  local is_rms=0 is_rm=0
  local name base ext

  [[ -n "${_OPT_RMS}" ]] && is_rms=1
  [[ -n "${_OPT_RM}" ]] && is_rm=1

  if [[ ${is_rms} -eq 0 && ${is_rm} -eq 0 ]]; then
    return 0
  fi

  if [[ ${is_rms} -eq 1 && ${is_rm} -eq 1 ]]; then
    MsgError "--rms and --rm cannot be used together"
    return 1
  fi

  ValidateTypeValue || return 1

  # Must pair with --type unless --path is explicitly given
  if [[ -z "${_OPT_PATH}" && ${_OPT_TYPE_SET} -ne 1 ]]; then
    MsgError "Option --rms/--rm must be used together with --type(--t), or specify --path"
    return 1
  fi

  if [[ ${is_rms} -eq 1 ]]; then
    name="${_OPT_RMS}"
    if [[ "${name}" == *.* ]]; then
      MsgError "--rms file name must not include a suffix: ${name}"
      return 1
    fi
    if [[ ! "${name}" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
      MsgError "Invalid --rms file name: ${name}"
      return 1
    fi
    if [[ -n "${_OPT_FILE}" ]]; then
      MsgError "Option --file cannot be combined with --rms"
      return 1
    fi
  else
    name="${_OPT_RM}"
    if [[ "${name}" != *.* ]]; then
      MsgError "--rm requires a file with suffix .h or .c: ${name}"
      return 1
    fi
    base="${name%.*}"
    ext="${name##*.}"
    if [[ "${ext}" != "h" && "${ext}" != "c" ]]; then
      MsgError "--rm only accepts .h or .c suffix: ${name}"
      return 1
    fi
    if [[ -z "${base}" || ! "${base}" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
      MsgError "Invalid --rm file name: ${name}"
      return 1
    fi
    if [[ -n "${_OPT_FILE}" ]]; then
      MsgError "Option --file cannot be combined with --rm"
      return 1
    fi
  fi

  if [[ ${_OPT_NOT_H} -eq 1 ]]; then
    MsgError "Option --not-h cannot be combined with --rms/--rm"
    return 1
  fi

  return 0
}

function DeleteOne() {
  local target="$1"
  if [[ ! -e "${target}" ]]; then
    MsgError "File not found: ${target}"
    return 1
  fi
  rm -f -- "${target}" || return 1
  MsgDone "Removed ${target}"
  return 0
}

function initf_rms() {
  local inc_dir src_dir target_h target_c
  local name="${_OPT_RMS}"

  inc_dir="$(ResolveDeleteIncDir)"
  src_dir="$(ResolveDeleteSrcDir)"
  target_h="${inc_dir}/${name}.h"
  target_c="${src_dir}/${name}.c"

  if [[ ! -e "${target_h}" && ! -e "${target_c}" ]]; then
    MsgError "File not found: ${target_h} or ${target_c}"
    return 1
  fi

  if [[ -e "${target_h}" ]]; then
    DeleteOne "${target_h}" || return 1
  else
    MsgWarning "Skip missing ${target_h}"
  fi

  if [[ -e "${target_c}" ]]; then
    DeleteOne "${target_c}" || return 1
  else
    MsgWarning "Skip missing ${target_c}"
  fi

  return 0
}

function initf_rm() {
  local inc_dir src_dir target
  local name="${_OPT_RM}"
  local ext="${name##*.}"

  if [[ "${ext}" == "h" ]]; then
    inc_dir="$(ResolveDeleteIncDir)"
    target="${inc_dir}/${name}"
  else
    src_dir="$(ResolveDeleteSrcDir)"
    target="${src_dir}/${name}"
  fi

  DeleteOne "${target}"
}

function ValidateArgs() {
  ValidateTypeValue || return 1

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
    if UseTestDirs; then
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

  ValidateDeleteArgs || return 1

  if [[ -n "${_OPT_RMS}" ]]; then
    initf_rms
    return $?
  fi

  if [[ -n "${_OPT_RM}" ]]; then
    initf_rm
    return $?
  fi

  initf
}

Main "$@"
exit $?
