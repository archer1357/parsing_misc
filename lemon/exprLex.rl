
struct ExprLexState {
  int cs;
  const char *p,*pe,*eof;
  
  //scanner
  int act;
  const char *ts,*te;
  
  //stack
  //int stack[128],top;
};

#define LEXTOK(TYPE)         \
{                            \
  tok.type=TYPE;             \
  tok.start=fsm.ts;          \
  tok.end=fsm.te;            \
  tok.data.s=0;              \
  callback(tok,parser,data); \
}

%%{
  machine exprLex;
  
  #printf("sym '%.*s'\n",fsm.te-fsm.ts,fsm.ts);
  
  action FloatAction {
	  
    size_t n=(size_t)(fsm.te-fsm.ts);
	  
    char tmp[256];
    strncpy(tmp,fsm.ts,n);
    tmp[n]='\0';
    
    //char tmp=strndup(fsm.ts,n);
    tok.data.f=(float)atof(tmp);
    //free(tmp);
    
    tok.type=ET_FLOAT; 
    tok.start=fsm.ts; 
    tok.end=fsm.te;    
    callback(tok,parser,data); 
  }
  
  action IntAction {
	  
    size_t n=(size_t)(fsm.te-fsm.ts);
    
    char tmp[256];
    strncpy(tmp,fsm.ts,n);
    tmp[n]='\0';
    
    //char tmp=strndup(fsm.ts,n);
    tok.data.i=atoi(tmp);
    //free(tmp);
	 
    tok.type=ET_INT; 
    tok.start=fsm.ts; 
    tok.end=fsm.te;    
    callback(tok,parser,data); 
  }
  

  
  int = [0]|[1-9][0-9]*;
  float = int[.]([0]|[0-9]*[1-9]);
  str = [{][^}]*[}];
  idn = [_a-zA-Z][_a-zA-Z0-9]*;
   
    #"${" @{tok.start=fpc+1;} [^}]+ "}" @{tok.end=fpc;} =>{TOKEN2(ET_VAR); };  
    #"$" @{tok.start=fpc+1;} idn @{tok.end=fpc+1;} =>{TOKEN2(ET_VAR); };  
    #[$] @{fsm.ts=fpc+1;} [_a-zA-Z][_a-zA-Z0-9]* =>{LEXTOK(ET_VAR); };  
  main :=|* 
    [$][_a-zA-Z][_a-zA-Z0-9]* =>{LEXTOK(ET_VAR); };  
    float => FloatAction;
    int => IntAction;
    "==" => {LEXTOK(ET_EQ); };  
    "!=" => {LEXTOK(ET_NE); };
    ">=" => {LEXTOK(ET_GE); };
    "<=" => {LEXTOK(ET_LE); };
    ">" => {LEXTOK(ET_GT); };
    "<" => {LEXTOK(ET_LT); };
    "+" => {LEXTOK(ET_PLUS); };
    "-" => {LEXTOK(ET_MINUS); };
    "*" => {LEXTOK(ET_TIMES); };
    "/" => {LEXTOK(ET_DIVIDE); };
    "(" => {LEXTOK(ET_LPAREN); };
    ")" => {LEXTOK(ET_RPAREN); };
    space* ;
  *| ;
 
}%%

  

%% access fsm.;  
%% variable p fsm.p;
%% variable pe fsm.pe;
%% variable eof fsm.eof;


%% variable eof fsm.eof;
%% variable eof fsm.eof;


%%{
prepush {
}
postpop {
}

}%%


bool exprLex(const char *input, size_t len,void (*callback)(struct ExprToken,void*, struct ExprParseState*),void *parser,struct ExprParseState *data ) {
  %% write data;
  
  struct ExprLexState fsm;
  %% write init;
  
  fsm.p=input;
  fsm.pe=input+len;
  fsm.eof=fsm.pe;
  
  
  
  struct ExprToken tok; 
  %% write exec;
  
  bool err=fsm.cs==%%{write error;}%%;
  if(err) {
   
      printf("lex err: %s\n",fsm.p);
    
 
  }
  
  return  !err;
}





