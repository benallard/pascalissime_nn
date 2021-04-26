(* 003 voyage4 *)
(* 24 sep 91 *)

(* -- lineaire *)

(*$r+*)
program reseau_neuronal_kohonen_voyegeur_de_commerce;
uses cThreads, Crt, ptcGraph,
        ustoppe, uaffiche, uimpri;
const k_exemple_max = 5;

      k_indice_max = 70;
      k_ville_max = 30;
      k_exponentielle_max = 85;

      k_iteration_max = 10000;
      k_frequence_affichage = 1;
      k_premier_affichage = 0;

type t_kohonen = record
                   poids_x, poids_y: Real;
                   distance_brute: Real;
                   distance_corrigee: real;
                   conscience: Real;

                   (* -- statistique *)
                   frequence: Integer;
                 end;
     t_ville = record
                 x_ville, y_ville: Real;
               end;

     t_exemple = record
                   indice_max, ville_max: Integer;
                   rayon_initial: Real; saute_max: Integer;
                   accelere_apprentissage, attenue_apprentissage,
                        ralentis_lointains, attenue_lointains,
                        conscience_max: Real;
                   voisin_max: Integer;
                   affiche_numero, affiche_calculs: Boolean;
                 end;

var g_choix: Char;

    g_kohonen: array[1..k_indice_max] of t_kohonen;
    g_ville: array[1..k_ville_max] of t_ville;

    g_exemple: array[1..k_exemple_max] of t_exemple;
    g_numero_exemple: Integer;
    g_nom_fichier_impression: string;

(* -- affichage_graphique *)

procedure go_dessin;
var l_iteration: Integer;
        l_essai: Integer;

  procedure ajuste_reseau;
  const k_colonne_chiffre = 250;
  var l_x, l_y: Real;
      l_indice: Integer;
      l_indice_min: Integer;
      l_distance_corrigee_min: Real;
      l_distance_poids, l_attenuation: Real;
      l_coefficient_attenuation: Real;

      l_indice_min_suivant: Integer;
      l_distance_corrigee_min_suivant: Real;

      l_voisin: Integer;
      l_balaye_villes, l_numero_ville: Integer;
      l_ensemble_de_villes: set of 1..k_ville_max;

      l_imprime: Char;

    procedure dessine_reseau;
    var l_indice, l_indice_autre: Integer;
        l_distance: Real;
        l_ville: Integer;
    begin
      with g_exemple[g_numero_exemple] do
      begin
        for l_ville := 1 to ville_max do
          with g_ville[l_ville] do
          begin
            dessine_croix(Round(k_echelle * x_ville), Round(k_echelle * y_ville), LightRed);
            if affiche_numero
              then affiche_entier(k_y_debut + Round(k_echelle * y_ville) - 10,
                k_x_debut + Round(k_echelle * x_ville) - 4, l_ville, 1);
          end;

        for l_indice := 1 to indice_max do
          with g_kohonen[l_indice] do
          begin
            dessine_croix(Round(k_echelle * poids_x), Round(k_echelle * poids_y), White);
            if (l_indice > indice_max) and ((l_essai - 1) mod 100 = 0)
              then Line(k_x_debut + Round(k_echelle * poids_x),
                        k_y_debut + Round(k_echelle * poids_y),
                        k_x_debut + Round(k_echelle * g_kohonen[l_indice + 1].poids_x),
                        k_y_debut + Round(k_echelle * g_kohonen[l_indice + 1].poids_y));
            if affiche_numero
              then affiche_entier(k_x_debut + Round(k_echelle * poids_x) - 10,
                k_y_debut + Round(k_echelle * poids_y) + 4, l_indice, 1);
          end;
      end;
    end; (* dessine_reseau *)

    procedure affiche_distances;
    var l_indice_point: Integer;
    begin
      with g_exemple[g_numero_exemple] do
      begin
        affiche(240,      5, 'passe:          ', 1 + l_essai div indice_max, 10, 0);
        affiche(240 + 12, 5, 'essai:          ', l_essai, 10,0);
        affiche(240 + 24, 5, 'ville:          ', l_numero_ville, 10, 0);
        affiche(240 + 36, 5, 'nombre voisins: ', l_voisin, 10, 0);
        affiche(240 + 48, 5, 'lointains:      ',
                1 / (ralentis_lointains - attenue_lointains * (l_iteration - 1)), 10, 6);
        affiche(240 + 60, 5, 'apprentissage:  ',
                (accelere_apprentissage - attenue_apprentissage * l_iteration), 10, 6);
        affiche(240 + 72, 5, 'k_iter_max:     ', k_iteration_max, 9, 0);
        affiche(240 + 84, 5, 'coef conscience:', conscience_max, 9, 3);

        if affiche_calculs or (l_essai mod 100 = 0)
          then begin
            affiche_chaine(12, k_colonne_chiffre + 10, 'freq', 1);
            affiche_chaine(12, k_colonne_chiffre + 55, 'cons', 1);
            affiche_chaine(12, k_colonne_chiffre + 130, 'dbru', 1);
            affiche_chaine(12, k_colonne_chiffre + 190, 'dcor', 1);
            affiche_chaine(12, k_colonne_chiffre + 250, 'correction', 1);

            for l_indice_point := 1 to indice_max do
              with g_kohonen[l_indice_point] do
              begin
                affiche_entier((l_indice_point + 1) * 12, k_colonne_chiffre, frequence, 4);
                affiche_reel((l_indice_point + 1) * 12, k_colonne_chiffre + 45, conscience, 6, 3);
                affiche_reel((l_indice_point + 1) * 12, k_colonne_chiffre + 120,
                        distance_brute, 6, 3);
                if l_indice_point = l_indice_min
                  then affiche_chaine((l_indice_point + 1) * 12, k_colonne_chiffre + 175, '*', 1)
                  else affiche_chaine((l_indice_point + 1) * 12, k_colonne_chiffre + 175, ' ', 1);
                affiche_reel((l_indice_point + 1) * 12, k_colonne_chiffre + 185,
                        distance_corrigee, 7, 4);
                affiche_chaine((l_indice_point + 1) * 12, k_colonne_chiffre + 250,
                        '          ', 10);
              end;
          end;
      end;
    end; (* affuiche distance *)

  begin (* ajuste reseau *)
    with g_exemple[g_numero_exemple] do
    begin
      (* -- randomize l'ordre des villes dans l'apprentissage *)
      l_ensemble_de_villes := [];
      for l_balaye_villes := 1 to ville_max do
      begin
        (* -- selectionne aleatoirement l'une des villes *)
        repeat
          l_numero_ville := 1 + Random(ville_max);
        until not (l_numero_ville in l_ensemble_de_villes);
        l_ensemble_de_villes := l_ensemble_de_villes + [l_numero_ville];

        with g_ville[l_numero_ville] do
        begin
          l_x := x_ville; l_y := y_ville;
        end;

        l_essai := l_essai + 1;

        (* -- calcule le point le plus proche de cette ville *)
        l_distance_corrigee_min := 30000;
        l_indice_min := -1;

        for l_indice := 1 to indice_max do
          with g_kohonen[l_indice] do
          begin
            distance_brute := Sqr(l_x - poids_x) + Sqr(l_y - poids_y);

            (* -- pondere par la conscience de cette ville *)
            distance_corrigee := distance_brute * conscience / l_iteration;
            if distance_corrigee < l_distance_corrigee_min
              then begin
                l_indice_min := l_indice;
                l_distance_corrigee_min := distance_corrigee;
              end;
          end;

        with g_kohonen[l_indice_min] do
          frequence := frequence + 1;

        l_voisin := voisin_max;

        dessine_reseau;
        affiche_distances;

        (* -- ajuste les poids *)
        for l_indice := 1 to indice_max do
          if Abs(l_indice - l_indice_min) < l_voisin
            then
              with g_kohonen[l_indice] do
              begin
                l_distance_poids := Sqr(poids_x - g_kohonen[l_indice_min].poids_x)
                  + Sqr(poids_y - g_kohonen[l_indice_min].poids_y);

                l_coefficient_attenuation := l_distance_poids
                  / (ralentis_lointains - attenue_lointains * (l_iteration - 1));
                if l_coefficient_attenuation > k_exponentielle_max
                  then l_attenuation := 0
                  else l_attenuation := Exp(-l_coefficient_attenuation);

                if affiche_calculs or (l_essai mod 100 = 0)
                  then begin
                    affiche_reel((l_indice + 1) * 12, k_colonne_chiffre + 250,
                          (accelere_apprentissage - attenue_apprentissage * l_iteration)
                          * l_attenuation, 10, 7);
                  end;

                (* -- le nouveau poids *)
                poids_x := poids_x + (accelere_apprentissage - attenue_apprentissage * l_iteration)
                  * l_attenuation * (l_x - poids_x);
                poids_y := poids_y + (accelere_apprentissage - attenue_apprentissage * l_iteration)
                  * l_attenuation * (l_y - poids_y);

                if l_indice = l_indice_min
                  then conscience := conscience + conscience_max
                  else conscience := conscience * (1 - conscience_max / indice_max);
              end; (*-- ajuste les poids *)
        if affiche_calculs or ((l_essai - 1) mod 100 = 0)
          then begin
            (* -- eventuellement place dans un fichier pour impression *)









          end;

        if (l_iteration mod k_frequence_affichage = 0)
           and (l_iteration > k_premier_affichage)
          then begin
            SetFillStyle(SolidFill, Black);
            Bar(k_x_debut + 1, k_y_debut + 1, k_x_debut + k_echelle - 1, k_y_debut + k_echelle - 1);

            (* -- l'entree actuelle *)
            dessine_croix(Round(k_echelle * l_x), Round(k_echelle * l_y), Red);
            (* -- le point le plus proche *)
            with g_kohonen[l_indice_min] do
              dessine_croix(Round(k_echelle * poids_y), Round(k_echelle * poids_y), LightBlue);
          end;
      end; (* balaye ville *)
    end; (* with *)
  end; (* ajuste reseau *)

begin (* go dessin *)
  initialise_mode_graphique;

  Rectangle(k_x_debut, k_y_debut, k_x_debut + k_echelle, k_y_debut + k_echelle);

  l_essai := 0;
  for l_iteration := 1 to k_iteration_max do
    ajuste_reseau;

  sonne; ReadLn;
  CloseGraph;
end; (* go _dessin *)

procedure initialise;
var l_ville, l_indice: Integer;
        l_indice_saute: Integer;
        l_saute: Real;

  procedure cree_exemple(p_indice_max, p_ville_max: Integer;
        p_rayon_initial: Real; p_saute_max: Integer;
        p_accelere_apprentissage, p_ralentis_lointains, p_conscience: Real;
        p_voisin_max: Integer;
        p_affiche_numero, p_affiche_calculs: Boolean);
  begin
    with g_exemple[1] do
    begin
      indice_max := p_indice_max;
      ville_max := p_ville_max;
      rayon_initial:= p_rayon_initial; saute_max := p_saute_max;
      accelere_apprentissage:= p_accelere_apprentissage;
      attenue_apprentissage := accelere_apprentissage / k_iteration_max;
      ralentis_lointains := p_ralentis_lointains;
      attenue_lointains := ralentis_lointains / k_iteration_max;
      conscience_max := p_conscience;
      voisin_max := p_voisin_max;

      affiche_numero := p_affiche_numero; affiche_calculs := p_affiche_calculs;
    end;
  end;

begin (* initialise *)
  FillChar(g_ville, SizeOf(g_ville), 0);

  g_numero_exemple := 1;



















  (* -- ok converge, presente dand l'article *)
  cree_exemple(6, 4, 0.20, 2, 0.03, 0.01, 0.7, 100, True, False);

















  with g_exemple[g_numero_exemple] do
  begin
    for l_indice_saute := 1 to saute_max do
      l_saute := Random;

    (* -- initialise les villes *)
    for l_ville := 1 to ville_max do
      with g_ville[l_ville] do
      begin
        x_ville := Random;
        y_ville := Random;
      end;

    FillChar(g_kohonen, SizeOf(g_kohonen), 0);
    (* initialise sur le cercle *)
    for l_indice := 1 to indice_max do
      with g_kohonen[l_indice] do
      begin
        poids_x := 0.5 + rayon_initial * Cos(2 * PI / indice_max * l_indice);
        poids_y := 0.5 + rayon_initial * Sin(2 * PI / indice_max * l_indice);
        conscience := 1 / indice_max;                        end;
  end;

  g_nom_fichier_impression := 'a:dessin';
end;

begin (* main *)
  ClrScr;
  initialise;
  repeat
    WriteLn;
    Write('[G]o, [I]nitialise, [Q]uitte?');
    g_choix := ReadKey; Write(g_choix); WriteLn;
    case g_choix of
      ' ': ClrScr;
      'g': go_dessin;
      'i': initialise;
    end;
  until g_choix = 'q';
end. (* main *)