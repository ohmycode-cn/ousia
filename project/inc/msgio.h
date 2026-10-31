/* project/inc/msgio.h */
#pragma once
#ifndef OUSIA_MSGIO_H
#define OUSIA_MSGIO_H

#include <stdbool.h>

enum color_string {
  NCLR = 0, /* Not any color */
  DARK = 1,
  RED = 2,
  GREEN = 3,
  YELLOW = 4,
  BLUE = 5,
  PURPLE = 6,
  CYAN = 7,
  WHITE = 8
};

struct MSGIO_ARGS {
  const char *clr_prefix;
  const char *clr_body;
  const char *msg_prefix;
  const char *msg_body;
  bool clr_on;
  bool fmt_on;
};

typedef void (*fnv)(struct MSGIO_ARGS args);
typedef char *(*fnc)(struct MSGIO_ARGS args);

struct MSGIO {
  fnv msgio_v; /* Print output content, v is return void */
  fnc msgio_c; /* Return string content, c is return char * */
};

extern const struct MSGIO msgio_ops;

#endif /* OUSIA_MSGIO_H */
