/* project/src/dev/arch/arch_ini.c */
#include "arch_ini.h"
#include "linux/linux_proc_cpuinfo.h"

const struct CPU_INFO_OPS_API cpu_info_ops_api = {
#if defined(__linux__) || defined(__gnu_linux__) || defined(__ANDROID__)
    .cpu_thrd.stdapi = linux_proc_cputhrd,
    .cpu_core.stdapi = linux_proc_cpucore,
    .cpu_name.stdapi = linux_proc_cpuname,
    .cpu_data.stdapi = linux_proc_cpudata
#endif
};
