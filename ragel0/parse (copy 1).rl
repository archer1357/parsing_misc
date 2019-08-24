 %%{

machine parse;

action parenStart {
  fsm->prnStart = fpc;
}

action cmntStart {
  DEBUG_MARK("comment:a",fpc);
}

action cmntEnd {
  DEBUG_MARK("comment:b",fpc);
}

action stmtStart {
  DEBUG_MARK("stmt:a",fpc);

  fsm->mStart=fpc;
  fsm->mEnd=fpc;
}

action stmtEnd {
  DEBUG_MARK("stmt:b",fpc);

  fsm->excur=true;
  fbreak;
}

action wordStart { 
  DEBUG_MARK("- word:a",fpc);

  fsm->mStart=fpc;
  fsm->mEnd=fpc;
}

action wordEnd {
  DEBUG_MARK("- word:b",fpc);
  DEBUG_VAL("===========w",fsm->mStart,fsm->mEnd);

  //mtclParseStrCallback(extraData,fsm->mStart,fsm->mEnd,x);
  
  //mtclParseWordEndCallback
}

action subStart {
  DEBUG_MARK("- - sub:a",fpc);
}

action subEnd {
  DEBUG_MARK("- - sub:b",fpc);

  fsm->mStart=fpc;
  fsm->mEnd=fpc;
}

action varStart {
  DEBUG_MARK("- - - var:a",fpc);

  fsm->wStart=fpc;  
}

action varEnd {
  DEBUG_VAL("===========v",fsm->mStart,fsm->mEnd);
  
  //mtclParseStrCallback
  
  const char *a=fsm->wStart+1;
  const char *b=fpc;
  
  if(a[0]=='{') {
    a++;
    b--;
  }

  DEBUG_MARK("- - - var:b",fpc);
  DEBUG_VAL("==========vv",a,b);
  
  //mtclParseCmdCallback(extraData,a,b,x);
  
  fsm->wStart=fpc;
}

action cmdStart {
  DEBUG_MARK("- - - cmd:a",fpc);

  fsm->wStart=fpc;  
}

action cmdEnd {
  const char *a=fsm->wStart+1;
  const char *b=fpc-1;
  
  DEBUG_VAL("===========c",fsm->mStart,fsm->mEnd);
  DEBUG_MARK("- - - cmd:b",fpc);
  DEBUG_VAL("==========cc",a,b);
  
  //mtclParseStrCallback(extraData,fsm->mStart,fsm->mEnd,x);
  //mtclParseCmdCallback(extraData,a,b,x);
  
  fsm->wStart=fpc;
}

action quoteStart {
  DEBUG_MARK("- - - qstr:a",fpc);

  fsm->wStart=fpc;
  fsm->mStart=fpc+1;  
}

action quoteEnd {
  DEBUG_MARK("- - - qstr:b",fpc);

  fsm->wStart=fpc;
}


action braceStart {
  DEBUG_MARK("- - - bstr:a",fpc);

  fsm->wStart=fpc;
}

action braceEnd {
  const char *a=fsm->wStart+1;
  const char *b=fpc-1;
  
  DEBUG_MARK("- - - bstr:b",fpc);
  DEBUG_VAL("==========bb",a,b);
  
  //mtclParseStrCallback(extraData,a,b,x);
    
  fsm->wStart=fpc;
  fsm->mStart=fpc;
}

action charEnd {  
  DEBUG_MARK("- - - str_char:b",fpc);

  fsm->wStart=fpc; //what was this for?
  fsm->mEnd=fpc;
}

action qcharEnd {  
  DEBUG_MARK("- - - str_qchar:b",fpc);

  fsm->wStart=fpc;
  fsm->mEnd=fpc;
}

action parenEof {
  fsm->parenErr=true;
}

m_clybrace  := ([^{}] | ('{' @{fcall m_clybrace;}))* $eof(parenEof) ('}' @{fret;});
m_sqrbrack := ([^\[\]] | ('[' @{fcall m_sqrbrack;}))* $eof(parenEof) (']' @{fret;});
  
clybrace  = '{' >parenStart @{fcall m_clybrace;};
sqrbrack = '[' >parenStart @{fcall m_sqrbrack;};
  
spc               = [ \t\r];
not_spc_sep = [^ \t\r\n;];
eol                = '\n';
not_eol         = (any*)-(any* eol any*);
idn                = [_a-zA-Z0-9];
sep               = (eol | ';' ) spc*;

var = ('$' (idn+ | clybrace)) >varStart %varEnd ;
cmd = sqrbrack >cmdStart %cmdEnd ;
sub = (cmd|var) @(gchar,1) >subStart %subEnd ;
 
qchar = (sub |  [^\"] >(gchar,0) @(gchar,0) %qcharEnd );
schar = (not_spc_sep >(gchar,0)  %charEnd );

qstr = ('"' >parenStart >quoteStart qchar** $eof(parenEof) '"'  ) $(gword,1) %quoteEnd ; 
str   = ( sub | schar )+ $(gword,0) ;
bstr = clybrace @(gword,1) >braceStart %braceEnd ;

word = (bstr|qstr|str) >wordStart %wordEnd ;
stmt = (word >stmtStart (spc+ word?)* %stmtEnd)  >(gstmt,0);
cmnt = ('#' >cmntStart not_eol %cmntEnd) $(gstmt,1) ; 

main := spc* sep* ((cmnt (eol space*)+) | (stmt sep+))* ((cmnt|stmt) sep*)?;
  
}%%

  

%% access fsm->;  
%% variable p fsm->p;
%% variable pe fsm->pe;
%% variable eof fsm->eof;

%%{

prepush {
}

postpop {
}

}%%


#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifndef __cplusplus
#include <stdbool.h>
#endif


#ifdef MTCL_PARSE_TEST
#define MTCL_PARSE_DEBUG
#else
#include "mtclParse.h"
#endif

#ifndef MTCL_PARSE_DEBUG
#define DEBUG_MARK(X,P)
#define DEBUG_VAL(X,A,B) 
#else
#define DEBUG_MARK(X,P) \
  printf("%s %i\n",X,(int)(P-fsm->text));
  
#define DEBUG_VAL(X,A,B) \
  if(A<B) { \
    printf("%s '%.*s'\n",X,(int)(B-A),A); \
  } else if(0) { \
    printf("%s (%i %i)\n",X,(int)(A-fsm->text),(int)(B-fsm->text)); \
  }

#endif


struct mtclParse {
  int cs;
  const char *p,*pe,*eof;
  int stack[128],top;
  
  const char *text;
  const char *prnStart;
  const char *wStart;
  const char *mStart,*mEnd;
  bool parenErr;
  bool excur;
};


%% write data;

void mtclParseInit(struct mtclParse *fsm, const char *text) {
  %% write init;
  
  fsm->p=text;
  fsm->pe=text+strlen(text);
  fsm->eof=fsm->pe;
  
  fsm->text=text;
  
  fsm->prnStart=0;
  fsm->wStart=0;
  fsm->mStart=0;
  fsm->mEnd=0;
  fsm->excur=false;
  fsm->parenErr=false;
}

void mtclParseNext(struct mtclParse *fsm) {
  %% write exec;
  
  
  if(fsm->parenErr) {
    DEBUG_MARK("paren err",fsm->p);
    //tok->type=PT_PAREN_ERR;
    //fsm->prnStart
  } else if(!fsm->excur && fsm->cs < %%{ write first_final; }%%) {
    DEBUG_MARK("err",fsm->p);
    //tok->type=PT_ERR;
  } 
}

#ifdef MTCL_PARSE_TEST
char *stringFromFile(const char *fn) {
  FILE *file = fopen(fn, "rb");
  if(!file) { return 0;  }
  fseek(file,0L,SEEK_END);
  unsigned int dataSize = ftell(file);
  fseek(file,0L,SEEK_SET);
  char *str=(char*)malloc(dataSize+1);
  str[dataSize]='\0';//is not already null terminated?
  fread(str,1,dataSize,file);
  fclose(file);
  return str;
}

int main() {
  char *text=stringFromFile("tests/evaltest.tcl");
  struct mtclParse fsm;
  mtclParseInit(&fsm,text);
  mtclParseNext(&fsm);

  free(text);
  printf("done\n");
  return 0;
}
#endif