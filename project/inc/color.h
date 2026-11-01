/* project/inc/color.h */
#pragma once
#ifndef OUSIA_COLOR_H
#define OUSIA_COLOR_H

struct COLOR {
  const char *RESET;
  const char *DARK;
  const char *RED;
  const char *GREEN;
  const char *YELLOW;
  const char *BLUE;
  const char *PURPLE;
  const char *CYAN;
  const char *WHITE;
};

struct BKCLR {
  const char *RESET;
  const char *DARK;
  const char *RED;
  const char *GREEN;
  const char *YELLOW;
  const char *BLUE;
  const char *PURPLE;
  const char *CYAN;
  const char *WHITE;
};

extern const struct COLOR color;
extern const struct BKCLR bkclr1; //  undertint background colors
extern const struct BKCLR bkclr;  // deep background colors

#endif // OUSIA_COLOR_H
