/* project/src/msgio.c */
#include "msgio.h"
#include "color.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define OUT_BUF_SIZE 1024

/* Resolve effective color: empty string when colors disabled. */
static const char *pick_color(const char *c, bool clr_on) {
  return clr_on && c ? c : "";
}

/* Compose "prefix: body" with optional color wrapping. */
static void compose_fmt(char *buf, size_t n, struct MSGIO_ARGS a) {
  const char *cp = pick_color(a.clr_prefix, a.clr_on);
  const char *cb = pick_color(a.clr_body, a.clr_on);
  const char *rst = a.clr_on ? color.RESET : "";

  if (a.clr_on) {
    snprintf(buf, n, "%s%s%s: %s%s%s", cp, a.msg_prefix ? a.msg_prefix : "",
             rst, cb, a.msg_body ? a.msg_body : "", rst);
  } else {
    snprintf(buf, n, "%s: %s", a.msg_prefix ? a.msg_prefix : "",
             a.msg_body ? a.msg_body : "");
  }
}

/* Compose "body" only with optional color wrapping. */
static void compose_body(char *buf, size_t n, struct MSGIO_ARGS a) {
  const char *cb = pick_color(a.clr_body, a.clr_on);
  const char *rst = a.clr_on ? color.RESET : "";

  if (a.clr_on) {
    snprintf(buf, n, "%s%s%s", cb, a.msg_body ? a.msg_body : "", rst);
  } else {
    snprintf(buf, n, "%s", a.msg_body ? a.msg_body : "");
  }
}

static void msgio_v_impl(struct MSGIO_ARGS args) {
  char buf[OUT_BUF_SIZE];

  if (args.fmt_on)
    compose_fmt(buf, sizeof(buf), args);
  else
    compose_body(buf, sizeof(buf), args);

  fputs(buf, stdout);
}

static char *msgio_c_impl(struct MSGIO_ARGS args) {
  char buf[OUT_BUF_SIZE];

  if (args.fmt_on)
    compose_fmt(buf, sizeof(buf), args);
  else
    compose_body(buf, sizeof(buf), args);

  return strdup(buf);
}

const struct MSGIO msgio_ops = {
    .msgio_v = msgio_v_impl,
    .msgio_c = msgio_c_impl,
};
