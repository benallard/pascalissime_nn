(* 001 kohonen3 *)
(* 13 jul 91 *)

(*$r+*)
program reseau_neuronal_kohonen;
uses cthreads, Crt, ptcGraph,
        ustoppe, uimpri, uaffiche;
const k_ligne_max = 3;
        k_colonne_max = 3;

        (* -- le regroupement du nuage initial par rapport a [0..1[ *)
        k_regroupement_initial = 0.05;
        (* -- un gros coefficient ralentit la modification des points lointains *)
        k_ralentis_lointains = 200.0;
        (* -- un gros coefficient accelere l'ajustement *)
        k_accelere_apprentissage = 0.10;

        k_iteration_max = 3000;
        k_frequence_affichage = 1;
        k_exponentielle_max = 85;

type t_kohonen = record
                   poids_x, poids_y : Real;
                   distance_entree: Real;
                 end;
var g_choix: Char;
        g_kohonen: array[1..k_ligne_max, 1.. k_colonne_max] of t_kohonen;

        g_nom_fichier_impression: string;

procedure go_dessin;
var l_ligne, l_colonne: Integer;
        l_iteration: Integer;

  procedure dessine_reseau;
  var l_ligne, l_colonne: Integer;
      l_imprime: Char;
  begin
    (* -- trace de la couche de sortie: les traits verticaux *)
    for l_ligne := 1 to k_ligne_max do
      for l_colonne := 1 to k_colonne_max - 1 do
        with g_kohonen[l_ligne, l_colonne] do
        begin
          if l_ligne = 1
            then SetColor(lightGreen)
            else SetColor(Yellow);
          Line(k_x_debut + Round(k_echelle * poids_x), k_y_debut + Round(k_echelle * poids_y),
               Round(k_x_debut + k_echelle * g_kohonen[l_ligne, l_colonne + 1].poids_x),
               Round(k_y_debut + k_echelle * g_kohonen[l_ligne, l_colonne + 1].poids_y));
        end;

    (* -- trace de la couche de sortie: les traits verticaux *)
    for l_colonne:= 1 to k_colonne_max do
      for l_ligne := 1 to k_ligne_max - 1 do
        with g_kohonen[l_ligne, l_colonne] do
        begin
          if l_colonne= 1
            then SetColor(lightBlue)
            else SetColor(lightRed);
          Line(k_x_debut + Round(k_echelle * poids_x), k_y_debut + Round(k_echelle * poids_y),
               Round(k_x_debut + k_echelle * g_kohonen[l_ligne + 1, l_colonne].poids_x),
               Round(k_y_debut + k_echelle * g_kohonen[l_ligne + 1, l_colonne].poids_y));
        end;
  end;

  procedure ajuste_reseau;
  var l_x, l_y: Real;
      l_ligne, l_colonne: Integer;
      l_ligne_min, l_colonne_min: Integer;
      l_distance_entree_min: Real;
      l_distance_poids, l_attenuation: Real;
      l_imprime: Char;
  begin
    l_x := Random; l_y := Random;

    (* -- calcule le plus proche de l'entree *)
    l_distance_entree_min := 30000;
    l_ligne_min := -1; l_colonne_min := -1;

    for l_ligne := 1 to k_ligne_max do
      for l_colonne := 1 to k_colonne_max do
        with g_kohonen[l_ligne,l_colonne] do
        begin
          distance_entree := Sqr(l_x - poids_x) + Sqr(l_y - poids_y);
          if distance_entree < l_distance_entree_min
            then begin
              l_ligne_min := l_ligne;
              l_colonne_min := l_colonne;
              l_distance_entree_min := distance_entree;
            end;
        end;

    (* -- ajuste les poids *)
    for l_ligne := 1 to k_ligne_max do
      for l_colonne := 1 to k_colonne_max do
        with g_kohonen[l_ligne, l_colonne] do
        begin
          l_distance_poids := Sqr(poids_x - g_kohonen[l_ligne_min, l_colonne_min].poids_x)
                + Sqr(poids_y - g_kohonen[l_ligne_min, l_colonne_min].poids_y);
          if l_distance_poids * k_ralentis_lointains > k_exponentielle_max
            then l_attenuation := 0
            else l_attenuation := Exp(-l_distance_poids * k_ralentis_lointains);

          (* -- le nouveau poids *)
          poids_x := poids_x + k_accelere_apprentissage * l_attenuation * (l_x - poids_x);
          poids_y := poids_y + k_accelere_apprentissage * l_attenuation * (l_y - poids_y);
        end;

    if l_iteration mod k_frequence_affichage = 0
      then begin
        SetFillStyle(SolidFill, Black);
        Bar(k_x_debut + 1, k_y_debut + 1, k_x_debut + k_echelle - 1, k_y_debut + k_echelle - 1);

        (* -- l'entree actuelle *)
        dessine_croix(Round(k_echelle * l_x), Round(k_echelle * l_y), White);
        (* -- le point le plus proche *)
        with g_kohonen[l_ligne_min, l_colonne_min] do
          dessine_croix(Round(k_echelle * poids_x), Round(k_echelle * poids_y), lightBlue);
        dessine_reseau;
      end;








  end;

begin (* go_dessin *)
  initialise_mode_graphique;
  Rectangle(k_x_debut, k_y_debut, k_x_debut + k_echelle, k_y_debut + k_echelle);

  for l_iteration := 1 to k_iteration_max do
    ajuste_reseau;

  sonne; ReadLn;
  CloseGraph;
end;

procedure initialise;
var l_ligne, l_colonne: Integer;
begin
  FillChar(g_kohonen, SizeOf(g_kohonen), 0);

  (* -- initialise dans le carree *)
  for l_ligne := 1 to k_ligne_max do
    for l_colonne := 1 to k_colonne_max do
      with g_kohonen[l_ligne, l_colonne] do
      begin
        poids_x := 0.5 * k_regroupement_initial * Random - 0.5 * k_regroupement_initial;
        poids_y := 0.5 * k_regroupement_initial * Random - 0.5 * k_regroupement_initial;
      end;

  g_nom_fichier_impression := 'a:dessin';
end;

begin (* main *)
  ClrScr;
  initialise;
  repeat
    WriteLn;
    Write('[G]o, [I]nitialise, [Q]uitte ?');
    g_choix := ReadKey;Write(g_choix);WriteLn;
    case g_choix of
      ' ': ClrScr;
      'g': go_dessin;

      'i': initialise;
    end;
  until g_choix = 'q';
end.