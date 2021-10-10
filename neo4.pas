(* 001 neo4 *)
(* 21 jan 93 *)

(* -- neo cognitroon *)
(* -- entraine les 12 plans U1 et analyse un 2 *)
(* -- entraine 1 plan /- du niveau 2 et analyse correctement '2' *)

(*$r+*)
program reseau_neuronal_neocognitron;
uses crt;
const k_S_0 = 19;
      k_cote_S_0 = 19;
      k_plan_1 = 12;

const k_motif_1_max = 12;
      k_cote_motif_1 = 3;
      k_poids_1 = 3;

      k_selectivite_1 = 1.7;
      k_selectivite_2 = 0.8;
      k_selectivite_3 = 1.5;
      k_selectivite_4 = 1.0;

      k_apprentissage_1 = 10.0;
      k_cycles_apprentissage_1 = 200;

type t_couche_S_0 = array[1..k_S_0, 1..k_S_0] of 0..1;

     t_motif_1 = array[1..k_cote_motif_1, 1..k_cote_motif_1] of 0..1;

     t_poids_1 = array[1..k_cote_motif_1, 1..k_cote_motif_1] of real;
     t_couche_S_1 = record
                      (* -- 12 plans, un pour chaque motif *)
                      plans_1: array [1..k_plan_1] of
                        record
                          (* -- pour la mise au point, stocke aussi le motif du plan *)
                          motif_1: t_motif_1;
                          (* -- contenant 19 x 19 neurones, mais qui ont les meme poids *)
                          (* -- 1 seule matrice de 3 x 3 et non pas 19 x 19 matrices de 3 x 3 *)
                          poids_1: t_poids_1;
                          poids_inhibe_1: Real;

                          (* -- mais les sorties sont differentes *)
                          sortie_1 : array[1..k_S_0, 1..k_S_0] of real;
                        end;
                      
                      (* -- un plan d'inhibition ayant des poids fixes *)
                      poids_plan_inhibe_1 : t_poids_1;
                    end;

const k_plan_2 = 5;
      k_poids_2 = 3;
type t_poids_2 = array[1..k_plan_1, 1..k_poids_2, 1..k_poids_2] of real;
     t_couche_S_2 = record
                      (* -- 5 plans *)
                      plans_2: array [1..k_plan_2] of
                        record
                          (* -- contenant 19x19 neurones, mais qui ont les meme poids *)
                          (* -- une seule matrice de 3x3 et non pas 19x19 matruces de 3x3 *)
                          poids_2: t_poids_2;
                          poids_inhibe_2: Real;

                          (* -- mais des sorties differentes *)
                          sortie_2: array[1..k_S_0, 1..k_S_0] of Real;
                        end;

                      (* -- un plan d'inhibition ayant des poids fixes *)
                      poids_plan_inhibe_2 : t_poids_1;
                    end;

var g_choix: Char;
    g_couche_S_0: t_couche_S_0;
    g_couche_S_1: t_couche_S_1;
    g_couche_S_2: t_couche_S_2;

    g_test: Boolean;
    g_niveau: Integer;

procedure stoppe;
  var l_stop: Char;
  begin
    l_stop := ReadKey;
  end;

procedure stoppe_niveau(p_niveau: Integer);
  var l_stop: Char;
  begin
    if p_niveau >= g_niveau
      then l_stop := ReadKey;
  end;

procedure go;
  var l_fichier_motifs: Text;

  procedure affiche_poids(p_x, p_y, p_plan: Integer);
    var l_x, l_y: Integer;
    begin
      with g_couche_S_1, plans_1[p_plan] do
      begin
        for l_y := 1 to k_cote_motif_1 do
          for l_x := 1 to k_cote_motif_1 do
          begin
            GotoXY(p_x+4+l_x*8, p_y+l_y);
            Write(poids_1[l_y, l_x]:8:3);
          end;

        GotoXY(p_x+4+8, p_y+4);
        Write(poids_inhibe_1:8:3);
      end;
    end;

  procedure affiche_inhibition(p_x, p_y: Integer);
    var l_x, l_y: Integer;
    begin
      with g_couche_S_1 do
      begin
        for l_y := 1 to k_cote_motif_1 do
          for l_x := 1 to k_cote_motif_1 do
            begin
              GotoXY(p_x+4+l_x*8, p_y+l_y);
              Write(poids_plan_inhibe_1[l_y, l_x]:8:3);
            end;
      end;
    end;

  procedure charge_motif(p_taille: Integer);
    var l_ligne: String;
        l_x, l_y: Integer;
    begin
      FillChar(g_couche_S_0, SizeOf(g_couche_S_0), 0);

      for l_y := 1 to p_taille do
      begin
        if not Eof(l_fichier_motifs)
          then begin
              ReadLn(l_fichier_motifs, l_ligne);

              l_x := 1;
              while (l_x <= p_taille) and (l_x <= Length(l_ligne)) do
                begin
                  if l_ligne[l_x] = 'x'
                    then begin
                        g_couche_S_0[l_y, l_x] := 1;
                      end;

                  Inc(l_x);
                end;
            end;
      end;

      if not Eof(l_fichier_motifs)
        then ReadLn(l_fichier_motifs, l_ligne);
    end;

  procedure affiche_motif_1(p_x, p_y: Integer; p_motif_1: t_motif_1);
    var l_x, l_y : Integer;
    begin
      for l_y := 1 to k_cote_motif_1 do
      begin
        GotoXY(p_x, p_y+l_y - 1);
        For l_x := 1 to k_cote_motif_1 do
          if p_motif_1[l_y, l_x] = 0
            then Write('.')
            else Write('X');
      end;
    end;

  procedure affiche_couche_0(p_x, p_y: Integer; p_taille: Integer);
    var l_x, l_y: Integer;
    begin
      for l_y := 1 to p_taille do
      begin
        GotoXY(p_x, p_y+l_y-1);
        for l_x := 1 to p_taille do
          if g_couche_S_0[l_y, l_x] = 0
            then Write('.')
            else Write('X');
      end;
    end;

  procedure entraine_S_1;
    var l_cycle, l_plan: Integer;

    procedure initialise_les_poids_1;
      var l_plan, l_x, l_y: Integer;
          l_total: Real;
      begin
        with g_couche_S_1 do
        begin
          (* -- initialise a de petites valeurs distinctes, pour *)
          (* -- que la presentation des motifs fournisss un gagnant *)
          for l_plan := 1 to k_plan_1 do
            with plans_1[l_plan] do
            begin
              for l_y := 1 to k_cote_motif_1 do
                for l_x := 1 to k_cote_motif_1 do
                  poids_1[l_y, l_x] := 0;
              poids_inhibe_1 := 0;
            end;

          poids_plan_inhibe_1[1,1] := 1;
          poids_plan_inhibe_1[1,3] := 1;
          poids_plan_inhibe_1[3,1] := 1;
          poids_plan_inhibe_1[3,3] := 1;
          poids_plan_inhibe_1[1,2] := 1.5;
          poids_plan_inhibe_1[2,1] := 1.5;
          poids_plan_inhibe_1[2,3] := 1.5;
          poids_plan_inhibe_1[3,2] := 1.5;
          poids_plan_inhibe_1[2,2] := 2;
          l_total := 0;
          for l_y := 1 to k_cote_motif_1 do
            for l_x := 1 to k_cote_motif_1 do
              l_total := l_total + Sqr(poids_plan_inhibe_1[l_y, l_x]);
          l_total := Sqrt(l_total);

          for l_y := 1 to k_cote_motif_1 do
            for l_x := 1 to k_cote_motif_1 do
              poids_plan_inhibe_1[l_y, l_x] := poids_plan_inhibe_1[l_y, l_x] / l_total;
        end;
      end;

    procedure copie_motif;
      var l_x, l_y: Integer;
      begin
        (* -- memorise pour la mise au point *)
        for l_y := 1 to k_cote_motif_1 do
          for l_x := 1 to k_cote_motif_1 do
            g_couche_S_1.plans_1[l_plan].motif_1[l_y, l_x] := g_couche_S_0[l_y, l_x];

      end;

    procedure ajuste_poids_1(p_plan: Integer);
      var l_x, l_y: Integer;
          l_total: Real;
          l_somme_inhibition: Real;
      begin
        with g_couche_S_1, plans_1[p_plan] do
        begin
          (* -- renforce les poids ayant une entree positive *)
          for l_y := 1 to k_cote_motif_1 do
            for l_x := 1 to k_cote_motif_1 do
            begin
              poids_1[l_y, l_x] :=
                poids_1[l_y, l_x]
                  + k_apprentissage_1 * g_couche_S_0[l_y, l_x]
                    * poids_plan_inhibe_1[l_y, l_x];
            end;

          (* -- calcule le poids d'inhibition *)
          l_somme_inhibition := 0;
          for l_y := 1 to k_cote_motif_1 do
            for l_x := 1 to k_cote_motif_1 do
              l_somme_inhibition := l_somme_inhibition
                + g_couche_S_0[l_y, l_x]
                  * poids_plan_inhibe_1[l_y, l_x];

          l_somme_inhibition := Sqrt(l_somme_inhibition);
          poids_inhibe_1 := poids_inhibe_1 + k_apprentissage_1 * l_somme_inhibition;
        end;
      end;
    
    begin (* entraine_S_1*)
      Assign(l_fichier_motifs, 'motif1.pas');
      Reset(l_fichier_motifs);

      (* -- mets des veleurs dans les poids des plans *)
      initialise_les_poids_1;

      (* -- presente les 12 motifs et corrigg les poids pour que *)
      (* --  chaque plan sache reconnaitre son motif *)
      ClrScr;
      for l_plan := 1 to k_plan_1 do
      begin
        charge_motif(k_cote_motif_1);
        copie_motif;
        affiche_couche_0(1, 1, k_cote_motif_1);

        for l_cycle := 1 to k_cycles_apprentissage_1 do
          ajuste_poids_1(l_plan);
      end;

      Close(l_fichier_motifs);
    end; (* entraine_S_1 *)

  procedure entraine_s_2;
    const k_cote_motif_2 = 10;

    procedure initialise_les_poids_2;
      var l_plan_1, l_plan_2, l_x, l_y: Integer;
          l_total: Real;
      begin
        with g_couche_S_2 do
        begin
          for l_plan_2 := 1 to k_plan_2 do
            with plans_2[l_plan_2] do
            begin
              for l_plan_1 := 1 to k_plan_1 do
                for l_y := 1 to k_cote_motif_1 do
                  for l_x := 1 to k_cote_motif_1 do
                    poids_2[l_plan_1, l_y, l_x] := 0;
              poids_inhibe_2 := 0;
            end;
          
          poids_plan_inhibe_2[1, 1] := 1;
          poids_plan_inhibe_2[1, 3] := 1;
          poids_plan_inhibe_2[3, 1] := 1;
          poids_plan_inhibe_2[3, 3] := 1;
          poids_plan_inhibe_2[1, 2] := 1.5;
          poids_plan_inhibe_2[2, 1] := 1.5;
          poids_plan_inhibe_2[2, 3] := 1.5;
          poids_plan_inhibe_2[3, 2] := 1.5;
          poids_plan_inhibe_2[2, 2] := 2;
          l_total := 0;
          for l_y := 1 to k_poids_2 do
            for l_x := 1 to k_poids_2 do
              l_total := l_total + Sqr(poids_plan_inhibe_2[l_y, l_x]);
          l_total := Sqrt(l_total);

          for l_y := 1 to k_poids_2 do
            for l_x := 1 to k_poids_2 do
              poids_plan_inhibe_2[l_y, l_x] := poids_plan_inhibe_2[l_y, l_x] / l_total;
        end;
      end;

    procedure extrais_1;
      var l_plan_1, l_x, l_y: Integer;

      procedure filtre(p_plan, p_x, p_y: Integer);
        (* -- verifie si l'image comporte cet exemplaire en p_x, p_y *)
        var l_x_1, l_y_1: Integer;
            l_somme: Real;
            l_somme_inhibition: Real;
            l_valeur: Real;
        begin
          with g_couche_S_1, plans_1[p_plan] do
          begin
            l_somme := 0;
            for l_y_1 := 1 to k_cote_motif_1 do
              for l_x_1 := 1 to k_cote_motif_1 do
                l_somme := l_somme
                  + g_couche_S_0[p_y + l_y_1 - 1, p_x + l_x_1 - 1] * poids_1[l_y_1, l_x_1];
                
            l_somme_inhibition := 0;
            for l_y_1 := 1 to k_cote_motif_1 do
              for l_x_1 := 1 to k_cote_motif_1 do
                l_somme_inhibition := l_somme_inhibition
                  + g_couche_S_0[p_y + l_y_1 - 1, p_x + l_x_1 - 1]
                  * poids_plan_inhibe_1[l_y_1, l_x_1];
            l_somme_inhibition := poids_inhibe_1 * Sqrt(l_somme_inhibition);

            l_valeur := (1 + l_somme) / (1 + k_selectivite_1 / (1+k_selectivite_1)
              * l_somme_inhibition) - 1;

            if l_valeur > 0
              then l_valeur := k_selectivite_1 * l_valeur
              else l_valeur := 0;

            GotoXY(40 + p_x + (p_plan - 1) div 3 * 8, 3 + p_y + ((p_plan - 1) mod 3) * 8);
            if l_valeur > 0
              then begin
                  Write('o');
                  sortie_1[p_x, p_y] := l_valeur;
                end
              else begin
                  Write('-');
                  sortie_1[p_y, p_x] := 0;
                end;
          end;
        end;

      begin (* extrais_1*)
        for l_plan_1 := 1 to k_plan_1 do
        begin
          affiche_motif_1(41 + (l_plan_1 - 1) div 3 * 8, 1 + ((l_plan_1 - 1) mod 3) * 8,
            g_couche_S_1.plans_1[l_plan_1].motif_1);

          for l_y := 1 to k_cote_motif_2 - 5 do
            for l_x := 1 to k_cote_motif_2 - 5 do
              filtre(l_plan_1, l_x, l_y);
        end;
      end;

    procedure ajuste_poids_2(p_plan_2: Integer);
      var l_plan_1, l_x, l_y: Integer;
          l_total: Real;
          l_somme_inhibition: Real;
      begin
        with g_couche_S_2, plans_2[p_plan_2] do
        begin
          (* -- renforce les poids ayant une entree positive *)
          for l_plan_1 := 1 to k_plan_1 do
            for l_y := 1 to k_poids_2 do
              for l_x := 1 to k_poids_2 do
              begin
                poids_2[l_plan_1, l_y, l_x] := 
                  poids_2[l_plan_1, l_y, l_x]
                    + k_apprentissage_1
                      * g_couche_S_1.plans_1[l_plan_1].sortie_1[l_y, l_x]
                      * poids_plan_inhibe_2[l_y, l_x];
              end;
          
          (* -- calcule le poids d'inhibition *)
          l_somme_inhibition := 0;
          for l_plan_1 := 1 to k_plan_1 do
            for l_y := 1 to k_poids_2 do
              for l_x := 1 to k_poids_2 do
                l_somme_inhibition := l_somme_inhibition
                  + g_couche_S_1.plans_1[l_plan_1].sortie_1[l_y, l_x]
                    * poids_plan_inhibe_2[l_y, l_x];

          l_somme_inhibition := Sqrt(l_somme_inhibition);
          poids_inhibe_2 := poids_inhibe_2 + k_apprentissage_1 * l_somme_inhibition;
        end;
      end;

    procedure affiche_poids_2;
      var l_plan_1, l_y, l_x: Integer;
      begin
        for l_plan_1 := 1 to k_plan_1 do
        begin
          GotoXY(1, 20); Write(l_plan_1);
          for l_y := 1 to k_poids_2 do
          begin
            GotoXY(1, 20+l_y);
            for l_x := 1 to k_poids_2 do
              Write(g_couche_S_2.plans_2[1].poids_2[l_plan_1, l_y, l_x]: 8 : 3);
          end;
          stoppe;
        end;
      end;
    
    var l_plan_2: Integer;

    begin (* entraine_S_2 *)
      Assign(l_fichier_motifs, 'motifs2.pas');
      Reset(l_fichier_motifs);
      initialise_les_poids_2;

      for l_plan_2 := 1 to 1 do
      begin
        charge_motif(k_cote_motif_2);
        affiche_couche_0(1, 1, k_cote_motif_2);
        extrais_1;
        ajuste_poids_2(l_plan_2);
        stoppe;
      end;

      Close(l_fichier_motifs);
    end;

  procedure analyse_chiffre;

    procedure charge_S_0;
      var g_fichier_dessin: file of t_couche_S_0;
      begin
        WriteLn('charge');
        Assign(g_fichier_dessin, 'u0.2');
        Reset(g_fichier_dessin);
        Read(g_fichier_dessin, g_couche_S_0);
        Close(g_fichier_dessin);
      end;

    procedure affiche_S_0;
      var l_x, l_y: Integer;
      begin
        ClrScr;
        for l_y := 1 to k_cote_S_0 do
        begin
          for l_x := 1 to k_cote_S_0 do
            Write(g_couche_S_0[l_y, l_x]);
          WriteLn;
        end;
      end;

    procedure affiche_partie_0_en_inverse(p_x, p_y, p_taille: Integer);
      var l_x, l_y: Integer;
      begin
        TextColor(Black); TextBackground(White);
        for l_y := 1 to p_taille do
        begin
          GotoXY(p_x, p_y + l_y - 1);
          for l_x := 1 to p_taille do
            Write(g_couche_S_0[p_y + l_y - 1, p_x + l_x - 1]);
        end;
        TextColor(White); TextBackground(Black);
      end;

    procedure affiche_partie_0_en_normal(p_x, p_y, p_taille: Integer);
      var l_x, l_y: Integer;
      begin
        for l_y := 1 to p_taille do
        begin
          GotoXY(p_x, p_y + l_y - 1);
          for l_x := 1 to p_taille do
            Write(g_couche_S_0[p_y + l_y - 1, p_x + l_x - 1]);
        end;
      end;

    procedure extrais_1;
      var l_plan_1: Integer;
          l_x, l_y: Integer;

      procedure filtre_1(p_plan, p_x, p_y: Integer);
        (* -- verifie si l'image comporte cet examplaire en p_x, p_y *)
        var l_x, l_y: Integer;
            l_somme: Real;
            l_somme_inhibition: Real;
            l_valeur: Real;
        begin
          with g_couche_S_1, plans_1[p_plan] do
          begin
            l_somme := 0;
            for l_y := 1 to k_cote_motif_1 do
              for l_x := 1 to k_cote_motif_1 do
                l_somme := l_somme
                  + g_couche_S_0[p_y + l_y - 1, p_x + l_x - 1] * poids_1[l_y, l_x];

            l_somme_inhibition := 0;
            for l_y := 1 to k_cote_motif_1 do
              for l_x := 1 to k_cote_motif_1 do
                l_somme_inhibition := l_somme_inhibition
                  + g_couche_S_0[p_y + l_y - 1, p_x + l_x - 1]
                  * poids_plan_inhibe_1[l_y, l_x];
            l_somme_inhibition := poids_inhibe_1 * Sqrt(l_somme_inhibition);

            l_valeur := (1 + l_somme) / (1 + k_selectivite_1 / (1 + k_selectivite_1)
              * l_somme_inhibition) - 1;

            if l_valeur > 0
              then l_valeur := k_selectivite_1 * l_valeur
              else l_valeur := 0;

            GotoXY(40 + p_x + l_x - 1, p_y + l_y - 1);

            if l_valeur > 0
              then begin
                  Write(1);
                  sortie_1[p_y, p_x] := l_valeur;
                end
              else begin
                  Write(0);
                  sortie_1[p_y, p_x] := 0;
                end;
          end;
        end;
      
      begin (* extrais_1 *)
        for l_plan_1 := 1 to k_plan_1 do
        begin
          GotoXY(25, 1); Write(l_plan_1);
          affiche_motif_1(25, 3, g_couche_S_1.plans_1[l_plan_1].motif_1);

          for l_y := 1 to k_S_0 - 2 do
            for l_x := 1 to k_S_0 - 2 do
              begin
                filtre_1(l_plan_1, l_x, l_y);
              end;
        end;
      end;

    procedure extrais_2;
      var l_plan_1, l_plan_2: Integer;
          l_x, l_y: Integer;

        procedure filtre_2(p_plan, p_x, p_y: Integer);
          (* -- verifie si l'image comport cet exemplaire en p_x, p_y *)
          var l_plan_1, l_x, l_y: Integer;
              l_somme: Real;
              l_somme_inhibition: Real;
              l_valeur: Real;
          begin
            with g_couche_S_2, plans_2[p_plan] do
            begin
              l_somme := 0;
              GotoXY(1, 24); ClrEol;

              for l_plan_1 := 1 to k_plan_1 do
                for l_y := 1 to k_poids_2 do
                  for l_x := 1 to k_poids_2 do
                    l_somme := l_somme
                      + g_couche_S_1.plans_1[l_plan_1].sortie_1[p_y + l_y - 1, p_x + l_x - 1]
                        * g_poids_2[l_plan_1, l_y, l_x];

              l_somme_inhibition := 0;
              for l_plan_1 := 1 to k_plan_1 do
                for l_y := 1 to k_poids_2 do
                  for l_x := 1 to k_poids_2 do
                    l_somme_inhibition := l_somme_inhibition
                      + g_couche_S_1.plans_1[l_plan_1].sortie_1[p_y + l_y - 1, p_x + l_x - 1]
                      * poids_plan_inhibe_2[l_y, l_x];
              l_somme_inhibition := poids_inhibe_2 * Sqrt(l_somme_inhibition);

              l_valeur := (1 + l_somme) / (1 + k_selectivite_2 / (1 + k_selectivite_2)
                * l_somme_inhibition) - 1;

              GotoXY(1, 25); Write(l_somme : 8 : 3, l_somme_inhibition : 8 : 3, l_valeur : 8 : 3);

              GotoXY(63 + p_x - 1, p_y);
              if l_valeur > 0
                then begin
                    Write('Z');
                    sortie_2[p_y, p_x] := l_valeur * k_selectivite_2;
                  end
                else begin
                    Write(',');
                    sortie_2[p_y, p_x] := 0;
                  end;
            end;
          end;

        procedure affiche_sortie_1(p_plan_1: Integer);
          var l_x, l_y: Integer;
          begin
            with g_couche_S_1.plans_1[p_plan_1] do
              for l_y := 1 to 5 do
                for l_x := 1 to 8 do
                begin
                  GotoXY(20 + l_x + (p_plan_1 - 1) div 3 * 11,
                    3 + l_y + ((p_plan_1 - 1) mod 3) * 8);
                  if sortie_1[l_y, l_x] > 0
                    then Write('o')
                    else Write('-');
                end;
          end;

        procedure affiche_sortie_2(p_plan_2: Integer);
          var l_x, l_y: Integer;
          begin
            with g_couche_S_2.plans_2[p_plan_2] do
              for l_y := 1 to k_S_0 - 4 do
              begin
                GotoXY(63, l_y);
                for l_x := 1 to k_S_0 - 4 do
                begin
                  if sortie_12[l_y, l_x] > 0
                    then Write('M')
                    else Write('+');
                end;
              end;
          end;


      begin (* extrais_2 *)
        
      end;

    begin (* analyse_chiffre *)
      
    end;

  begin (* go *)
    
  end;

begin
end.