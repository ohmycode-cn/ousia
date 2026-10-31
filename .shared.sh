#!/bin/bash

# Author：ohmycode-cn(ohcode@163.com)
# Date: 2026-10-31
# Bash Standard: bash 5.0 plus
# File Type: shared script
# Standard Usage: source ".shared.sh"

# const: _start

# pubilc:

#shellcheck disable=SC2034
CONST_ONCE_TIME="$(date +%F-%H-%M-%S-%3N)"

# private:

__ANSI__="\033"
__FONT__="[0;"
__CHAR__="m"

# const: _endof 

# private variable: _start

_RESET_="${__ANSI__}${__FONT__}0${__CHAR__}"
_DARK_="${__ANSI__}${__FONT__}30${__CHAR__}"
_RED_="${__ANSI__}${__FONT__}31${__CHAR__}"
_GREEN_="${__ANSI__}${__FONT__}32${__CHAR__}"
_YELLOW_="${__ANSI__}${__FONT__}33${__CHAR__}"
_BLUE_="${__ANSI__}${__FONT__}34${__CHAR__}"
_PURPLE_="${__ANSI__}${__FONT__}35${__CHAR__}"
_CYAN_="${__ANSI__}${__FONT__}36${__CHAR__}"
_WHITE_="${__ANSI__}${__FONT__}37${__CHAR__}"

# private variable: _endof

function NowTime() {
  echo -e "$(date +%F-%H-%M-%S::%3N)"
}

function MsgError() {
  echo -e "$(NowTime) ${_RED_}Error${_RESET_}: ${_RED_}${1}${_RESET_}"
}

function MsgInfo() {
  echo -e "$(NowTime) ${_CYAN_}Info ${_RESET_}: ${_BLUE_}${1}${_RESET_}"
}

function MsgWarning() {
  echo -e "$(NowTime) ${_YELLOW_}Warning${_RESET_}: ${_YELLOW_}${1}${_RESET_}"
}

function MsgDone() {
  echo -e "$(NowTime) ${_GREEN_}Done ${_RESET_}: ${_GREEN_}${1}${_RESET_}"
}

function MsgAllow() {
  echo -e "$(NowTime) ${_GREEN_}Allow${_RESET_}: ${_CYAN_}${1}${_RESET_}"
}
