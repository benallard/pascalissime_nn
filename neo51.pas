(* 001 neo51 *)
(* 21 jan 93 *)

(* -- neo cognitroon *)
(* -- entraine les 12 plans U1 et analyse un 2 *)
(* -- entraine 1 plan /- du niveau 2 et analyse correctement '2' *)

(* -- passe en graphique *)

(*$r+*)
program reseau_neuronal_neocognitron;
uses Crt, ptcGraph;

const k_cote_plan_0 = 19;
type t_motif_0 = ARRAY[1..k_cote_plan_0, 1..k_cote_plan_0] of 0..1;
     t_couche_0 = record
                    motif_0: t_motif_0;
                    sortie_0: array[1..k_cote_plan_0, 1..k_cote_plan_0] of real;
                  end;
     t_pt_couche_0 = ^t_couche_0;

const k_plan_1 = 12;
      k_cote_plan_1 = 17;
      k_poids_1 = 13;
      k_cote_motif_1 = 3;
type t_motif_1 = array[1..k_cote_motif_1, 1..k_cote_motif_1] of 0..1;
     t_poids_1 = array[1..k_cote_motif_1, 1..k_cote_motif_1] of real;
     t_couche_1 = record
                    (* -- 12 plans, un pour chaque motifs *)
                    plans_1: array[1..k_plan_1] of
                      record
                          (* -- pour la mise au point, stocke aussi le motif du plan *)
                          motif_1: t_motif_1;

                          (* -- contenant 19 x 19 neurones, mais qui ont les meme poids *)
                          (* -- 1 seule matrice de 3 x 3 et non pas 19 x 19 matrices de 3 x 3 *)
                          poids_1: t_poids_1;
                          poids_inhibe_1: Real;

                          (* -- mais les sorties sont differentes *)
                          sortie_1 : array[1..k_cote_plan_1, 1..k_cote_plan_1] of real;
                        end;
                      
                      (* -- un plan d'inhibition ayant des poids fixes *)
                      poids_plan_inhibe_1 : t_poids_1;
                    end;
     t_pt_couche_1 = ^t_couche_1;

const k_plan_2 = 5; (* 30; *)
      k_cote_plan_2 = 15;
      k_poids_2 = 3;
      k_cote_motif_2 = 10;
type t_motif_2 = array[1..k_cote_motif_2, 1..k_cote_motif_2] of 0..1;
     t_poids_2 = array[1..k_plan_1, 1..k_poids_2, 1..k_poids_2] of real;
     t_couche_2 = record
                    plans_2: array[1..k_plan_2] of
                      record
                          motif_2: t_motif_2;
                          poids_2: t_poids_2;
                          poids_inhibe_2: Real;

                          sortie_2: array[1..k_cote_plan_2, 1..k_cote_plan_2] of real;
                        end;
                    
                    (* -- un plan d'inhibition ayant des poids fixes *)
                    poids_plan_inhibe_2: t_poids_1;
                  end;
     t_pt_couche_2 = ^t_couche_2;

const k_plan_3 = 4;
      k_cote_plan_3 = 13;
      k_poids_3 = 3;
      k_cote_motif_3 = 15;
type t_motif_3 = array[1..k_cote_motif_3, 1..k_cote_motif_3] of 0..1;
     t_poids_3 = array[1..k_plan_2, 1..k_poids_3, 1..k_poids_3] of real;
     t_couche_3 = record
                    plans_3: array[1..k_plan_3] of
                      record
                          motif_3: t_motif_3;

                          poids_3: t_poids_3;
                          poids_inhibe_3: Real;

                          sortie_3: array[1..k_cote_plan_3, 1..k_cote_plan_3] of real;
                        end;

                    (* -- un plan d'inhibition ayant des poids fixes *)
                    poids_plan_inhibe_3: t_poids_1;
                  end;
      t_pt_couche_3 = ^t_couche_3;

const k_plan_4 = 16;
      k_cote_plan_4 = 9;
      k_poids_4 = 5;
      k_cote_motif_4 = 19;
type t_motif_4 = array[1..k_cote_motif_4, 1..k_cote_motif_4] of 0..1;
     t_poids_4 = array[1..k_plan_3, 1..k_poids_4, 1..k_poids_4] of real;
     t_couche_4 = record
                    plans_4: array[1..k_plan_4] of
                      record
                          motif_4: t_motif_4;

                          poids_4: t_poids_4;
                          poids_inhibe_4: Real;

                          sortie_4: array[1..k_cote_plan_4, 1..k_cote_plan_4] of real;
                      end;

                    (* -- un plan d'inhibition ayant des poids fixes *)
                    poids_plan_inhibe_4: array[1..k_poids_4, 1..k_poids_4] of real;
                  end;
      t_pt_couche_4 = ^t_couche_4;
const k_x_motif_1 = k_cote_plan_0 + 17;
      k_x_sortie_1 = k_x_motif_1 + k_cote_motif_1 + 7;
      k_y_1 = k_cote_plan_1 + 7;

      k_x_motif_2 = k_x_sortie_1 + k_cote_plan_1 + 17;
      k_x_sortie_2 = k_x_motif_2 + k_cote_motif_2 + 7;
      k_y_2 = k_cote_plan_2 + 7;

      k_x_motif_3 = k_x_sortie_2 + k_cote_plan_2 + 17;
      k_x_sortie_3 = k_x_motif_3 + k_cote_motif_3 + 7;
      k_y_3 = k_cote_motif_3 + 7;

      k_rose = lightblue;
      k_rouge = lightred;
{
  const k_selectivite_1 = 1.7;
        k_selectivite_2 = 4.0;
        k_selectivite_3 = 1.5;
        k_selectivite_4 = 1.0;
}
const k_selectivite_1 = 1.7;
      k_selectivite_2 = 0.7; (* 8 *)
      k_selectivite_3 = 0.3;

      k_apprentissage_1 = 10.0;
      k_cycles_apprentissage_1 = 200;

var g_choix: Char;
    g_test: Boolean;
    g_en_mode_graphique: Boolean;
    g_niveau: Integer;

    g_pt_couche_0: t_pt_couche_0;
    g_pt_couche_1: t_pt_couche_1;
    g_pt_couche_2: t_pt_couche_2;
    g_pt_couche_3: t_pt_couche_3;
    g_pt_couche_4: t_pt_couche_4;

(* -- mise au point *)

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

procedure sonne;
  begin
    Write(Chr(7));
  end;

procedure initialise_mode_graphique;
  var l_pilote, l_mode_graphique: Integer;
  begin
    l_pilote := Detect;
    InitGraph(l_pilote, l_mode_graphique, '');

    g_en_mode_graphique := True;
  end;

procedure termine_mode_graphique;
  begin
    sonne; stoppe;
    CloseGraph;

    g_en_mode_graphique := False;
  end;

procedure go;
  var l_fichier_motifs: Text;

  procedure charge_motif(p_taille: Integer; VAR pv_motif);
    var l_ligne: String;
        l_x, l_y: Integer;
        lpv_motif: array[0..1000] of 0..1 absolute pv_motif;
    begin
      FillChar(g_pt_couche_0^, SizeOf(t_couche_0), 0);

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
                  g_pt_couche_0^.motif_0[l_y, l_x] := 1;
                  g_pt_couche_0^.sortie_0[l_y, l_x] := 1.0;

                  (* -- le copie dans le motif de la couche pour la mise au point *)
                  if p_taille <> k_cote_plan_0
                    then lpv_motif[(l_y - 1) * p_taille + l_x - 1] := 1;
                end;

              Inc(l_x);
            end;
          end;
        end;
      
      if not Eof(l_fichier_motifs)
        then ReadLn(l_fichier_motifs, l_ligne);
    end; (* charge_motif *)

  procedure dessine_motif(p_x, p_y, p_taille: Integer; VAR pv_motif);
    var l_x, l_y: Integer;
        lpv_motif: array[0..1000] of 0..1 absolute pv_motif;
    begin
      rectangle(p_x - 1, p_y - 1, p_x + p_taille + 1, p_y + p_taille + 1);
      for l_y := 1 to p_taille do
        for l_x := 1 to p_taille do
          if lpv_motif[(l_y - 1) * p_taille + l_x - 1] = 0
            then putpixel(p_x + l_x - 1, p_y + l_y - 1, k_rose)
            else putpixel(p_x + l_x - 1, p_y + l_y - 1, white);
    end; (* dessine_motif *)

  procedure affiche_motif(p_x, p_y, p_taille: Integer; VAR pv_motif);
    var l_x, l_y: Integer;
        lpv_motif: array[0..1000] of 0..1 absolute pv_motif;
    begin
      for l_y := 1 to p_taille do
      begin
        GotoXY(p_x, p_y + l_y - 1);
        for l_x := 1 to p_taille do
          Write(lpv_motif[(l_y - 1) * p_taille + l_x - 1]);
      end;
    end; (* affiche_motif *)

  procedure purge_motif(p_x, p_y, p_taille: Integer);
    var l_x, l_y: Integer;
    begin
      for l_y := 1 to p_taille do
        for l_x := 1 to p_taille do
            putpixel(p_x + l_x - 1, p_y + l_y - 1, k_rose);
    end; (* purge_motif *)

  procedure dessine_sortie(p_x, p_y, p_taille: Integer; VAR pv_sortie);
    var l_x, l_y: Integer;
        lpv_sortie: array[0..1000] of 0..1 absolute pv_sortie;
    begin
      rectangle(p_x - 1, p_y - 1, p_x + p_taille + 1, p_y + p_taille + 1);
      for l_y := 1 to p_taille do
      begin
        for l_x := 1 to p_taille do
        begin
          if lpv_sortie[(l_y - 1) * p_taille + l_x - 1] = 0
            then putpixel(p_x + l_x - 1, p_y + l_y - 1, k_rouge)
            else putpixel(p_x + l_x - 1, p_y + l_y - 1, white);
        end;
      end;
    end; (* dessine_sortie *)

  procedure dessine_sorties_1;
    var l_plan_1: Integer;
    begin
      for l_plan_1 := 1 to k_plan_1 do
      begin
        dessine_sortie(k_x_sortie_1, 2+(l_plan_1 - 1) * k_y_1,
          k_cote_plan_1,
          g_pt_couche_1^.plans_1[l_plan_1].sortie_1);
      end;
    end; (* dessine_sorties_1 *)

  procedure dessine_sorties_2;
    var l_plan_2: Integer;
    begin
      for l_plan_2 := 1 to k_plan_2 do
      begin
        dessine_sortie(k_x_sortie_2, 2+(l_plan_2 - 1) * k_y_2,
          k_cote_plan_2,
          g_pt_couche_2^.plans_2[l_plan_2].sortie_2);
      end;
    end; (* dessine_sorties_2 *)

  procedure dessine_sorties_3;
    var l_plan_3: Integer;
    begin
      for l_plan_3 := 1 to k_plan_3 do
      begin
        dessine_sortie(k_x_sortie_3, 2+(l_plan_3 - 1) * k_y_3,
          k_cote_plan_3,
          g_pt_couche_3^.plans_3[l_plan_3].sortie_3);
      end;
    end; (* dessine_sorties_3 *)

  procedure charge_0;
    (* -- uniquement pour dessiner quelque chose *)
    begin
      Assign(l_fichier_motifs, 'deux2.pas');
      Reset(l_fichier_motifs);

      charge_motif(k_cote_plan_0, g_pt_couche_0^.motif_0);
      dessine_motif(1, 1, k_cote_plan_0, g_pt_couche_0^.motif_0);

      Close(l_fichier_motifs);
    end; (* charge_0 *)
    
  procedure entraine_1;

    procedure initialise_1;
      var l_x, l_y: Integer;
          l_total: Real;
      begin
        New(g_pt_couche_1);
        FillChar(g_pt_couche_1^, SizeOf(t_couche_1), 0);

        with g_pt_couche_1^ do
        begin
          poids_plan_inhibe_1[1, 1]:= 1;
          poids_plan_inhibe_1[1, 3]:= 1;
          poids_plan_inhibe_1[3, 1]:= 1;
          poids_plan_inhibe_1[3, 3]:= 1;
          poids_plan_inhibe_1[1, 2]:= 1.5;
          poids_plan_inhibe_1[2, 1]:= 1.5;
          poids_plan_inhibe_1[2, 3]:= 1.5;
          poids_plan_inhibe_1[3, 2]:= 1.5;
          poids_plan_inhibe_1[2, 2]:= 2.0;
          l_total := 0;
          for l_y := 1 to k_cote_motif_1 do
            for l_x := 1 to k_cote_motif_1 do
              l_total := l_total + Sqr(poids_plan_inhibe_1[l_y, l_x]);
          l_total := Sqrt(l_total);

          for l_y := 1 to k_cote_motif_1 do
            for l_x := 1 to k_cote_motif_1 do
              poids_plan_inhibe_1[l_y, l_x] := poids_plan_inhibe_1[l_y, l_x] / l_total;
        end; (* with *)
      end; (* initialise_1 *)

    procedure ajuste_poids_1(p_plan: Integer);
      var l_x, l_y: Integer;
          l_total: Integer;
          l_somme_inhibition: Real;
      begin
        with g_pt_couche_1^, plans_1[p_plan] do
        begin
          (* -- renforce les poids ayant une entree positive *)
          for l_y := 1 to k_cote_motif_1 do
            for l_x := 1 to k_cote_motif_1 do
            begin
              poids_1[l_y, l_x] :=
                poids_1[l_y, l_x]
                  + k_apprentissage_1 * g_pt_couche_0^.motif_0[l_y, l_x]
                    * poids_plan_inhibe_1[l_y, l_x];
            end;

          (* -- calcule le poids d'inhibition *)
          l_somme_inhibition := 0;
          for l_y := 1 to k_cote_motif_1 do
            for l_x := 1 to k_cote_motif_1 do
              l_somme_inhibition := l_somme_inhibition
                + g_pt_couche_0^.motif_0[l_y, l_x]
                  * poids_plan_inhibe_1[l_y, l_x];

          l_somme_inhibition := Sqrt(l_somme_inhibition);
          poids_inhibe_1 := poids_inhibe_1 + k_apprentissage_1 * l_somme_inhibition;
        end;
      end; (* ajuste_poids_1 *)

    var l_cycle, l_plan: Integer;

    begin (* entraine_1 *)
      Assign(l_fichier_motifs, 'motif1.pas');
      Reset(l_fichier_motifs);

      (* -- mets des valeurs dans les poids des plans *)
      initialise_1;

      (* -- presente les 12 motifs et corrige les poids pour que *)
      (* -- chaque plan sache reconnaitre son motif *)
      for l_plan := 1 to k_plan_1 do
      begin
        charge_motif(k_cote_plan_1, g_pt_couche_1^.plans_1[l_plan].motif_1);
        dessine_motif(k_x_motif_1, 2+ (l_plan - 1) * k_y_1, 3, g_pt_couche_1^.plans_1[l_plan].motif_1);

        for l_cycle := 1 to k_cycles_apprentissage_1 do
          ajuste_poids_1(l_plan);
      end; (* for *)

      Close(l_fichier_motifs);
    end; (* entraine_1 *)

  procedure extrais_1(p_taille: Integer);

    procedure filtre_1(p_plan_1, p_x_0, p_y_0: Integer);
      (* -- verifie si l'image comporte cet exemplaire en p_x_0, p_y_0 *)
      var l_x, l_y: Integer;
          l_somme: Real;
          l_somme_inhibition: Real;
          l_valeur: Real;
      begin
        with g_pt_couche_1^, plans_1[p_plan_1] do
        begin
          l_somme := 0;
          for l_y := 1 to k_poids_1 do
            for l_x := 1 to k_poids_1 do
              l_somme := l_somme
                + g_pt_couche_0^.motif_0[p_y_0 + l_y - 1, p_x_0 + l_x - 1] * poids_1[l_y, l_x];
          
          l_somme_inhibition := 0;
          for l_y := 1 to k_poids_1 do
            for l_x := 1 to k_poids_1 do
              l_somme_inhibition := l_somme_inhibition
                + g_pt_couche_0^.motif_0[p_y_0 + l_y - 1, p_x_0 + l_x - 1]
                 * poids_plan_inhibe_1[l_y, l_x];
          l_somme_inhibition := poids_inhibe_1 * Sqrt(l_somme_inhibition);

          l_valeur := (1 + l_somme) / (1 + k_selectivite_1 / (1 + k_selectivite_1)
            * l_somme_inhibition) - 1;

          if l_valeur > 0
           then sortie_1[p_y_0, p_x_0] := k_selectivite_1 * l_valeur
           else sortie_1[p_y_0, p_x_0] := 0;
        end (* with *)
      end; (* filtre_1 *)
    
    var l_plan_1, l_x_0, l_y_0: Integer;

    begin (* extrais_1 *)
      for l_plan_1 := 1 to k_plan_1 do
      begin
        for l_y_0 := 1 to p_taille do
          for l_x_0 := 1 to p_taille do
            filtre_1(l_plan_1, l_x_0, l_y_0);
      end;
    end; (* extrais_1 *)

  procedure entraine_2;

    procedure initialise_2;
      begin
        New(g_pt_couche_2); FillChar(g_pt_couche_2^, SizeOf(t_couche_2), 0);

        g_pt_couche_2^.poids_plan_inhibe_2 := g_pt_couche_1^.poids_plan_inhibe_1;
      end;

    procedure ajuste_poids_2(p_plan_2: Integer);
      var l_plan_1, l_x, l_y: Integer;
          l_total: Integer;
          l_somme_inhibition: Real;
      begin
        with g_pt_couche_2^, plans_2[p_plan_2] do
        begin
          (* -- renforce les poids ayant une entree positive *)
          for l_plan_1 := 1 to k_plan_1 do
            for l_y := 1 to k_poids_2 do
              for l_x := 1 to k_poids_2 do
              begin
                poids_2[l_plan_1, l_y, l_x] := 
                  poids_2[l_plan_1, l_y, l_x]
                    + k_apprentissage_1
                      * g_pt_couche_1^.plans_1[l_plan_1].sortie_1[l_y, l_x]
                      * poids_plan_inhibe_2[l_y, l_x];
              end;

          (* -- calcule le poids d'inhibition *)
          l_somme_inhibition := 0;
          for l_plan_1 := 1 to k_plan_1 do
            for l_y := 1 to k_poids_2 do
              for l_x := 1 to k_poids_2 do
                l_somme_inhibition := l_somme_inhibition
                  + g_pt_couche_1^.plans_1[l_plan_1].sortie_1[l_y, l_x]
                    * poids_plan_inhibe_2[l_y, l_x];
          
          l_somme_inhibition := Sqrt(l_somme_inhibition);
          poids_inhibe_2 := poids_inhibe_2 + k_apprentissage_1 * l_somme_inhibition;
        end;
      end;

    var l_plan_2: Integer;

    begin (* entraine_2 *)
      Assign(l_fichier_motifs, 'motif2.pas');
      Reset(l_fichier_motifs);

      initialise_2;

      for l_plan_2 := 1 to k_plan_2 do
      begin
        charge_motif(k_cote_motif_2, g_pt_couche_2^.plans_2[l_plan_2].motif_2);
        dessine_motif(k_x_motif_2, 2 + (l_plan_2 - 1) * k_y_2, k_cote_motif_2,
          g_pt_couche_2^.plans_2[l_plan_2].motif_2);

        purge_motif(1, 1, k_cote_plan_0);
        dessine_motif(1, 1, k_cote_motif_2, g_pt_couche_2^.plans_2[l_plan_2].motif_2);
        extrais_1(k_cote_motif_2 - 2);
        dessine_sorties_1;

        ajuste_poids_2(l_plan_2);
      end;
      
      Close(l_fichier_motifs);
    end; (* entraine_2 *)
      
  procedure extrais_2(p_taille: Integer);
    
    procedure filtre_2(p_plan_2, p_x_1, p_y_1: Integer);
      (* -- verifie si l'image comporte cet exempleire en p_x_0, p_y_0 *)
      var l_plan_1, l_x, l_y: Integer;
          l_somme: Real;
          l_somme_inhibition: Real;
          l_valeur: Real;
      begin
        with g_pt_couche_2^, plans_2[p_plan_2] do
        begin
          l_somme := 0;
          for l_plan_1 := 1 to k_plan_1 do
            for l_y := 1 to k_poids_2 do
              for l_x := 1 to k_poids_2 do
                l_somme := l_somme
                  + g_pt_couche_1^.plans_1[l_plan_1].sortie_1[p_y_1 + l_y - 1, p_x_1 + l_x - 1]
                    * poids_2[l_plan_1, l_y, l_x];

          l_somme_inhibition := 0;
          for l_plan_1 := 1 to k_plan_1 do
            for l_y := 1 to k_poids_2 do
              for l_x := 1 to k_poids_2 do
                l_somme_inhibition := l_somme_inhibition
                  + g_pt_couche_1^.plans_1[l_plan_1].sortie_1[p_y_1 + l_y - 1, p_x_1 + l_x - 1]
                    * poids_plan_inhibe_2[l_y, l_x];
          l_somme_inhibition := poids_inhibe_2 * Sqrt(l_somme_inhibition);

          l_valeur := (1 + l_somme) / (1 + k_selectivite_2 / (1 + k_selectivite_2)
            * l_somme_inhibition) - 1;
            
          if l_valeur > 0
            then sortie_2[p_y_1, p_x_1] := k_selectivite_2 * l_valeur
            else sortie_2[p_y_1, p_x_1] := 0;
        end;
      end; (* filtre_2 *)

    var l_plan_2, l_x_1, l_y_1: Integer;

    begin (* extrais_2 *)
      for l_plan_2 := 1 to k_plan_2 do
      begin
        for l_y_1 := 1 to p_taille do
          for l_x_1 := 1 to p_taille do
            filtre_2(l_plan_2, l_x_1, l_y_1);
      end;
    end; (* extrais_2 *)

  procedure entraine_3;
    
    procedure initialise_3;
      begin
        New(g_pt_couche_3); FillChar(g_pt_couche_3^, SizeOf(t_couche_3), 0);

        g_pt_couche_3^.poids_plan_inhibe_3 := g_pt_couche_1^.poids_plan_inhibe_1;
      end;

    procedure ajuste_poids_3(p_plan_3: Integer);
      var l_plan_2, l_x, l_y: Integer;
          l_total : Real;
          l_somme_inhibition: Real;
      begin
        with g_pt_couche_3^, plans_3[p_plan_3] do
        begin
          (* -- renforce les poids ayant une entree positive *)
          for l_plan_2 := 1 to k_plan_2 do
            for l_y := 1 to k_poids_3 do
              for l_x := 1 to k_poids_3 do
              begin
                poids_3[l_plan_2, l_y, l_x] :=
                  poids_3[l_plan_2, l_y, l_x]
                    + k_apprentissage_1
                      * g_pt_couche_2^.plans_2[l_plan_2].sortie_2[l_y, l_x]
                      * poids_plan_inhibe_3[l_y, l_x];
              end;

          (*-- calcule le poids d'inhibition *)
          l_somme_inhibition := 0;
          for l_plan_2 := 1 to k_plan_2 do
            for l_y := 1 to k_poids_3 do
              for l_x := 1 to k_poids_3 do
                l_somme_inhibition := l_somme_inhibition
                  + g_pt_couche_2^.plans_2[l_plan_2].sortie_2[l_y, l_x]
                    * poids_plan_inhibe_3[l_y, l_x];
          
          l_somme_inhibition := Sqrt(l_somme_inhibition);
          poids_inhibe_3 := poids_inhibe_3 + k_apprentissage_1 * l_somme_inhibition;
        end;
      end; (* ajuste_poids_3 *)

    var l_plan_3: Integer;

    begin
      Assign(l_fichier_motifs, 'motif3.pas');
      Reset(l_fichier_motifs);

      initialise_3;

      for l_plan_3 := 1 to k_plan_3 do
      begin
        charge_motif(k_cote_motif_3, g_pt_couche_3^.plans_3[l_plan_3].motif_3);
        dessine_motif(k_x_motif_3, 2 + (l_plan_3 - 1) * k_y_3, k_cote_motif_3,
          g_pt_couche_3^.plans_3[l_plan_3].motif_3);
        purge_motif(1, 1, k_cote_plan_0);
        dessine_motif(1, 1, k_cote_motif_3, g_pt_couche_3^.plans_3[l_plan_3].motif_3);

        extrais_1(k_cote_motif_3 - 2);
        dessine_sorties_1;

        extrais_2(k_cote_motif_3 - 4);
        dessine_sorties_2;

        ajuste_poids_3(l_plan_3);
      end;

      Close(l_fichier_motifs);
    end; (* entraine_3 *)

  procedure extrais_3(p_taille: Integer);

    procedure filtre_3(p_plan_3, p_x_2, p_y_2: Integer);
      (* -- verifie si l'image comporte cet exemplaireen p_x_0, p_y_0 *)
      var l_plan_2, l_x, l_y: Integer;
          l_somme: Real;
          l_somme_inhibition: Real;
          l_valeur: Real;
      begin
        with g_pt_couche_3^, plans_3[p_plan_3] do
        begin
          l_somme := 0;
          for l_plan_2 := 1 to k_plan_2 do
            for l_y := 1 to k_poids_3 do
              for l_x := 1 to k_poids_3 do
                l_somme := l_somme
                  + g_pt_couche_2^.plans_2[l_plan_2].sortie_2[p_y_2 + l_y - 1, p_x_2 + l_x - 1]
                    * poids_3[l_plan_2, l_y, l_x];
          
          l_somme_inhibition := 0;
          for l_plan_2 := 1 to k_plan_2 do
            for l_y := 1 to k_poids_3 do
              for l_x := 1 to k_poids_3 do
                l_somme_inhibition := l_somme_inhibition
                  + g_pt_couche_2^.plans_2[l_plan_2].sortie_2[p_y_2 + l_y - 1, p_x_2 + l_x - 1]
                    * poids_plan_inhibe_3[l_y, l_x];
          l_somme_inhibition := poids_inhibe_3 * Sqrt(l_somme_inhibition);

          l_valeur := (1 + l_somme) / (1 + k_selectivite_3 / (1 + k_selectivite_3)
            * l_somme_inhibition) - 1;

          if l_valeur > 0
            then sortie_3[p_y_2, p_x_2] := k_selectivite_3 * l_valeur
            else sortie_3[p_y_2, p_x_2] := 0;
        end;
      end; (* filtre_3 *)

    var l_plan_3, l_x_2, l_y_2: Integer;

    begin
      for l_plan_3 := 1 to k_plan_3 do
      begin
        for l_y_2 := 1 to p_taille do
          for l_x_2 := 1 to p_taille do
            filtre_3(l_plan_3, l_x_2, l_y_2);
      end
    end; (* extrais_3 *)
              
  procedure analyse_chiffre;
    begin
      charge_0;

      extrais_1(k_cote_plan_1);
      dessine_sorties_1;

      extrais_2(k_cote_plan_2);
      dessine_sorties_2;

      extrais_3(k_cote_plan_3);
      dessine_sorties_3;
    end; (* analyse_chiffre *)

  begin (* go *)
    initialise_mode_graphique;

    New(g_pt_couche_0);

    charge_0;

    entraine_1;
    entraine_2;
    entraine_3;

    analyse_chiffre;

    termine_mode_graphique;
  end; (* go *)

procedure initialise;
  begin
  end;  (* initialise *)

begin (* main *)
  ClrScr;
  initialise;
  repeat
    WriteLn;
    Write('Go, Quitte ?');
    g_choix := ReadKey; Write(g_choix); WriteLn;
    case g_choix of
      'g', 'G': go;
    end;
  until g_choix = 'q';
end. (* main *)
