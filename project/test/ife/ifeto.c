#include "ifeto.h"
#include "color.h"
#include "msgio.h"
#include <stdio.h>

static void test_msgio_output_00() {
  msgio_ops.msgio_v(
      (struct MSGIO_ARGS){.clr_prefix = color.YELLOW,
                          .clr_body = color.RED,
                          .clr_on = true,
                          .msg_prefix = "DEBUG",
                          .msg_body = "This is msgio_v test output\n",
                          .fmt_on = true});
  printf("%s", msgio_ops.msgio_c((struct MSGIO_ARGS){
                   .clr_prefix = color.YELLOW,
                   .clr_body = color.RED,
                   .clr_on = true,
                   .msg_prefix = "DEBUG",
                   .msg_body = "This is msgio_v test output\n\n",
                   .fmt_on = true}));
}

void ifemn() { test_msgio_output_00(); }
