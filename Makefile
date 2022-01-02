ALL = recneur3\
 retropr2\
 robotl1\
 kohonen3\
 carre3\
 unun\
 voyage4\
 art14\
 bam\
 chiffres\
 bolzdem3\
 neo31\
 neo4\
 neo51\
 contrep\
 simpneu2\
 spattemp\
 spattmp2\
 brain4\
 founeu\
 radial\
 cascade2
all: $(ALL)

recneur3: uimpri.o
retropr2: uimpri.o
robotl1: uimpri.o uaffiche.o ustoppe.o
kohonen3: uimpri.o uaffiche.o ustoppe.o
carre3: uimpri.o uaffiche.o ustoppe.o
unun: uimpri.o uaffiche.o ustoppe.o
voyage4: uimpri.o uaffiche.o ustoppe.o
bam: usortie.o
chiffres: usortie.o
simpneu2: uclavier.o uerreur.o
spattemp: uerreur.o
spattmp2: uerreur.o
brain4: uerreur.o uosortie.o
radial: ugrafbor.o uerreur.o

%.o: %.pas
	fpc -Mtp -g $<

%: %.pas
	fpc -Mtp -g $@

phony: clean all

clean:
	$(RM) *.o $(ALL)
