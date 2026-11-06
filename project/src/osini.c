/* project/src/osini.c */
#include "osini.h"
#include <stddef.h>

const char **darosa_ini(size_t *number) {
  static const char *inibox[] = {
      " host name: null",                                  //
      " host ip  : null",                                  //
      " devs name:",                                       //
      "          |_name1:   null",                         //
      "          |_name2:   null",                         //
      "          |_name3:   null",                         //
      "          |_.....:   ....",                         //
      " arch :",                                           //
      "      |_x86_32: no",                                //
      "      |_x86_64: ok",                                //
      "      |_arm_64: no",                                //
      " release:",                                         //
      "        |_kernel: darosa v0.0.1 beta-mini",         //
      "        |_system: ousia  v0.0.1 beta-mini",         //
      " shell: darosa api shell",                          //
      "      |_dash e-lite v0.0.1 beta-mini",              //
      " sql  : sql-like sytanx {darsql v0.0.1 beta-mini}", //
      " cpu  : null",                                      //
      " gpu  : null",                                      //
      " npu  : null",                                      //
      " mem  : null",                                      //
      " used : null",                                      //
      " free : null",                                      //
  };
  (*number) = 23;
  return inibox;
};