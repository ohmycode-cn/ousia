/* project/inc/dev/arch/arch_ini.h */
// this arch open api, provide standard plantform file
#pragma once
#ifndef OUSIA_ARCH_INI_H
#define OUSIA_ARCH_INI_H

#include "arch_api.h"

struct CPU_INFO_OPS_API {
#if defined(__linux) || defined(__gnu_linux__) || defined(__ANDROID__)
  struct ARCH_STD_API cpu_thrd;
  struct ARCH_STD_API cpu_core;
  struct ARCH_STD_API cpu_name;
  struct ARCH_STD_API cpu_data;
// #elif defined(_WIN32) || defined(_WIN64)
// #elif defined(__ANDROID__)
// #elif defined(__APPLE__)
// #else
#endif
};

extern const struct CPU_INFO_OPS_API cpu_info_ops_api;

#endif // OUSIA_ARCH_INI_H
