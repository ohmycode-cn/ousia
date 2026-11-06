/* project/src/dev/arch/linux/linux_proc_cpuinfo.c */
#include "linux_proc_cpuinfo.h"
#include <threads.h>

static char *linux_fetch_cpudata() {
  static thread_local char buf[512];
  return buf;
};

static char *linux_fetch_cpuname() {
  static thread_local char buf[64];
  return buf;
};

static char *linux_fetch_cpucore() {
  static thread_local char buf[16];
  return buf;
}

static char *linux_fetch_cputhrd() {
  static thread_local char buf[16];
  return buf;
};

char *linux_proc_cputhrd() { return linux_fetch_cputhrd(); }
char *linux_proc_cpucore() { return linux_fetch_cpucore(); }
char *linux_proc_cpuname() { return linux_fetch_cpuname(); }
char *linux_proc_cpudata() { return linux_fetch_cpudata(); }
