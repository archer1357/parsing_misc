
OUTFILE = expr

LEX = lex
YACC = yacc -d
#LEX = flex 
#YACC = bison -d
CC = gcc

.PHONY: all test
all: $(OUTFILE)

y.tab.c y.tab.h: expr.y
	$(YACC) $<

lex.yy.c: expr.l
	$(LEX) $<
	
y.tab.o: y.tab.c y.tab.h
	$(CC) -c $< -o $@
	
lex.yy.o: lex.yy.c
	$(CC) -c $< -o $@
	
$(OUTFILE) : y.tab.o lex.yy.o
	$(CC) $^ -o $@

test: $(OUTFILE)
	@$(OUTFILE)

clean:
	@rm -f lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o $(OUTFILE) $(OUTFILE).exe
	
	
	


