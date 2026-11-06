/* project/inc/dev/ops_api.h */
#pragma once
#ifndef OUSIA_OPS_API_H
#define OUSIA_OPS_API_H

#define DEV_API_BASE_BUFFER_00 512
#define DEV_API_BASE_BUFFER_01 128

// data type alias

typedef char *ptr_string;
typedef int ito;

// function type alias

typedef char *(*ftype)();

// standard class function interface
struct DEV_OPS_API {
  ftype getter;
};

#endif // OUSIA_OPS_API_H
