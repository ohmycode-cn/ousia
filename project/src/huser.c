/* project/src/huser.c */
#include "huser.h"
#include "color.h"
#include "msgio.h"
#include <stdio.h>

#define OTBKC_TBUF_SIZE 256

static void otbkc_loop(const char *space, const char *bki[], int bks_size) {
  const char *RESET = {color.RESET};
  for (int index = {0}; index < bks_size; index++) {
    {
      char buf[OTBKC_TBUF_SIZE];
      snprintf(buf, sizeof(buf), "%s%s%s", bki[index], space, RESET);
      printf("%s", buf);
    }
  }
  printf("\n");
}

void huser() {

  char *base_msgs[] = {"Welcome to ousia mini lite database",
                       "Github https://github.com/ohmycode-cn/ousia",
                       "Author ohmycode-cn"};
  size_t bmsg_size = {3};
  for (size_t index = {0}; index < bmsg_size; index++)
    printf("%s\n",
           msgio_ops.msgio_c((struct MSGIO_ARGS){.clr_prefix = color.GREEN,
                                                 .clr_body = color.CYAN,
                                                 .msg_prefix = "Info ",
                                                 .msg_body = base_msgs[index],
                                                 .clr_on = true,
                                                 .fmt_on = true}));
}

void otbkc() {
  const char *space = "    ";
  int bks_size = {8};
  const char *bk0[] = {bkclr.DARK, bkclr.RED,    bkclr.GREEN, bkclr.YELLOW,
                       bkclr.BLUE, bkclr.PURPLE, bkclr.CYAN,  bkclr.WHITE};
  const char *bk1[] = {bkclr1.DARK, bkclr1.RED,    bkclr1.GREEN, bkclr1.YELLOW,
                       bkclr1.BLUE, bkclr1.PURPLE, bkclr1.CYAN,  bkclr1.WHITE};
  {
    otbkc_loop(space, bk0, bks_size);
    otbkc_loop(space, bk1, bks_size);
  }
}
