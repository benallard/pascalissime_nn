(* 001 art14 *)
(* 17 fev 92 *)

(*$r+*)

program ART1;
uses crt, dos, printer;
const
{
        k_iteration_max = 25;
        k_F1_max = 6;
        k_F2_max = 4;

        k_caracteres_max = 6;

        (* -- codage du jeu d'essai *)
        k_table_caracteres: array[1..k_caracteres_max, 1..k_F1_max] of Integer

        = ((0,0,0,0,0,1), (1,0,0,0,0,0), (1,0,1,1,0,1),
           (0,0,0,0,1,1), (0,0,1,1,0,1), (1,0,0,0,0,0));
}
        k_iteration_max=40;

        (* -- les lettres de 5 x 5 *)
        k_F1_max = 5 * 5;
        (* -- le nombre de categories max *)
        k_F2_max = 13;

        (* -- le jeu de caracteres en entree *)
        k_caracteres_max = 20;

        k_table_caracteres: array[1..k_caracteres_max, 1..k_F1_max] of Integer =
                ((1,1,1,1,1, { A }
                  1,0,0,0,1,
                  1,1,1,1,1,
                  1,0,0,0,1,
                  1,0,0,0,1),

                 (1,1,1,1,0, { B }
                  1,0,0,0,1,
                  1,1,1,1,0,
                  1,0,0,0,1,
                  1,1,1,1,0),

                 (1,1,1,1,1, { C }
                  1,0,0,0,0,
                  1,0,0,0,0,
                  1,0,0,0,0,
                  1,1,1,1,1),

                 (1,1,1,1,0, { D }
                  1,0,0,0,1,
                  1,0,0,0,1,
                  1,0,0,0,1,
                  1,1,1,1,0),

                 (1,1,1,1,1, { E }
                  1,0,0,0,0,
                  1,1,1,1,1,
                  1,0,0,0,0,
                  1,1,1,1,1),

                 (1,1,1,1,1, { F }
                  1,0,0,0,0,
                  1,1,1,1,1,
                  1,0,0,0,0,
                  1,0,0,0,0),

                 (1,1,1,1,1, { G }
                  1,0,0,0,0,
                  1,0,1,1,1,
                  1,0,0,0,1,
                  1,1,1,1,1),

                 (1,0,0,0,1, { H }
                  1,0,0,0,1,
                  1,1,1,1,1,
                  1,0,0,0,1,
                  1,0,0,0,1),

                 (1,1,1,1,1, { I }
                  0,0,1,0,0,
                  0,0,1,0,0,
                  0,0,1,0,0,
                  1,1,1,1,1),

                 (1,1,1,1,1, { J }
                  0,0,1,0,0,
                  0,0,1,0,0,
                  0,0,1,0,0,
                  1,1,1,0,0),

                 (1,0,0,0,1, { K }
                  1,0,0,1,0,
                  1,1,1,0,0,
                  1,0,0,1,0,
                  1,0,0,0,1),

                 (1,0,0,0,0, { L }
                  1,0,0,0,0,
                  1,0,0,0,0,
                  1,0,0,0,0,
                  1,1,1,1,1),

                 (1,0,0,0,1, { M }
                  1,1,0,1,1,
                  1,0,1,0,1,
                  1,0,0,0,1,
                  1,0,0,0,1),

                 (1,0,0,0,1, { N }
                  1,1,0,0,1,
                  1,0,1,0,1,
                  1,0,0,1,1,
                  1,0,0,0,1),

                 (1,1,1,1,1, { O }
                  1,0,0,0,1,
                  1,0,0,0,1,
                  1,0,0,0,1,
                  1,1,1,1,1),

                 (1,1,1,1,1, { P }
                  1,0,0,0,1,
                  1,1,1,1,1,
                  1,0,0,0,0,
                  1,0,0,0,0),

                 (1,1,1,1,1, { Q }
                  1,0,0,0,1,
                  1,0,1,0,1,
                  1,0,0,1,1,
                  1,1,1,1,1),

                 (1,1,1,1,1, { R }
                  1,0,0,0,1,
                  1,1,1,1,1,
                  1,0,0,1,0,
                  1,0,0,0,1),

                 (1,1,1,1,1, { S }
                  1,0,0,0,0,
                  1,1,1,1,1,
                  0,0,0,0,1,
                  1,1,1,1,1),

                 (1,1,1,1,1, { T }
                  0,0,1,0,0,
                  0,0,1,0,0,
                  0,0,1,0,0,
                  0,0,1,0,0));


        (* -- patrameter de sensibilite pour l'apprentissage 0..1 *)
        k_vigilence_apprentissage = 0.8;
        (* -- parametre de sensibilite pour la reconnaisance. 0..1 *)
        k_vigilence_reconnaissance = 0.8;

        (* -- parametres de l'etage F1: *)
        (* -- les valeurs sont fixes pour rechercher un retour rapide a zero *)
        (* -- quand le neurone n'est pas renforce ni par les entrees ni par la retroaction *)
        (* -- plus cette convergence est rapide, moins il y a de bruit *)
        (* -- contrainte a respecter: max (1, k_F2_F1) < k_F1 < 1 + k_F2_F1 *)
        k_F1 = 2.1;
        k_F2_F1 = 1.9;

        (* -- parametres de l'etage F2: Objectif: obtenir a la fois *)
        (* --  - une inihibition laterale suffisante *)
        (* --  - une ontee en puissance rapide des neurones deactives en cas de reset *)
        (* -- constance inihibitrice de la competition *)
        k_inhibe_F2 = 2.2;
        (* -- constance de l'exitation de l'action de F1 sur F2 *)
        k_F1_F2 = 1.6;

        (* -- plasticite (ajustement des poids) pour les poids F1 -> F2 *)
        (* -- moins elle est forte, moins il y a de bruit *)
        (* -- mais plus les iterations augmentent. Cette valeur depends de k_F1_poids_F1_F2 *)
        k_poids_F1_F2: Real = 0.08;
        (* -- constrainte a respecter: k_F1_poids_F1_F2 > 1 *)
        k_F1_poids_F1_F2 = 1.4;

        (* -- plasticite descendant: pas trop forte pour eviter les bruits de resets *)
        k_poids_F2_F1 = 0.035;

        (* -- pour les activites des neurones, la modification doit etre rapide. *)
        (* -- Mais si elle est trop forte, les unites retombent a zero 1 coup sur 2 *)
        (* -- contrainte a respoecter: 0 < E << 1 *)
        k_activite = 0.1;

TYPE t_curseur = (curseur_visible, curseur_eteint);
     t_traitement = (apprentissage, reconnaissance);

     t_element_entree = RECORD
                          entree_F1: Integer;
                          (* -- contient la categorie de chaque caractere pour detecter les echecs *)
                          categorie_caractere: Integer;
                        END;
     t_entree = RECORD
                  entree: ARRAY[1..k_F1_max] OF t_element_entree;
                  (* -- evite la saturation quand g_vigilence = 1 *)
                  nombre_caracteres_utilises: Integer;
                END;

     t_neurone_1 = RECORD
                     activite_F1, sortie_F1: Real;
                     poids_F2_F1: ARRAY [1..k_F2_max] OF Real;
                   END;
     t_couche_1 = RECORD
                    neurone_F1: ARRAY [1..k_F1_max] OF t_neurone_1;
                    nombre_sorties_F1_a_1: Integer;
                    nombre_entrees_F1_a_1: Integer;
                  END;

     t_neurone_2 = RECORD
                     activite_F2, sortie_F2: Real;
                     poids_F1_F2: ARRAY[1..k_F1_max] OF Real;
                     (* -- les indices de reset successifs *)
                     historique_indices_reset: Integer;
                   END;
     t_couche_2 = RECORD
                    neurone_F2: ARRAY[1..k_F2_max] OF t_neurone_2;
                    nombre_sorties_F2_a_1: Integer;
                    (* -- total pour le calcul de l'inhibition lateralle *)
                    total_activite_F2: Real;

                    (* -- neurone de F2 qui est entree en resonnance *)
                    indice_F2_en_resonnance: Integer;
                    (* -- affichage: neurone de F2 qui est entre en resonnance *)
                    indice_F2_en_resonnance_precedent: Integer;

                    (* -- nombre de neurones de F2 utilises actuellement *)
                    nombre_neurones_F2: Integer;

                    (* -- indice du Reset actuel *)
                    indice_reset_actuel: Integer;
                  END;

VAR g_choix: Char;

    g_entree: t_entree;
    g_couche_1: t_couche_1;
    g_couche_2: t_couche_2;

    (* -- parametres apprentissage ou vigilence: soit k_vigilence_apprentissage *)
    (* -- soit k_vigilence_reconnaissance *)
    g_vigilence: Real;

    g_test, g_arret: Boolean;
    g_exemple_1: Boolean;
    g_nom_fichier: Char;

procedure affiche_curseur(p_curseur: t_curseur);
  {var l_registres: Registers;}
  begin
    {l_registres.AX := $0100;
    CASE p_curseur OF
      curseur_visible: l_registres.CX := $0607;
      curseur_eteint: l_registres.CX := $0807;
    END;
    Intr($10, l_registres);}    
  end;

procedure stoppe;
  var l_stoppe: Char;
  begin
    affiche_curseur(curseur_eteint);
    l_stoppe := ReadKey;
  end;

procedure sonne;
  begin
    Write(Chr(7));
  end;

procedure dump_ecran;
  {var g_ecran: ARRAY[1..25, 1..80] OF
        RECORD
          caractere: Char; attribut: Byte;
        END ABSOLUTE $B800:$0000;
      l_ligne, l_colonne: Integer;
      l_fichier: Text;}
  begin
    {Assign(l_fichier, 'a:'+g_nom_fichier+'.pas');
    Rewrite(l_fichier);
    FOR l_ligne := 1 TO 25 DO
    BEGIN
      for l_colonne := 1 to 80 do
        Write(l_fichier, g_ecran[l_ligne, l_colonne].caractere);
      WriteLn;
    END;
    Close(l_fichier);
    g_nom_fichier := Succ(g_nom_fichier);}
  end;

procedure stoppe_imprime;
  var l_stoppe: Char;
  begin
    l_stoppe := UpCase(ReadKey);
    IF l_stoppe = 'I'
      THEN dump_ecran;
  end;

(* -- initialisation avant chaque caractere *)

procedure initialise_F1_et_F2(p_indice_lettre: Integer);
  var l_indice_F1, l_indice_F2: Integer;
  begin
    (* -- initialisation des entrees pour ce caractere. Recopie simplement ce caractere *)
    FOR l_indice_F1 := 1 TO k_F1_max DO
      g_entree.entree[l_indice_F1].entree_F1 := k_table_caracteres[p_indice_lettre, l_indice_F1];

    (* -- initialisation de F1 *)
   WITH g_couche_1, g_entree DO
   BEGIN
      nombre_entrees_F1_a_1 := 0;

      FOR l_indice_F1 := 1 TO k_F1_max DO
        WITH neurone_F1[l_indice_F1] DO
        BEGIN
          activite_F1 := 0.0;
          sortie_F1 := 0.0;

          nombre_entrees_F1_a_1 := nombre_entrees_F1_a_1 + entree[l_indice_F1].entree_F1;
        END;
   END;

    (* -- initialise F2 *)
    WITH g_couche_2 DO
    BEGIN
      nombre_sorties_F2_a_1 := 0;
      total_activite_F2 := 0.0;

      FOR l_indice_F2 := 1 TO nombre_neurones_F2 DO
        WITH neurone_F2[l_indice_F2] DO
        BEGIN
          activite_F2 := 0.0;
          sortie_F2 := 0.0;

          (* -- aucun neurone n'a encore subi de Reset *)
          historique_indices_reset := 0;
        END;

      indice_reset_actuel := 1;
      indice_F2_en_resonnance:= 0;
      indice_F2_en_resonnance_precedent:= 1;
    END;
  END;

procedure calcule_un_cycle(p_modifie_connections: t_traitement);
  var l_indice_F1, l_indice_F2: Integer;
      l_sortie_F2_max, l_cumul_F2: Real;
  begin
    WITH g_entree, g_couche_1, g_couche_2 DO
    BEGIN
      (* -- pour l'affichage *)
      indice_F2_en_resonnance_precedent := indice_F2_en_resonnance;

      (* -- calcul de l'activite et des sorties de F1 *)
      (* -- dAi/dt = k_activite * [-Ai + (1-k_A1 * Ai) * (Ei + k_F2_F1 * `somme_sur_j(Sj * Pj.i)) *)
      (* --          - (k_F1 + k_C1 * Ai) * |Sj|] *)
      (* -- F2 a 0 ou 1 neurone actif, celui qui est le gagnant (qui resonne) *)
      (* -- dAi/dt = k_activite * [-Ai + (1-k_A1 * Ai) * (Ei + k_F2_F1 * (Sj_max * Pj_max.i)) *)
      (* --          - (k_F1 + k_C1 * Ai) * Sj_max] *)
      (* -- Sj est binaire et n'admet qu'un maximum superieur a zero. *)
      (* -- par consequent |Sj| est forcement egal a Sj_max, qui a pour valeur 1 *)
      (* -- Alors: *)
      (* --   - quand l'etage F2 est inactif on a Sj_max = 0 *)
      (* --     et dAi / dt = k_activite * (-Ai + (1 + k_A1 * Ai) * Ei) *)
      (* --   - quand l'etage F2 est actif, il y a un maximum et *)
      (* --     Sj_max = 1 et *)
      (* --     dAi/dt = k_activite * [-Ai + (1 - kA1 * Ai) * (Ei + k_F2_F1 * Pj_max.i) *)
      (* --              - (k_F1 + k_C1 * Ai)] *)
      (* -- en plus, nous utilisons les formules simplifies ou k_A1 = 0 et k_C1 = 0: *)
      (* --   - quand l'etage F2 est inactif: dAi/dt = k_activite * (-Ai + Ei) *)
      (* --   - quand l'etage F2 est actif: dAi/dt = k_activite * [-Ai + Ei + k_F2_F1 * Pj_max.i - k_F1] *)

      nombre_sorties_F1_a_1 := 0;

      (* -- calcule la sortie de la couche F1 *)
      FOR l_indice_F1 := 1 TO k_F1_max DO
        WITH neurone_F1[l_indice_F1] DO
        BEGIN
          (* -- nos formules utilisent la simplification k_A1 = 0 et k_C1 = 0 *)
          IF nombre_sorties_F2_a_1 > 0
            THEN activite_F1 := activite_F1 * (1- k_activite)
                                + k_activite * (entree[l_indice_F1].entree_F1
                                + k_F2_F1 * poids_F2_F1[indice_F2_en_resonnance] - k_F1)
            ELSE activite_F1 := activite_F1 * (1 - k_activite)
                                + k_activite * entree[l_indice_F1].entree_F1;

          (* -- filtrage de la sactivite: bride la sortie a [0..1] *)
          IF activite_F1 > 1.0
            THEN activite_F1 := 1.0;
          IF activite_F1 < 0.0
            THEN activite_F1 := 0.0;

          (* -- calcule du vecteur de sortie binaire et du nombre de sorties a 1 *)
          IF activite_F1 > 0.0
            THEN
              BEGIN
                sortie_F1 := 1.0;
                nombre_entrees_F1_a_1 := nombre_sorties_F1_a_1 + 1;
              END
            ELSE sortie_F1 := 0.0;
        END;

      (* -- Reset des neurones de F2, Determine s'il faut crer une nouvelle categorie *)
      (* -- Le Reset intervient lorsque: *)
      (* -- nombre_sorties_F1_a_1 / nombre_entree-F1_a_1 < g_vigilence_apprentissage *)
      IF nombre_sorties_F1_a_1 < g_vigilence * nombre_entrees_F1_a_1
        THEN
          FOR l_indice_F2 := 1 TO nombre_neurones_F2 DO
            WITH neurone_F2[l_indice_F2] DO
              IF sortie_F2 > 0.0
                THEN
                  BEGIN
                    total_activite_F2 := total_activite_F2 - activite_F2;
                    sortie_F2 := 0.0;
                    activite_F2 := 0.0;
                    nombre_sorties_F2_a_1 := 0;

                    (* -- gestion de l'historique des resets pour affichage *)
                    historique_indices_reset := indice_reset_actuel;
                    indice_reset_actuel := indice_reset_actuel + 1;

                    (* -- il n'y a plus de resonance pour ce cycle *)
                    indice_F2_en_resonnance := 0;
                  END;

      (* -- modifie les poids de F1 -> F2 *)
      (* -- dPi.j/dt = k_K * Sj[(1-Pi.j) * k_F1_poids_F1_F2 * Si - Pi.j * |Si| - 1] *)
      (* -- Comme le seul Sj qui peut etre superieur a zero est Sj_max, de l'unite *)
      (* -- maximum de F2 et que quand il n'est pas nul Sj_max = 1 *)
      (* -- dPi.j_max/dt = k_K * [(1 - Pi.j_max) * k_F1_poids_F1_F2 * Si - Pi.j_max * (|Si| - 1)] *)
      (* -- et Pi.j tend: *)
      (* --   - soit vers 0 lorsque Si = 0 *)
      (* --   - soit vers k_F1_poids_F1_F2 / (k_F1_poids_F1_F2 - 1 + |Si|) lorsque Si = 1 *)
      IF (p_modifie_connections = apprentissage) AND (nombre_sorties_F2_a_1 > 0)
        THEN
          FOR l_indice_F1 := 1 TO k_F1_max DO
            WITH neurone_F1[l_indice_F1], neurone_F2[indice_F2_en_resonnance] DO
            BEGIN
              IF sortie_F1 = 1.0
                THEN BEGIN
                    poids_F1_F2[l_indice_F1] := poids_F1_F2[l_indice_F1]
                                                + k_poids_F1_F2 * (k_F1_poids_F1_F2 - poids_F1_F2[l_indice_F1]
                                                                    * (k_F1_poids_F1_F2 + nombre_sorties_F1_a_1 - 1.0));
                  END
                ELSE
                  IF poids_F1_F2[l_indice_F1] > 0.0
                    THEN
                      BEGIN
                        poids_F1_F2[l_indice_F1] := poids_F1_F2[l_indice_F1]
                                                    * (1.0 - k_poids_F1_F2 * nombre_sorties_F1_a_1);

                        (* -- eviter les erreurs de valeurs trop petites *)
                        IF poids_F1_F2[indice_F2_en_resonnance] < 0.000001
                          THEN poids_F1_F2[indice_F2_en_resonnance] := 0.0;
                      END;
            END;

      (* -- modification des poids F2 -> F1 *)
      (* --  dPi.j/dt = k_activite * Sj[-Pj.i + Si] *)
      (* -- Comme le seul Vj > 0 est le Vj_max de l'unite maximum de F2, seules ses connexions *)
      (* -- apprennent quelque chose: *)
      (* --  dPj_max.i/dt = k_activite (Si - Pj_max.i) - Pk_max.i *)
      (* -- cette valeur tend *)
      (* --   - vers 0 quand Si = 0 *)
      (* --   - vers 1 quand Si = 1 *)
      IF (p_modifie_connections = apprentissage) AND (nombre_sorties_F2_a_1 > 0)
        THEN
          FOR l_indice_F1 := 1 TO k_F1_max DO
            WITH neurone_F1[l_indice_F1] DO
            BEGIN
              IF sortie_F1 = 0.0
                THEN poids_F2_F1[indice_F2_en_resonnance] := 
                       poids_F2_F1[indice_F2_en_resonnance]
                       - k_poids_F2_F1 * poids_F2_F1[indice_F2_en_resonnance]
                ELSE poids_F2_F1[indice_F2_en_resonnance] :=
                       poids_F2_F1[indice_F2_en_resonnance]
                       + k_poids_F2_F1 * (1.0 - poids_F2_F1[indice_F2_en_resonnance]);
            END;

      (* -- calcule des activites de F2: *)
      (* -- dAj/dt = k_activite * [-Aj + (1 - k_A2 * Aj) * (Aj + k_F1_F2 * SOMME_SUR_I(Ai * Pi.j)) *)
      (* --          - (k_inhibe_F2 + k_C2 * Aj)(SOMME_SUR_J(Aj) - Aj)] *)
      (* -- il ya  inihibation lateralle sur les neurones de F2: *)
      (* -- chaque neurone s'auto-renforce et est inhibe par les autres neurones de F2 *)
      (* -- total activite F2 - j est l'activite de tous ses voisins moins la sienne *)
      l_sortie_F2_max := 0.0;
      FOR l_indice_F2 := 1 TO nombre_neurones_F2 DO
        WITH neurone_F2[l_indice_F2] DO
          IF historique_indices_reset = 0
            THEN
              BEGIN
                l_cumul_F2 := 0.0;
                (* -- calcul de la sortie de F2: *)
                (* -- si Si > 0 alors Si = 1 *)
                FOR l_indice_F1 := 1 TO k_F1_max DO
                  IF neurone_F1[l_indice_F1].sortie_F1 > 0
                    THEN l_cumul_F2 := l_cumul_F2 + poids_F1_F2[l_indice_F1];

                (* -- nous avons utilise une formule simplifiee ou k_A2 = 0 et k_C2 = 0 *)
                activite_F2 := activite_F2 + k_activite * (k_F1_F2 * l_cumul_F2
                               - k_inhibe_F2 * (total_activite_F2 - activite_F2));

                (* -- filtrage des sorties de F2 pour les ramener dans [0..1] *)
                IF activite_F2 > 1.0
                  THEN activite_F2 := 1.0;
                IF activite_F2 < 0.0
                  THEN activite_F2 := 0.0;

                (* -- calcul du max *)
                IF activite_F2 > l_sortie_F2_max
                  THEN l_sortie_F2_max := activite_F2;
              END;

      (* -- calcul des sorties de F2 *)
      (* -- Si l_sortie_F2_max est nul (lors de la premiere itaration) *)
      (* -- ou apres iun reset qui annule toute les sorties *)
      (* -- force un maximum a 1 *)
      IF l_sortie_F2_max = 0.0
        THEN l_sortie_F2_max := 1.0;

      (* -- calcule le gagnant de F2 *)
      (* -- pour le cycle suivant, calcule l'activite totale F2 pour l'inhibition laterale *)
      nombre_sorties_F2_a_1 := 0;
      total_activite_F2 := 0.0;
      FOR l_indice_F2 := 1 TO nombre_neurones_F2 DO
        WITH neurone_F2[l_indice_F2] DO
        BEGIN
          IF (activite_F2 = l_sortie_F2_max) AND (historique_indices_reset = 0)
            THEN BEGIN (* bingo ! *)
                indice_F2_en_resonnance := l_indice_F2;
                nombre_sorties_F2_a_1 := nombre_sorties_F2_a_1 + 1;
              END;
          
          total_activite_F2 := total_activite_F2 + activite_F2;
        END;

      (* -- sortie de F2: un seul gagnant ayant une valeur 1, les autres 0 *)
      FOR l_indice_F2 := 1 TO nombre_neurones_F2 DO
        WITH neurone_F2[l_indice_F2] DO
        BEGIN
          IF l_indice_F2 = indice_F2_en_resonnance
            THEN (* -- le gagnant *)
              sortie_F2 := 1.0
            ELSE (* -- pas le max: perd et met sa sortie a 0 *)
              sortie_F2 := 0.0;
        END;
    END;
  end;

FUNCTION f_pixel(p_valeur: Real): Char;
  BEGIN
    IF p_valeur > 0.75
      THEN f_pixel:= 'X'
      ELSE
        IF p_valeur > 0.5
          THEN f_pixel := 'o'
          ELSE
            IF p_valeur > 0.25
            THEN f_pixel := '='
            ELSE f_pixel := '.';
  END;

PROCEDURE affiche_reseau;
  VAR l_indice_F1, l_indice_F2: Integer;
  BEGIN
    WITH g_entree, g_couche_1, g_couche_2 DO
    BEGIN
      (* -- les entrees *)
      FOR l_indice_F1 := 1 TO k_F1_max DO
      BEGIN
        GotoXY(1 + (l_indice_F1 - 1) DIV 3, 14 + (l_indice_F1 - 1) MOD 3);
        Write(f_pixel(g_entree.entree[l_indice_F1].entree_F1));

        GotoXY(3, 1 + (l_indice_F1 - 1) * 4);
        Write(g_entree.entree[l_indice_F1].entree_F1);
      END;

      (* -- la couche F1 *)
      FOR l_indice_F1 := 1 TO k_F1_max DO
        WITH neurone_F1[l_indice_F1] DO
        BEGIN
          FOR l_indice_F2 := 1 to k_F2_max DO
          BEGIN
            GotoXY(5, 1 + (l_indice_F1 - 1) * 4 + l_indice_F2 - 1);
            Write(poids_F2_F1[l_indice_F2] * 100:4:0);
            IF l_indice_F2 = indice_F2_en_resonnance_precedent
              THEN Write('<- ')
              ELSE Write('   ');

            (* -- le dessin di caractere de chaque categorie renvoye par F2 vers F1 *)
            GotoXY(27 + (l_indice_F1 - 1) DIV 3,
                   1 + (l_indice_F2 - 1) * 6 + (l_indice_F1 - 1) MOD 3);
            Write(f_pixel(poids_F2_F1[l_indice_F2]));
          END;

          GotoXY(12, 1+ (l_indice_F1 - 1) * 4);
          Write(activite_F1 * 100 :3:0, sortie_F1 * 100:4:0);
        END;

      (* -- la couche F2 *)
      FOR l_indice_F2 := 1 TO k_F2_max DO
        WITH neurone_F2[l_indice_F2] DO
        BEGIN
          IF l_indice_F2 > 1
            THEN BEGIN
                GotoXY(29, 1 + (l_indice_F2 - 1) * 6 - 1);
                Write('_');
              END;

          IF (indice_F2_en_resonnance = 0)
              OR (l_indice_F2 = indice_F2_en_resonnance)
            THEN BEGIN
                FOR l_indice_F1 := 1 TO k_F1_max DO
                BEGIN
                  GotoXY(30, 1 + (l_indice_F2 - 1) * 6 + l_indice_F1 - 1);
                  Write(poids_F1_F2[l_indice_F1] * 100:4:0);
                END;

                GotoXY(40, 1 + (l_indice_F2 - 1) * 6);
                Write(activite_F2*100:3:0, sortie_F2*100:4:0);
              END
            ELSE BEGIN
                FOR l_indice_F1 := 1 TO k_F1_max DO
                BEGIN
                  GotoXY(30, 1 + (l_indice_F2 - 1) * 6 + l_indice_F1 - 1);
                  Write(' ':4);
                END;

                GotoXY(40, 1 + (l_indice_F2 - 1) * 6);
                Write(' ':7);
              END;

          GotoXY(50, 1 + (l_indice_F2 - 1) * 6);
          IF indice_F2_en_resonnance = l_indice_F2
            THEN Write('RES ')
            ELSE Write('    ');
          GotoXY(60, 1 + (l_indice_F2 - 1) * 6);
          IF historique_indices_reset > 0
            THEN Write(historique_indices_reset)
            ELSE Write('  ');
        END;

        (* -- affichages divers *)
        GotoXY(60, 1); Write('res prec ', indice_F2_en_resonnance_precedent);
        GotoXY(60, 2); Write('res ', indice_F2_en_resonnance);
        GotoXY(60, 3); Write('res ', g_vigilence:7:3);
        GotoXY(60, 4); Write('entrees a 1 ', nombre_entrees_F1_a_1);
        GotoXY(60, 5); Write('sorties F1 a 1 ', nombre_sorties_F1_a_1);
        GotoXY(60, 6); Write('Reset ', nombre_sorties_F1_a_1 < g_vigilence * nombre_entrees_F1_a_1);
    END;
  END;

PROCEDURE affiche_feed_back(p_indice: Integer; p_inverse: Boolean);
  VAR l_indice_F1, l_indice_F2: Integer;
  BEGIN
    IF NOT g_exemple_1
      THEN
        WITH g_entree, g_couche_1, g_couche_2 DO
        BEGIN
          IF p_indice > 0
            THEN
              FOR l_indice_F1 := 1 TO k_F1_max DO
                WITH  neurone_F1[l_indice_F1] DO
                BEGIN
                  (* -- ler dessin du caractere de chaque categorie renvoye par F2 vers F1 *)
                  l_indice_F2 := p_indice;
                  IF p_inverse
                    THEN BEGIN
                        TextColor(Black); TextBackground(White);
                      END;

                  GotoXY(15 + (l_indice_F1 - 1) MOD 5 + ((l_indice_F2 - 1) DIV 4) * 12,
                         2 + (((l_indice_F2 - 1) MOD 4) * 6 + (l_indice_F1 - 1) DIV 5));
                  Write(f_pixel(poids_F2_F1[l_indice_F2]));

                  IF p_inverse
                    THEN BEGIN
                        TextColor(White); TextBackground(Black);
                      END;
                END;
        END;
  END;

PROCEDURE affiche_tous_les_feed_back;
  VAR l_indice_F2: Integer;
  BEGIN
    IF NOT g_exemple_1
      THEN
        WITH g_couche_2 DO
          FOR l_indice_F2 := 1 TO nombre_neurones_F2 DO
            affiche_feed_back(l_indice_F2, False);
  END;

PROCEDURE affiche_reseau_2;
  VAR l_indice_F1, l_indice_F2: Integer;
  BEGIN
    IF NOT g_exemple_1
      THEN
        WITH g_entree, g_couche_1, g_couche_2 DO
        BEGIN
          (* -- les entrees *)
          FOR l_indice_F1 := 1 TO k_F1_max DO
          BEGIN
            GotoXY(1 + (l_indice_F1 - 1) MOD 5, 10 + (l_indice_F1 - 1) DIV 5);
            Write(f_pixel(g_entree.entree[l_indice_F1].entree_F1));
          END;

          GotoXY(8, 12); Write('AND');

          affiche_feed_back(indice_F2_en_resonnance_precedent, False);
          affiche_feed_back(indice_F2_en_resonnance, True);

          GotoXY(52, 12); Write('==>');

          (* -- la couche F1 *)
          FOR l_indice_F1 := 1 TO k_F1_max DO
            WITH neurone_F1[l_indice_F1] DO
            BEGIN
              (* -- la sortie de F1 *)
              GotoXY(60 + (l_indice_F1 - 1) MOD 5, 10 + (l_indice_F1 - 1) DIV 5);
              Write(f_pixel(sortie_F1));
            END;

          (* -- affiche qui gagne, et eventuellement, le mechanisme du Reset *)
          FOR l_indice_F2 := 1 TO nombre_neurones_F2 DO
            WITH neurone_F2[l_indice_F2] DO
            BEGIN
              GotoXY(15 + ((l_indice_F2 - 1) DIV 4) * 12,
                     1 + (((l_indice_F2 - 1) MOD 4) * 6));
              Write('        ');
              GotoXY(15 + ((l_indice_F2 - 1) DIV 4) * 12,
                    1 + (((l_indice_F2 - 1) MOD 4) * 6));
              IF indice_F2_en_resonnance = l_indice_F1
                THEN Write('GAGNE');
              IF historique_indices_reset > 0
                THEN Write(historique_indices_reset);
            END;

          (* -- le contenu de chaque categorie *)
          FOR l_indice_F1 := 1 TO k_F1_max DO
            WITH g_entree.entree[l_indice_F1] DO
            BEGIN
              IF categorie_caractere <> 0
                THEN BEGIN
                    GotoXY(21 + ((categorie_caractere - 1) DIV 4) * 12 + (l_indice_F1 - 1) DIV 5,
                           2 + (((categorie_caractere - 1) MOD 4) * 6 + (l_indice_F1 - 1) MOD 5));
                    Write(Chr(64 + l_indice_F1));
                  END;
            END;
        END;
  END;

PROCEDURE entraine_reseau;
  VAR l_indice_caractere: Integer;

  PROCEDURE initialise_les_poids;
    (* -- effectue une seule fois pour chaque traitement *)
    (* -- les poids doiventr respecter certaines limites *)
    (* -- ou sinon il y a des risques de divergence, d'effondrement du reseau *)
    (* -- de choix de mauvaise classifications et autres calamites ... *)
    VAR l_indice_F1, l_indice_F2: Integer;
        l_max_poids_F2, l_minimum_poids_F1: Real;
    BEGIN
      WITH g_entree, g_couche_1, g_couche_2 DO
      BEGIN
        l_max_poids_F2 := k_F1_poids_F1_F2 / (k_F1_poids_F1_F2 + k_F1_max);
        l_minimum_poids_F1 := (k_F1 - 1.0) / k_F2_F1;

        FOR l_indice_F1 := 1 TO k_F1_max DO
          FOR l_indice_F2 := 1 TO nombre_neurones_F2 DO
            BEGIN
              neurone_F2[l_indice_F2].poids_F1_F2[l_indice_F1] := Random * l_max_poids_F2;
              neurone_F1[l_indice_F1].poids_F2_F1[l_indice_F2] :=
                  Random * (1 - l_minimum_poids_F1) + l_minimum_poids_F1;
            END;

        k_poids_F1_F2 := k_F1_F2 * l_max_poids_F2 / 2;
      END;
    END;

  PROCEDURE itere;
    VAR l_iteration: Integer;
    BEGIN
      initialise_F1_et_F2(l_indice_caractere);

      IF g_exemple_1
        THEN BEGIN
            affiche_reseau; stoppe_imprime;
          END
        ELSE BEGIN
            GotoXY(1, 1); Write(Chr(64 + l_indice_caractere), ' / ', k_caracteres_max);
          END;

      GotoXY(1, 2); Write('    / ', k_iteration_max);
      FOR l_iteration := 0 TO k_iteration_max DO
      BEGIN
        GotoXY(1, 2); Write(l_iteration:3);

        calcule_un_cycle(apprentissage);
        IF g_exemple_1
          THEN affiche_reseau
          ELSE affiche_reseau_2;

        IF g_arret
          THEN stoppe_imprime;

        (* -- remet le feed_back en video normale *)
        WITH g_couche_2 DO
          IF indice_F2_en_resonnance_precedent <> indice_F2_en_resonnance
            THEN affiche_feed_back(indice_F2_en_resonnance_precedent, False);
      END;
    END;

  BEGIN
    affiche_curseur(curseur_eteint); ClrScr;

    initialise_les_poids;
    affiche_tous_les_feed_back;

    g_vigilence := k_vigilence_apprentissage;

    WITH g_entree DO
      FOR l_indice_caractere := 1 TO nombre_caracteres_utilises DO
      BEGIN
        itere;

        (* -- memorise la categorie d'encodage du caractere *)
        entree[l_indice_caractere].categorie_caractere := g_couche_2.indice_F2_en_resonnance;

        (* -- remet le feed_back en video normale *)
        affiche_feed_back(g_couche_2.indice_F2_en_resonnance, False);
        IF g_test
          THEN stoppe;
        IF g_arret
          THEN ReadLn;
      END;

    GotoXY(1, 23);
    affiche_curseur(curseur_visible);
  END;

PROCEDURE reconnais_caractere;
  VAR l_caractere, l_iteration: Integer;
      l_echec: Integer;
  BEGIN
    WITH g_couche_2 DO
    BEGIN
      g_vigilence := k_vigilence_reconnaissance;

      l_echec := 0;
      ClrScr;

      affiche_tous_les_feed_back;

      FOR l_caractere := 1 TO g_entree.nombre_caracteres_utilises DO
      BEGIN
        initialise_F1_et_F2(l_caractere);

        (* -- repete nombre de neurones_F2 * 2 fois pour pouvoir voir tous les Reset *)
        (* -- et donc l'ordre dans lequel les neurones de F2 sont actives *)
        FOR l_iteration := 1 TO Succ(g_couche_2.nombre_neurones_F2) * 2 DO
          calcule_un_cycle(reconnaissance);

        affiche_reseau_2;
        (* -- affiche le gagnant *)
        affiche_feed_back(indice_F2_en_resonnance, True);

        (* -- la categorie est-elle la bonne ? *)
        GotoXY(1, 1);
        Write(Chr(64 + l_caractere), ' ', indice_F2_en_resonnance:2);
        IF g_entree.entree[l_caractere].categorie_caractere <> indice_F2_en_resonnance
          THEN
            BEGIN
              l_echec := Succ(l_echec);
              Write('NON');
            END
          ELSE Write('OUI');

        (* -- statistique *)
        GotoXY(1, 2);
        Write(l_caractere - l_echec:2, ' SUR ', l_caractere);
        stoppe;

        (* -- remet le gagnant en video normale *)
        affiche_feed_back(indice_F2_en_resonnance, False);
      END;
    END;

    GotoXY(1, 23);
    affiche_curseur(curseur_visible);
  END;

PROCEDURE calcule_nombre_neurones_F2;
  BEGIN
    WITH g_entree, g_couche_2 DO
      IF g_exemple_1
        THEN BEGIN
            nombre_caracteres_utilises := 3;
            nombre_neurones_F2 := 4;
          END
        ELSE BEGIN
            nombre_caracteres_utilises := 20;
            IF k_vigilence_apprentissage <= 0.1
              THEN nombre_neurones_F2 := 2
              ELSE
                IF k_vigilence_apprentissage <= 0.3
                  THEN nombre_neurones_F2 := 3
                  ELSE
                    IF k_vigilence_apprentissage <= 0.4
                      THEN nombre_neurones_F2 := 4
                      ELSE
                        IF k_vigilence_apprentissage <= 0.5
                          THEN nombre_neurones_F2 := 5
                          ELSE
                            IF k_vigilence_apprentissage <= 0.6
                              THEN nombre_neurones_F2 := 7
                              ELSE
                                IF k_vigilence_apprentissage <= 0.7
                                  THEN nombre_neurones_F2 := 8
                                  ELSE
                                    IF k_vigilence_apprentissage <= 0.8
                                      THEN nombre_neurones_F2 := 10
                                      ELSE
                                        IF k_vigilence_apprentissage <= 0.9
                                          THEN nombre_neurones_F2 := 12
                                          ELSE
                                            BEGIN
                                              nombre_neurones_F2 := k_F2_max;
                                              nombre_caracteres_utilises := 16;
                                            END;
          END;
  END;

PROCEDURE initialise;
  BEGIN
    FillChar(g_entree, SizeOf(g_entree), 0);
    FillChar(g_couche_1, SizeOf(g_couche_1), 0);
    FillChar(g_couche_2, SizeOf(g_couche_2), 0);

    g_nom_fichier := 'A';

    g_couche_2.indice_F2_en_resonnance := 1;
    g_couche_2.indice_F2_en_resonnance_precedent := 1;
{
    g_exemple_1 := True; g_test := False; g_arret := True;
}
    g_exemple_1 := False; g_test := False; g_arret := True;
    calcule_nombre_neurones_F2;
  END;

BEGIN (* main *)
  initialise;
  REPEAT
    WriteLn;
    Write('Apprent: ', k_vigilence_apprentissage:3:2,
          ', Reconn: ', k_vigilence_reconnaissance:3:2,
          ', Nb Car: ', g_entree.nombre_caracteres_utilises,
          ', Nb Categ Sortie: ', g_couche_2.nombre_neurones_F2,
          ', -> ', g_nom_fichier);
    WriteLn;

    Write('[A]pprends, [R]econnais, Parame[t]res, [Q]uitte ?');
    g_choix := ReadKey; WriteLn(g_choix);
    CASE g_choix OF
      ' ': BEGIN
             TextColor(White); TextBackground(Black);
             ClrScr;
           END;
      'a': entraine_reseau;
      'r': reconnais_caractere;
      't': g_test := NOT g_test
    END;
  UNTIL g_choix = 'q';
END.