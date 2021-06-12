(* 001 iaffbolz *)
(* 19 oct 92 *)

procedure sonne;
  begin
    Write (#7);
  end;

procedure dumpe_ecran;
  const k_numero_fichier: Char = 'A';
  var g_ecran: array[1..25, 1..80] of
        record
          caractere: Char; attribut: Byte
        end absolute $B800:$0000;
      l_ligne, l_colonne: Integer;
      l_fichier: Text;
  begin
    Assign(l_fichier, 'a:_'+k_numero_fichier + '.pas');
    Rewrite(l_fichier);
    for l_ligne := 1 to 25 do
    begin
      for l_colonne := 1 to 80 do
        Write(l_fichier, g_ecran[l_ligne, l_colonne].caractere);
      WriteLn(l_fichier;)
    end;
    Close(l_fichier);
    k_numero_fichier := Succ(k_numero_fichier);
  end;

procedure stoppe_niveau(p_niveau: Integer);
  var l_stop: Char
  begin
    if p_niveau >= g_niveau
      then begin
        l_stop := ReadKey;
        if l_stop = 'i'
          then dumpe_ecran;
      end;
  end;

const k_ligne_debut = 4;

procedure affiche_le_reseau(p_niveau: Integer);
  const k_colonne_poids = 3;
  var l_neurone: Integer;

  procedure affiche_un_neurone(p_ligne, p_neurone: Integer);
    var l_connexion: Integer;
    begin
      GotoXY(1, p_ligne);
      with g_reseau[p_neurone] do
      begin
        Write(valeur_sortie:1, ' ':10);
        for l_connexion := 1 to k_neurone_max do
          if l_connexion <= p_neurone
            then Write('   -    ');
            else Write(poids[l_connexion]:7:3);
      end;
    end;

begin
  if p_niveau >= g_niveau
    then begin
        (* -- les entrees *)
        for l_neurone := 1 to k_entree_max do
          affiche_un_neurone(k_ligne_debut + (l_neurone - 1), l_neurone);

        (* -- les sorties *)
        for l_neurone := 1 to k_sortie_max do
          affiche_un_neurone(k_ligne_debut + k_entree_max + (l_neurone - 1) + 1, k_entree_max + l_neurone);

        (* -- les cachees *)
        for l_neurone := 1 to k_cache_max do
          affiche_un_neurone(k_ligne_debut + k_entree_max + k_sortie_max + (l_neurone - 1) + 2,
                             k_entree_max + k_sortie_max + l_neurone);
      end;
end;

function f_ligne_neurone(p_neurone: Integer): Integer;
  begin
    if p_neurone <= k_neurone_max
      then f_ligne_neurone := k_ligne_debut + p_neurone - 1
      else
        if p_neurone > k_entree_max + k_sortie_max
          then f_ligne_neurone := k_ligne_debut + p_neurone + 1
          else f_ligne_neurone := k_ligne_debut + p_neurone;
  end;

procedure affiche_les_co_occurences(p_ligne: Integer; p_co_occurence: t_co_occurence; p_niveau: Integer);
  var l_neurone: Integer;
  begin
    if p_niveau >= g_niveau
      then
        for l_neurone := 1 to k_neurone_max do
        begin
          GotoXY(50, l_neurone + p_ligne);
          for l_connexion := 1 to k_neurone_max do
            if l_connexion <= l_neurone
              then Write('  -  ')
              else Write(p_co_occurence[l_neurone, l_connexion]:5:2);
          WriteLn;
        end;
  end;

procedure affiche_toutes_co_occurences(p_ligne_1, p_ligne_2, p_ligne_3: Integer; p_niveau: Integer);
  var l_delta: t_co_occurence;
      l_neurone, l_connexion: Integer;
  begin
    for l_neurone := 1 to k_neurone_max do
      for l_connexion := 1 to k_neurone_max do
        l_delta[l_neurone, l_connexion] := 
              g_co_occurence_fige[l_neurone, l_connexion] - g_co_occurence_libre[l_neurone, l_connexion];

    affiche_les_co_occurences(p_ligne_1, g_co_occurence_fige, p_niveau);
    affiche_les_co_occurences(p_ligne_2, g_co_occurence_libre, p_niveau);
    affiche_les_co_occurences(p_ligne_3, l_delta, p_niveau);
  end;

(* -- fin iaffbolz *)