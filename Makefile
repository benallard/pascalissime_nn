all: recneur3 retropr2 robotl1 kohonen3 carre3 unun voyage4 art14 bam chiffres bolzdem3 neo31 neo4 neo51 contrep

recneur3: uimpri.o
retropr2: uimpri.o
robotl1: uimpri.o uaffiche.o ustoppe.o
kohonen3: uimpri.o uaffiche.o ustoppe.o
carre3: uimpri.o uaffiche.o ustoppe.o
unun: uimpri.o uaffiche.o ustoppe.o
voyage4: uimpri.o uaffiche.o ustoppe.o
bam: usortie.o
chiffres: usortie.o


%.o: %.pas
	fpc -Mtp -g $<

%: %.pas
	fpc -Mtp -g $@

phony: clean all

clean:
	$(RM) *.o retropr2 recneur3 robotl1 kohonen3 carre3 unun voyage4 art14 bam chiffres bolzdem3 neo31 neo4 neo51 contrep
