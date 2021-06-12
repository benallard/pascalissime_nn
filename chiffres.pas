(* 001 chiffres *)
(* 15 jun 92 *)


(*$r+*)
program reseau_neuronal_bam;
uses crt, usortie;
const k_pixel_max = 44;
      k_exemplaire_max = 7;
      k_essai_max = 1;
type t_chiffre = array [0..k_pixel_max] of -1..1;
     t_exemplaire = array[0..k_exemplaire_max] of t_chiffre;
const k_exemplaire: t_exemplaire = 
        ((-1, -1, 1, -1, -1, { 0 }
          -1, 1, 1, 1, -1,
          1, 1, -1, 1, 1,
          1, -1, -1, -1, 1,
          1, -1, -1, -1, 1,
          1, -1, -1, -1, 1,
          1, 1, -1, 1, 1,
          -1, 1, 1, 1, -1,
          -1, -1, 1, -1, -1),
         (-1, -1, 1, 1, -1, { 1 }
          -1, -1, 1, 1, -1,
          -1, -1, 1, 1, -1,
          -1, -1, 1, 1, -1,
          -1, -1, 1, 1, -1,
          -1, -1, 1, 1, -1,
          -1, -1, 1, 1, -1,
          -1, -1, 1, 1, -1,
          -1, -1, 1, 1, -1),
         (1, 1, 1, 1, 1, { 2 }
          -1, -1, -1, 1, 1,
          -1, -1, -1, 1, 1,
          -1, -1, -1, 1, 1,
          1, 1, 1, 1, 1,
          1, 1, -1, -1, -1,
          1, 1, -1, -1, -1,
          1, 1, -1, -1, -1,
          1, 1, 1, 1, 1),
         (1, 1, 1, 1, 1, { 3 }
          -1, -1, -1, 1, 1,
          -1, -1, 1, 1, 1,
          1, 1, 1, 1, -1,
          -1, -1, -1, 1, 1,
          -1, -1, -1, 1, 1,
          -1, -1, -1, 1, 1,
          -1, -1, -1, 1, 1,
          1, 1, 1, 1, -1),
         (1, -1, -1, -1, -1, { 4 }
          1, -1, -1, -1, -1,
          1, -1, -1, -1, -1,
          1, -1, -1, -1, -1,
          1, -1, -1, 1, -1,
          1, -1, -1, 1, -1,
          1, 1, 1, 1, 1,
          -1, -1, -1, 1, -1,
          -1, -1, -1, 1, -1),
         (1, 1, 1, 1, 1, { 5 }
          1, 1, -1, -1, -1,
          1, 1, -1, -1, -1,
          1, 1, -1, -1, -1,
          1, 1, 1, 1, 1,
          -1, -1, -1, 1, 1,
          -1, -1, -1, 1, 1,
          -1, -1, -1, 1, 1,
          1, 1, 1, 1, 1),
         (1, 1, 1, 1, 1, { 6 }
          1, -1, -1, -1, -1,
          1, -1, -1, -1, -1,
          1, -1, -1, -1, -1,
          1, 1, 1, 1, 1,
          1, -1, -1, -1, 1,
          1, -1, -1, -1, 1,
          1, -1, -1, -1, 1,
          1, 1, 1, 1, -1),
          (1, 1, 1, 1, 1, { 7 }
          -1, -1, -1, -1, 1,
          -1, -1, -1, 1, 1,
          -1, -1, -1, 1, -1,
          -1, -1, 1, -1, -1,
          -1, 1, -1, -1, -1,
          -1, 1, -1, -1, -1,
          -1, 1, -1, -1, -1,
          -1, 1, -1, -1, -1));

        k_essai: t_chiffre = 
         (1, -1, -1, 1, -1, 
          -1, 1, -1, -1, 1,
          -1, 1, -1, 1, 1,
          1, 1, -1, -1, -1,
          1, -1, -1, 1, 1,
          -1, -1, -1, 1, 1,
          1, -1, -1, 1, -1,
          -1, 1, 1, 1, 1,
          -1, 1, -1, -1, 1);
var g_choix: Char;

    g_poids: array[0..k_pixel_max, 0..k_pixel_max] of integer;
    g_table_sortie: array[1..25, 1..80] of char;

procedure stoppe;
  var l_stop: Char;
  begin
    l_stop := ReadKey;
  end;

procedure affiche_essai(p_ligne, p_colonne:Integer; p_chiffre: t_chiffre);
  var l_pixel : Integer;
  begin
    with g_sortie do
      if nom_sortie='Con'
        then
          for l_pixel := 0 to k_pixel_max do
          begin
            GotoXY(1+p_colonne * 7 + l_pixel MOD 5, p_ligne * 10 + 4 + l_pixel DIV 5);
            if p_chiffre[l_pixel] < 0
              then Write('.')
              else Write('X');
          end
        else
          for l_pixel := 0 to k_pixel_max do
          begin
            if p_chiffre[l_pixel] < 0
              then g_table_sortie[p_ligne * 10 + 4 + l_pixel DIV 5,
                                  1 + p_colonne * 7 + l_pixel MOD 5] := '.'
              else g_table_sortie[p_ligne * 10 + 4 + l_pixel DIV 5,
                                  1 + p_colonne * 7 + l_pixel MOD 5] := 'X'
          end;
  end;

procedure affiche_exemplaires;
  var l_chiffre: Integer;
  begin
    for l_chiffre := 0 to k_exemplaire_max do
      affiche_essai(0, l_chiffre, k_exemplaire[l_chiffre]);
    stoppe;
  end;

procedure emet_sortie;
  var l_ligne, l_colonne: Integer;
  begin
    with g_sortie do
    begin
      for l_ligne := 1 to 25 do
      begin
        for l_colonne := 1 to 80 do
          Write(sortie, g_table_sortie[l_ligne, l_colonne]);
        WriteLn(sortie);
      end;
    end;
  end;

procedure go;

  procedure calcule_les_poids;
    var l_ligne, l_colonne, l_indice: Integer;
        l_valeur: Integer;
    begin
      (* -- calcule la matrice des poids *)
      for l_ligne := 0 to k_pixel_max do
        for l_colonne := 0 to k_pixel_max do
        begin
          l_valeur := 0;
          for l_indice := 0 to k_exemplaire_max do
            l_valeur := l_valeur + k_exemplaire[l_indice, l_ligne] * k_exemplaire[l_indice, l_colonne];
          g_poids[l_ligne, l_colonne] := l_valeur;
        end;
    end;

  procedure cherche_bassin;
    var l_a_converge: Boolean;

    procedure propage(p_colonne: Integer);
      var l_colonne, l_ligne: Integer;
          l_valeur: Integer;
          l_sortie: t_chiffre;
      begin
        if l_a_converge
          then Exit;

        for l_ligne := 0 to k_pixel_max do
        begin
          l_valeur := 0;
          for l_colonne := 0 to k_pixel_max do
            l_valeur := l_valeur + g_poids[l_ligne, l_colonne] * k_essai[l_colonne];

          (* -- modifie la sortie brute en fonction du signe de cette valeur *)
          if l_valeur < 0
            then l_sortie[l_ligne] := -1
            else
              if l_valeur = 0
                then (* laisse le y precedent *)
                  l_sortie[l_ligne] := k_essai[l_ligne]
                else
                  l_sortie[l_ligne] := +1;
        end;

        l_a_converge := True;
        for l_ligne := 0 to k_pixel_max do
          if l_sortie[l_ligne] <> k_essai[l_ligne]
            then l_a_converge := False;
        k_essai := l_sortie;

        affiche_essai(1, p_colonne, k_essai);
      end;
    
    begin (* cherche bassin *)
      WriteLn;
      l_a_converge := False;

      affiche_essai(1, 0, k_essai);
      propage(1);
      propage(2);
      propage(3);
      propage(4);
      propage(5);
      propage(6);
      propage(7);
      propage(8);
      propage(9);
      propage(10);
      if g_sortie.nom_sortie <> 'Con'
        then emet_sortie;
      ReadLn;
    end;
  
  begin (* go *)
    affiche_exemplaires;
    calcule_les_poids;
    cherche_bassin;
  end;

procedure initialise;
  begin
    FillChar(g_table_sortie, SizeOf(g_table_sortie), ' ');
  end;

begin (* main *)
  ClrScr;
  initialise;
  repeat
    WriteLn;
    Write('Go, Sortie, Quitte ?');
    g_choix := ReadKey;Write(g_choix); WriteLn;
    case g_choix of
      ' ': ClrScr;
      'g': go;
      's': choisis_sortie;
    end;
  until g_choix = 'q';
  ferme_sortie;
end.