/* project/inc/dev/arch/arch_api.h */
#pragma once
#ifndef OUSIA_ARCH_API_H
#define OUSIA_ARCH_API_H

typedef char *(*fnret)();

struct ARCH_STD_API {
  fnret stdapi;
};

#endif // OUSIA_ARCH_API_H
