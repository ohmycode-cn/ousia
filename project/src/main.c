/* project/src/main.c */
#include "color.h"
#include "darosa.h"
#include "huser.h"
#include "msgio.h"
#include "term.h"
#include <stdio.h>

#ifdef UNIT_TEST_CTL
#include "ifeto.h"
#endif // UNIT_TEST_CTL

#define TERM_MINI_BUFF 1024

[[maybe_unused]]
static int oexec(char *query) {
  return 2;
}

[[maybe_unused]]
static int orun() {

  char *qslist[TERM_MINI_BUFF];
  unsigned int cnt = {0};
  bool irc = {true};

  // UNSAFETY: BUG _start:
  term(*qslist, TERM_MINI_BUFF, irc);
  for (size_t idx = {0}; idx < TERM_MINI_BUFF; idx++) {
    auto ret = oexec("tmp");
    if (1 == ret)
      return 1;
    if (0 == ret)
      cnt++;
  }
  // UNSAFETY: BUG _endof;

  printf("%s\n",
         msgio_ops.msgio_c((struct MSGIO_ARGS){.clr_prefix = color.GREEN,
                                               .clr_body = color.GREEN,
                                               .clr_on = true,
                                               .msg_prefix = "Done ",
                                               .msg_body = "Executed",
                                               .fmt_on = true}));

  return 0;
}

int main(int args, char *argc[]) {
  {
#ifdef UNIT_TEST_CTL
    ifemn();
#endif // UNIT_TEST_CTL
    huser();
    darsoa((struct DAROSA_ARGS){.color_on = true});
    otbkc();
  }
  return 0;
}
