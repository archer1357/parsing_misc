OUTDIR = bin
OUTFILE = $(OUTDIR)/test

CC = gcc
EXT = c

CPPFLAGS :=
CFLAGS :=
LDFLAGS :=

#DEBUG_BUILD = -g
#DEBUG_TEST = gdb --eval-command=run

objs := $(patsubst %.$(EXT),$(OUTDIR)/%.o,$(wildcard *.$(EXT)))
#objs += $(patsubst %.rl,$(OUTDIR)/%.o,$(wildcard *.rl))
incls := $(patsubst %.rl,%.incl,$(wildcard *.rl))

deps := $(objs:.o=.dep)

.PHONY: all test
all: $(incls) $(OUTFILE)

-include $(deps)
 
%.incl : %.rl
	ragel -C $< -o $@

$(OUTDIR)/%.o: %.$(EXT)
	@mkdir -p $(@D)
	$(CC) $(DEBUG_BUILD) $(CPPFLAGS) $(CFLAGS) -c $< -o $@
	@$(CC) $(CPPFLAGS) $(CFLAGS) -MM $< | sed -e '1,1 s|[^:]*:|$@:|' > $(OUTDIR)/$*.dep

$(OUTFILE) : $(objs)
	$(CC) $(DEBUG_BUILD) $^ $(LDFLAGS) -o $@

test: $(OUTFILE)
	@$(DEBUG_TEST) $(OUTFILE)

clean:
	@rm -f $(deps) $(objs) $(OUTFILE) $(OUTFILE).exe 
	@rmdir --ignore-fail-on-non-empty $(OUTDIR)
