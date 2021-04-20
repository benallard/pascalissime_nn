(* 002 carre3 *)
(* 19 jul 91 *)

(* -- 2 dimensions continu vers 3x3 discret *)

(*$r+*)
program reseau_neuronal_kohonen;
uses cthreads, Crt, ptcGraph, uimpri, uaffiche, ustoppe;
const (* -- le nombre de points de la couvhe de kohonen *)
        k_ligne_max = 6;
        k_colonne_max = 6;

        (* -- 4x4, voisins 2, init 0.03, appr 0.01, ralentis 0.01, separe bien mais converge plus *)
        (* -- 6x6, voisins: diamant 2, initial 0.03, apprent 0.001, ralentis 0.05, separa a peu pres par x/y *)

        (* -- le regroupement du nuage initial par rapport a [0..1[ *)
        k_regroupement_initial = 0.03;

        (* -- un numbre fixe de voisins *)
        k_voisins = 3;

        k_iteration_max = 30010;

        (* -- un gros coefficient accelere l'ajustement *)
        k_accelere_apprentissage = 0.00005;
        (*
        k_attenue_apprentissage = k_accelere_apprentissage / k_iteration_max;
        *)
        k_attenue_apprentissage = 0;

        (* -- un gros coefficient ralentit la modofocation des points lointains *)
        k_ralentis_lointains = 0.05;
        (*
        k_attenue_lointains = k_ralentis_lointains / k_iteration_max;
        *)
        k_attenue_lointains = 0;

        k_frequence_affichage: Integer = 100;
        k_affiche_coefficients = 100;
        k_premier_affichage = 1;
        k_exponentielle_max = 85;

type t_kohonen = record
                   poids_x, poids_y: Real;
                   distance_entree: Real;
                   frequence: Integer;
                 end;
var g_choix: Char;
        g_kohonen: array[1..k_ligne_max, 1..k_colonne_max] of t_kohonen;

        g_nom_fichier_impression: string;
        g_test: Boolean;

(* -- affichage graphique *)

procedure go_dessin;
var l_iteration: Integer;

  procedure ajuste_reseau;
  var l_x, l_y: Real;
        l_ligne, l_colonne: Integer;
        l_ligne_min, l_colonne_min: Integer;
        l_distance_entree_min: Real;
        l_distance_poids, l_attenuation: Real;
        l_coefficient_attenuation: Real;
        l_voisin: Integer;
        l_nombre_modifies: Integer;

    procedure affiche_poids_et_frequence;
    var l_ligne, l_colonne: Integer;
    begin
      (* -- affiche en deux fois *)
      for l_colonne := 1 to k_colonne_max div 2 do
        for l_ligne := 1 to k_ligne_max do
          with g_kohonen[l_ligne, l_colonne] do
          begin
            if (l_ligne = l_ligne_min) and (l_colonne = l_colonne_min)
              then affiche_chaine(10 + l_ligne * 10, 135 + l_colonne * 150 - 10, '*', 1)
              else affiche_chaine(10 + l_ligne * 10, 135 + l_colonne * 150 - 10, ' ', 1);

            affiche_reel(10 + l_ligne * 10, 100 + l_colonne * 135, poids_x, 3, 2);
            affiche_reel(10 + l_ligne * 10, 100 + 40 + l_colonne * 135, poids_y, 3, 2);
            affiche_entier(10 + l_ligne * 10, 100 + 85 + l_colonne * 135, frequence, 4);
          end;

      for l_colonne := k_colonne_max div 2 + 1 to k_colonne_max do
        for l_ligne := 1 to k_ligne_max do
          with g_kohonen[l_ligne, l_colonne] do
          begin
            if (l_ligne = l_ligne_min) and (l_colonne = l_colonne_min)
              then affiche_chaine(100 + l_ligne * 10, 100 + (l_colonne - 3) * 135 - 10, '*', 1)
              else affiche_chaine(100 + l_ligne * 10, 100 + (l_colonne - 3) * 135 - 10, ' ', 1);

            affiche_reel(100 + l_ligne * 10, 100 + (l_colonne - 3) * 135, poids_x, 3, 2);
            affiche_reel(100 + l_ligne * 10, 100 + 45 + (l_colonne - 3) * 135, poids_y, 3, 2);
            affiche_entier(100 + l_ligne * 10, 100 + 85 + (l_colonne - 3) * 135, frequence, 4);
          end;
    end; (* affcihe poids et frequence *)

    procedure dessine_kohonen;
    var l_ligne, l_colonne: Integer;
    begin
      Rectangle(k_x_debut, k_y_debut, k_x_debut + k_echelle, k_y_debut + k_echelle);

      SetFillStyle(SolidFill, Black);
      Bar(k_x_debut + 1, k_y_debut + 1, k_x_debut + k_echelle - 1, k_y_debut + k_echelle - 1);

      (* -- l'entree actuelle *)
      dessine_croix(Round(l_x * k_echelle), Round(l_y * k_echelle), Red);
      (* -- le point le plus proche *)
      with g_kohonen[l_ligne_min, l_colonne_min] do
        dessine_croix(Round(poids_x * k_echelle), Round(poids_y * k_echelle), LightBlue);

      SetColor(LightRed);
      for l_ligne := 1 to k_ligne_max do
        for l_colonne := 1 to k_colonne_max - 1 do
          with g_kohonen[l_ligne, l_colonne] do
            Line(k_x_debut + Round(poids_x * k_echelle), k_y_debut + Round(poids_y * k_echelle),
                k_x_debut + Round(g_kohonen[l_ligne, l_colonne + 1].poids_x * k_echelle),
                k_y_debut + Round(g_kohonen[l_ligne, l_colonne + 1].poids_y * k_echelle));

      SetColor(LightBlue);
      for l_colonne := 1 to k_colonne_max do
        for l_ligne := 1 to k_ligne_max - 1 do
          with g_kohonen[l_ligne, l_colonne] do
            Line(k_x_debut + Round(poids_x * k_echelle), k_y_debut + Round(poids_y * k_echelle),
                k_x_debut + Round(g_kohonen[l_ligne + 1, l_colonne].poids_x * k_echelle),
                k_y_debut + Round(g_kohonen[l_ligne + 1, l_colonne].poids_y * k_echelle));


      SetColor(White);

      affiche_poids_et_frequence;
    end; (* dessine kohonen *)

    procedure affiche_coefficients;
    var l_ligne: Integer;
        l_imprime: Char;
    begin
      SetColor(White);

      affiche(270, 10, 'nombre voisins: ', l_voisin, 10, 0);
      affiche(280, 10, 'lointains:      ',
        1 / (k_ralentis_lointains - k_attenue_lointains * (l_iteration - 1)), 10, 6);
      affiche(290, 10, 'apprentissage:  ',
        (k_accelere_apprentissage - k_attenue_apprentissage * l_iteration), 10, 6);
      affiche(300, 10, 'modifies:       ', l_nombre_modifies, 10, 0);
      affiche(310, 10, 'distance:       ', l_distance_entree_min, 10, 6);

      affiche_chaine(300, 300, 'taper touche', 12);
      //l_imprime := ReadKey;
      if l_imprime in ['0'..'9', 'A'..'Z']
        then begin
          affiche_chaine(300, 300, 'imprime', 12);
          imprime_avec_tampon(g_nom_fichier_impression + l_imprime);
        end;
      affiche_chaine(300, 300, 'calcule', 12);
    end;

  begin (* ajuste reseau *)
    l_x := Random; l_y := Random;

    (* -- calcule le plus proche de l'entree *)
    l_distance_entree_min := 30000;
    l_ligne_min := -1;
    l_colonne_min := -1;

    for l_ligne := 1 to k_ligne_max do
      for l_colonne := 1 to k_colonne_max do
        with g_kohonen[l_ligne, l_colonne] do
        begin
          distance_entree := Sqr(l_x - poids_x) + Sqr(l_y - poids_y);
          (* -- le mechanisme de 'conscience' *)
          if l_iteration > 100
            then distance_entree := distance_entree
                * frequence / (l_iteration / k_ligne_max * k_colonne_max);

          if distance_entree < l_distance_entree_min
            then begin
              l_ligne_min := l_ligne;
              l_colonne_min := l_colonne;
              l_distance_entree_min := distance_entree;
            end;
        end;

    (* -- ici la frequence est utilisee pour repartir les gagnants *)
    Inc(g_kohonen[l_ligne_min, l_colonne_min].frequence, 1);

    l_voisin := k_voisins;

    (* -- pour suivre l'evolution *)
    l_nombre_modifies := 0;

    (* -- ajuste les poids *)
    for l_ligne := 1 to k_ligne_max do
      for l_colonne := 1 to k_colonne_max do
        if (Abs(l_ligne - l_ligne_min) < l_voisin) and (Abs(l_colonne - l_colonne_min) < l_voisin)
                (* -- pour un voisinage diamant, ajouter la condition suivante:
                and ((l_ligne = l_ligne_min) or (l_colonne = l_colonne_min))
                *)
          then
            with g_kohonen[l_ligne, l_colonne] do
            begin
              l_distance_poids := Sqr(poids_x - g_kohonen[l_ligne_min, l_colonne_min].poids_x)
                + Sqr(poids_y - g_kohonen[l_ligne_min, l_colonne_min].poids_y);

              l_coefficient_attenuation := l_distance_poids
                / (k_ralentis_lointains - k_attenue_lointains * (l_iteration - 1));
              if l_coefficient_attenuation > k_exponentielle_max
                then l_attenuation := 0
                else l_attenuation := Exp(-l_coefficient_attenuation);

              (* -- statistique de suivi *)
              if l_attenuation <> 0
                then l_nombre_modifies := l_nombre_modifies + 1;

              (* -- le nouveau poids *)
              poids_x := poids_x + (k_accelere_apprentissage - k_attenue_apprentissage * l_iteration)
                * l_attenuation * (l_x - poids_x);
              poids_y := poids_y + (k_accelere_apprentissage - k_attenue_apprentissage * l_iteration)
                * l_attenuation * (l_y - poids_y);
            end;

    (* -- affichage et impressions *)
    if (l_iteration - 1) mod 100 = 0
      then affiche(260, 10, 'iteration:    ', l_iteration, 10, 0);
    if ((l_iteration - 1) mod k_frequence_affichage = 0)
        and (l_iteration >= k_premier_affichage)
      then dessine_kohonen;
    if (l_iteration - 1) mod k_affiche_coefficients = 0
      then affiche_coefficients;
  end; (* ajuste reseau *)

begin (* go dessin *)
  sonne;
  initialise_mode_graphique;

  for l_iteration := 1 to k_iteration_max do
    ajuste_reseau;

  sonne; ReadLn;
  CloseGraph;
end; (* go dessin *)

procedure initialise;
var l_ligne, l_colonne: Integer;
begin
  FillChar(g_kohonen, SizeOf(g_kohonen), 0);

  (* -- initialise dans le carree *)
  for l_ligne := 1 to k_ligne_max do
    for l_colonne := 1 to k_colonne_max do
      with g_kohonen[l_ligne, l_colonne] do
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
    Write('[G]o, [I]nitialise, [Q]uitte ?');
    g_choix := ReadKey; Write(g_choix); WriteLn;
    case g_choix of
      ' ': ClrScr;
      'g': go_dessin;
      '0'..'9', 'A'..'Z': imprime_fichier(g_nom_fichier_impression + g_choix);

      'i': initialise;
    end;
  until g_choix = 'q';
end.