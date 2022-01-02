(* 001 idessmac *)
(* 13 mar 95 *)

procedure initialise_mode_graphique;
  var l_pilote, l_mode_graphique: Integer;
  begin
    l_pilote := Detect;
    InitGraph(l_pilote, l_mode_graphique, '');
  end;

procedure termine_mode_graphique;
  begin
    ReadLn;
    CloseGraph;
  end;

type t_courbe = ARRAY[0..0] of Real;
var g_courbe: ^t_courbe;
    g_taille: Integer;
    g_min, g_max: Real;

procedure initialise_courbe(p_taille: Integer);
  begin
    g_taille := p_taille;
    GetMem(g_courbe, g_taille * SizeOf(Real));
    FillChar(g_courbe^, g_taille * SizeOf(Real), 0);
  end;

(*$r-*)

procedure calcule_min_max;
  var l_date: Word;
  begin
    g_min := 1e38; g_max := -1e38;

    for l_date := 0 to g_taille - 1 do
      begin
        if g_courbe^[l_date] > g_max
          then g_max := g_courbe^[l_date];
        if g_courbe^[l_date] < g_min
          then g_min := g_courbe^[l_date];
      end;
  end;

const k_echelle_x = 2;
var g_echelle_y: Real;

procedure dessine_courbe(p_y_ecran_min, p_y_ecran_max: Word);

  procedure calcule_echelle;
    begin
      if g_max > g_min
        then g_echelle_y := (p_y_ecran_max + 1 - p_y_ecran_min) / (g_max - g_min)
        else g_echelle_y := 0;
    end; (* calcule_echelle *)

  procedure dessine_la_courbe;
    var l_date: Word;
        l_x_precedent: Integer;
    begin
      l_date := 0;
      l_x_precedent := 480 - (p_y_ecran_min + Round((g_courbe^[l_date] - g_min) * g_echelle_y));

      for l_date := 1 to g_taille - 1 do
        begin
          Line((l_date - 1) * k_echelle_x, l_x_precedent,
            l_date * k_echelle_x, 480 - (p_y_ecran_min + Round((g_courbe^[l_date] - g_min) * g_echelle_y)));

          l_x_precedent := 480 - (p_y_ecran_min + Round((g_courbe^[l_date] - g_min) * g_echelle_y));
        end;
    end; (* dessine_la_courbe *)

(*$r+*)

  begin
    calcule_min_max;
    calcule_echelle;

    dessine_la_courbe;
  end;

(* -- idessmac *)