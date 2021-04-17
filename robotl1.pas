(* 002 robotl1 *)
(* 19 jul 91 *)

(* -- robot trouve le chemin dans un L *)

(*$r+*)
program reseau_neuronal_kohonen;
uses cthreads, Crt, ptcGraph,
        uimpri, uaffiche, ustoppe;
const (* -- le nombre de points de la couche de kohonen *)
        k_indice_max = 50;

        (* -- L une dim: essayer 50 points, regroupement 1.00, apprentissage 0.02, loinains 1.0 *)
        (*      l_voisin := 4 - (l_iteration div 2000); : L tordu *)
        (*      l_voisin := 3 - (l_iteration div 3400); : S tordu *)
        (*      l_voisin := 6 - (l_iteration div 2200); : C simple *)

        (* -- O: avec l_voisin 6: se bloque dans un & *)
        (*       avec l_voisin 10: donne un C mais ne peut le fermer *)

        (* le regroupement du nuage initial par rapport a [0..1[ *)
        k_regroupement_initial = 1.00;

        (* -- l'epaisseur du L *)
        k_epaisseur_l = 0.2;

        k_iteration_max = 10000;

        (* -- un gros coefficient accelere l'ajustement *)
        k_accelere_apprentissage = 0.02;
        k_attenue_apprentissage = k_accelere_apprentissage / k_iteration_max;

        (* -- un gros coefficient ralentit la modification des points lointains *)
        (* -- provoque l'efondrement ou l'etirement correct de la chaine *)
        k_ralentis_lointains = 2.0;
        k_attenue_lointains = k_ralentis_lointains / k_iteration_max;

        (* -- affiche ou non le reseau *)
        k_frequence_affichage: Integer = 1000;
        k_affiche_coefficients = 1000;
        k_premier_affichage = 1;

        (* -- au dela, overflow *)
        k_exponentielle_max = 85;

type t_kohonen = record
                   poids_x, poids_y: Real;
                   distance_entree: Real;
                   (* -- statistique *)
                   frequence: Integer;
                 end;
var g_choix: Char;

        g_kohonen: array[1..k_indice_max] of t_kohonen;

        g_nom_fichier_impression: string;
        g_test: Boolean;

procedure go_dessin;
var l_iteration: Integer;

  procedure ajuste_reseau;
  var l_x, l_y: Real;
      l_indice: Integer;

      (* -- le gagnant *)
      l_indice_min: Integer;
      l_distance_entree_min: Real;

      (* -- les calculs d'ajustement *)
      l_distance_poids, l_attenuation: Real;
      l_coefficient_attenuation: Real;
      l_voisin: Integer;

  procedure dessine_reseau;
  var l_indice: Integer;
  begin
    Rectangle(k_x_debut, k_y_debut, k_x_debut + k_echelle, k_y_debut + k_echelle);

    SetFillStyle(SolidFill, Black);
    Bar(k_x_debut + 1, k_y_debut + 1, k_x_debut + k_echelle - 1, k_y_debut + k_echelle - 1);

    Rectangle(k_x_debut + Round(k_echelle * k_epaisseur_l),
              k_y_debut,
              k_x_debut + k_echelle,
              k_y_debut + Round(k_echelle * (1 - k_epaisseur_l)));

    (* -- l'entree actuelle *)
    dessine_croix(Round(k_echelle * l_x), Round(k_echelle * l_y), Red);
    (* -- le point le plus proche *)
    with g_kohonen[l_indice_min] do
      dessine_croix(Round(k_echelle * poids_x), Round(k_echelle * poids_y), lightBlue);

    SetColor(White);
    for l_indice := 1 to k_indice_max - 1 do
      with g_kohonen[l_indice] do
        Line(k_x_debut + Round(k_echelle * poids_x), k_y_debut + Round(k_echelle * poids_y),
             Round(k_x_debut + k_echelle * g_kohonen[l_indice + 1].poids_x),
             Round(k_y_debut + k_echelle * g_kohonen[l_indice + 1].poids_y));
  end; (* dessine_reseau *)

  procedure affiche_coefficients;
  var l_indice: Integer;
      l_imprime: Char;
  begin
    affiche(310, 10, 'nombre voisins: ', l_voisin, 10, 0);
    affiche(320, 10, 'lointains:      ',
        1 / (k_ralentis_lointains - k_attenue_lointains * (l_iteration - 1)), 10, 6);
    affiche(330, 10, 'apprentissage:  ',
        (k_accelere_apprentissage - k_attenue_apprentissage * l_iteration), 10, 6);

    (* -- affiche la frequence. Pour 50 points, affichera sur deux colonnes *)
    for l_indice := 1 to k_indice_max do
      affiche_entier(10 + 10 * (l_indice - 1) mod 250, 300 + ((l_indice - 1) div 25) * 50,
        g_kohonen[l_indice].frequence, 4);

    (* -- eventuellement place dans un fichier pour impression *)
    affiche_chaine(300, 300, 'tapez touche', 12);
    l_imprime := ReadKey;
    if l_imprime in ['0'..'9', 'A'..'Z']
      then begin
        affiche_chaine(300, 300, 'imprime     ', 12);
        imprime_avec_tampon(g_nom_fichier_impression + l_imprime);
      end;
    affiche_chaine(300, 300, 'calcule...  ', 12);
  end; (* affiche_coefficients *)

  begin (* ajuste_reseau *)
    (* -- un point aleatoire dans le L. l_y > 0.8 car les Y croissent vers le bas *)
    repeat
      l_x := Random; l_y := Random;
    until (l_x <= k_epaisseur_l) or (l_y >= 1 - k_epaisseur_l);

    (* -- calcule le point du reseau le plus proche du point aleatoire *)
    l_distance_entree_min := 30000;
    l_indice_min := -1;

    for l_indice := 1 to k_indice_max do
      with g_kohonen[l_indice] do
      begin
        distance_entree := Sqr(l_x - poids_x) + Sqr(l_y - poids_y);
        if (distance_entree < l_distance_entree_min)
          then begin
            l_indice_min := l_indice;
            l_distance_entree_min := distance_entree;
          end;
      end;

    (* -- statistiques *)
    Inc(g_kohonen[l_indice_min].frequence, 1);

    (* -- quelques autres formules essayees
    l_voisin := 4 - (l_iteration div 2000);
    l_voisin := 3 - (l_iteration div 3400);
    l_voisin := 5 - (l_iteration div 2200);
    l_voisin := 6 - (l_iteration div 2200);
    l_voisin := Abs(10 - l_iteration div 500);
    if l_voisin < 4
      then l_voisin := 4;
    *)

    (* -- la selection des points voisins a ajuster *)
    l_voisin := Abs(20 - (l_iteration div 500));
    if l_voisin < 4
      then l_voisin := 4;

    (* -- ajuste les poids de quelques points voisins *)
    for l_indice := 1 to k_indice_max do
      if Abs(l_indice - l_indice_min) < l_voisin
        then
          with g_kohonen[l_indice] do
          begin
            l_distance_poids := Sqr(poids_x - g_kohonen[l_indice_min].poids_x)
                + Sqr(poids_y - g_kohonen[l_indice_min].poids_y);

            l_coefficient_attenuation := l_distance_poids
                / (k_ralentis_lointains - k_attenue_lointains * (l_iteration - 1));
            if l_coefficient_attenuation > k_exponentielle_max
              then l_attenuation := 0
              else l_attenuation := Exp(-l_coefficient_attenuation);

            (* -- les nouveaux poids *)
            poids_x := poids_x + (k_accelere_apprentissage - k_attenue_apprentissage * l_iteration)
                * l_attenuation * (l_x - poids_x);
            poids_y := poids_y + (k_accelere_apprentissage - k_attenue_apprentissage * l_iteration)
                * l_attenuation * (l_y - poids_y);
          end;

    (* -- affiche les resultats *)
    if (l_iteration - 1) mod 100 = 0
      then affiche(300, 10, 'iteration: ', l_iteration, 10, 0);
    if ((l_iteration - 1) mod k_frequence_affichage = 0)
        and (l_iteration >= k_premier_affichage)
      then dessine_reseau;
    if (l_iteration - 1) mod k_affiche_coefficients = 0
      then affiche_coefficients;
  end; (* ajuste reseaux *)

begin (* go_dessin *)
  initialise_mode_graphique;

  for l_iteration := 1 to k_iteration_max do
    ajuste_reseau;

  sonne; ReadLn;
  CloseGraph;
end; (* go dessin *)

procedure initialise;
var l_indice: Integer;
begin
  FillChar(g_kohonen, SizeOf(g_kohonen), 0);

  (* -- initialise dans le carree *)
  for l_indice := 1 to k_indice_max do
    with g_kohonen[l_indice] do
    begin
      poids_x := 0.5 + k_regroupement_initial * Random - 0.5 * k_regroupement_initial;
      poids_y := 0.5 + k_regroupement_initial * Random - 0.5 * k_regroupement_initial;
    end;

  g_nom_fichier_impression := 'a:dessin';
  g_test := False;
end; (* initialise *)

begin (* main *)
  ClrScr;
  initialise;
  repeat
    WriteLn;
    Write('[G]o, [I]nitialise, I[m]prime, [Q]uitte ?');
    g_choix := ReadKey; Write(g_choix); WriteLn;
    case g_choix of
      ' ': ClrScr;
      'g': go_dessin;
      '0'..'9', 'A'..'Z': imprime_fichier(g_nom_fichier_impression + g_choix);
      'i': initialise;
    end;
  until g_choix = 'q';
end.