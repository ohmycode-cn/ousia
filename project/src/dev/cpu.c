/* project/src/dev/cpu.c */
#include "cpu.h"
#include "ops_api.h"
#include <threads.h>
// #include

/**
 * @brief: macro -> cpu buffer default size 512 and 128,
 *         unit default use: byte
 */

#define CPU_DEFAULT_BUFFER DEV_API_BASE_BUFFER_00
#define CPU_MINIUMS_BUFFER DEV_API_BASE_BUFFER_00

static ptr_string ret_cup_threads_number() { return nullptr; };

static ptr_string ret_cup_cores_number() {
  static thread_local char tmp[CPU_MINIUMS_BUFFER];
  // TODO: Get parser after cpu of buffer;
  return tmp;
};

static ptr_string ret_cup_name() {
  static thread_local char tmp[CPU_MINIUMS_BUFFER];
  // TODO: Get parser after cpu of buffer;
  return tmp;
};

const struct CPU_DATA_INFO cpu_ops = {
    .get_cpu_threads_number.getter = ret_cup_threads_number,
    .get_cpu_cores_number.getter = ret_cup_cores_number,
    .get_cpu_name.getter = ret_cup_name};