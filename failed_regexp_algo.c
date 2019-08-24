/*
  A failed attempt at an algorithm for parsing regular like expressions (similar to ragel's).
  Uses a single stack where the expressions are pushed on in reverse (similar to revese polish), the stack is resized depending on the operation, or/and/many. The top of the stack is repeatedly processed until there's nothing left.

  Couldn't solve how to do OR operation consistently, especially for the MANY(* or +) operations.
  
  Example used:
      a = c d e
      main = x ((a|b) y)+ z

*/

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

struct parser;
struct parser_element;

typedef void (*parser_func)(struct parser*,const struct parser_element*);

struct parser_element {
    const char *name;
    const char *src;
    parser_func func;
    const char *funcData;
    size_t success,failure;
};

struct parser {
    struct parser_element *stk;
    size_t stkMaxSize,stkSize;
    const char *errMsg;
};



size_t push(const char *name,
            struct parser *p,
            const char *src,
            parser_func func,
            const char *funcData,
            size_t success,
            size_t failure) {

    p->stk[p->stkSize].name=name;
    p->stk[p->stkSize].src=src;
    p->stk[p->stkSize].func=func;
    p->stk[p->stkSize].funcData=funcData;
    p->stk[p->stkSize].success=success;
    p->stk[p->stkSize].failure=failure;

    p->stkSize++;

    return p->stkSize;
}

void onLeaf(struct parser *p,const struct parser_element *cur,const char *parsed) {
    if(cur->failure>0) {
        struct parser_element *cf=&(p->stk[cur->failure-1]);

        if(!cf->src) {
            cf->src=cur->src;
        }
    }

    if(parsed) {
        p->stkSize=cur->success;

        if(p->stkSize>0) {
            p->stk[p->stkSize-1].src=parsed;
        }
    } else {
        p->stkSize=cur->failure;
    }
}

void parse_char(struct parser *p,const struct parser_element *cur) {
    printf("%i char '%s', '%s'\n",(p->stkSize)+1,cur->funcData,cur->src);


    //

    const char *funcData=cur->funcData;
    while(funcData[0]!='\0') {
        if(funcData[0]==cur->src[0]) {

            printf("\tsucceeded %i c '%c'\n",p->stkSize,cur->src[0]);
            //
            onLeaf(p,cur,cur->src+1);

            if(p->stkSize>0) {
                printf("\t=>'%s'\n", p->stk[p->stkSize-1].name);
            }

            return;
        }

        funcData++;
    }

    onLeaf(p,cur,NULL);
    printf("\tfailed\n");


}

void parse_a(struct parser *p,const struct parser_element *cur) {

    // printf("%i a\n",(p->stkSize)+1);

    size_t d,e;

    e=push("e",p,NULL, parse_char,"e", cur->success,0);
    d=push("d",p,NULL, parse_char,"d", e,0);
    push("c",p,cur->src, parse_char,"c", d,cur->failure);
}


void parse_a_b_y(struct parser *p,const struct parser_element *cur) {

    // printf("%i a_b_y\n",(p->stkSize)+1);

    size_t b,y;

    y=push("y",p,NULL,parse_char,"y",  cur->success,cur->failure);
    b=push("b",p,NULL,parse_char,"b",  y,      cur->failure);
    push("a",p,cur->src,parse_a,   NULL, y,      b      );
}


void parse_a_b_y_many0(struct parser *p,const struct parser_element *cur) {

    // printf("%i a_b_y_many0\n",(p->stkSize)+1);
    size_t a_b_y_many0;

    a_b_y_many0=push("a_b_y_many0",p,NULL, parse_a_b_y_many0,NULL, cur->success,cur->failure);
    push("a_b_y",p,cur->src, parse_a_b_y,NULL, a_b_y_many0,cur->failure);
}

void parse_main(struct parser *p,const struct parser_element *cur) {

    size_t z,a_b_y_many0,a_b_y;
    z=push("z",p,NULL, parse_char,"z", cur->success,0);
    a_b_y_many0 =push("a_b_y_many0",p,NULL, parse_a_b_y_many0,NULL, z,z);
    a_b_y=push("a_b_y",p,NULL, parse_a_b_y,NULL, a_b_y_many0,0);
    push("x",p,cur->src, parse_char,"x", a_b_y,cur->failure);
}

void run2(struct parser *p) {
    while(p->stkSize>0) {
        struct parser_element cur=p->stk[--(p->stkSize)];
        // printf("'%s' : %i '%s'\n",cur->name,p->stkSize,cur->src);

        printf("stack: ");
        struct parser_element *a;
        for(a=p->stk;a!=p->stk+p->stkSize;a++) {
            printf("%s ",a->name);
        }

        printf("%s\n",cur.name);
        // printf("%s\n",cur->src?cur->src:"none");

        cur.func(p,&cur);
    }
}

int main() {
    const char *src="xcdeybyz";

    struct parser p;
    p.stkMaxSize=96;
    p.stkSize=0;
    p.stk=(struct parser_element*)malloc(sizeof(struct parser_element)*p.stkMaxSize);

    // parse_main(&stk,&stkMaxSize,&stkSize,src,NULL,0,0);

    push("main",&p,src,parse_main,NULL,0,0);

    run2(&p);


    printf("_%i\n",p.stkSize);
    return 0;
}




// const char *parse_nchar(struct parser *p,
//                         size_t *pstkMaxSize,size_t p->stkSize,
//                         const char *src,const char *funcData,
//                         size_t success,size_t failure) {

//     while(funcData[0]!='\0') {
//         if(funcData[0]==src[0]) {
//             printf("%i nchar '%c'\n",p->stkSize,src[0]);
//             return NULL;
//         }

//         funcData++;
//     }

//     return src+1;
// }

// const char *parse_range(struct parser *p,
//                         size_t *pstkMaxSize,size_t p->stkSize,
//                         const char *src,const char *funcData,
//                         size_t success,size_t failure) {

//     while(funcData[0]!='\0') {
//         if(src[0] >= funcData[0] && src[0] <= funcData[1]) {
//             printf("%i range '%c'\n",p->stkSize,src[0]);
//             return src+1;
//         }

//         funcData+=2;
//     }

//     return NULL;
// }

// const char *parse_word(struct parser *p,
//                        size_t *pstkMaxSize,size_t p->stkSize,
//                        const char *src,const char *funcData,
//                        size_t success,size_t failure) {

//     const char *start=src;

//     while(funcData[0]!='\0' && src[0]==funcData[0]) {
//         src++;
//         funcData++;
//     }

//     if(funcData[0]=='\0') {
//         printf("%i word '%.*s'\n",p->stkSize,(int)(src-start),start);
//         return src;
//     }

//     return NULL;
// }
