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
    writeln('ENTREE INTERMEDIAIRE SORTIE (Iteration: ', p_iteration:3,
	    'text:', p_numero_apprentissage: 3, ')');
    case p_mouvement of
      depart: write('INIT');
      avant: write('AVANT');
      arriere: write('ARRIE');
      ajuste: write('AJUST');
      resultat: write('RESU');
    end;
    writeln('bj wej tj f(tj) Bk, Wjk, Tk F(Tk) Sk S-f(Tk) 1/2err');
    writeln('        f''(tj) f''err    Ek');

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


begin
end.
