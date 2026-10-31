#!/bin/bash

if [[ "${0}" != "${BASH_SOURCE[0]}" ]]; then
  return 1 &>/dev/null
fi

#shellcheck disable=SC1091
source ".shared.sh"

function Test0() {
  MsgWarning "This is test msg"
  MsgInfo "This is test msg"
  MsgDone "This is test msg"
  MsgAllow "This is test msg"
  MsgError "This is test msg"
}

Test0
exit 0
