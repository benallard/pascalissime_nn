(* 001 neo31 *)
(* 21 jan 93 *)

(* -- neo cognitroon *)
(* -- entraine les 12 plans de la couche 1 et analyse un '2' *)

(*$r+*)
program reseau_neuronal_neocognitron;
uses crt;
const k_cote_plan_0 = 19;
type t_couche_0 = array [1..k_cote_plan_0, 1..k_cote_plan_0] of 0..1;

const k_cote_plan_1 = k_cote_plan_0 - 2;
      k_plan_1 = 12;
      k_poids_1 = 3;
type t_poids_1 = array[1..k_poids_1, 1..k_poids_1] of real;
     t_couche_1 = record
                    (* -- 12 plans, un pour chaque motif *)
                    plans_1: array[1..k_plan_1] of
                      record
                        (* -- contenant 17 x 17 neurones, mais qui ont les meme poids *)
                        (* -- 1 seule matrice de 3x3 et non pas 17x17 matrices de 3x3 *)
                        poids_1: t_poids_1;
                        poids_inhibe_1: real;

                        (* -- mais des sorties differentes *)
                        sortie_1: array [1..k_cote_plan_1, 1..k_cote_plan_1] of 0..1;
                      end;

                    (* -- un plan d'inhibition ayant des poids fixes *)
                    distance_1: t_poids_1;
                  end;
type t_motif = array[1..k_poids_1, 1..k_poids_1] of 0..1;
const k_motif_1: array[1..k_plan_1] of t_motif = 
        (((0,0,0),
          (1,1,1),
          (0,0,0)),
          
         ((0,0,1),
          (1,1,0),
          (0,0,0)),
          
         ((0,0,0),
          (0,1,1),
          (1,0,0)),
          
         ((0,0,1),
          (0,1,0),
          (1,0,0)),
          
         ((0,1,0),
          (0,1,0),
          (1,0,0)),
          
         ((0,0,1),
          (0,1,0),
          (0,1,0)),
          
         ((0,1,0),
          (0,1,0),
          (0,1,0)),
          
         ((1,0,0),
          (0,1,0),
          (0,1,0)),
          
         ((0,1,0),
          (0,1,0),
          (0,0,1)),
          
         ((1,0,0),
          (0,1,0),
          (0,0,1)),
          
         ((0,0,0),
          (1,1,0),
          (0,0,1)),
          
         ((1,0,0),
          (0,1,1),
          (0,0,0)));

const k_test_max = 9;
      k_test_1: array[1..k_test_max] of t_motif =
        (((0,0,0),
          (1,1,1),
          (0,0,0)),
          
         ((1,1,1),
          (0,0,0),
          (0,0,0)),
          
         ((1,0,0),
          (0,1,1),
          (0,0,0)),
          
         ((1,0,0),
          (1,1,1),
          (0,0,0)),
          
         ((1,1,0),
          (1,1,1),
          (0,0,0)),
          
         ((1,1,1),
          (1,1,1),
          (0,0,0)),
          
         ((1,1,1),
          (1,1,1),
          (1,0,0)),
          
         ((1,1,1),
          (1,1,1),
          (1,1,0)),
          
         ((1,0,1),
          (0,1,0),
          (0,0,0)));

      k_selectivite_1 = 1.7;
      k_apprentissage_1 = 10.0;
      k_cycles_apprentissage_1 = 200;

var g_choix: char;
    g_test: boolean;
    g_niveau: Integer;

    g_couche_0: t_couche_0;
    g_couche_1: t_couche_1;


procedure stoppe;
  var l_stop: Char;
  begin
    l_stop := ReadKey;
  end;

procedure go;

  procedure affiche_poids(p_colonne, p_ligne, p_plan: Integer);
    var l_j, l_i: Integer;
    begin
      with g_couche_1, plans_1[p_plan] do
      begin
        for l_i := 1 to k_poids_1 do
          for l_j := 1 to k_poids_1 do
          begin
            GotoXY(p_colonne + 4 + l_j * 8, p_ligne + l_i);
            Write(poids_1[l_i, l_j]: 8: 3);
          end;
  
        GotoXY(p_colonne + 4 + 8, p_ligne + 4);
        Write(poids_inhibe_1: 8: 3);
      end;
    end;

  procedure affiche_inhibition(p_colonne, p_ligne: Integer);
    var l_j, l_i: Integer;
    begin
      with g_couche_1 do
      begin
        for l_i := 1 to k_poids_1 do
          for l_j := 1 to k_poids_1 do
          begin
            GotoXY(p_colonne + 4 + l_j * 8, p_ligne + l_i);
            Write(distance_1[l_i, l_j]: 8: 3);
          end;
      end;
    end; 
  
  procedure affiche_0;
    var l_x, l_y: Integer;
    begin
      ClrScr;
      for l_y := 1 to k_cote_plan_0 do
      begin
        for l_x := 1 to k_cote_plan_0 do
          Write(g_couche_0[l_y, l_x]);
        WriteLn;
      end;
    end;

  procedure affiche_motif(p_colonne, p_ligne: Integer; p_motif: t_motif);
    var l_i, l_j: Integer;
    begin
      for l_i := 1 to k_poids_1 do
      begin
        GotoXY(p_colonne, p_ligne + l_i - 1);
        for l_j := 1 to k_poids_1 do
          Write(p_motif[l_i, l_j]);
      end;
    end;

  procedure affiche_partie_en_inverse(p_colonne, p_ligne: Integer);
    (* -- animation: affiche le rectangle d'analyse en video inverse *)
    var l_i, l_j: Integer;
    begin
      TextColor(Black); TextBackground(White);
      for l_i := 1 to k_poids_1 do
        for l_j := 1 to k_poids_1 do
        begin
          GotoXY(p_colonne + l_j - 1, p_ligne + l_i - 1);
          Write(g_couche_0[p_ligne + l_i - 1, p_colonne + l_j - 1]);
        end;
      TextColor(White); TextBackground(Black);
    end;

  procedure affiche_partie_en_normal(p_colonne, p_ligne: Integer);
    var l_i, l_j: Integer;
    begin
      for l_i := 1 to k_poids_1 do
        for l_j := 1 to k_poids_1 do
        begin
          GotoXY(p_colonne + l_j - 1, p_ligne + l_i - 1);
          Write(g_couche_0[p_ligne + l_i - 1, p_colonne + l_j - 1]);
        end;
    end;

  procedure initialise_les_poids_1;
    var l_plan: Integer;
        l_i, l_j: Integer;
        l_total: Real;
    begin
      with g_couche_1 do
      begin
        (* -- initialise a des petite valeurs distinctes, pour *)
        (* -- que la presentation des motifs fournisse un gagnant *)
        for l_plan := 1 to k_plan_1 do
          with plans_1[l_plan] do
          begin
            for l_j := 1 to k_poids_1 do
              for l_i := 1 to k_poids_1 do
                poids_1[l_j, l_i] := 0;
            poids_inhibe_1 := 0;
          end;

          distance_1[1,1] := 1;
          distance_1[1,3] := 1;
          distance_1[3,1] := 1;
          distance_1[3,3] := 1;
          distance_1[1,2] := 1.5;
          distance_1[2,1] := 1.5;
          distance_1[2,3] := 1.5;
          distance_1[3,2] := 1.5;
          distance_1[2,2] := 2;
          l_total := 0;
          for l_i := 1 to k_poids_1 do
            for l_j := 1 to k_poids_1 do
              l_total := l_total + Sqr(distance_1[l_i, l_j]);
          l_total := Sqrt(l_total);

          for l_i := 1 to k_poids_1 do
            for l_j := 1 to k_poids_1 do
              distance_1[l_i, l_j] := distance_1[l_i, l_j] / l_total;
      end;
    end;

  procedure ajuste_poids_1(p_plan_1: Integer);
    var l_i, l_j: Integer;
        l_total: Real;
        l_somme_inhibition: Real;
    begin
      with g_couche_1, plans_1[p_plan_1] do
      begin
        (* -- renforce les poids ayant une entree positive *)
        for l_i := 1 to k_poids_1 do
          for l_j := 1 to k_poids_1 do
          begin
            poids_1[l_i, l_j] := 
                poids_1[l_i, l_j]
                + k_apprentissage_1 * k_motif_1[p_plan_1, l_i, l_j]
                * distance_1[l_i, l_j];
          end;
        
        (* -- calcule le poids d'inhibition *)
        l_somme_inhibition := 0;
        for l_j := 1 to k_poids_1 do
          for l_i := 1 to k_poids_1 do
            l_somme_inhibition := l_somme_inhibition
                + k_motif_1[p_plan_1, l_i, l_j]
                * distance_1[l_i, l_j];
        l_somme_inhibition := Sqrt(l_somme_inhibition);

        poids_inhibe_1 := poids_inhibe_1 + k_apprentissage_1 * l_somme_inhibition;
      end;
    end;

  procedure test_apprentissage;
    (* -- analyse des reponse en fournissant quelques exemplaires *)
    var l_test: Integer;
        l_somme, l_somme_inhibition, l_sortie: Real;
        l_i, l_j: Integer;
    begin
      ClrScr;
      (* -- analyse le plan 1: motif horizontal *)
      affiche_motif(1, 1, k_motif_1[1]);
      for l_test := 1 to k_test_max do
      begin
        affiche_motif(1, 5, k_test_1[l_test]);

        with g_couche_1, plans_1[1] do
        begin
          l_somme := 0;
          for l_i := 1 to k_poids_1 do
            for l_j := 1 to k_poids_1 do
              l_somme := l_somme
                  + k_test_1[l_test, l_i, l_j] * poids_1[l_i, l_j];

          l_somme_inhibition := 0;
          for l_i := 1 to k_poids_1 do
            for l_j := 1 to k_poids_1 do
              l_somme_inhibition := l_somme_inhibition
                  + k_test_1[l_test, l_i, l_j]
                  * distance_1[l_i, l_j];
          l_somme_inhibition := Sqrt(l_somme_inhibition);

          l_sortie := (1 + l_somme)
                  / (1 + k_selectivite_1 / (1 + k_selectivite_1) * poids_inhibe_1 * l_somme_inhibition)
                  - 1;

          GotoXY(20, 4);
          Write('somme: ', l_somme:8:2, ', inhibition: ', poids_inhibe_1 * l_somme_inhibition: 8: 2,
                l_sortie: 8: 3);
        end;

        stoppe;
      end;
    end;

  procedure extrais_motifs_du_chiffre_deux;
    (* -- analyse un 2 en montrant les motifs reconnus *)

    procedure charge_0;
      var l_fichier_deux: Text;
          l_ligne: String;
          l_x, l_y: Integer;
      begin
        WriteLn('charge');
        Assign(l_fichier_deux, 'deux.pas');
        Reset(l_fichier_deux);

        FillChar(g_couche_0, SizeOf(t_couche_0), 0);

        for l_y := 1 to k_cote_plan_0 do
        begin
          if not Eof(l_fichier_deux)
            then begin
                ReadLn(l_fichier_deux, l_ligne);

                l_x := 1;
                while (l_x <= k_cote_plan_0) and (l_x <= Length(l_ligne)) do
                begin
                  if l_ligne[l_x] = 'x'
                    then begin
                        g_couche_0[l_y, l_x] := 1;
                      end;
                  
                  Inc(l_x);
                end;
              end;
        end;

        Close(l_fichier_deux);
      end; (* charge_0*)

    procedure filtre(p_plan_1, p_x, p_y: Integer);
      (* --  verifie si l'image contient cet exemplaire en p_x, p_y *)
      var l_i, l_j: Integer;
          l_somme: Real;
          l_somme_inhibition: Real;
          l_valeur: Real;
      begin
        with g_couche_1, plans_1[p_plan_1] do
        begin
          l_somme := 0;
          for l_i := 1 to k_poids_1 do
            for l_j := 1 to k_poids_1 do
              l_somme := l_somme
                  + g_couche_0[p_y + l_i - 1, p_x + l_j - 1] * poids_1[l_i, l_j];

          l_somme_inhibition := 0;
          for l_i := 1 to k_poids_1 do
            for l_j := 1 to k_poids_1 do
              l_somme_inhibition := l_somme_inhibition
                  + g_couche_0[p_x + l_i - 1, p_y + l_j - 1]
                  * distance_1[l_i, l_j];
          l_somme_inhibition := poids_inhibe_1 * Sqrt(l_somme_inhibition);

          l_valeur := (1 + l_somme) / (1 + k_selectivite_1 / (1 + k_selectivite_1)
              * l_somme_inhibition) - 1;

          if l_valeur> 0
            then l_valeur := k_selectivite_1 * l_valeur
            else l_valeur := 0;

          GotoXY(40 + p_x + l_j - 1, p_y + l_i - 1);
          if l_valeur > 0
            then Write(1)
            else Write(0);  
        end;
      end;

    var l_plan_1: Integer;
        l_x, l_y: Integer;

    begin (* extrait 2 *)
      charge_0;
      affiche_0;
      stoppe;

      for l_plan_1 := 1 to k_plan_1 do
      begin
        GotoXY(25, 1); Write(l_plan_1);
        affiche_motif(25, 3, k_motif_1[l_plan_1]);

        for l_y := 1 to k_cote_plan_1 do
          for l_x := 1 to k_cote_plan_1 do
          begin
           affiche_partie_en_inverse(l_x, l_y);
           filtre(l_plan_1, l_x, l_y);
           affiche_partie_en_normal(l_x, l_y);
          end;

        stoppe;
      end;
    end; (* extrait 2 *)

  var l_cycle, l_plan: Integer;

  begin (* go *)
    initialise_les_poids_1;

    (* -- presente les 12 motifs et corrige les poids pour que *)
    (* -- chaque plan sache reconnaitre son motif *)
    ClrScr;
    for l_plan := 1 to k_plan_1 do
    begin
      for l_cycle := 1 to k_cycles_apprentissage_1 do
        ajuste_poids_1(l_plan);

      affiche_motif(1, 2, k_motif_1[l_plan]);
      affiche_poids(1, 5, l_plan);
    end;

    affiche_inhibition(1, 10);
    WriteLn; stoppe;

    test_apprentissage;

    extrais_motifs_du_chiffre_deux;
  end; (* go *)

procedure initialise;
  begin
  end;

begin (* main *)
  ClrScr;
  initialise;
  repeat
    WriteLn;
    Write('Go, Quitte');
    g_choix := ReadKey; Write(g_choix); WriteLn;
    case g_choix of
      'g': go;
    end;
  until g_choix = 'q';
end. (* main *)