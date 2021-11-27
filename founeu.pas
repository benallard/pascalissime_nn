(* 001 founeu *)
(* 17 aou 94 *)

(*$r+*)
program fourrier_neurone;
uses cthreads, crt, ptcgraph;

procedure initialise_mode_graphique;
  var l_pilote, l_mode_graphique : Integer;
  begin
    l_pilote := Detect;
    InitGraph(l_pilote, l_mode_graphique, '');
  end;

procedure termine_mode_graphique;
  begin
    ReadLn;
    CloseGraph;
  end;

const k_N = 256;
      k_rapport_cyclique = 0.1;
type t_tableau = array[0..k_N - 1] of real;
var a, b, mu: t_tableau;

function f(p_x: Integer): Real;
  (* -- marche escalier *)
  begin
    p_x := p_x mod k_N;
    if p_x < Round(k_rapport_cyclique * k_N)
      then f := 1
      else f := 0;
  end;

procedure calcule;
  var l_temps: Integer;
      l_essai: Integer;
      l_erreur: Real;
      l_cumul_erreur: Real;

  procedure affiche_a;
    var l_indice: Word;
    begin
      GotoXY(1, 1); Write(l_essai: 8, l_erreur: 8: 4, l_cumul_erreur / l_essai: 8 : 4);
      for l_indice := 0 to 21 do
      begin
        GotoXY(1, 2+l_indice);Write(a[l_indice]: 12: 7);
      end;
    end; (* affiche_a *)

  procedure dessine_a;
    var l_min, l_max: Real;

    procedure calcule_min_max;
      var l_indice: Integer;
      begin
        l_min := 1e30; l_max := -l_min;
        for l_indice := 0 to k_N - 1 do
        begin
          if a[l_indice] < l_min
            then l_min := a[l_indice];
          if a[l_indice] > l_max
            then l_max := a[l_indice];
        end;
      end; (* calcule_min_max *)

    procedure dessine;

      procedure dessine_a_l_echelle;
        var l_echelle: Real;
            l_indice: Word;
        begin
          l_echelle := 480 / (l_max - l_min);

          SetColor(LightRed);

          for l_indice := 0 to k_N - 1 do
          begin
{
            PutPixel(l_indice, Round(480 - (a[l_indice] - l_min) * l_echelle), LightRed);
}
            MoveTo(l_indice, Round(480 - (a[l_indice] - l_min) * l_echelle));
            LineTo(l_indice, Round(480 + l_min * l_echelle));
          end;
        end; (* dessine_a_l_echelle *)

      begin (* dessine *)
        initialise_mode_graphique;

        dessine_a_l_echelle;

        termine_mode_graphique;
      end; (* dessine *)

    begin (* dessine_a *)
      calcule_min_max;
      ReadLn;
      dessine;
    end; (* dessine_a *)

  procedure initialise_a_b;
    var l_indice: Word;
    begin
      for l_indice := 0 to k_N - 1 do
      begin
        a[l_indice] := 0.1; b[l_indice] := 0.1;
        a[l_indice] := 0; b[l_indice] := 0;
        mu[l_indice] := 0.001;
      end;

      l_cumul_erreur := 0;
      ClrScr;
    end; (* initialise_a_b *)

  const k_beta = 0.5;
        k_omega = 6.28 / k_N;

  procedure calcule_erreur;
    var l_somme: Real;
        l_indice: Word;
    begin
      (* -- accumule ai Cos (wi t) + bi Sin (wi t) *)
      l_somme := 0;
      for l_indice := 0 to k_N - 1 do
        l_somme := l_somme + a[l_indice] * Cos(k_omega * l_indice * l_temps)
                          + b[l_indice] * Sin(k_omega * l_indice * l_temps);

      (* -- compare au signal mesure *)
      l_erreur := f(l_temps) - l_somme;

      (* -- bride (Hubert) *)
      if l_erreur < -k_beta
        then l_erreur := -k_beta
        else
          if l_erreur > k_beta
            then l_erreur := k_beta;
    end; (* calcule_erreur *)

  procedure ajuste_a_b;
    var l_indice: Word;
    begin
      (* -- da / dt = muk * erreur * Cos ( k omega t) *)
      for l_indice := 0 to k_N - 1 do
      begin
        a[l_indice] := a[l_indice] + mu[l_indice] * l_erreur * Cos(k_omega * l_indice * l_temps);
        b[l_indice] := b[l_indice] + mu[l_indice] * l_erreur * Sin(k_omega * l_indice * l_temps);
      end;
    end; (* ajuste_a_b *)

  begin (* calcule *)
    initialise_a_b;
    l_temps := 0;
    l_essai := 1;
    
    repeat
      calcule_erreur;
      ajuste_a_b;

      l_cumul_erreur := l_cumul_erreur + l_erreur;

      affiche_a;

      l_temps := (l_temps + 1) mod k_N;
      l_essai := l_essai + 1;
    until (l_cumul_erreur / l_essai < 0.1) and (l_essai > 10);

    dessine_a;

    GotoXY(1, 23); Write('Fin');
  end; (* calcule *)

var g_choix: Char;

begin
  repeat
    Write('Calcule, ');
    Write('Quitte ? ');
    g_choix := ReadKey;WriteLn(g_choix);
    case g_choix of
      ' ': ClrScr;
      'c': calcule;
    end;
  until g_choix = 'q';
end.