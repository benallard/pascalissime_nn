all: recneur3 retropr2

recneur3: uimpri.o
retropr2: uimpri.o

%.o: %.pas
	fpc -Mtp $<

%: %.pas
	fpc -Mtp $@

phony: clean all

clean:
	$(RM) *.o retropr2 recneur3 
