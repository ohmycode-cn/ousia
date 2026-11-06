/* project/inc/dev/cpu.h */
#pragma once
#ifndef OUSIA_CPU_H
#define OUSIA_CPU_H

#include "ops_api.h"

struct CPU_DATA_INFO {
  struct DEV_OPS_API get_cpu_threads_number;
  struct DEV_OPS_API get_cpu_cores_number;
  struct DEV_OPS_API get_cpu_name;
};

extern const struct CPU_DATA_INFO cpu_ops;

#endif // OUSIA_CPU_H
