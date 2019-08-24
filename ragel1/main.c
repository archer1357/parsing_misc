
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifndef __cplusplus
#include <stdbool.h>
#endif

#include "eval.incl"

char *stringFromFile(const char *fn) {
  FILE *file = fopen(fn, "rb");
  if(!file) { return 0;  }
  fseek(file,0L,SEEK_END);
  unsigned int dataSize = ftell(file);
  fseek(file,0L,SEEK_SET);
  char *str=(char*)malloc(dataSize+1);
  str[dataSize]='\0';
  fread(str,1,dataSize,file);
  fclose(file);
  return str;
}

int main() {
  char *text=stringFromFile("test.tcl");
  parse(text,text+strlen(text),0);
  free(text);
  printf("done\n");
  return 0;
}