FBC=fbc
OUTFILE=accounts
FBCFLAGS=-g -exx -w all
MAIN=main
INC=$(wildcard *.bi)
SRC=$(wildcard *.bas)
OBJ=$(patsubst %.bas,o/%.o,$(SRC))

all: $(OUTFILE)

$(OUTFILE): $(OBJ)
	$(FBC) $(FBCFLAGS) $(OBJ) -x $(OUTFILE)

o/%.o: %.bas $(INC)
	$(FBC) $(FBCFLAGS) -m $(MAIN) -c $< -o $@

install: $(OUTFILE)
	cp $(OUTFILE) /usr/local/bin/$(OUTFILE)

clean:
	rm -f $(OBJ)
