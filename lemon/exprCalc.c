
bool exprCalcAdd(struct ExprToken *a,
                 const struct ExprToken *b,
                 const struct ExprToken *c) {
  if(b->type==ET_FLOAT || c->type==ET_FLOAT) {
    a->type=ET_FLOAT;

    if(b->type==ET_INT) {
      a->data.f=(float)b->data.i+c->data.f;
    } else if(c->type==ET_INT) {
      a->data.f=b->data.f+(float)c->data.i;
    } else {
      a->data.f=b->data.f+c->data.f;
    }
  } else {
    a->type=ET_INT;
    a->data.i=b->data.i+c->data.i;
  }

  return true;
}

bool exprCalcSub(struct ExprToken *a,
                 const struct ExprToken *b,
                 const struct ExprToken *c) {
  if(b->type==ET_FLOAT || c->type==ET_FLOAT) {
    a->type=ET_FLOAT;

    if(b->type==ET_INT) {
      a->data.f=(float)b->data.i-c->data.f;
    } else if(c->type==ET_INT) {
      a->data.f=b->data.f-(float)c->data.i;
    } else {
      a->data.f=b->data.f-c->data.f;
    }
  } else {
    a->type=ET_INT;
    a->data.i=b->data.i-c->data.i;
  }

  return true;
}

bool exprCalcMul(struct ExprToken *a,
                 const struct ExprToken *b,
                 const struct ExprToken *c) {
  if(b->type==ET_FLOAT || c->type==ET_FLOAT) {
    a->type=ET_FLOAT;

    if(b->type==ET_INT) {
      a->data.f=(float)b->data.i*c->data.f;
    } else if(c->type==ET_INT) {
      a->data.f=b->data.f*(float)c->data.i;
    } else {
      a->data.f=b->data.f*c->data.f;
    }
  } else {
    a->type=ET_INT;
    a->data.i=b->data.i*c->data.i;
  }

  return true;
}

bool exprCalcDiv(struct ExprToken *a,
                 const struct ExprToken *b,
                 const struct ExprToken *c) {
  if(b->type==ET_FLOAT || c->type==ET_FLOAT) {
    a->type=ET_FLOAT;

    if(b->type==ET_INT) {
      a->data.f=(float)b->data.i/c->data.f;
    } else if(c->type==ET_INT) {
      a->data.f=b->data.f/(float)c->data.i;
    } else {
      a->data.f=b->data.f/c->data.f;
    }
  } else {
    // if(b->data.i % c->data.i == 0) {
    a->type=ET_INT;
    a->data.i=b->data.i/c->data.i;
    // } else {
    //   a->type=ET_FLOAT;
    //   a->data.f=(float)b->data.i/(float)c->data.i;
    // }
  }

  return true;
}


bool exprCalcEq(struct ExprToken *a,
                 const struct ExprToken *b,
                 const struct ExprToken *c) {
  a->type=ET_INT;

  if(b->type==ET_FLOAT || c->type==ET_FLOAT) {


    if(b->type==ET_INT) {
      a->data.i=((float)b->data.i==c->data.f)?1:0;
    } else if(c->type==ET_INT) {
      a->data.i=(b->data.f==(float)c->data.i)?1:0;
    } else {
      a->data.i=(b->data.f==c->data.f)?1:0;
    }
  } else {
    a->data.i=(b->data.i==c->data.i)?1:0;
  }

  return true;
}

bool exprCalcNe(struct ExprToken *a,
                 const struct ExprToken *b,
                 const struct ExprToken *c) {

  exprCalcEq(a,b,c);
  a->data.i=a->data.i?0:1;
  return true;
}

bool exprCalcGt(struct ExprToken *a,
                 const struct ExprToken *b,
                 const struct ExprToken *c) {
  a->type=ET_INT;

  if(b->type==ET_FLOAT || c->type==ET_FLOAT) {
    if(b->type==ET_INT) {
      a->data.i=((float)b->data.i>c->data.f)?1:0;
    } else if(c->type==ET_INT) {
      a->data.i=(b->data.f>(float)c->data.i)?1:0;
    } else {
      a->data.i=(b->data.f>c->data.f)?1:0;
    }
  } else {
    a->data.i=(b->data.i>c->data.i)?1:0;
  }

  return true;
}

bool exprCalcLt(struct ExprToken *a,
                 const struct ExprToken *b,
                 const struct ExprToken *c) {
  a->type=ET_INT;

  if(b->type==ET_FLOAT || c->type==ET_FLOAT) {
    if(b->type==ET_INT) {
      a->data.i=((float)b->data.i<c->data.f)?1:0;
    } else if(c->type==ET_INT) {
      a->data.i=(b->data.f<(float)c->data.i)?1:0;
    } else {
      a->data.i=(b->data.f<c->data.f)?1:0;
    }
  } else {
    a->data.i=(b->data.i<c->data.i)?1:0;
  }

  return true;
}

bool exprCalcGe(struct ExprToken *a,
                 const struct ExprToken *b,
                 const struct ExprToken *c) {

  exprCalcGt(a,b,c);

  if(!a->data.i) {
    exprCalcEq(a,b,c);
  }

  return true;
}

bool exprCalcLe(struct ExprToken *a,
                 const struct ExprToken *b,
                 const struct ExprToken *c) {

  exprCalcLt(a,b,c);

  if(!a->data.i) {
    exprCalcEq(a,b,c);
  }

  return true;
}

bool exprCalcNeg(struct ExprToken *a,
                 const struct ExprToken *b) {
  if(b->type==ET_FLOAT) {
    a->type=ET_FLOAT;
    a->data.f=-b->data.f;
  } else {
    a->type=ET_INT;
    a->data.i=-b->data.i;
  }

  return true;
}

bool exprStrLexNum(const char *text, struct ExprToken *tok) {
  const char *pos=text;

  if(pos[0]=='0'&& pos[1]=='\0') {
    tok->type=ET_INT;
    tok->data.i=0;
    return true;
  } else if(pos[0]=='0'&& pos[1]=='.') {
  } else if(pos[0]>='1'&& pos[0]<='9') {
  } else {
    // printf("x1 '%s'\n",pos);
    return false;
  }

  while(pos[0]>='0'&& pos[0]<='9') {
    pos++;
  }

  if(pos[0]=='\0') {
    tok->type=ET_INT;
    tok->data.i=atoi(text);
    return true;
  }

  if((pos++)[0]!='.') {
    // printf("x2 '%s'\n",pos);
    return false;
  }

  while(pos[0]>='0'&& pos[0]<='9') {
    pos++;
  }

  if(pos[0]!='\0' ) {
    // printf("x3 '%s'\n",pos);
    return false;
  }

  tok->type=ET_FLOAT;
  tok->data.f=(float)atof(text);
  return true;
}


bool exprCalcVar(struct picolInterp *i,struct ExprToken *a,
                 const struct ExprToken *b) {

  a->start=b->start;
  a->end=b->end;
  
  const char *start=b->start+1;
  const char *end=b->end;
  
  if(start[0]=='{') {
  start++;end--;
  }
  size_t tmpLen=end-start;  
  char *tmp=(char*)malloc(tmpLen+1);     
  memcpy(tmp,start,tmpLen);    
  tmp[tmpLen]='\0';        
  
  struct picolVar *pv=picolGetVar(i,tmp,NULL);
  if(!pv) {    
    char errbuf[1024];
	snprintf(errbuf,1024,"No such variable '%s'",tmp);
	free(tmp);
    picolSetResult(i,errbuf); 
	return false; 
  }     
  
  free(tmp);                

  if(!exprStrLexNum(pv->val,a)) {
    a->type=ET_STR;
    a->data.s=strdup(pv->val);
  }

  return true;
}

void exprTokenResult(struct ExprToken *tok,struct ExprParseState *parseState) {


  if(tok->type==ET_INT) {
    parseState->result=(char*)malloc(512);
    snprintf(parseState->result,512,"%i",tok->data.i);
  } else if(tok->type==ET_FLOAT) {
    parseState->result=(char*)malloc(512);
    snprintf(parseState->result,512,"%g",(double)tok->data.f);
  } else {
    printf("answer err %i\n",tok->type);
  }
}

