#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>

#ifdef _MSC_VER
#define snprintf _snprintf
#endif

#ifndef __cplusplus
#include <stdbool.h>
#endif

#include "expr.h"


struct ExprParseState {
  struct picolInterp *i;
  char *result;
};

struct ExprToken {
  int type;
  const char *start,*end;

  union {
    float f;
    int i;
    char *s;
  } data;
};
