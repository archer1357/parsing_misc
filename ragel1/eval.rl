 %%{

machine tcl_parser;

action markAct {
  mark=fpc;
  printf("mark p=%i\n",(int)(fpc-srcStart));
}

action wordAct {
  printf("-word p=%i, '%.*s'\n",
         (int)(fpc-srcStart),
         (int)(fpc-mark),
         mark);
  }


action schrAct {
  printf("-schr p=%i, '%.*s'\n",
         (int)(fpc-srcStart),
         (int)(fpc-mark),
         mark);
}

action sescAct {
  printf("-sesc p=%i, '%.*s'\n",
         (int)(fpc-srcStart),
         (int)(fpc-mark),
         mark);
}

action qchrAct {
  printf("-qchr p=%i, '%.*s'\n",
         (int)(fpc-srcStart),
         (int)(fpc-mark),
         mark);
}

action bchrAct {
  printf("-bchr p=%i, '%.*s'\n",
         (int)(fpc-srcStart),
         (int)(fpc-mark),
         mark);
}

action varAct {
  printf("-var p=%i, '%.*s'\n",
         (int)(fpc-srcStart),
         (int)(fpc-mark),
         mark);
}

action stmtAct {

  printf("-stmt p=%i, '%.*s'\n",
         (int)(fpc-srcStart),
         (int)(fpc-mark),
         mark);
}


action cmntAct {
  printf("-cmnt p=%i\n",(int)(fpc-srcStart));
}

action sepAct {
  printf("sep p=%i\n",
         (int)(fpc-srcStart));
}


nws =( [^ \t\r\n;]+) ; #%(bla,1)   ;
ws = [ \t\r\n;]* $(sep,1) ;

var_idn = ([_a-zA-Z0-9]+) >(var,0) ;
var_array = (var_idn? '(' [^)]* ')') >(var,2) ;
var_str = ('{' [^}]* '}') >(var,1) ;

sesc = ('\\\r\n' | '\\' any) $(chr,1)  >markAct  %sescAct ;
schr = [^ \t\r\n;] >(chr,0) >markAct  %schrAct  ;

bchr = ([^{}] | [\\][{}])+ >markAct %bchrAct ;
qchr = [^\"]+ >markAct %qchrAct;

var = ('$' (var_idn | var_array | var_str ))
  >(chr,1)
  @(chr,2) >markAct %varAct;

cmac := (']' @{fret;});
cmd =  ('[' @{fcall cmac;}) ;

bmac := (bchr | '{' @{fcall bmac;})* ('}' @{fret;});

sstr = (var
#|sesc
|schr
)+ $(word,0) ;
bstr = ('{' @{fcall bmac;}) $(word,1)    ;
qstr = ('"' (qchr)* '"') $(word,2)   ;

word = (
sstr
#| bstr | qstr
) ;

spc =([ \t] | '\\\n' | '\\\r\n')+ $(sep,4) ;
sep = ([ \t\r]* [;\n] ws) $(sep,2) %sepAct;

stmt = word (spc word)*;
cmnt = ([#][^\n]*) $(sep,3) >markAct %cmntAct;

main := ws (cmnt | stmt) (sep (cmnt | stmt))* ws;

}%%



%% access fsm.;
%% variable p fsm.p;
%% variable pe fsm.pe;
%% variable eof fsm.eof;

%%{

prepush {
}

postpop {
}

}%%




void parse(const char *srcStart,const char *srcEnd,void *extraData) {
  %% write data;

  struct {
    int cs;
    const char *p,*pe,*eof;
    int stack[128],top;
  } fsm;

  %% write init;

  fsm.p=srcStart;
  fsm.pe=srcEnd;
  fsm.eof=fsm.pe;

  const char *mark=srcStart;


  %% write exec;

  if(fsm.top != 0) {
    printf("Err1\n");
  } else if(fsm.cs < %%{ write first_final; }%%) {
    printf("Err2\n");
  }
}
