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

typedef void (*fnv)(const char *msg, bool color, enum color_string);
typedef char *(*fnc)(const char *msg, bool color, enum color_string);

struct MSGIO {
  fnv msgio_v; // Print output content, v is return void
  fnc msgio_c; // Return string content, c is return char *
};

static const struct MSGIO msgio_ops;

#endif // OUSIA_MSGIO_H
