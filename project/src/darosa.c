/* project/src/darosa.c */
#include "darosa.h"
#include "osini.h"
#include <stddef.h>
#include <stdio.h>

static const char **logo(size_t *count, int *wline) {
  static const char *box[] = {
      "+------------------------------------------------------+", //
      "|        ##########                  ##########        |", //
      "|        ##########                  ##########        |", //
      "|        ##########                  ##########        |", //
      "|        ##########                  ##########        |", //
      "|        ##########                  ##########        |", //
      "|        ##########    ##########    ##########        |", //
      "|        ##########    ##########    ##########        |", //
      "|        ##########    ##########    ##########        |", //
      "|                                                      |", //
      "|           - - - - - - - - - - - - - - - -            |", //
      "|                                                      |", //
      "|              D A R O S A   K E R N E L               |", //
      "|                                                      |", //
      "|        ##########    ##########    ##########        |", //
      "|        ##########    ##########    ##########        |", //
      "|        ##########    ##########    ##########        |", //
      "|        ##########                  ##########        |", //
      "|        ##########                  ##########        |", //
      "|        ##########                  ##########        |", //
      "|        ##########                  ##########        |", //
      "|        ##########                  ##########        |", //
      "+------------------------------------------------------+", //

  };

  (*wline) = 56;
  (*count) = 23;
  return box;
}

void darsoa(struct DAROSA_ARGS args) {

  // keep it.
  [[maybe_unused]] auto clron = args.color_on;

  size_t count1 = {0};
  size_t count2 = {0};
  int wline = {0};

  const char **logobox = logo(&count1, &wline);
  const char **inibox = darosa_ini(&count2);

  size_t maxct = {(count1 > count2) ? count1 : count2};

  for (size_t idx = {0}; idx < maxct; idx++) {
    if (idx < count1 && idx < count2) {
      printf("%s%s\n", logobox[idx], inibox[idx]);
    } else if (idx >= count1) {
      printf("%*s%s\n", wline, "", inibox[idx]);
    } else if (idx <= count1) {
      printf("%s\n", logobox[idx]);
    }
  }
}