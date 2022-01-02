(* 001 cascade2 *)
(* 07 mar 95 *)

(*$r+*)
program cascade2;
uses cthreads, Crt, ptcGraph;

const k_entree = 6;
type t_couche_entree = array [0.. k_entree - 1] of Real;

const k_cache_max = 3;
type t_neurone_cache = record
                         biais: Real;
                         poids: array [0.. k_entree + k_cache_max - 1] of Real;
                         activation, sortie_calculee: Real;
                         
                         delta_biais: Real;
                         delta_poids: array[0..k_entree + k_cache_max - 1] of Real;
                       end;
     t_couche_cache = array [0.. k_cache_max - 1] of t_neurone_cache;

const k_sortie = 1;
type t_neurone_sortie = record
                          biais: Real;
                          poids: array [0.. k_entree + k_cache_max - 1] of Real;
                          activation, sortie_calculee, erreur, sortie_desiree: Real;
                        end;
     t_couche_sortie = array[0..k_sortie - 1] of t_neurone_sortie;
var g_reseau: record
                couche_entree: t_couche_entree;
                couche_cachee: t_couche_cache;
                couche_sortie: t_couche_sortie;

                nombre_couches_cachees: Integer;
                numero_passe: Integer;
              end;

(*$i imackey *)

(*$r+*)

function f_transfert(p_valeur: Real): Real;
  begin
    if Abs(p_valeur) < 1e-10
      then f_transfert := 0.5
      else
        if Abs(p_valeur) > 1e1
          then f_transfert := 0.99
          else f_transfert := 1 / (1.0 + Exp(-p_valeur));
  end;

function f_derivee_fonction_transfert(p_reel: Real): Real;
  begin
    f_derivee_fonction_transfert := f_transfert(p_reel) * (1 - f_transfert(p_reel));
  end;

const k_essai_max = 3;
      k_temps_max = 200;
      k_poids_initial = 0.2;
      k_apprentissage = 0.05;
      k_colonne_sortie = 60;

      k_poids_initial_poule = 0.2;

      k_essai_poule_max = 40;
      k_poule_max = 3;
      k_apprentissage_poule = 0.03;

      k_colonne_phase = 12;
      k_colonne_essai = 20;
      k_colonne_periode = 40;

      k_colonne_cache = 10;

(* -- les erreurs de la passe precedentes *)
type t_erreur = array[0..k_temps_max - 1] of Real;
var g_erreur: t_erreur;
    g_variance: Real;

procedure initialise_serie;
  var l_entree: Integer;
  begin
    initialise_mackey; saute_mackey(100);

    for l_entree := 0 to k_entree - 1 do
      g_reseau.couche_entree[l_entree] := f_mackey;

    g_reseau.couche_sortie[0].sortie_desiree := f_mackey;
  end; (* initialise_serie *)

procedure presente_exemplaire;
  var l_periode: Integer;
  begin
    with g_reseau do
    begin
      (* -- ripe toutes les valeurs d'une periode *)
      for l_periode := 0 to k_entree - 1 do
        couche_entree[l_periode] := couche_entree[l_periode + 1];

      (* -- la sortie comme derniere entree *)
      couche_entree[k_entree - 1] := couche_sortie[0].sortie_desiree;

      (* -- la nouvelle valeur *)
      couche_sortie[0].sortie_desiree := f_mackey;
    end;
  end; (* presente_exemplaire *)

procedure propage_vers_l_avant;
  var l_sortie, l_cache, l_poids: Integer;
  begin
    with g_reseau do
    begin
      for l_cache := 0 to nombre_couches_cachees - 1 do
        with couche_cachee[l_cache] do
        begin
          activation := biais;

          (* -- entree -> couche cachee *)
          for l_poids := 0 to k_entree - 1 do
            activation := activation + couche_entree[l_poids] * poids[l_poids];

          (* -- couche cachees precedentes -> couches caches suivantes *)
          for l_poids := 0 to nombre_couches_cachees - 2 do
            activation := activation + couche_cachee[l_poids].sortie_calculee * poids[k_entree + l_poids];

          sortie_calculee := f_transfert(activation);
        end;
  
      for l_sortie := 0 to k_sortie - 1 do
        with couche_sortie[l_sortie] do
        begin
          activation := biais;

          (* -- entree -> sortie *)
          for l_poids := 0 to k_entree - 1 do
            activation := activation + couche_entree[l_poids] * poids[l_poids];

          (* -- couche cachees -> sortie *)
          for l_poids := 0 to nombre_couches_cachees - 1 do
            activation := activation + couche_cachee[l_poids].sortie_calculee * poids[k_entree + l_poids];

          sortie_calculee := f_transfert(activation);
        end;
    end; (* with *)
  end; (* propage_vers_l_avant *)

procedure calcule;

  procedure initialise_reseau;
    var l_sortie, l_poids: Integer;
    begin
      FillChar(g_reseau, SizeOf(g_reseau), 0);

      with g_reseau do
      begin
        for l_sortie := 0 to k_sortie - 1 do
          with couche_sortie[l_sortie] do
          begin
            biais := k_poids_initial * Random;
            for l_poids := 0 to k_entree + k_cache_max - 1 do
              poids[l_poids] := k_poids_initial * Random;
          end;
        nombre_couches_cachees := 0;
      end; (* with *)

      FillChar(g_erreur, SizeOf(g_erreur), 0);
    end; (* initialise_reseau *)

  procedure affiche_reseau;
    var l_entree, l_cache, l_cache_precedent, l_sortie: Integer;
        l_poids: Integer;
        l_colonne_cache: Integer;
    begin
      with g_reseau do
      begin
        for l_entree := 0 to k_entree - 1 do
        begin
          GotoXY(1, 3 + l_entree * 3); Write(couche_entree[l_entree]:8:5);
        end;

        for l_cache := 0 to nombre_couches_cachees - 1 do
          with couche_cachee[l_cache] do
          begin
            l_colonne_cache := k_colonne_cache + l_cache * 9;
            if l_colonne_cache > 60
              then l_colonne_cache := k_colonne_cache + 3 * 9; 
            
            GotoXY(l_colonne_cache - 1, 3); Write(biais:8:3);
            for l_entree := 0 to k_entree - 1 do
            begin
              GotoXY(l_colonne_cache, 3 + 1 + l_entree);
              Write(poids[l_entree]:8:3);
            end;

            for l_cache_precedent := 0 to l_cache - 1 do
            begin
              GotoXY(l_colonne_cache, 3 + k_entree + 1 + l_cache_precedent);
              Write(poids[k_entree + l_cache_precedent]:8:3);
            end;
          end;

        for l_sortie := 0 to k_sortie - 1 do
          with couche_sortie[l_sortie] do
          begin
            GotoXY(k_colonne_sortie - 1, 3 + l_sortie * 7); Write(biais:5:2);
            
            for l_poids := 0 to k_entree - 1 do
            begin
              GotoXY(k_colonne_sortie, 3 + 1 + l_sortie * 7 + l_poids);
              Write(poids[l_poids]:5:2);
            end;

            for l_poids := 0 to nombre_couches_cachees - 1 do
            begin
              GotoXY(k_colonne_sortie, 3 + k_entree + 1 + l_sortie * 7 + l_poids);
              Write(poids[k_entree + l_poids]:5:2);
            end;

            GotoXY(k_colonne_sortie + 6, 3 + l_sortie * 3); Write(sortie_desiree:8:5);
            GotoXY(k_colonne_sortie + 6, 3 + l_sortie * 3 + 1); Write(sortie_calculee:5:2);
          end; (* with *)
      end; (* with *)
    end; (* affiche_reseau *)

  (* -- entraine les poids de la couche de sortie *)

  procedure ajuste_poids_sortie;
    var l_essai: Integer;
        l_erreur_cumulee: Real;

    procedure entraine_serie;

      procedure ajuste_poids;
        var l_sortie: integer;
            l_poids: Integer;
        begin
          with g_reseau do
          begin
            for l_sortie := 0 to k_sortie - 1 do
              with couche_sortie[l_sortie] do
              begin
                erreur := sortie_desiree - sortie_calculee;
                l_erreur_cumulee := l_erreur_cumulee + erreur;

                biais := biais + k_apprentissage * erreur;
                for l_poids := 0 to k_entree - 1 do
                  poids[l_poids] := poids[l_poids] + k_apprentissage * erreur * couche_entree[l_poids];
              end; 
          end; (* with *)
        end; (* ajuste_poids *)
  
      var l_temps: Integer;

      begin (* entraine_serie *)
        with g_reseau do
        begin
          initialise_serie;
          l_erreur_cumulee := 0;

          for l_temps := 0 to k_temps_max - 1 do
            begin
              GotoXY(k_colonne_periode, 1); Write('Periode ', l_temps:4, ' / ', k_temps_max:4, ',');

              presente_exemplaire;
              propage_vers_l_avant;
              ajuste_poids;

              (* -- si c'est le dernier essai, memorise l'erreur cumulee *)
              if l_essai = k_essai_max
                then g_erreur[l_temps] := couche_sortie[0].erreur;

              affiche_reseau;
            end; (* for l_temps *)

          GotoXY(60, 1); Write(l_erreur_cumulee/k_temps_max:8:3);
        end; (* with *)
      end; (* entraine_serie *)

    procedure calcule_variance_erreur;
      var l_temps: Integer;
      begin
        g_variance := 0;
        for l_temps := 0 to k_temps_max - 1 do
          g_variance := g_variance + Sqr(g_erreur[l_temps]);
      end; (* calcule_variance_erreur *)

    begin (* ajuste_poids_sortie *)
      GotoXY(k_colonne_phase, 1); Write('Sortie');

      for l_essai := 1 to k_essai_max do
      begin
        GotoXY(k_colonne_essai, 1); Write('Essai ', l_essai:4, ' / ', k_essai_max:4, ',');
        entraine_serie;
      end; (* for l_essai *)

      calcule_variance_erreur;
    end; (* ajuste_poids_sortie *)
  
  (* -- ajoute graduellement des neurones intermediaires *)

  procedure ajoute_couche_cachee;
    type t_poule = record
                     neurone_poule: t_neurone_cache;
                     correlation_poule, correlation_poule_2: Real;
                     variance_poule: Real;
                   end;
    var l_poule_de_neurones: array[0..k_poule_max-1] of t_poule;
        l_nombre_poids_poule: Integer;

    procedure cree_poule;
      var l_poule, l_poids: Integer;
      begin
        with g_reseau do
        begin
          FillChar(l_poule_de_neurones, SizeOf(l_poule_de_neurones), 0);
          l_nombre_poids_poule := k_entree + nombre_couches_cachees;

          for l_poule := 0 to k_poule_max - 1 do
            with l_poule_de_neurones[l_poule].neurone_poule do
            begin
              biais := k_poids_initial_poule * Random;

              for l_poids := 0 to l_nombre_poids_poule - 1 do
                poids[l_poids] := k_poids_initial_poule * Random;
            end; (* with *)
        end; (* with g_reseau *)
      end; (* cree_poule *)

    procedure entraine_poule;
      var l_essai: Integer;
          l_erreur_cumulee: Real;

      procedure entraine_serie_poule;
        var l_poule: Integer;

        procedure propage_une_poule;
          var l_temps: Integer;

          procedure propage_entree_cachee_poule;
            var l_cache, l_poids: Integer;
                l_reel: Real;
            begin
              with g_reseau do
              begin
                (* -- calcule les sortie des couches cachees existantes *)
                for l_cache := 0 to nombre_couches_cachees - 1 do
                  with couche_cachee[l_cache] do
                  begin
                    activation := biais;

                    (* -- entree -> couche cachee *)
                    for l_poids := 0 to k_entree - 1 do
                      activation := activation + poids[l_poids] * couche_entree[l_poids];

                    (* -- couches cacheeds precedentes -> couches cachees suivantes *)
                    for l_poids := 0 to nombre_couches_cachees - 2 do
                      activation := activation
                       + poids[k_entree + l_poids] * couche_cachee[l_poids].sortie_calculee;

                    sortie_calculee := f_transfert(activation);
                  end; (* with *)
                
                with l_poule_de_neurones[l_poule], neurone_poule do
                begin
                  activation := biais;

                  (* -- entree -> poule *)
                  for l_poids := 0 to k_entree - 1 do
                    activation := activation + poids[l_poids] * couche_entree[l_poids];

                  (* -- couches cachees -> poule *)
                  for l_poids := 0 to nombre_couches_cachees - 1 do
                    activation := activation + poids[k_entree + l_poids]
                      * couche_cachee[l_poids].sortie_calculee;

                  sortie_calculee := f_transfert(activation);

                  (* -- calcule la correlation sortie_poule / erreur precedente *)
                  correlation_poule := correlation_poule + g_erreur[l_temps] * sortie_calculee;
                  variance_poule := variance_poule + Sqr(sortie_calculee);

                  (* -- calcule a la volee les elements de corrections *)
                  delta_biais := delta_biais
                    + g_erreur[l_temps] * 1 * f_derivee_fonction_transfert(activation);

                  for l_poids := 0 to k_entree - 1 do
                    delta_poids[l_poids] := delta_poids[l_poids]
                      + g_erreur[l_temps] * couche_entree[l_poids]
                      * f_derivee_fonction_transfert(activation);
                  for l_poids := 0 to nombre_couches_cachees - 1 do
                    delta_poids[k_entree + l_poids] := delta_poids[k_entree + l_poids]
                      + g_erreur[l_temps] * couche_cachee[l_poids].sortie_calculee
                      * f_derivee_fonction_transfert(activation);
                end; (* with poule *)
              end; (* with g_reseau *)
            end; (* propage_entree_cachee_poule *)

          begin (* propage_une_poule *)
            for l_temps := 0 to k_temps_max - 1 do
            begin
              GotoXY(k_colonne_periode + 20, 1); Write('Periode ', l_temps:4, ' / ', k_temps_max:4);
              presente_exemplaire;

              propage_entree_cachee_poule;
              affiche_reseau;
            end; (* for l_temps *)
          end; (* propage_une_poule *)
        
        procedure ajuste_poids_poule;
          var l_signe: Real;
              l_poids: Integer;
          begin
            with g_reseau, l_poule_de_neurones[l_poule], neurone_poule do
            begin
              if correlation_poule > 0
                then l_signe := -1
                else l_signe := 1;

              biais := biais + l_signe * k_apprentissage_poule * delta_biais;
              for l_poids := 0 to k_entree + nombre_couches_cachees - 1 do
                poids[l_poids] := poids[l_poids]
                  + l_signe * k_apprentissage_poule * delta_poids[l_poids];
            end; (* with *)
          end; (* ajuste_poids_poule *)

        procedure affiche_poule;
          var l_poids: Integer;
              l_colonne, l_ligne: Integer;
          begin
            l_colonne := k_colonne_cache + g_reseau.nombre_couches_cachees * 9;
            if l_colonne > 45
              then l_colonne := k_colonne_cache + 3 * 9;

            with l_poule_de_neurones[l_poule] do
            begin
              l_ligne := 3 + l_poule * (1 + k_entree + g_reseau.nombre_couches_cachees);
              if l_ligne <= 25
                then begin
                    GotoXY(l_colonne - 1, l_ligne);
                    Write(neurone_poule.biais:8:3);

                    for l_poids := 0 to k_entree + g_reseau.nombre_couches_cachees - 1 do
                      if l_ligne + 1 + l_poids <= 25
                        then begin
                            GotoXY(l_colonne, l_ligne + 1+l_poids);
                            Write(neurone_poule.poids[l_poids]:8:3);
                          end;
                  end;

              GoToXY(l_colonne + 9, 3 + 3 * l_poule); Write(correlation_poule: 10: 5);
              GoToXY(l_colonne + 9, 3 + 3 * l_poule + 1); Write(correlation_poule_2: 10: 5);
            end; (* with l_poule *)
          end; (* affiche_poule *)

        var l_poids: Integer;

        begin (* entraine_serie_poule *)
          initialise_serie;

          for l_poule := 0 to k_poule_max - 1 do
            with l_poule_de_neurones[l_poule] do
            begin
              GotoXY(k_colonne_periode, 1); Write('Poule ', l_poule:4, ' / ', k_poule_max:3, ', ');

              correlation_poule := 0;
              variance_poule := 0;
              for l_poids := 0 to k_entree - 1 do
                neurone_poule.delta_poids[l_poids] := 0;

              propage_une_poule;

              (* -- normalise *)
              correlation_poule_2 := correlation_poule / (Sqrt(g_variance) * Sqrt(variance_poule));

              ajuste_poids_poule;

              affiche_poule;
            end; (* with l_poule *)
        end; (* entraine_serie_poule *)

      begin (* entraine_poule *)
        GotoXY(k_colonne_phase, 1); Write('Poule'); ClrEol;
        l_essai := 1;
        repeat
          GotoXY(k_colonne_essai, 1); Write('Essai ', l_essai:4, ' / ', k_essai_poule_max:4, ', ');
          entraine_serie_poule;

          Inc(l_essai);
        until (l_essai >= k_essai_poule_max) and (l_poule_de_neurones[0].correlation_poule > 0);
      end; (* entraine_poule *)

    procedure selectionne_et_installe_meilleur;
      var l_poule: Integer;
          l_max : Real;
          l_indice_max: Integer;
          l_poids: Integer;
      begin
        (* -- determine le meilleur de la poule *)
        l_max := -1e30;
        for l_poule := 0 to k_poule_max - 1 do
          if l_poule_de_neurones[l_poule].correlation_poule > l_max
            then begin
                l_indice_max := l_poule;
                l_max := l_poule_de_neurones[l_poule].correlation_poule;
              end;

        (* -- pour verif *)
        with g_reseau do
        begin
          (* -- installe le vainqueur dans le reseau *)
          couche_cachee[nombre_couches_cachees]:= 
            l_poule_de_neurones[l_indice_max].neurone_poule;

          (* -- inverse les poids *)
          with couche_cachee[nombre_couches_cachees] do
          begin
            biais := -biais;
            for l_poids := 0 to k_entree + nombre_couches_cachees - 1 do
              poids[l_poids] := -poids[l_poids];
          end;

          Inc(nombre_couches_cachees);
        end; (* with g_reseau *)
      end; (* selectionne_et_installe_meilleur *)

    begin (* ajoute_couches_cachees *)
      with g_reseau do
      begin
        cree_poule;
        entraine_poule;
        selectionne_et_installe_meilleur;
      end; (* with g_reseau *)
    end; (* ajoute_couches_cachees *)

  var l_stoppe: Char;

  begin (* calcule *)
    initialise_reseau;

    ClrScr;
    repeat
      GotoXY(1, 1); Write('Passe ', g_reseau.numero_passe: 2, ', '); ClrEol;
      ajuste_poids_sortie;
      ajoute_couche_cachee;

{
      l_stoppe := ReadKey;
}
      l_stoppe := ' ';
      Inc(g_reseau.numero_passe);
      ClrScr;
    until (l_stoppe = 'q') or (g_reseau.numero_passe >= k_cache_max);

    GotoXY(1, 24);
  end; (* calcule *)

(*$i idessmac *)

procedure dessine;
  var l_indice, l_temps: Integer;
  begin
    initialise_mackey;
    initialise_courbe(k_temps_max);

    for l_indice := 0 to k_temps_max - 1 do
    (*$r-*)
      g_courbe^[l_indice] := f_mackey;
    (*$r-*)

    initialise_mode_graphique;

    dessine_courbe(200, 380);

    initialise_serie;
    for l_temps := 0 to k_temps_max - 1 do
    begin
      presente_exemplaire;
      propage_vers_l_avant;
      (*$r-*)
      g_courbe^[l_temps] := g_reseau.couche_sortie[0].sortie_calculee;
      (*$r+*)
    end;

    dessine_courbe(100, 200);

    termine_mode_graphique;
  end; (* dessine *)

procedure initialise;
  begin
    ClrScr;
  end;

var g_choix: Char;

begin
  initialise;

  repeat
    Write('(M)acKey, (C)alcule, (D)essine, (Q)uitte ? ');

    g_choix := Upcase(ReadKey); WriteLn(g_choix);
    case g_choix of
      ' ': ClrScr;
      'M': affiche_mackey;
      'C': calcule;
      'D': dessine;
    end;
  until g_choix = 'Q';
end.