(* 001 unun *)
(* 24 sep 91 *)

(* -- une dimension vers une dimension *)

(*$r+*)
program reseau_rneuronal_kohonen;
uses cthreads, Crt, ptcGraph,
        uimpri, uaffiche, ustoppe;
const (* -- le nombre de points de la couche de kohonen *)
        k_indice_max = 30;

        (* -- le regoupement du nuage initial par rapport a [0..1[ *)
        k_regroupement_initial =1.00;
        (* -- saute les premieres valeurs de Random *)
        k_saute = 12;


        k_iteration_max = 10000;

        (* -- un gros coefficient accelere l'ajustement *)
        (* -- 0.9: nouge trop, 0.1: tres lent *)
        k_accelere_apprentissage = 0.30;
        k_attenue_apprentissage = k_accelere_apprentissage / k_iteration_max;

        (* -- un gros coefficient ralentit la modification des points lointains *)
        k_ralentis_lointains = 3.0;
        k_attenue_lointains = k_ralentis_lointains / k_iteration_max;

        k_frequence_affichage: Integer = 10;
        k_affiche_coefficients = 10;
        k_premier_affichage = 1;

        k_exponentielle_max = 85;

type t_kohonen = Record
                   poids_y: Real;
                   distance_entree: Real;
                   frequence: Integer;
                 end;
var g_choix: Char;
        g_kohonen: array[1..k_indice_max] of t_kohonen;

        g_nom_fichier_impression: string;
        g_test: Boolean;

(* -- affichage graphique *)

procedure go_dessin;
var l_iteration: Integer;
        l_distance_moyenne: Real;

  procedure ajuste_reseau;
  var l_x, l_y: Real;
        l_indice: Integer;
        l_indice_min: Integer;
        l_distance_entree_min: Real;
        l_distance_poids, l_attenuation: Real;
        l_coefficient_attenuation: Real;
        l_voisin: Integer;

    procedure dessine_reseau;
    var l_indice: Integer;
    begin
      Rectangle(k_x_debut, k_y_debut, k_x_debut + k_echelle, k_y_debut + k_echelle);

      SetFillStyle(SolidFill, Black);
      Bar(k_x_debut + 1, k_y_debut + 1, k_x_debut + k_echelle - 1, k_y_debut + k_echelle - 1);

      SetColor(White);
      for l_indice := 1 to k_indice_max - 1 do
        with g_kohonen[l_indice] do
          Line(k_x_debut + l_indice * k_echelle div k_indice_max,
               k_y_debut + Round(poids_y * k_echelle),
               k_x_debut + (l_indice + 1) * k_echelle div k_indice_max,
               k_y_debut + Round(g_kohonen[l_indice + 1].poids_y * k_echelle));
    end; (* dessine_reseau *)

    procedure affiche_coefficients;
    var l_indice: Integer;
        l_imprime: Char;
    begin
      affiche(300, 10, 'iteration', l_iteration, 10, 0);
      affiche(310, 10, 'nombre voisins: ', l_voisin, 10, 0);
      affiche(320, 10, 'lointains:',
        1 / (k_ralentis_lointains - k_attenue_lointains * (l_iteration - 1)), 10, 6);
      affiche(330, 10, 'apprentissage',
        (k_accelere_apprentissage - k_attenue_apprentissage * l_iteration), 10, 6);

      (* -- affiche la frequence, Pour 50 points: 2 collones *)
      for l_indice := 1 to k_indice_max do
        affiche_entier(10 + 10 * (l_indice - 1) mod 250, 300 + ((l_indice - 1) div 25) * 50,
                g_kohonen[l_indice].frequence, 4);

      (* -- eventuellement place dans un fichier pour impression *)
      affiche_chaine(300, 300, 'tapez touche', 12);
      //l_imprime := ReadKey;





      affiche_chaine(300, 300, 'calcule... ', 12);
    end; (* -- affiche_coefficients *)

  begin (* ajuste reseau *)
    l_x := Random;

    (* -- calcule le plus proche de l'entree *)
    l_distance_entree_min := 30000;
    l_indice_min := -1;

    for l_indice := 1 to k_indice_max do
      with g_kohonen[l_indice] do
      begin
        distance_entree := Abs(l_x - poids_y);
        if distance_entree < l_distance_entree_min
          then begin
            l_indice_min := l_indice;
            l_distance_entree_min := distance_entree;
          end;
      end;

      Inc(g_kohonen[l_indice_min].frequence, 1);

      l_voisin := Abs(6 - l_iteration div 500);
      if l_voisin < 4
        then l_voisin := 4;

      (* -- ajuste les poids *)
      for l_indice := 1 to k_indice_max do
      if Abs(l_indice - l_indice_min) < l_voisin
        then
          with g_kohonen[l_indice] do
          begin
            l_distance_poids := Abs(poids_y - g_kohonen[l_indice_min].poids_y);

            (* valeur calculee uniquement pour l'affichage *)
            l_distance_moyenne := l_distance_moyenne + Sqrt(l_distance_poids);

            l_coefficient_attenuation := l_distance_poids
                / (k_ralentis_lointains - k_attenue_lointains * (l_iteration - 1));
            if l_coefficient_attenuation > k_exponentielle_max
              then l_attenuation := 0
              else l_attenuation := Exp(-l_coefficient_attenuation);

            (* -- le nouveau poids *)
            poids_y := poids_y + (k_accelere_apprentissage - k_attenue_apprentissage * l_iteration)
                * l_attenuation * (l_x - poids_y);
          end;

    (* -- affiche les resultats *)
    if ((l_iteration - 1) mod k_frequence_affichage=0)
        and (l_iteration >= k_premier_affichage)
      then dessine_reseau;
    if (l_iteration - 1) mod k_affiche_coefficients = 0
      then affiche_coefficients;
  end; (* ajuste reseau *)

begin (* go_dessin *)
  initialise_mode_graphique;

  l_distance_moyenne := 0.0;

  for l_iteration := 1 to k_iteration_max do
    ajuste_reseau;

  sonne; ReadLn;
  CloseGraph;
end; (* go dessin *)

procedure initialise;
var l_ligne, l_colonne: Integer;
        l_indice_saute: Integer;
        l_saute: Real;
begin
  FillChar(g_kohonen, SizeOf(g_kohonen), 0);

  (* -- initialise dans le caree *)
  for l_indice_saute := 1 to k_saute do
    l_saute := Random;

  for l_ligne := 1 to k_indice_max do
    with g_kohonen[l_ligne] do
    begin
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
    Write('[G]o, [I]nitialise, [Q]uitte?');
    g_choix := ReadKey; Write(g_choix); WriteLn;
    case g_choix of
      ' ': ClrScr;
      'g': go_dessin;
      'i': initialise;
    end;
  until g_choix = 'q';
end. (* main*)
