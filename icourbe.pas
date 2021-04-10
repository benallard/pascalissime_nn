(* 001 icourbe *)
(* 14 jul 91 *)

procedure go_courbe(p_intermediaire, p_sortie, p_erreur:integer; p_imprime: string);
var l_sortie: integer;
	l_numero_apprentissage, l_passe, l_apprentissage: integer;
	l_ensemble_apprentissage: set of 1..k_apprentissage_max;
	l_intermediaire_precedent: array[1..k_intermediaire_max] of t_intermediaire;
	l_biais_precedent: t_biais;
	l_sortie_precedente: array[1..k_sortie_max] of t_sortie;
	l_erreur_precedente:real;

  procedure affiche_un_poids(p_x, p_y: integer; p_valeur: real; var pv_precedent: real);

    procedure affiche_axe(p_x, p_y: integer);
    begin
      moveto(p_x, p_y);
      lineto(p_x + 200, p_y);
      moveto(p_x, p_y - 20);
      lineto(p_x, p_y + 20);
    end;

  begin
    if p_x = 0
      then affiche_axe(p_x, p_y);

    moveto(p_x + (l_passe div k_frequence_affichage) * 2,
    	p_y - round(pv_precedent * 20));
    lineto(p_x + (l_passe div k_frequence_affichage + 1) * 2,
   	p_y - round(p_valeur * 20));
    pv_precedent := p_valeur;
  end; (* affiche un poids *)

  procedure affiche_intermediaire;
  var l_entree: integer;
  begin
    if p_intermediaire <> 0
      then
	with g_intermediaire[p_intermediaire] do
	begin
	  affiche_un_poids(0, 40, g_biais[p_intermediaire],
		  l_biais_precedent[p_intermediaire]);
	  for l_entree := 1 to k_entree_max do
	    begin
	      affiche_un_poids(0, 40 + 40 * l_entree,
		      poids[l_entree],
		      l_intermediaire_precedent[p_intermediaire].poids[l_entree]);
	    end;
	end;
  end; (* affiche_intermediaire *)

  procedure affiche_sortie;
  var l_intermediaire: integer;
  begin
    if p_sortie <> 0
      then
	with g_sortie[p_sortie] do
	begin
	  affiche_un_poids(0, 40, g_biais[k_intermediaire_max + p_sortie],
		  l_biais_precedent[k_intermediaire_max + p_sortie]);

	  for l_intermediaire := 1 to k_intermediaire_max do
	    begin
	      affiche_un_poids(0, 40 + 40 * l_intermediaire,
		      poids[l_intermediaire],
		      l_sortie_precedente[p_sortie].poids[l_intermediaire]);
	    end;
	end;
  end; (* affiche_sortie *)

  procedure affiche_erreur;
  begin
    if p_erreur <> 0
      then affiche_un_poids(0, 40, g_erreur_sortie,
	      l_erreur_precedente);
  end;

begin (* go_courbe *)
  g_cumul_erreur := 0;
  g_nombre_essais := 0;

  initialise_mode_graphique;
  fillchar(l_intermediaire_precedent, sizeof(l_intermediaire_precedent), 0);
  fillchar(l_biais_precedent, sizeof(l_biais_precedent), 0);
  fillchar(l_sortie_precedente, sizeof(l_sortie_precedente), 0);
  l_erreur_precedente := 0;

  l_passe := 0;
  repeat

    if l_passe mod k_frequence_affichage = 0
      then begin
        if p_intermediaire <> 0
          then affiche_intermediaire;
        if p_sortie <> 0
          then affiche_sortie;
        if p_erreur <> 0
          then affiche_erreur;
      end;

    l_ensemble_apprentissage := [];
    for l_numero_apprentissage := 1 to k_apprentissage_max do
    begin
      repeat
        l_apprentissage := 1 + random(k_apprentissage_max);
      until not (l_apprentissage in l_ensemble_apprentissage);
      l_ensemble_apprentissage := l_ensemble_apprentissage + [l_apprentissage];

      propage_vers_l_avant(l_apprentissage);
      calcule_erreur_finale(l_apprentissage);

      propage_erreur_vers_l_arriere(l_apprentissage);
      ajuste_poids_sortie(l_apprentissage);
      ajuste_poids_intermediaire(l_apprentissage);

      calcule_erreur_apres_back_prop(l_apprentissage)
    end;
    l_passe := l_passe + 1;
  until (l_passe > k_iteration_max)
        or (abs(g_cumul_erreur / g_nombre_essais) < k_niveau_erreur_max);

  (* -- envoie dans un fichier qui sera imprime *)
  if p_imprime <> ''
    then imprime_avec_tampon(p_imprime);
  sonne; readln;
  closegraph;

  write(l_passe, ' ', g_cumul_erreur / g_nombre_essais : 10: 3);
end;

(* fin icourbe *)