(* 001 idessin *)
(* 14 jul 91 *)

procedure go_dessin;
var l_sortie: integer;
  l_numero_apprentissage, l_passe, l_apprentissage: integer;
  l_ensemble_apprentissage: set of 1..k_apprentissage_max;

const (* -- les parameters de ce reseau *)
  k_couche_max = 3;
  k_neurone_max = 7;
  k_poids_max = 7;
  (* -- les valeurs initiales *)
  k_rayon_neurone = 30;
  k_rayon_poids = 6;
  (* -- laisser un peu de gras autour *)
  k_marge_horizontale = 10;
  k_marge_verticale = 10;
  (* -- pour que les poids se touchent *)
  k_aspect = 1.2;
  (* -- agrandissement pour passer les valeurs de sortie aux rayons *)
  k_coefficient_neurone=30;
  k_coeficient_poids=4;

  k_taille_signe=3;
  k_dessin_initial=false;
type t_neurone = record
        x_neurone, y_neurone: integer;
        rayon_neurone_precedent: integer;
        poids: array[1..k_poids_max] of
          record
            x_poids, y_poids: integer;
            rayon_poids_precedent:integer;
          end;
  end;
  t_couche = record
        neurone_max, poids_max: integer;
        neurones: array[1..k_neurone_max] of t_neurone;
  end;
var l_reseau: array[1..k_couche_max] of t_couche;
  l_largeur_couche, l_espacement: integer;
  l_largeur_image: integer;

  procedure initialise_reseau;
  var l_couche, l_neurone, l_poids: integer;
  begin
    with l_reseau[1] do
    begin
      neurone_max := 6; poids_max := 0;
    end;
    with l_reseau[2] do
    begin
      neurone_max := 3; poids_max := 7;
    end;
    with l_reseau[3] do
    begin
      neurone_max := 7; poids_max := 4;
    end;

    (* -- le centrage de chaque coushe: |- -- --| *)
    l_largeur_couche := 2 * (k_rayon_poids + k_rayon_neurone);
    l_espacement := (l_largeur_image + 1 - 2 * k_marge_horizontale - 2 * k_rayon_neurone
        - (k_couche_max - 1) * l_largeur_couche) div (k_couche_max - 1)
        + l_largeur_couche;

    for l_couche := 1 to k_couche_max do
      with l_reseau[l_couche] do
      begin
        for l_neurone := 1 to neurone_max do
          with neurones[l_neurone] do
          begin
            if l_couche = 1
              then x_neurone := k_marge_horizontale + k_rayon_neurone
              else x_neurone := l_reseau[l_couche - 1].neurones[1].x_neurone + l_espacement;
            y_neurone := k_rayon_neurone + k_marge_verticale
                 + (GetMaxY + 1 - 2 * k_marge_verticale - 2 * k_rayon_neurone)
                 div (neurone_max - 1) * (l_neurone - 1);
            for l_poids := 1 to poids_max do
              with poids[l_poids] do
              begin
                x_poids := x_neurone - k_rayon_neurone - k_rayon_poids;
                y_poids := y_neurone - (poids_max * 2 * k_rayon_poids) div 2
                        + k_rayon_poids + k_rayon_poids * 2 * (l_poids - 1);
              end;
          end;
      end;
  end;

  procedure dessine_reseau;
  var l_couche, l_neurone, l_poids: integer;
    l_neurone_suivant: integer;
  begin
    rectangle(0, 0, l_largeur_image, GetMaxY);

    (* -- les biais *)
    for l_couche := 2 to k_couche_max do
      with l_reseau[l_couche] do
        for l_neurone := 1 to neurone_max do
          with neurones[l_neurone].poids[1] do
            line(x_poids - 10 * k_rayon_poids, y_poids, x_poids, y_poids);

    (* -- les jonctions *)
    for l_couche := 1 to k_couche_max - 1 do
      with l_reseau[l_couche] do
      begin
        for l_neurone := 1 to neurone_max do
          with neurones[l_neurone] do
          begin
            for l_neurone_suivant := 1 to l_reseau[l_couche + 1].neurone_max do
            begin
              with l_reseau[l_couche + 1].neurones[l_neurone_suivant].poids[l_neurone + 1] do
                line(x_neurone + k_rayon_neurone, y_neurone, x_poids, y_poids);
            end;
          end;
      end;

    (* -- met en noir pour eviter les reliquats de points *)
    if not k_dessin_initial
      then begin
        SetFillStyle(SolidFill, Black);
        for l_couche := 2 to k_couche_max do
          with l_reseau[l_couche] do
            with neurones[1].poids[1] do
              bar(x_poids - k_rayon_poids, 0, x_poids + k_rayon_poids, GetMaxY);
      end;
  end;
begin (* go_dessin *)
end;