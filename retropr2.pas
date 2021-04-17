(* 001 retropr2 *)
(* 13 jul 91 *)

(*$r+*)
program reseau_neuronal_avec_retro_propagation;
uses cthreads, crt, ptcgraph, uimpri;
const k_entree_max=6;
	k_intermediaire_max=3;
	k_sortie_max=7;

	k_apprentissage_max=3;
	(* -- en mode texte:
	k_iteration_max=1000;
	k_niveau_erreur_max=0.05
	*)

	(* -- en mode graphique *)
	k_iteration_max = 700;
	k_niveau_erreur_max=0.05;
	k_poids_initiaux_differents=false;
	k_learning_rate = 1.0;

	k_seuil_erreur_prevision=0.30;
	k_frequence_affichage=3;
type t_mouvement=(depart, avant, arriere, ajuste, resultat);

	t_transfert=function(p_reel: real): real;


	t_entree=array[1..k_entree_max] of real;
	t_biais=array[1..(k_intermediaire_max + k_sortie_max)] of real;
	t_intermediaire = record
		poids: array[1..k_entree_max] of real;
		somme, sortie, erreur_locale_ponderee: real;

		transfert: t_transfert;

	end;
	t_sortie = record
		poids: array[1..k_intermediaire_max] of real;
		somme, sortie, erreur_locale_brute, erreur_locale_ponderee: real;

		transfert: t_transfert;



		demi_erreur_carree: real;
	end;

	t_apprentissage = record
		entree: t_entree;
		sortie_desiree: array[1..k_sortie_max] of real;
	end;
var g_choix: char;
	(* -- ununsed
	g_entree: t_entree;
	*)
	g_biais: t_biais;
	g_intermediaire: array[1..k_intermediaire_max] of t_intermediaire;
	g_sortie: array[1..k_sortie_max] of t_sortie;

	g_apprentissage: array[1..k_apprentissage_max] of t_apprentissage;

	g_erreur_sortie: real;
	g_cumul_erreur: real;

	g_nombre_essais: integer;
	g_ensemble_essai: set of 1..k_apprentissage_max;

	g_capture_ecran: boolean;
	g_texte_ecran: text;

	g_debug: (detail, une_iteration, cent_iterations);
	g_graphique: boolean;
	g_test: boolean;

(* -- mise au point *)

procedure stoppe;
var l_stop: char;
begin
  l_stop := readkey;
end;

procedure sonne;
begin
  write(chr(7));
end;

(* -- transfert functions *)

function f_sigmoid(p_valeur: real): real;
begin
  if (abs(p_valeur) < 1e-10)
    then begin
      f_sigmoid:= 0.5;
      sonne;
    end
    else f_sigmoid := 1/ (1.0 + exp(-p_valeur));
end;

function f_derivee_sigmoid(p_valeur: real): real;
begin
  f_derivee_sigmoid := f_sigmoid(p_valeur) * (1-f_sigmoid(p_valeur));
end;

procedure affiche_sigmoid;
(* -- mise au point *)
var l_valeur: integer;
	g_text_ecran: text;
begin
  assign(g_text_ecran, 'a:sig.pas');
  rewrite(g_text_ecran);
  for l_valeur := -20 to 20 do
    begin
      writeln(g_text_ecran, l_valeur / 10:5:2, f_sigmoid(l_valeur / 10):5:2,
      	f_derivee_sigmoid(l_valeur / 10):5:2);
    end;
  close(g_text_ecran);
end;

(* -- affichage en mode texte *)

procedure capture_ecran(p_nom: string);
const k_segment_ecran= $B800;
var l_ligne, l_colonne: integer;
	g_ecran: array[1..25, 1..80] of record
		caractere: char; attribut: byte;
	end absolute k_segment_ecran;
begin
  if g_capture_ecran
    then begin
      for l_ligne:= 1 to 25 do
	begin
          for l_colonne := 1 to 80 do
            write(g_texte_ecran, g_ecran[l_ligne, l_colonne].caractere);
          writeln(g_texte_ecran);
	end;
      writeln(g_texte_ecran);
    end;
end;

procedure affiche(p_iteration, p_numero_apprentissage: integer; p_mouvement: t_mouvement);
var l_entree, l_intermediaire, l_sortie: integer;
	l_erreur_apres_back_prop: real;
begin
  with g_apprentissage[p_numero_apprentissage] do
  begin
    if p_mouvement = avant
      then clrscr
      else gotoxy(1, 1);
    writeln('ENTREE     INTERMEDIAIRE               SORTIE (Iteration: ', p_iteration:3,
	    ' test:', p_numero_apprentissage: 3, ')');
    case p_mouvement of
      depart: write('INIT  ');
      avant: write('AVANT ');
      arriere: write('ARRIE ');
      ajuste: write('AJUST ');
      resultat: write('RESU  ');
    end;
    writeln(' bj   wij  tj   f(tj)     Bk    Wjk   Tk   F(Tk) Sk  S-f(Tk) 1/2err');
    writeln('                 f''(tj) f''*err              Ek');

    for l_entree:= 1 to k_entree_max do
    begin
      gotoxy(1, 6+(l_entree - 1) * 3); write(entree[l_entree]:5:2);
    end;

    for l_intermediaire := 1 to k_intermediaire_max do
      with g_intermediaire[l_intermediaire] do
      begin
        gotoxy(7, 4 + (l_intermediaire - 1) * (k_entree_max + 1));
	write(g_biais[l_intermediaire]:5 : 2);
	for l_entree := 1 to k_entree_max do
	begin
	  gotoxy(12, 4+(l_intermediaire - 1) * (k_entree_max + 1) + (l_entree - 1));
	  write(poids[l_entree]:5:2);
	end;
	case p_mouvement of
	  avant:
            begin
	      gotoxy(17, 4 + (l_intermediaire - 1) * (k_entree_max + 1));
	      write(somme:5:2, sortie:5:2);
	    end;
	  arriere, ajuste:
	    begin
	      gotoxy(17, 5 + (l_intermediaire - 1) * (k_entree_max + 1));
	      write(f_derivee_sigmoid(somme):6:3, erreur_locale_ponderee :6: 3);
	    end;
	  resultat:
	    begin
	      gotoxy(17, 6 + (l_intermediaire - 1) * (k_entree_max + 1));
	      write(somme:5:2, sortie:5:2);
	    end;
	end; (* case *)
      end; (* for intermediaire *)

    l_erreur_apres_back_prop := 0.0;
    for l_sortie := 1 to k_sortie_max do
      with g_sortie[l_sortie] do
      begin
	gotoxy(32, 3 + (l_sortie - 1) * k_intermediaire_max + 1);
	write(g_biais[k_intermediaire_max + l_sortie]: 5 : 2);

	for l_intermediaire := 1 to k_intermediaire_max do
	begin
	  gotoxy(38, 3+(l_sortie - 1) * k_intermediaire_max + 1 + l_intermediaire - 1);
	  write(poids[l_intermediaire]:5:2);
	end;

	case p_mouvement of
	  avant:
	    begin
	      gotoxy(44, 3 + (l_sortie - 1) * k_intermediaire_max + 1);
	      write(somme:5:2, sortie:5:2, sortie_desiree[l_sortie]:5:2,
		      erreur_locale_brute:6:3,
		      demi_erreur_carree:6:3);
	    end;
	  arriere, ajuste:
	    begin
	      gotoxy(44, 4 + (l_sortie - 1) * k_intermediaire_max + 1);
	      write(erreur_locale_ponderee : 6 : 3);
	    end;
	  resultat:
	    begin
	      gotoxy(44, 5 + (l_sortie - 1) * k_intermediaire_max + 1);
	      write(somme:5:2, sortie:5:2, sortie_desiree[l_sortie]:5:2,
		      erreur_locale_brute:6:3,
		      demi_erreur_carree:6:3);
	      l_erreur_apres_back_prop := l_erreur_apres_back_prop + demi_erreur_carree;
	    end;
	end; (* case *)
      end; (* for sortie *)

      case p_mouvement of
        avant:
          begin
            gotoxy(1, 25); clreol;
	    write('Err essai:', g_erreur_sortie:10:4);
	  end;
	arriere, ajuste:
	  begin
	    gotoxy(55, 25); clreol;
	    write('Err Cum Moy:', g_cumul_erreur / g_nombre_essais :10:4);
	  end;
	resultat:
	  begin
	    gotoxy(25, 25);
	    write('Err apres back:', l_erreur_apres_back_prop:10:4);
	  end;
      end;

      gotoxy(1, 24);
  end; (* with apprentissage *)
end; (* affiche *)

(* -- l'apprentissage *)

procedure propage_vers_l_avant(p_numero_apprentissage: integer);
var l_entree, l_intermediaire, l_sortie: integer;
begin
  with g_apprentissage[p_numero_apprentissage] do
  begin
    (* -- propage_vers_l_avant la sortie *)
    for l_intermediaire := 1 to k_intermediaire_max do
      with g_intermediaire[l_intermediaire] do
      begin
	somme := g_biais[l_intermediaire];
	for l_entree := 1 to k_entree_max do
	  somme := somme + poids[l_entree] * entree[l_entree];
        sortie := transfert(somme);
      end; (* for intermediaire *)

    for l_sortie := 1 to k_sortie_max do
      with g_sortie[l_sortie] do
      begin
	somme := g_biais[k_intermediaire_max + l_sortie];
	for l_intermediaire := 1 to k_intermediaire_max do
	  somme := somme + poids[l_intermediaire] * g_intermediaire[l_intermediaire].sortie;
        sortie := transfert(somme);
      end; (* for sortie *)
  end;
end;

procedure calcule_erreur_finale(p_numero_apprentissage: integer);
var l_sortie: integer;
begin
  with g_apprentissage[p_numero_apprentissage] do
  begin
    g_erreur_sortie := 0.0;

    for l_sortie := 1 to k_sortie_max do
      with g_sortie[l_sortie] do
      begin
	erreur_locale_brute := sortie_desiree[l_sortie] - sortie;
	erreur_locale_ponderee := erreur_locale_brute * f_derivee_sigmoid(somme);

	(* -- mise au point *)
	demi_erreur_carree := 0.5 * sqr(erreur_locale_brute);
        g_erreur_sortie := g_erreur_sortie + demi_erreur_carree;
      end;
    g_cumul_erreur := g_cumul_erreur + g_erreur_sortie;
    g_nombre_essais := g_nombre_essais + 1;
  end;
end;

procedure propage_erreur_vers_l_arriere(p_numero_apprentissage: integer);
(* -- back prop *)
var l_intermediaire, l_sortie: integer;
begin
  (* -- erreur au niveau precedent *)
  for l_intermediaire := 1 to k_intermediaire_max do
    with g_intermediaire[l_intermediaire] do
    begin
      erreur_locale_ponderee := 0;
      for l_sortie := 1 to k_sortie_max do
        erreur_locale_ponderee := erreur_locale_ponderee +
		g_sortie[l_sortie].erreur_locale_ponderee * g_sortie[l_sortie].poids[l_intermediaire];
      erreur_locale_ponderee := f_derivee_sigmoid(somme) * erreur_locale_ponderee;
    end;
end;

procedure ajuste_poids_sortie(p_numero_apprentissage: integer);
(* -- ajuste les poids intermediaires / sortie *)
var l_intermediaire, l_sortie: integer;
begin
  for l_sortie := 1 to k_sortie_max do
    with g_sortie[l_sortie] do
    begin
      g_biais[k_intermediaire_max + l_sortie] := g_biais[k_intermediaire_max + l_sortie]
      	+ erreur_locale_ponderee * k_learning_rate;

      for l_intermediaire := 1 to k_intermediaire_max do
	poids[l_intermediaire] := poids[l_intermediaire]
		+ erreur_locale_ponderee * g_intermediaire[l_intermediaire].sortie;
    end;
end;

procedure ajuste_poids_intermediaire(p_numero_apprentissage: integer);
(* -- ajuste les poids d'entree / intermediaire *)
var l_entree, l_intermediaire: integer;
begin
  with g_apprentissage[p_numero_apprentissage] do
    for l_intermediaire := 1 to k_intermediaire_max do
      with g_intermediaire[l_intermediaire] do
      begin
        g_biais[l_intermediaire] := g_biais[l_intermediaire]
		+ erreur_locale_ponderee * k_learning_rate;
        for l_entree := 1 to k_entree_max do
          poids[l_entree] := poids[l_entree] + erreur_locale_ponderee * entree[l_entree];
      end;
end;

procedure calcule_erreur_apres_back_prop(p_numero_apprentissage: integer);
(* -- mise au point: verifie que back prop reduit l'erreur globale *)
var l_entree, l_intermediaire, l_sortie: integer;
begin
  with g_apprentissage[p_numero_apprentissage] do
  begin
    (* -- propage_vers_l_avant la sortie *)
    (* -- peut reutiliser somme et sortie, cars eront recalcule pour le prochain essai *)
    for l_intermediaire := 1 to k_intermediaire_max do
      with g_intermediaire[l_intermediaire] do
      begin
	somme := g_biais[l_intermediaire];
	for l_entree := 1 to k_entree_max do
          begin
	    somme := somme + poids[l_entree] * entree[l_entree];
          end;
	sortie := transfert(somme);
      end;

    for l_sortie := 1 to k_sortie_max do
      with g_sortie[l_sortie] do
      begin
        somme := g_biais[k_intermediaire_max + l_sortie];
	for l_intermediaire := 1 to k_intermediaire_max do
	  somme := somme + poids[l_intermediaire] * g_intermediaire[l_intermediaire].sortie;
        sortie := transfert(somme);
      end;

    (* -- difference entre desir et prevision *)
    for l_sortie := 1 to k_sortie_max do
      with g_sortie[l_sortie] do
      begin
	erreur_locale_brute := sortie_desiree[l_sortie] - sortie;
	demi_erreur_carree := 0.5 * sqr(erreur_locale_brute);
      end;
  end;
end;

procedure go_texte;
var l_sortie: integer;
	l_numero_apprentissage, l_passe, l_apprentissage: integer;
	l_ensemble_apprentissage: set of 1..k_apprentissage_max;
begin
  assign(g_texte_ecran, 'a:converge.pas'); rewrite(g_texte_ecran);

  g_cumul_erreur := 0;
  g_nombre_essais := 0;

  g_capture_ecran := true;
  affiche(1, 1, depart);
  g_capture_ecran := false;

  l_passe := 1;
  repeat
    if l_passe mod k_frequence_affichage = 0
      then write('.');

    l_ensemble_apprentissage := [];
    for l_numero_apprentissage := 1 to k_apprentissage_max do
      begin
	repeat
	  l_apprentissage := 1 + random(k_apprentissage_max);
	until not (l_apprentissage in l_ensemble_apprentissage);
	l_ensemble_apprentissage := l_ensemble_apprentissage + [l_apprentissage];

	propage_vers_l_avant(l_apprentissage);
	calcule_erreur_finale(l_apprentissage);

	if g_test and (l_apprentissage = 2)
	  then begin
	    g_capture_ecran := true;
	    affiche(l_passe, l_apprentissage, avant);
	    g_capture_ecran := false;
	  end
	else
	  if g_debug = detail
            then affiche(l_passe, l_apprentissage, avant);
	

	propage_erreur_vers_l_arriere(l_apprentissage);
	
	if g_test and (l_apprentissage = 2)
	  then begin
	    g_capture_ecran := true;
	    affiche(l_passe, l_apprentissage, arriere);
	    g_capture_ecran := false;
	  end
	else
	  if g_debug = detail
            then affiche(l_passe, l_apprentissage, arriere);

	ajuste_poids_sortie(l_apprentissage);
	ajuste_poids_intermediaire(l_apprentissage);
	
	if g_test and (l_apprentissage = 2)
	  then begin
	    g_capture_ecran := true;
	    affiche(l_passe, l_apprentissage, ajuste);
	    g_capture_ecran := false;
	  end
	else
	  if g_debug = detail
            then affiche(l_passe, l_apprentissage, ajuste);

	calcule_erreur_apres_back_prop(l_apprentissage);
	
	if g_test and (l_apprentissage = 2)
	  then begin
	    g_capture_ecran := true;
	    affiche(l_passe, l_apprentissage, resultat);
	    g_capture_ecran := false;
	  end
	else
	  if g_debug = detail
            then begin
	      affiche(l_passe, l_apprentissage, resultat);
	    end;
      end;
      l_passe := l_passe + 1;
  until (l_passe > k_iteration_max)
  	or (abs(g_cumul_erreur / g_nombre_essais) < k_niveau_erreur_max);

  g_capture_ecran := true;
  affiche(l_passe, l_apprentissage, resultat);
  g_capture_ecran := false;

  close(g_texte_ecran);
  write(g_nombre_essais, g_cumul_erreur / g_nombre_essais:10:3, '<RET>'); readln;
end; (* go texte *)


(* -- utilisation du reseau pour la prevision *)

procedure prevois_resultat;
var l_apprentissage: 1..k_apprentissage_max;
	l_sortie : 1..k_sortie_max;
begin
  assign(g_texte_ecran, 'a:prevision.pas'); rewrite(g_texte_ecran);

  for l_apprentissage := 1 to k_apprentissage_max do
  begin
    propage_vers_l_avant(l_apprentissage);
    calcule_erreur_finale(l_apprentissage);

    g_capture_ecran := true;
    affiche(1, l_apprentissage, avant);
    g_capture_ecran := false;

    gotoxy(1, 24); clreol;
    for l_sortie := 1 to k_sortie_max do
      begin
	write(l_sortie);
	with g_sortie[l_sortie] do
	if abs(erreur_locale_brute) < k_seuil_erreur_prevision
          then write('OK, ')
          else write('NOK, ');
      end;
      stoppe;
  end;

  close(g_texte_ecran);
end;

(*$i icourbe *)
(*$i idessin *)
procedure initialise;
var l_numero_apprentissage: integer;
	l_entree, l_biais, l_intermediaire, l_sortie: integer;

  procedure entre_apprentissage(p_entree_1, p_entree_2, p_entree_3, p_entree_4, p_entree_5, p_entree_6,
	  p_sortie_1, p_sortie_2, p_sortie_3, p_sortie_4, p_sortie_5, p_sortie_6, p_sortie_7: real);
  begin
    g_apprentissage[l_numero_apprentissage].entree[1] := p_entree_1;
    g_apprentissage[l_numero_apprentissage].entree[2] := p_entree_2;
    g_apprentissage[l_numero_apprentissage].entree[3] := p_entree_3;
    g_apprentissage[l_numero_apprentissage].entree[4] := p_entree_4;
    g_apprentissage[l_numero_apprentissage].entree[5] := p_entree_5;
    g_apprentissage[l_numero_apprentissage].entree[6] := p_entree_6;

    g_apprentissage[l_numero_apprentissage].sortie_desiree[1] := p_sortie_1;
    g_apprentissage[l_numero_apprentissage].sortie_desiree[2] := p_sortie_2;
    g_apprentissage[l_numero_apprentissage].sortie_desiree[3] := p_sortie_3;
    g_apprentissage[l_numero_apprentissage].sortie_desiree[4] := p_sortie_4;
    g_apprentissage[l_numero_apprentissage].sortie_desiree[5] := p_sortie_5;
    g_apprentissage[l_numero_apprentissage].sortie_desiree[6] := p_sortie_6;
    g_apprentissage[l_numero_apprentissage].sortie_desiree[7] := p_sortie_7;

    l_numero_apprentissage := l_numero_apprentissage + 1;
  end;

begin
  l_numero_apprentissage := 1;

  entre_apprentissage(1.0, 1.0, 1.0, 0.0, 0.0, 0.0,  0.9, 0.9, 0.9, 0.1, 0.1, 0.1, 0.1);
  entre_apprentissage(0.0, 1.0, 0.0, 1.0, 1.0, 0.0,  0.1, 0.1, 0.1, 0.9, 0.9, 0.9, 0.1);
  entre_apprentissage(1.0, 0.0, 0.0, 1.0, 0.0, 1.0,  0.1, 0.1, 0.1, 0.9, 0.1, 0.9, 0.9);

  (* -- alternative, partitionnee
  entre_apprentissage(1.0, 1.0, 0.0, 0.0, 0.0, 0.0,  0.9, 0.9, 0.1, 0.1, 0.1, 0.1, 0.1);
  entre_apprentissage(0.0, 0.0, 1.0, 1.0, 0.0, 0.0,  0.1, 0.1, 0.9, 0.9, 0.1, 0.1, 0.1);
  entre_apprentissage(1.0, 0.0, 0.0, 0.0, 1.0, 1.0,  0.1, 0.1, 0.1, 0.1, 0.9, 0.9, 0.1);
  *)

  fillchar(g_biais, sizeof(g_biais), 0);
  fillchar(g_intermediaire, sizeof(g_intermediaire), 0);
  fillchar(g_sortie, sizeof(g_sortie), 0);

  if k_poids_initiaux_differents
    then randomize;

  for l_biais:= 1 to k_intermediaire_max + k_sortie_max do
    g_biais[l_biais] := random;

  for l_intermediaire := 1 to k_intermediaire_max do
    with g_intermediaire[l_intermediaire] do
    begin
      for l_entree := 1 to k_entree_max do
	poids[l_entree] := random;
      transfert := f_sigmoid;
    end;

  for l_sortie := 1 to k_sortie_max do
    with g_sortie[l_sortie] do
    begin
      for l_intermediaire := 1 to k_intermediaire_max do
	poids[l_intermediaire] := random;
      transfert := f_sigmoid;
    end;

  g_ensemble_essai := [1,2,3];
  g_debug := detail;
  g_graphique := false;
  g_capture_ecran := true;
  g_test := false;
end;

begin
  clrscr;
  initialise;
  repeat
    writeln;
    write('Go texte, Prevois, Courbes, Dessin, Initialise, Quitte ?');
    g_choix := readkey; write(g_choix);writeln;
    case g_choix of
      ' ': clrscr;
      'g': go_texte;
      'd': go_texte;
      'c': go_courbe(0, 1, 0, 'a:sortie1.pas');
      'a': affiche_sigmoid;
      'p': prevois_resultat;
      'i': initialise;
      't': if g_debug = detail
      		then g_debug := cent_iterations
      		else g_debug := detail;
    end;
  until g_choix = 'q';
end.
