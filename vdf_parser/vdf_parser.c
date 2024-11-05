/*

main = spc (str spc (str|grp) spc)*
spc = [\r\n\s\t]*
str = '"' [^"]* '"'
grp = '{' main '}'


main:
    call spc
.b
    call str
    jf SUCCESS
    call spc
    call str
    js .a
    call grp
    jf FAIL
.a:
    call spc
    jmp .b
    SUCCESS

spc:
.a:
    parse '\r'
    js .a
    parse '\n'
    js .a
    parse '\s'
    js .a
    parse '\t'
    js .a
    SUCCESS

grp:
    parse '{'
    jf FAIL
    jmp main
    parse '}'
    jf FAIL
    SUCCESS

*/

#include <stdio.h>
#include <stdlib.h>

const char *parse_str(const char *text) {
    if((++text)[0]!='"') {
        return 0;
    }

    while(text[0]!='"') {
        text++;
    }
    
    if((++text)[0]!='"') {
        return 0;
    }

    return text;
}

const char *parse_spc(const char *text) {
    while(text[0]=='\r' ||
          text[0]=='\n' ||
          text[0]=='\s' ||
          text[0]=='\t') {
        text++;
    }

    return text;
}


const char *parse_main(const char *text) {
    /*
main = spc (str spc (str|grp) spc)*
spc = [\r\n\s\t]*
str = '"' [^"]* '"'
grp = '{' main '}'
*/
    text=parse_spc(text);

    while(true) {

        if(!(text=parse_str(text))) {
            break;
        }
                
        text=parse_spc(text);
        
        if((text=parse_str(text))) {
                    
        } else {
            if(text[0]=='{') {
                text++;

                
                if(text[0]!='}') {
                    return 0;
                }                      
            } else {
                
            }                        
        }        
        
        text=parse_spc(text);
        
    }
}


char *string_from_file(const char *fn) {
  FILE *file;
  unsigned int dataSize;
  char *str;

  if(!(file = fopen(fn, "rb"))) {
    return 0;
  }

  fseek(file,0L,SEEK_END);
  dataSize = ftell(file);
  fseek(file,0L,SEEK_SET);
  str=(char*)malloc(dataSize+1);
  str[dataSize]='\0';
  fread(str,1,dataSize,file);
  fclose(file);

  return str;
}

int main(int argc, const char* argv[]) {
    if(argc!=2) {
        fprintf( stderr, "Arguments: FILE.vdf\n",argv[0]);
        return 1;
    }

    const char *text=string_from_file(argv[1]);

    if(!text) {
        fprintf( stderr, "Error reading file '%s'.",argv[1]);
        return 1;
    }

    //printf("%s",text);

    return 0;
}
