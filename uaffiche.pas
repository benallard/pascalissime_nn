(* 002 uaffiche *)
(* 19 jul 91 *)

(* -- procedures d'affichage graphique *)

unit uaffiche;
interface
const (* - le coin gauche superieur du rectangle d'affichage *)
        k_x_debut = 30; k_y_debut = 30;
        k_echelle = 200;

procedure dessine_croix(p_x, p_y: Integer; p_couleur: Integer);

procedure affiche_entier(p_ligne, p_colonne: Word; p_valeur: Integer; p_colonnes: Word);
procedure affiche_chaine(p_ligne, p_colonne: Word; p_valeur: string; p_colonnes: Word);
procedure affiche_reel(p_ligne, p_colonne: Word; p_valeur: Real; p_colonnes, p_decimales: Word);
procedure affiche(p_ligne, p_colonne: Word; p_texte: string;
        p_valeur: real; p_colonnes, p_decimales: Integer);

implementation
uses ptcGraph;
const k_taille_croix = 3;

procedure dessine_croix(p_x, p_y: Integer; p_couleur: Integer);
begin
  SetColor(p_couleur);
  p_x := p_x + k_x_debut; p_y := p_y + k_y_debut;
  Line(p_x - k_taille_croix, p_y, p_x + k_taille_croix, p_y);
  Line(p_x, p_y - k_taille_croix, p_x, p_y + k_taille_croix);
end;

procedure affiche_entier(p_ligne, p_colonne: Word; p_valeur: Integer; p_colonnes: Word);
var l_valeur: string;
begin
  Str(p_valeur : p_colonnes, l_valeur);

  SetFillStyle(1, black);
  Bar(p_colonne, p_ligne, p_colonne + TextWidth(l_valeur) + 2, p_ligne + TextHeight('0'));

  OutTextXY(p_colonne + 1, p_ligne, l_valeur);
end;

procedure affiche_chaine(p_ligne, p_colonne: Word; p_valeur: string; p_colonnes: Word);
begin
  SetFillStyle(1, black);
  Bar(p_colonne, p_ligne, p_colonne + TextWidth(p_valeur) + 2, p_ligne + TextHeight('0'));

  OutTextXY(p_colonne + 1, p_ligne, p_valeur);
end;

procedure affiche_reel(p_ligne, p_colonne: Word; p_valeur: Real; p_colonnes, p_decimales: Word);
var l_valeur: string;
begin
  Str(p_valeur : p_decimales + 3 : p_decimales, l_valeur);
  SetFillStyle(1, black);
  Bar(p_colonne, p_ligne, p_colonne + TextWidth(l_valeur) + 2, p_ligne + TextHeight('0'));

  OutTextXY(p_colonne + 1, p_ligne, l_valeur);
end;

procedure affiche(p_ligne, p_colonne: Word; p_texte: String;
         p_valeur: Real; p_colonnes, p_decimales: Integer);
var l_valeur: string;
begin
  Str(p_valeur : p_colonnes : p_decimales, l_valeur);
  l_valeur := p_texte + l_valeur;

  SetFillStyle(1, black);
  Bar(p_colonne - 1, p_ligne, p_colonne + TextWidth(l_valeur) + 2, p_ligne + TextHeight('0'));

  OutTextXY(p_colonne + 1, p_ligne, l_valeur);
end;

begin
end.
