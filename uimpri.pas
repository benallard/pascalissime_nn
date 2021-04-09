(* 001 uimpri *)
(* 09 mai 91 *)

(*$r+*)

UNIT uimpri;
  INTERFACE
    PROCEDURE initialise_mode_graphique;
    PROCEDURE imprime_avec_tampon(p_nom_fichier: STRING);
    PROCEDURE imprime_fichier(p_nom_fichier: STRING);

  IMPLEMENTATION
    USES ptcgraph, printer;
    CONST k_port_graphique_12=$03CE;
          k_registre_selection_plan_lecture=$04;
	  k_escape=#27;

    PROCEDURE initialise_mode_graphique;
      VAR l_carte, l_mode: INTEGER;
      BEGIN
        l_carte := DETECT;
	INITGRAPH(l_carte, l_mode, '');
      END;

    PROCEDURE imprime_avec_tampon(p_nom_fichier: STRING);
      BEGIN
      END;

    PROCEDURE imprime_fichier(p_nom_fichier: STRING);
      BEGIN
      END;

BEGIN
END.
