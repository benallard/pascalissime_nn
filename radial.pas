(* 001 radial *)
(* 15 nov 94 *)

(*$r+*)
program radial_basis_function;
uses cthreads, Crt, ptcGraph,
     ugrafbor, uerreur;

const k_entraine = 10;
      k_apprentissage = 2.4;
const k_entree = 1;
      k_cache = 10;
      k_sortie = 1;
      k_sigma = 360 / (2 * k_cache);
type t_entree = ARRAY[1..k_entree] of Real;
     t_cache = ARRAY[1..k_cache] of record
                                      x, sigma_carre: Real;
                                      sortie_cache: Real;
                                    end;
     t_sortie = ARRAY[1..k_sortie] of Record
                                        poids: array[1..k_cache] of Real;
                                        valeur_sortie: Real;
                                      end;

     t_reseau = Record
                  entree: t_entree;
                  cache: t_cache;
                  sortie: t_sortie;
                end;
const k_exemplaire = k_cache;
type t_exemplaires = array [1..k_exemplaire] of record
                                                  x, y: Real;
                                                end;
var g_reseau: t_reseau;
    g_exemplaires: t_exemplaires;

function f_y(p_degre: Real): Real;
  begin
    f_y := sin(p_degre * 2 * pi / 360);
  end;

function f_exp(p_reel: Real): Real;
  const k_e_max = 1e38;
        k_max = 38;
  begin
    if p_reel < -k_max
      then f_exp := 0
      else
        f_exp := exp(p_reel);
  end; (* f_exp *)

procedure initialise_exemplaires;
  var l_exemplaire: Integer;
  begin
    for l_exemplaire := 1 to k_exemplaire do
      with g_exemplaires[l_exemplaire] do
        begin
          x := (360 / (k_exemplaire - 1)) * (l_exemplaire - 1);
          y := f_y(x);
        end;
  end; (* initialise_exemplaires *)

procedure initialise_reseau;
  var l_cache, l_sortie: Integer;
  begin
    initialise_exemplaires;
    with g_reseau do
    begin
      for l_cache := 1 to k_cache do
        with cache[l_cache] do
        begin
          x := g_exemplaires[l_cache].x;
          sigma_carre := Sqr(k_sigma);
        end;

      for l_sortie := 1 to k_sortie do
        with sortie[l_sortie] do
        begin
          for l_cache := 1 to k_cache do
            poids[l_cache] := g_exemplaires[l_cache].y;
        end;
    end;
  end; (* initialise_reseau *)

procedure affiche_reseau;
    (* -- mise au point *)
  var l_cache: Integer;
  begin
    for l_cache := 1 to k_cache do
      WriteLn(g_reseau.cache[l_cache].x: 8: 3);
    for l_cache := 1 to k_cache do
      WriteLn(g_reseau.sortie[1].poids[l_cache]: 8: 3);
  end; (* affiche_reseau *)

procedure propage(p_x: Real);
  var l_entree, l_cache, l_sortie: Integer;
      l_somme_activation: Real;
  begin
    with g_reseau do
    begin
      l_somme_activation := 0;

      for l_cache := 1 to k_cache do
        with cache[l_cache] do
        begin
          sortie_cache := 0;
          for l_entree := 1 to k_entree do
            sortie_cache := sortie_cache + Sqr(p_x - x);
          sortie_cache := f_exp(-sortie_cache / sigma_carre);

          l_somme_activation := l_somme_activation + sortie_cache;
        end; (* for l_cache *)

      (* -- normalise *)
      if l_somme_activation < 1e-3
        then Write(Chr(7))
        else
          for l_cache := 1 to k_cache do
            with cache[l_cache] do
              sortie_cache := sortie_cache / l_somme_activation;

      for l_sortie := 1 to k_sortie do
        with sortie[l_sortie] do
        begin
          valeur_sortie := 0;
          for l_cache := 1 to k_cache do
            valeur_sortie := valeur_sortie + poids[l_cache] * cache[l_cache].sortie_cache;
        end; (* for l_sortie *)
    end; (* with g_reseau *)
  end; (* propage *)

procedure prevois(p_initialise: Boolean);
  var l_indice, l_angle: Integer;
  begin (* prevois *)
    with g_reseau do
    begin
      if p_initialise
        then initialise_mode_graphique(False);
      for l_angle := 0 to 360 do
      begin
        PutPixel(l_angle, Round(240 - 200 * f_y(l_angle)), LightRed);

        propage(l_angle);
        PutPixel(l_angle, Round(240 - 200 * sortie[1].valeur_sortie), LightGreen);
      end; (* for l_angle *)
      if p_initialise
        then termine_mode_graphique;
    end; (* with g_reseau *)
  end; (* prevois *)

procedure entraine(p_initialise: Boolean);
  var l_exemplaire: Integer;

  procedure ajuste_poids;
    var l_sortie, l_cache: Integer;
    begin
      with g_reseau do
      begin
        for l_sortie := 1 to k_sortie do
          with sortie[l_sortie] do
          begin
            for l_cache := 1 to k_cache do
            begin
              poids[l_cache] := poids[l_cache]
                  + k_apprentissage * (g_exemplaires[l_exemplaire].y - valeur_sortie)
                  * cache[l_cache].sortie_cache;
            end; (* for l_cache *)
          end;
      end; (* with g_reseau *)
    end; (* ajuste_poids *)

  var l_entraine: Integer;

  begin (* entraine *)
    with g_reseau do
    begin
      if p_initialise
        then initialise_mode_graphique(False);

      for l_entraine := 1 to k_entraine * k_exemplaire do
      begin
        l_exemplaire := Random(k_exemplaire) + 1;
        with g_exemplaires[l_exemplaire] do
          begin
            propage(x);
            ajuste_poids;
            prevois(False);
          end; (* with g_exemplaires[l_exemplaire] *)
      end; (* for l_entraine *)
    end; (* with g_reseau *)

    if p_initialise
      then termine_mode_graphique;
  end; (* entraine *)
    
procedure initialise;
  begin
    initialise_reseau;
  end; (* initialise *)

var g_choix: Char;

begin
  initialise;

  repeat
    WriteLn;
    WriteLn('Affiche, Entraine, Prevois, Quitte ?');
    g_choix := Upcase(ReadKey); WriteLn(g_choix);
    case g_choix of
      ' ': ClrScr;
      'A': affiche_reseau;
      'E' : entraine(True);
      'P' : prevois(True);
    end;
  until g_choix = 'Q';
end.