
void exprLexCallback(struct ExprToken tok,void *parser, struct ExprParseState *parseState) {
  ExprParse(parser,tok.type,tok,parseState);
  // printf("'%.*s'\n",(size_t)(tok.end-tok.start),tok.start);
}

int exprRun(struct picolInterp *i, const char *text) {
  void *parser;
  struct ExprParseState parseState;
  parser=(void*)ExprParseAlloc(malloc);
  parseState.i=i;
  parseState.result=0;

  if(!exprLex(text,strlen(text),exprLexCallback,parser,&parseState)) {
    ExprParseFree(parser,free);
    return PICOL_ERR;
  }

  {
     struct ExprToken tok;
     ExprParse(parser, 0,tok,&parseState);
  }

  picolSetResult(i,parseState.result);
  free(parseState.result);

  return PICOL_OK;
}
