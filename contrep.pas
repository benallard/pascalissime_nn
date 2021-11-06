(* 001 contrep *)
(* 20 jul 93 *)

(*$r+*)
program counterp1;
uses Crt;
     //uerresim;

const k_entree_max = 25;
      k_intermediaire_max = 4;
      k_sortie_max = 2;

      k_apprentissage_intermediaire = 0.3;
      k_convergence_intermediaire = 0.1;

      k_apprentissage_sortie = 0.3;
      k_convergence_sortie = 0.1;
type t_matrice_entree = array[1..k_entree_max] of real;
     
     t_entree = t_matrice_entree;
     t_intermediaire = array[1..k_intermediaire_max] of
                          record
                            activation: real;
                            poids: t_matrice_entree;
                          end;
      t_sortie = array[1..k_intermediaire_max] of
                            record
                                sortie: real;
                                poids: array[1..k_intermediaire_max] of real;
                            end;
var g_entree: t_entree;
    g_intermediaire: t_intermediaire;
    g_sortie: t_sortie;

    g_test: Boolean;

const k_exemple_max = 4;
      vi_exemple: array[1..k_exemple_max] of record
                                entree: t_matrice_entree;
                                sortie: array [1..k_sortie_max] of real;
                            end =
        ((entree: (0, 1, 1, 1, 0,
                   0, 0, 1, 0, 0,
                   0, 0, 1, 0, 0,
                   0, 0, 1, 0, 0,
                   0, 0, 1, 0, 0);
          sortie: (0, 1)),
         (entree: (0, 0, 0, 0, 0,
                   1, 0, 0, 0, 0,
                   1, 1, 1, 1, 1,
                   1, 0, 0, 0, 0,
                   0, 0, 0, 0, 0);
          sortie: (1, 0)),
         (entree: (0, 0, 0, 0, 0,
                   0, 0, 0, 0, 1,
                   1, 1, 1, 1, 1,
                   0, 0, 0, 0, 1,
                   0, 0, 0, 0, 0);
          sortie: (0, -1)),
         (entree: (0, 0, 1, 0, 0,
                   0, 0, 1, 0, 0,
                   0, 0, 1, 0, 0,
                   0, 0, 1, 0, 0,
                   0, 1, 1, 1, 0);
          sortie: (-1, 0)));


const k_essai_max = 2;
      vi_essai: array[1..k_essai_max] of t_entree =
        ((0, 1, 1, 0, 0,
          0, 0, 1, 1, 0,
          0, 0, 1, 0, 0,
          0, 0, 1, 0, 0,
          0, 1, 0, 0, 0),
         (0, 1, 0, 0, 0,
          0, 0, 1, 0, 0,
          0, 1, 0, 1, 0,
          1, 0, 0, 0, 0,
          0, 0, 0, 0, 0)
        );

procedure affiche_matrice(p_x, p_y: Integer; p_matrice: t_matrice_entree);
  var l_indice_entree: Integer;
  begin
    for l_indice_entree := 1 to k_entree_max do
      begin
        gotoxy(p_x + ((l_indice_entree - 1) mod 5) * 5, p_y + (l_indice_entree - 1) div 5);
        write(p_matrice[l_indice_entree]:5:2);
      end;
  end; (* affiche_matrice *)

procedure affiche_sortie(p_x, p_indice_exemple: Integer);
  var l_indice_sortie: Integer;
  begin
    GotoXY(p_x, 2+(p_indice_exemple - 1) * 6);
    for l_indice_sortie := 1 to k_sortie_max do
      write(g_sortie[l_indice_sortie].sortie:5:2);
  end; (* affiche_sortie *)

procedure affiche_poids_sorties(p_x, p_delta_y, p_indice_gagnant: Integer);
  var l_indice_sortie: Integer;
      l_indice_intermediaire: Integer;
  begin
    for l_indice_sortie := 1 to k_sortie_max do
      for l_indice_intermediaire := 1 to k_intermediaire_max do
        begin
          GotoXY(p_x, 4+(l_indice_sortie - 1) * 10 + l_indice_intermediaire);
          write(g_sortie[l_indice_sortie].poids[l_indice_intermediaire]:5:2);

          if (l_indice_intermediaire = p_indice_gagnant) and (WhereX < 70)
            then Write(' -> ');
        end;
  end; (* affiche_poids_sorties *)

procedure normalise_entree;
  var l_indice_entree : Integer;
      l_norme_au_carre, l_norme: Real;
  begin
    l_norme_au_carre := 0;
    for l_indice_entree := 1 to k_entree_max do
      l_norme_au_carre := l_norme_au_carre + Sqr(g_entree[l_indice_entree]);
    l_norme := Sqrt(l_norme_au_carre);
    for l_indice_entree := 1 to k_entree_max do
      g_entree[l_indice_entree] := g_entree[l_indice_entree] / l_norme;
  end; (* normalise_entree *)

procedure propage_entree_vers_intermediaire(VAR pv_gagnant: Integer);
  var l_indice_entree, l_indice_intermediaire: Integer;
      l_maximum: Real;
  begin
    pv_gagnant := 1; l_maximum := -100;

    (* -- calcule les activations de tous les neurones intermediaires *)
    for l_indice_intermediaire := 1 to k_intermediaire_max do
      with g_intermediaire[l_indice_intermediaire] do
      begin
        (* -- activation d'un neurone intermediaire: cosinus(Entree, Poids) *)
        activation := 0;
        for l_indice_entree := 1 to k_entree_max do
          activation := activation + g_entree[l_indice_entree] * poids[l_indice_entree];

        (* -- mets a jour le gagnant *)
        if activation > l_maximum
          then begin
                 l_maximum := activation;
                 pv_gagnant := l_indice_intermediaire;
               end;
      end;
  end; (* propage_entree_vers_intermediaire *)

procedure propage_intermediaire_vers_sortie(p_gagnant: Integer);
  var l_indice_sortie: Integer;
  begin
    (* -- calcule les sorties *)
    for l_indice_sortie := 1 to k_sortie_max do
      with g_sortie[l_indice_sortie] do
        sortie := poids[p_gagnant] * 1;
  end; (* propage_intermediaire_vers_sortie *)

procedure entraine_reseau;

  procedure entraine_la_couche_intermediaire;

    procedure initialise_poids_intermediaires;
      var l_indice_intermediaire, l_indice_entree: Integer;
      begin
        (* -- initialise les poids a ceux d'un des exemplaires *)
        for l_indice_intermediaire := 1 to k_intermediaire_max do
            g_intermediaire[l_indice_intermediaire].poids := vi_exemple[l_indice_intermediaire].entree;

      end; (* initialise_poids_intermediaires *)

    procedure initialise_poids_intermediaires_aleatoirement;
      var l_indice_intermediaire, l_indice_entree: Integer;
      begin
        for l_indice_intermediaire := 1 to k_intermediaire_max do
          for l_indice_entree := 1 to k_entree_max do
            g_intermediaire[l_indice_intermediaire].poids[l_indice_entree] := Random;
      end; (* initialise_poids_intermediaires_aleatoirement *)

    procedure entraine_intermediaire(VAR pv_gagnant: Integer);
      var l_indice_entree: Integer;
          l_indice_intermediaire: Integer;
      begin
        (* -- calcule le gagnant *)
        propage_entree_vers_intermediaire(pv_gagnant);

        (* -- ajuste les poids du gagnant *)
        with g_intermediaire[pv_gagnant] do
          for l_indice_entree := 1 to k_entree_max do
            poids[l_indice_entree] := poids[l_indice_entree]
             + k_apprentissage_intermediaire * (g_entree[l_indice_entree] - poids[l_indice_entree]);
      end;

    var l_tous_classes_correctement: Boolean;
        l_table_gagnants: array[1..k_intermediaire_max] of real;
        l_somme_cosinus: real;
        l_indice_exemple, l_gagnant: Integer;
        l_indice_intermediaire: Integer;

    begin
      (* -- pour accelerer l'apprentissage:
      initialise_poids_intermediaires;
      *)
      initialise_poids_intermediaires_aleatoirement;

      repeat
        for l_indice_intermediaire := 1 to k_intermediaire_max do
          l_table_gagnants[l_indice_intermediaire] := 0;
  
        ClrScr;
        for l_indice_intermediaire := 1 to k_intermediaire_max do
          affiche_matrice(1, 1 + (l_indice_intermediaire - 1) * 6,
                          g_intermediaire[l_indice_intermediaire].poids);

        for l_indice_exemple := 1 to k_exemple_max do
        begin
          g_entree := vi_exemple[l_indice_exemple].entree;
          normalise_entree;
          entraine_intermediaire(l_gagnant);
          affiche_matrice(27, 1 + (l_gagnant - 1) * 6, vi_exemple[l_indice_exemple].entree);
          affiche_matrice(54, 1 + (l_gagnant - 1) * 6, g_intermediaire[l_gagnant].poids);

          l_table_gagnants[l_gagnant] := g_intermediaire[l_gagnant].activation;
        end;

        (* -- verifie que chaque intermedeiaire a ete choisi *)
        l_tous_classes_correctement := True;
        l_somme_cosinus := 0;
        for l_indice_intermediaire := 1 to k_intermediaire_max do
        begin
          if l_table_gagnants[l_indice_intermediaire] = 0
            then l_tous_classes_correctement := False
            else l_somme_cosinus := l_somme_cosinus + l_table_gagnants[l_indice_intermediaire];
        end;

        (* -- si tous les intermediaires ont ete choisis, on sort de la boucle *)
        (* -- et que chaque cosinus est environ 1*)
      until l_tous_classes_correctement
        and (Abs(l_somme_cosinus - k_intermediaire_max) < k_convergence_intermediaire);
      ReadLn;
    end; (* entraine_la_couche_intermediaire *)

  procedure entraine_la_couche_de_sortie;

    procedure initialise_poids_sortie;
      var l_indice_sortie, l_indice_intermediaire: Integer;
      begin
        for l_indice_sortie := 1 to k_sortie_max do
          for l_indice_intermediaire := 1 to k_intermediaire_max do
            g_sortie[l_indice_sortie].poids[l_indice_intermediaire] := Random;
      end; (* initialise_poids_sortie *)

    procedure entraine_sortie(VAR pv_a_converge: Boolean);
      var l_gagnant, l_indice_sortie: Integer;
          l_ajustement: Real;
      begin
        (* -- propage de l'entree vers la couche intermediaire *)
        propage_entree_vers_intermediaire(l_gagnant);

        (* -- l'intermediaire gagnant *)
        affiche_matrice(38, 1 + (l_gagnant - 1) * 6, g_intermediaire[l_gagnant].poids);
        (* -- les poids de sorttie avant ajustement *)
        affiche_poids_sorties(64, 0, l_gagnant);

        (* -- ajuste les poids de sortie connecte au gagnant *)
        for l_indice_sortie := 1 to k_sortie_max do
          with g_sortie[l_indice_sortie] do
          begin
            l_ajustement := (g_sortie[l_indice_sortie].sortie - poids[l_gagnant]);
            poids[l_gagnant] := poids[l_gagnant]
              + k_apprentissage_sortie * l_ajustement;
            
            if Abs(l_ajustement) > k_convergence_sortie
              then pv_a_converge := False;
          end;

        affiche_poids_sorties(72, 1, l_gagnant);

        if g_test
          then ReadLn;
      end; (* entraine_sortie *)

    var l_indice_exemple, l_indice_sortie: Integer;
        l_a_converge: Boolean;

    begin (* entraine la couche de sortie *)
      initialise_poids_sortie;

      repeat
        ClrScr;

        l_a_converge := True;

        for l_indice_exemple := 1 to k_exemple_max do
        begin
          (* -- soumet cet exemple *)
          g_entree := vi_exemple[l_indice_exemple].entree;
          for l_indice_sortie := 1 to k_sortie_max do
            g_sortie[l_indice_sortie].sortie := vi_exemple[l_indice_exemple].sortie[l_indice_sortie];

          affiche_matrice(1, 1 + (l_indice_exemple - 1) * 6, vi_exemple[l_indice_exemple].entree);
          affiche_sortie(27, l_indice_exemple);

          normalise_entree;
          entraine_sortie(l_a_converge);
        end;

        (* -- quitte lorsque l'ajustement des poids devient faible *)
      until l_a_converge;
      ReadLn;
    end; (* entraine_la_couche_de_sortie *)

  begin (* entraine reseau *)
    entraine_la_couche_intermediaire;
    entraine_la_couche_de_sortie;

    GotoXY(1, 25);
  end; (* entraine reseau *)
    
procedure verifie_les_exemples;
  var l_indice_exemple: Integer;
      l_gagnant, l_indice_sortie: Integer;
  begin
    for l_indice_exemple := 1 to k_exemple_max do
    begin
      (* -- soumet cet exemple *)
      g_entree := vi_exemple[l_indice_exemple].entree;

      ClrScr;
      affiche_matrice(1, 1 + (l_indice_exemple - 1) * 6, vi_exemple[l_indice_exemple].entree);
      (* -- uniquement pour l'affichage de mise en point *)
      for l_indice_sortie := 1 to k_sortie_max do
        g_sortie[l_indice_sortie].sortie := vi_exemple[l_indice_exemple].sortie[l_indice_sortie];
      affiche_sortie(27, l_indice_exemple);

      normalise_entree;
      (* -- propage de l'entree vers la couche intermediaire *)
      propage_entree_vers_intermediaire(l_gagnant);

      (* -- l'intermediaire gagnant *)
      affiche_matrice(38, 1 + (l_gagnant - 1) * 6, g_intermediaire[l_gagnant].poids);
      
      affiche_poids_sorties(64, 0, l_gagnant);
      
      (* -- les sorties trouvees *)
      for l_indice_sortie := 1 to k_sortie_max do
      begin
        GotoXY(72, 4 + (l_indice_sortie - 1)* 10 + l_gagnant);
        Write(g_sortie[l_indice_sortie].poids[l_gagnant]:5:2);
      end;
      ReadLn;
    end;
  end;

procedure utilise_reseau;
  var l_indice_essai: Integer;
      l_gagnant, l_indice_sortie: Integer;
  begin
    for l_indice_essai := 1 to k_essai_max do
    begin
      (* -- soumet cet exemple *)
      g_entree := vi_essai[l_indice_essai];

      ClrScr;
      affiche_matrice(1, 1, vi_essai[l_indice_essai]);
      normalise_entree;
      (* -- propage de l'entree vers la couche intermediaire *)
      propage_entree_vers_intermediaire(l_gagnant);

      (* -- l'intermediaire gagnant *)
      affiche_matrice(38, 1 + (l_gagnant - 1) * 6, g_intermediaire[l_gagnant].poids);

      affiche_poids_sorties(64, 0, l_gagnant);

      (* -- les sorties trouvees *)
      for l_indice_sortie := 1 to k_sortie_max do
      begin
        GotoXY(72, 4 + (l_indice_sortie - 1)* 10 + l_gagnant);
        Write(g_sortie[l_indice_sortie].poids[l_gagnant]:5:2);
      end;
      ReadLn;
    end;
  end;

var g_choix: Char;

procedure initialise;
  begin
    g_test := False;
  end;

begin
  initialise;

  repeat
    WriteLn;
    Write('Entraine, Verifie, Utilise, ');
    Write('Quitte ?');
    g_choix := ReadKey; WriteLn(g_choix);
    case g_choix of
      ' ': ClrScr;
      'E', 'e': entraine_reseau;
      'V', 'v': verifie_les_exemples;
      'U', 'u': utilise_reseau;
      't': g_test := NOT g_test;
    end;
  until g_choix in ['Q', 'q'];
end.