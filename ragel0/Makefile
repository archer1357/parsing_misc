PARSE_NAME=mtclEvalParse
OUTDIR=tmp

.PHONY: all
all: $(OUTDIR)/$(PARSE_NAME).c
 
$(OUTDIR)/$(PARSE_NAME).c : parse.rl
	mkdir -p $(OUTDIR)
	ragel -C $< -o $@
	gcc -g $@ -DMTCL_PARSE_TEST -o $(OUTDIR)/test
