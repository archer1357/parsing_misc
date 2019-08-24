%name ExprParse
%token_prefix    ET_

%stack_size 100

%token_type    {struct ExprToken}

//%token_destructor {      size_t n=(size_t)($$.end-$$.start);      printf("'%.*s'\n",n,$$.start);}

%extra_argument { struct ExprParseState *data }

%parse_accept {
  //printf("parsing complete!\n");
}

%parse_failure {
  fprintf(stderr,"Giving up.  Parser is hopelessly lost...\n");
}

%stack_overflow {
  fprintf(stderr,"Giving up.  Parser stack overflow\n");
}

%left AND.
%left OR.
%nonassoc EQ NE GT GE LT LE.
%left PLUS MINUS.
%left TIMES DIVIDE MOD.
%right EXP NOT.

program ::= expr(A).                                 {exprTokenResult(&A,data);}
expr(A) ::= expr(B) EQ expr(C).              {exprCalcEq(&A,&B,&C); }
expr(A) ::= expr(B) NE expr(C).              {exprCalcNe(&A,&B,&C); }
expr(A) ::= expr(B) GE expr(C).              {exprCalcGe(&A,&B,&C); }
expr(A) ::= expr(B) LE expr(C).              {exprCalcLe(&A,&B,&C); }
expr(A) ::= expr(B) GT expr(C).              {exprCalcGt(&A,&B,&C); }
expr(A) ::= expr(B) LT expr(C).              {exprCalcLt(&A,&B,&C); }
expr(A) ::= expr(B) PLUS expr(C).              {exprCalcAdd(&A,&B,&C); }
expr(A) ::= expr(B) MINUS expr(C).            {exprCalcSub(&A,&B,&C); }
expr(A) ::= expr(B) TIMES expr(C).             {exprCalcMul(&A,&B,&C); }
expr(A) ::= expr(B) DIVIDE expr(C).            {exprCalcDiv(&A,&B,&C); }
expr(A) ::= LPAREN expr(B) RPAREN.         {A=B;}
expr(A) ::= MINUS expr(B).  [NOT]              {exprCalcNeg(&A,&B); }  
expr(A) ::= PLUS expr(B).  [NOT]                {A=B;}
expr(A) ::= FLOAT(B).                                 {A=B;}
expr(A) ::= INT(B).                                     {A=B;}
expr(A) ::= VAR(B).                                     {exprCalcVar(data->i,&A,&B);}
expr(A) ::= STR(B).                                     {A=B;}

 