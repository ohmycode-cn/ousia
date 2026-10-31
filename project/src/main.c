/* project/src/main.c */
#include "color.h"
#include "msgio.h"
#include <stdio.h>
#include <stdlib.h>

int main(int args, char *argc[]) {
  msgio_ops.msgio_v((struct MSGIO_ARGS){
      .clr_prefix = color.DARK,
      .clr_body = color.GREEN,
      .msg_prefix = "Info ",
      .msg_body = "RUN MAIN ...... (msgio_v)\n",
      .clr_on = true,
      .fmt_on = true,
  });

  char *s = msgio_ops.msgio_c((struct MSGIO_ARGS){
      .clr_prefix = color.DARK,
      .clr_body = color.GREEN,
      .msg_prefix = "Info ",
      .msg_body = "RUN MAIN ...... (msgio_c)\n",
      .clr_on = true,
      .fmt_on = true,
  });
  printf("%s", s);
  free(s);

  return 0;
}
