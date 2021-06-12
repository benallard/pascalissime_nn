(* 001 iverifie *)
(* 19 oct 92 *)

procedure verifie_resultats;
  var l_statistiques: array[1..k_sortie_max] of Integer;
      l_statistique_exemplaires: array[1..k_exemplaire_max] of Integer;

  procedure calcule_avec_neurones_entree_figes;
    var l_exemplaire: Integer;
        l_sortie: Integer;
        l_ok: Boolean;

    procedure initialise_neurones_entree(p_exemplaire: Integer);
      var l_neurone, l_cache: Integer;
      begin
        (* -- les neurones visibles sont figes *)
        for l_neurone := 1 to k_entree_max do
          g_reseau[l_neurone].valeur_sortie := k_exemplaire[p_exemplaire, l_neurone];

        (* -- initialise les neurones caches: valeur aleatoire *)
        for l_neurone := k_entree_max + 1 to k_entree_max + k_sortie_max + k_cache_max do
          g_reseau[l_neurone].valeur_sortie := Round(Random + 0.1);

        affiche_le_reseau(4);
      end;

    procedure calcule_sortie_neurones_entree_figes(p_temperature: Integer);
      var l_cumul: Real;
          l_neurone_active: Integer;
          l_neurone: Integer;
          l_cache: Integer;
          l_resultat: Integer;
      begin
        (* -- ?? ici devrait tirer le neurone qu'il faut activer au sort *)
        WriteLn(k_entree_max + 1, ' ', k_neurone_max);

        for l_neurone_active := k_entree_max + 1 to k_neurone_max do
        begin
          l_cumul := 0;
          (* -- les valeurs des entrees *)
          for l_neurone := 1 to k_neurone_max do
            with g_reseau[l_neurone] do
              if l_neurone <> l_neurone_active
                then l_cumul := l_cumul + valeur_sortie * poids[l_neurone_active];

          GotoXY(1, 2); Write('CU ', l_cumul:6:3, ' ');
          calcule_probabilite(-l_cumul / p_temperature, l_resultat);
          g_reseau[l_neurone_active].valeur_sortie := l_resultat;

          GotoXY(2, f_ligne_neurone(l_neurone_active));
          Write('->', l_resultat);
          stoppe_niveau(1);
        end;
      end;

    procedure affectue_un_programme_de_recuit_neurones_entree_figes;
      var l_pallier, l_iteration: Integer;
      begin
        for l_pallier :=  1 to k_pallier_recuit_max do
        begin
          GotoXY(40, 1); Write('PALLIER:', l_pallier:3, '/', k_pallier_recuit_max);

          with vi_programme_de_recuit[l_pallier] do
          begin
            for l_iteration := 1 to iteration do
            begin
              GotoXY(59, 1); Write('It=', l_iteration:3, '/', iteration:2,
                     ' T= ', temperature:2);
              calcule_sortie_neurones_entree_figes(temperature);
            end;
          end;
        end;
      end;
    
  begin (* calcule_avec_neurones_entree_figes *)
    (* -- pour chaquer exemplaire: *)
    for l_exemplaire := 1 to k_exemplaire_max do
    begin
      GotoXY(24, 1); Write('EXEMPLAIRE: ', l_exemplaire, ' / ', k_exemplaire_max);
      initialise_neurones_entree(l_exemplaire);

      effectue_un_programme_de_recuit_neurones_entree_figes;

      l_ok := True;
      for l_sortie := 1 to k_sortie_max do
      begin
        (* -- la valeur attendue *)
        GotoXY(7, f_ligne_neurone(k_entree_max + l_sortie));
        Write(k_exemplaite[l_exemplaire, k_entree_max + l_sortie], '*');

        if g_reseau[k_entree_max + l_sortie].valeur_sortie = 
              k_exemplaire[l_exemplaire, k_entree_max + l_sortie]
          then Inc(l_statistiques[l_sortie])
          else l_ok := False;

        Write(l_statistiques[l_sortie]:3)
      end;

      if l_ok
        then Inc(l_statistique_exemplaires[l_exemplaire]);
      GotoXY(9+l_exemplaire * 3, f_ligne_neurone(k_entree_max + k_sortie_max + 1));
      Write(l_statistique_exemplaires[l_exemplaire]);
    end;
  end;

var l_essai, l_exemplaire: Integer;

begin (* verifie_resultats *)
  GotoXY(1, 24); ClrEol; Write('VERIFIE');
  FillChar(l_statistiques, SizeOf(l_statistiques), 0);
  FillChar(l_statistique_exemplaires, SizeOf(l_statistique_exemplaires), 0);

  for l_essai := 1 to k_cycle_verification do
  begin
    GotoXY(6, 1); Write(l_essai:3);
    calcule_avec_neurones_entree_figes;
  end;

  GotoXY(1, 24);
  Write(l_statistiques[1]:3, l_statistiques[2]:3, ' --- ');
  for l_exemplaire := 1 to k_exemplaire_max do
    Write(l_statistique_exemplaires[l_exemplaire]:4);
end;

(* -- fin iverifie *)