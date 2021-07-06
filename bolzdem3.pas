(* 001 bolzdem3 *)
(* 30 jul 92 *)

{ complet: 300 cycles, 30 18, 27 20 sur 30. Difference 1.65 }
{ entree/sortie: 300 cycles, 26 23, 29, 27 sur 30. Difference 0.84 }

(*$r+*)
program reseau_neuronal_bolzman;
uses crt;
const k_entree_max = 2;
      k_sortie_max = 2;
      k_cache_max = 1;
      k_exemplaire_max = 4;
      k_neurone_max = k_entree_max + k_sortie_max + k_cache_max;

      (* -- architecture complete ou entree / sortie *)
      k_architecture_complet_ou_entree_sortie = True;

      k_pallier_recuit_max = 4;
      k_coefficient_apprentissage = 0.3;

      k_cycles_apprentissage = 300;
      k_cycles_co_occurences_apprentissage = 5;
      k_cycles_verification = 30;
      k_saute_random = 70;
      k_periodicite_affichage = 300;
type t_un_exemple = array [1..k_entree_max + k_sortie_max] of 0..1;
     t_exemplaire = array [1..k_exemplaire_max] of t_un_exemple;

     t_neurone = record
                   valeur_sortie: Integer;
                   poids: array[1..k_neurone_max] of real;
                 end;

     t_pallier_de_recuit = record
                             temperature: Integer;
                             iteration: Integer;
                           end;
     t_programme_de_recuit = array [1..k_pallier_recuit_max] of t_pallier_de_recuit;

     t_co_occurence = array[1..k_neurone_max, 1..k_neurone_max] of real;

const k_exemplaire: t_exemplaire = 
        ((1,1,0, 1),
         (0, 1, 1, 1),
         (1, 0, 0, 1),
         (0, 0, 1, 0));


      vi_programme_de_recuit: t_programme_de_recuit = 
        ((temperature: 20; iteration: 1),
         (temperature: 10; iteration: 2),
         (temperature: 5; iteration: 4),
         (temperature: 1; iteration: 10));
      { autre essai: (20, 2), (13, 2), (9, 4), (7, 10); }
var g_choix: Char;

    g_reseau: array[1..k_neurone_max] of t_neurone;
    g_co_occurence_fige, g_co_occurence_libre: t_co_occurence;

    g_niveau: Integer;
    g_energie_moyenne, g_difference_moyenne: Real;

(*$i iaffbolz *)

procedure calcule_probabilite(p_valeur: real; var pv_valeur: Integer);
  (* -- laisse en global pour la mise au point: afficher la distribution *)
  var l_probabilite: Real;
      l_seuil: Real;
  begin
    l_probabilite := 1.0 / (1.0 + Exp(p_valeur));

    l_seuil := Random;
    Write('PRO', l_probabilite:5:2, l_seuil:5:2);
    if l_probabilite > l_seuil
      then pv_valeur := 1
      else pv_valeur := 0;

    Write(' ->', pv_valeur);
    (* -- la veleur avec une fonction de seuil non probabiliste *)
    if p_valeur > 0
      then Write(' (0)')
      else Write(' (1)');
  end;

procedure go;

  procedure initialise_les_poids;
    (* -- initialise les poids a des valeurs aleatoires dans ]-1, +1[ *)
    var l_neurone, l_connexion: integer;
        l_valeur: Real;
    begin
      for l_neurone := 1 to k_neurone_max do
        with g_reseau[l_neurone] do
        begin
          (* -- pas de connexion du neurone sur lui meme *)
          poids[l_neurone] := 0;

          for l_connexion := 1 to k_neurone_max do
          begin
            if l_connexion > l_neurone
              then begin
                  l_valeur := -1 + 2 * Random;

                  (* -- pour l'architecture entree / sortie, pas de connection entre les neurones d'entree *)
                  if not k_architecture_complet_ou_entree_sortie
                        and (l_neurone <= k_entree_max) and (l_connexion < k_entree_max)
                    then l_valeur := 0;

                  poids[l_connexion] := l_valeur;
                  (* -- la table des poids doir etre symetrique pour garantire la convergence *)
                  g_reseau[l_connexion].poids[l_neurone] := l_valeur;
                end;
          end;
        end;
    end;

    procedure calcule_energie;
      (* -- mise au point: verifie que le systeme converge un peu *)
      var l_neurone, l_connexion: Integer;
      begin
        for l_neurone := 1 to k_neurone_max do
          with g_reseau[l_neurone] do
            for l_connexion := 1 to k_neurone_max do
              g_energie_moyenne := g_energie_moyenne + valeur_sortie * poids[l_connexion]
                                   * g_reseau[l_connexion].valeur_sortie;
      end;
    
    procedure calcule_difference_moyenne;
      (* -- mise au point: verifie qe cette valeur tends vers 0 *)
      var l_neurone, l_connexion: Integer;
      begin
        for l_neurone := 1 to k_neurone_max do
          for l_connexion := 1 to k_neurone_max do
            if l_connexion <= l_neurone
              then g_difference_moyenne := g_difference_moyenne
                           + Abs(g_co_occurence_fige[l_neurone, l_connexion]
                                 - g_co_occurence_libre[l_neurone, l_connexion]);
      end;

    procedure entraine_le_reseau;

      procedure initialise_neurones(p_exemplaire: Integer);
        var l_neurone, l_cache: Integer;
        begin
          (* -- les neurones visibles sont figes aves les valeurs d'un exemplaire *)
          for l_neurone := 1 to k_entree_max + k_sortie_max do
            g_reseau[l_neurone].valeur_sortie := k_exemplaire[p_exemplaire, l_neurone];

          (* -- initialise les neurones caches: aleatoirement 0 ou 1 *)
          for l_cache := 1 to k_cache_max do
            g_reseau[k_entree_max + k_sortie_max + l_cache].valeur_sortie := Round(Random);
          affiche_le_reseau(0); stoppe_niveau(0);
        end;

      procedure calcule_avec_neurones_figes;
        var l_exemplaire: Integer;

        procedure calcule_sortie_figee(p_temperature: Integer);
          var l_cumul: Real;
              l_neurone: Integer;
              l_cache: Integer;
              l_resultat: Integer;
          begin
            (* -- ?? ici devrait tirer le neurone cache qu'il faut activer au sort *)
            for l_cache := 1 to k_cache_max do
            begin
              (* -- calcule le cumul pondere des entrees *)
              l_cumul := 0;
              for l_neurone := 1 to k_entree_max + k_sortie_max + k_cache_max do
                with g_reseau[l_neurone] do
                  if l_neurone <> k_entree_max + k_sortie_max + l_cache
                    then l_cumul := l_cumul
                      + valeur_sortie * poids[k_entree_max + k_sortie_max  + l_cache];

              (* -- calcule la sortie des neurone caches *)
              GotoXY(1, 2); Write(' NEU ', l_neurone : 2, ' CU ', l_cumul:7:3, ' ');
              calcule_probabilite(-l_cumul / p_temperature, l_resultat);
              g_reseau[k_entree_max + k_sortie_max + l_cache].valeur_sortie := l_resultat;

              GotoXY(1, f_ligne_neurone(k_entree_max + k_sortie_max + l_cache)); Write(l_resultat);
              stoppe_niveau(0);
            end;
          end;

        procedure effectue_un_programme_de_recuit_fige;
          var l_pallier, l_iteration: Integer;
          begin
            for l_pallier := 1 to k_pallier_recuit_max do
            begin
              GotoXY(40, 1); Write('PALLIER:', l_pallier:3, ' / ', k_pallier_recuit_max);

              with vi_programme_de_recuit[l_pallier] do
              begin
                for l_iteration := 1 to iteration do
                begin
                  GotoXY(59, 1); Write('It=', l_iteration:3, ' / ', iteration:2,
                     ', T= ', temperature:2);

                  calcule_sortie_figee(temperature);
                end;
              end;
            end;
          end;

        procedure calcule_co_occurences_figees;
          var l_iteration: Integer;
              l_neurone, l_connexion: Integer;
          begin
            GotoXY(40, 1); Write('EQUILIB:');

            for l_iteration := 1 to k_cycles_co_occurences_apprentissage do
            begin
              GotoXY(59, 1); Write('It=', l_iteration:3, '/', k_cycles_co_occurences_apprentissage:2, '           ');

              calcule_sortie_figee(vi_programme_de_recuit[k_pallier_recuit_max].temperature);

              for l_neurone := 1 to k_neurone_max do
                for l_connexion := 1 to k_neurone_max do
                  if (g_reseau[l_neurone].valeur_sortie = 1)
                      and (g_reseau[l_connexion].valeur_sortie = 1)
                    then g_co_occurence_fige[l_neurone, l_connexion] :=
                      g_co_occurence_fige[l_neurone, l_connexion]
                          + 1 / (k_exemplaire_max * k_cycles_co_occurences_apprentissage);

              affiche_le_reseau(0);
              affiche_les_co_occurences(3, g_co_occurence_fige, 0); stoppe_niveau(0);
            end;

            affiche_les_co_occurences(3, g_co_occurence_fige, 1);
          end;

        begin (* calcule_avec_neurone_figes *)
          GotoXY(18, 1); Write('FIGE');

          (* -- pour chaque exemplaire *)
          for l_exemplaire := 1 to k_exemplaire_max do
          begin
            GotoXY(24, 1); Write('EXEMPLAIRE: ', l_exemplaire, '/', k_exemplaire_max);

            initialise_neurones(l_exemplaire);
            effectue_un_programme_de_recuit_fige;
            calcule_co_occurences_figees;
          end;
        end;

      procedure calcule_avec_neurones_libres;
        var l_exemplaire: Integer;

        procedure calcule_sortie_libre(p_temperature: Integer);
          var l_cumul: Real;
              l_neurone_actif: Integer;
              l_neurone: Integer;
              l_cache: Integer;
              l_resultat: Integer;
              l_repetition, l_repetition_max: Integer;
          begin
            if k_architecture_complet_ou_entree_sortie
              then l_repetition_max := 2 * k_neurone_max
              else l_repetition_max := 2 * (k_sortie_max + k_cache_max);

            (* -- deux fois pour chaque neurone libre *)
            for l_repetition := 1 to l_repetition_max do
            begin
              if k_architecture_complet_ou_entree_sortie
                then l_neurone_actif := 1 + Random(k_neurone_max)
                else l_neurone_actif := 1 + k_entree_max + Random(k_sortie_max + k_cache_max);

              l_cumul := 0;
              (* -- les valeurs des entrees *)
              for l_neurone := 1 to k_neurone_max do
                with g_reseau[l_neurone] do
                  if l_neurone <> l_neurone_actif
                    then l_cumul := l_cumul + valeur_sortie * poids[l_neurone_actif];

              GotoXY(1, 2); Write('NEU ', l_neurone:2, ' CU ', l_cumul:7:3, '  ');
              calcule_probabilite(-l_cumul / p_temperature, l_resultat);
              g_reseau[l_neurone_actif].valeur_sortie := l_resultat;

              GotoXY(1, f_ligne_neurone(l_neurone_actif)); Write(l_resultat);
            end;
          end;
          
          procedure effectue_un_programme_de_recuit_libre;
            var l_pallier, l_iteration: Integer;
            begin
              for l_pallier :=  1 to k_pallier_recuit_max do
              begin
                GotoXY(40, 1); Write('PALLIER: ', l_pallier:3, '/', k_pallier_recuit_max);

                with vi_programme_de_recuit[l_pallier] do
                begin
                  for l_iteration := 1 to iteration do
                  begin
                    GotoXY(59, 1); Write('It=', l_iteration:3, '/', iteration:2,
                        ', T= ', temperature:2);
                    calcule_sortie_libre(temperature);
                  end;
                end;
              end;
            end;

          procedure calcule_co_occurences_libres;
            var l_iteration: Integer;
                l_neurone, l_connexion: Integer;
            begin
              GotoXY(40, 1); Write('EQUILIB: ');

              for l_iteration := 1 to k_cycles_co_occurences_apprentissage do
              begin
                GotoXY(59, 1); Write('It=', l_iteration:3, '/', k_cycles_co_occurences_apprentissage:2,
                      '        ');
                calcule_sortie_libre(vi_programme_de_recuit[k_pallier_recuit_max].temperature);

                for l_neurone := 1 to k_neurone_max do
                  for l_connexion := 1 to k_neurone_max do
                    if (g_reseau[l_neurone].valeur_sortie = 1)
                        and (g_reseau[l_connexion].valeur_sortie = 1)
                      then g_co_occurence_libre[l_neurone, l_connexion] :=
                          g_co_occurence_libre[l_neurone, l_connexion]
                            + 1 / (k_exemplaire_max * k_cycles_co_occurences_apprentissage);


                affiche_les_co_occurences(9, g_co_occurence_libre, 1);
              end;

              affiche_les_co_occurences(9, g_co_occurence_libre, 1);
              stoppe_niveau(2);
            end;

        begin (* calcule_avec_neurone_libres *)
          GotoXY(18, 1); Write('LIBRE');

          (* -- pour chaque exemplaire: *)
          for l_exemplaire := 1 to k_exemplaire_max do
          begin
            GotoXY(24, 1); Write('EXEMPLAIRE: ', l_exemplaire, '/', k_exemplaire_max);

            initialise_neurones(l_exemplaire);
            effectue_un_programme_de_recuit_libre;
            initialise_neurones(l_exemplaire);
            calcule_co_occurences_libres;

            calcule_energie;
          end;
        end;

      procedure ajuste_les_poids;
        var l_neurone, l_connexion: Integer;
        begin

          for l_neurone := 1 to k_neurone_max do
            for l_connexion := 1 to k_neurone_max do
              with g_reseau[l_neurone] do
                if l_neurone <> l_connexion
                  then begin
                      poids[l_connexion] := poids[l_connexion]
                        + k_coefficient_apprentissage
                          * (g_co_occurence_fige[l_neurone, l_connexion]
                            - g_co_occurence_libre[l_neurone, l_connexion]);

                      affiche_le_reseau(3);
                      affiche_toutes_co_occurences(3, 9, 15, 3);
                      stoppe_niveau(2);
                    end;

          calcule_difference_moyenne;
        end;

      begin
        calcule_avec_neurones_figes;
        calcule_avec_neurones_libres;
        ajuste_les_poids;
      end;

    (*$i iverifie *)

  var l_essai: Integer;

  begin (* go *)
    ClrScr;
    initialise_les_poids;
    affiche_le_reseau(6); stoppe_niveau(1);
  end;

procedure essai_proba;
  var l_valeur: Integer;
      l_indice: Integer;
  begin
    ClrScr;
    for l_indice := -7 to 7 do
    begin
      Write(l_indice);
      calcule_probabilite(-l_indice / 20, l_valeur);
      calcule_probabilite(-l_indice / 3, l_valeur);
      WriteLn;
    end;
  end;

procedure initialise;
  var l_pallier: Integer;
      l_saute_random: Integer; l_saute: Real;
  begin
    (* -- un randomize reproductible *)
    for l_saute_random := 1 to k_saute_random do
      l_saute := Random;

    FillChar(g_reseau, SizeOf(g_reseau), 0);

    g_niveau := 0;
  end;

begin
  ClrScr;
  initialise;
  repeat
    WriteLn;
    Write('Go, Sortie, Quitte?');
    g_choix := ReadKey; Write(g_choix); WriteLn;
    case g_choix of
      ' ': ClrScr;
      'g': go;
      'c': essai_proba;
      'n': ReadLn(g_niveau);
    end;
  until g_choix = 'q';
end.