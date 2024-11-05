OUT = bin/test.exe
CC = gcc

CPPFLAGS :=
CFLAGS :=
LDFLAGS :=

objs := $(patsubst %.c,$(dir $(OUT))%.o,$(wildcard *.c))
deps := $(objs:.o=.dep)

.PHONY: all test
all: $(OUT)

-include $(deps)

$(dir $(OUT))%.o: %.c
	@mkdir -p $(@D)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@
	@$(CC) $(CPPFLAGS) -MM $< | sed -e '1,1 s|[^:]*:|$@:|' > $(@D)/$*.dep

$(OUT) : $(objs)
	$(CC) $^ $(LDFLAGS) -o $@

test: $(OUT)
	@$ ./$(OUT) localconfig.vdf

clean:
	@rm -f $(deps) $(objs) $(OUT)
	@rmdir --ignore-fail-on-non-empty $(dir $(OUT))
