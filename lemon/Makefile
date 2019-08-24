PARSE_NAME=exprParse
LEX_NAME=exprLex

FILES = $(PARSE_NAME).c $(PARSE_NAME).h $(LEX_NAME).c expr.c

.PHONY: all 
all: expr.c

$(PARSE_NAME).c : $(PARSE_NAME).y
	lemon -q $<
	
$(LEX_NAME).c : $(LEX_NAME).rl
	ragel -C $<
	
expr.c : $(PARSE_NAME).c $(LEX_NAME).c
	echo -e "\n\n\n//entering exprCalc.h" > $@
	cat exprCalc.h >> $@
	
	echo -e "\n\n\n//entering $(PARSE_NAME).h" >> $@
	cat $(PARSE_NAME).h >> $@
	
	echo -e "\n\n\n//entering exprCalc.c" >> $@
	cat exprCalc.c >> $@
	
	echo -e "\n\n\n//entering $(PARSE_NAME).c" >> $@
	cat $(PARSE_NAME).c >> $@
	
	echo -e "\n\n\n//entering $(LEX_NAME).h" >> $@
	cat $(LEX_NAME).c >> $@
	
	echo -e "\n\n\n//entering exprRun.c" >> $@
	cat exprRun.c >> $@
	
	cp -f $@ ../$@

clean:
	@rm -f $(FILES)
