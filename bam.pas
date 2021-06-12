(* 001 bam *)
(* 05 avr 92 *)

(*$r+*)
PROGRAM reseau_neuronal_bam;
USES Crt, usortie;
CONST k_x_max = 10;
      k_y_max = 6;
      k_modele_max = 2;
      k_essai_max = 1;
TYPE t_x = ARRAY [1..k_x_max] OF INTEGER;
     t_y = ARRAY [1..k_y_max] OF INTEGER;
     t_couple = RECORD
                  x: t_x;
                  y: t_y;
                END;
VAR g_choix: Char;
    g_test: Boolean;

    g_modele: ARRAY [1..k_modele_max] OF t_couple;
    g_poids: ARRAY [1..k_y_max, 1..k_x_max] OF INTEGER;

    g_essai: ARRAY [1..k_essai_max] OF t_couple;

procedure stoppe;
  var l_stop: Char;
  begin
    l_stop:= readkey;
  end;

procedure affiche_poids;
  var l_x, l_y, l_modele: Integer;
  begin
    with g_sortie do
    begin
      WriteLn(sortie, 'les poids: ');
      for l_y := 1 to k_y_max do
      begin
        for l_x := 1 to k_x_max do
          Write(sortie, g_poids[l_y, l_x]:3);
        WriteLn(sortie);
      end;
    end
  end;

procedure affiche_x(p_titre: String; p_x: t_x);
  var l_x: Integer;
  begin
    with g_sortie do
    begin
      Write(sortie, p_titre);
      for l_x := 1 to k_x_max do
        Write(sortie, p_x[l_x]:3);
      WriteLn(sortie);
    end;
  end;

procedure affiche_y(p_titre: String; p_y: t_y);
  var l_y: Integer;
  begin
    with g_sortie do
    begin
      Write(sortie, p_titre, ' ':3*k_x_max + 8);
      for l_y := 1 to k_y_max do
        Write(sortie, p_y[l_y]:3);
      WriteLn(sortie);
    end;
  end;

procedure go;

  procedure calcule_les_poids;
    var l_x, l_y, l_modele: Integer;
        l_valeur: Integer;
    begin
      (* -- calcule la matrice des poids *)
      for l_y := 1 to k_y_max do
        for l_x := 1 to k_x_max do
        begin
          l_valeur := 0;
          for l_modele := 1 to k_modele_max do
            with g_modele[l_modele] do
              l_valeur := l_valeur + x[l_x] * y[l_y];
          g_poids[l_y, l_x] := l_valeur;
        end;
      
      affiche_poids;
    end;

  procedure cherche_bassin(p_essai: t_couple);
  
    procedure propage_x_vers_y;
      var l_y, l_x: Integer;
          l_valeur: Integer;
      begin
        for l_y := 1 to k_y_max do
        begin
          l_valeur := 0;
          for l_x :=  1 to k_x_max do
            l_valeur := l_valeur + g_poids[l_y, l_x] * p_essai.x[l_x];

          (* -- modifie le y precedent en fonction du signe de cette valeur *)
          if l_valeur < 0
            then p_essai.y[l_y] := -1
            else
              if l_valeur = 0
                then (* laisse le y precedent *)
                else
                  p_essai.y[l_y] := +1;
        end;

        affiche_y('x -> y: ', p_essai.y);
      end;

    procedure propage_y_vers_x;
      var l_x, l_y: Integer;
          l_valeur: Integer;
      begin
        for l_x := 1 to k_x_max do
        begin
          l_valeur := 0;
          for l_y :=  1 to k_y_max do
            l_valeur := l_valeur + g_poids[l_y, l_x] * p_essai.y[l_y];

          (* -- modifie le y precedent en fonction du signe de cette valeur *)
          if l_valeur < 0
            then p_essai.x[l_x] := -1
            else
              if l_valeur = 0
                then (* laisse le x precedent *)
                else
                  p_essai.x[l_x] := +1;
        end;

        affiche_x('y <- x: ', p_essai.x);
      end;

    begin (* cherche_bassin *)
      WriteLn;
      affiche_x('x0:     ', p_essai.x);
      affiche_y('y0:     ', p_essai.y);
      WriteLn;

      propage_x_vers_y;
      propage_y_vers_x;

      stoppe;
      propage_x_vers_y;
      propage_y_vers_x;

      stoppe;
      propage_x_vers_y;
      propage_y_vers_x;

      stoppe;
      propage_x_vers_y;
      propage_y_vers_x;
    end;

  begin
    calcule_les_poids;
    cherche_bassin(g_essai[1]);
  end;

procedure initialise;
  var l_indice_modele: Integer;

  procedure initialise_modele(p_x1, p_x2, p_x3, p_x4, p_x5, p_x6, p_x7, p_x8, p_x9, p_x10,
                              p_y1, p_y2, p_y3, p_y4, p_y5, p_y6: Integer; var pv_table: t_couple);
    begin
      with pv_table do
      begin
        x[1] := p_x1;
        x[2] := p_x2;
        x[3] := p_x3;
        x[4] := p_x4;
        x[5] := p_x5;
        x[6] := p_x6;
        x[7] := p_x7;
        x[8] := p_x8;
        x[9] := p_x9;
        x[10] := p_x10;

        y[1] := p_y1;
        y[2] := p_y2;
        y[3] := p_y3;
        y[4] := p_y4;
        y[5] := p_y5;
        y[6] := p_y6;
      end;
      l_indice_modele := l_indice_modele + 1;
    end;

  begin
    g_test := False;
  
    l_indice_modele := 1;
    initialise_modele(1, -1, -1, 1, -1, 1, 1, -1, -1, 1, 1, -1, -1, -1, -1, 1, g_modele[l_indice_modele]);
    initialise_modele(1, 1, 1, -1, -1, -1, 1, 1, -1, -1, 1, 1, 1, 1, -1, -1, g_modele[l_indice_modele]);

    l_indice_modele := 1;
    initialise_modele(1, -1, -1, 1, -1, 1, 1, -1, -1, 1, 1, 1, 1, 1, -1, -1, g_essai[l_indice_modele]);
  end;

begin (* main *)
  ClrScr;
  initialise;
  repeat
    WriteLn;
    Write('Go, Sortie, Quitte ?');
    g_choix := ReadKey; Write(g_choix); WriteLn;
    case g_choix of
      ' ': ClrScr;
      'g': go;
      's': choisis_sortie;
    end;
  until g_choix = 'q';
  ferme_sortie;
end.