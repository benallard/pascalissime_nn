all: recneur3 retropr2 robotl1 kohonen3 carre3

recneur3: uimpri.o
retropr2: uimpri.o
robotl1: uimpri.o uaffiche.o ustoppe.o
kohonen3: uimpri.o uaffiche.o ustoppe.o
carre3: uimpri.o uaffiche.o ustoppe.o

%.o: %.pas
	fpc -Mtp $<

%: %.pas
	fpc -Mtp $@

phony: clean all

clean:
	$(RM) *.o retropr2 recneur3 robotl1 kohonen3 carre3
