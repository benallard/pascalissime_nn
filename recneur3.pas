(* 001 recneur3 *)
(* 20 avr 91 *)

(*$r+*)
PROGRAM reconnaissance_d_arretes_par_reseau_neuronal;
 USES cthreads, CRT, uimpri, ptcGRAPH;

 CONST k_signal_max=109;
       k_connection_max=4;
       k_couche_max=7;
       k_biais=0.02;

 TYPE t_string_80=STRING[80];

      (* -- le signal initial *)
      t_signal=ARRAY[0..k_signal_max] OF REAL;

      (* -- les poids de chaque neurone *)
      t_table_poids=ARRAY[-k_connection_max..k_connection_max] OF REAL;
      (* -- la fonction de transfer *)
      t_transfert=PROCEDURE(VAR pv_valeur: REAL);

      t_neurone=RECORD
      	        (* -- les parametres de chaque neurone *)
      	        biais: REAL;
	        poids: t_table_poids;
	        (*  -- eventuellement un seuil *)
	        transfert: t_transfert;

	        sortie: REAL;
               END;

  (* -- la table des luminosites de notre object *)
  CONST kt_table_signal: t_signal=
          (0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20,
           0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20,
           0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.15, 0.20, 0.25,
           0.30, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.65, 0.70, 0.75,
           0.80, 0.80, 0.80, 0.80, 0.80, 0.80, 0.83, 0.80, 0.70, 0.90,
           0.80, 0.80, 0.60, 0.90, 0.40, 0.60, 0.30, 0.10, 0.20, 0.20,
           0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20,
           0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20,
           0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20,
           0.20, 0.20, 0.20, 0.10, 0.25, 0.30, 0.10, 0.20, 0.20, 0.20,
           0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20);

	(* -- les poids de chaque neurone: MHF ou "Sombrero" *)
	kt_table_poids: t_table_poids=
	  (-0.10, -0.60, -0.30, 0.50, 1.10, 0.50, -0.30, -0.60, -0.10);

 VAR g_choix: CHAR;
     g_reseau: ARRAY[0..k_couche_max, 0..k_signal_max] OF t_neurone;

PROCEDURE stoppe;
VAR l_stop: CHAR;
BEGIN
  l_stop := READKEY;
END;

(*$f+*)
PROCEDURE zero_un(VAR pv_valeur: REAL);
(* -- la fonction de transfer qui bride la sortie a 0..1 *)
(*$f-*)
BEGIN
  IF pv_valeur < 0
    THEN pv_valeur:=0;
  IF pv_valeur > 1
    THEN pv_valeur:=1;
END;

PROCEDURE propage_signal(p_couche_sortie: INTEGER);
VAR l_indice_voisins: INTEGER;
    l_indice_resultat: INTEGER;
    l_fin_resultat: INTEGER;
    l_debut_resultat: INTEGER;
    l_resultat: REAL;
BEGIN
  l_debut_resultat := k_connection_max;
  l_fin_resultat := k_signal_max - k_connection_max;

  FOR l_indice_resultat := l_debut_resultat TO l_fin_resultat DO
  BEGIN
    l_resultat:= -g_reseau[p_couche_sortie, l_indice_resultat].biais;
    FOR l_indice_voisins := -k_connection_max TO k_connection_max DO
      l_resultat := l_resultat
          + g_reseau[p_couche_sortie, l_indice_resultat].poids[l_indice_voisins]
	  * g_reseau[p_couche_sortie - 1, l_indice_resultat + l_indice_voisins].sortie;


    g_reseau[p_couche_sortie, l_indice_resultat].transfert(l_resultat);

    g_reseau[p_couche_sortie, l_indice_resultat].sortie := l_resultat;
  END; (* FOR *)

  (* -- traitement special du debut: ... *) 
  l_resultat := g_reseau[p_couche_sortie, l_debut_resultat].sortie;
  FOR l_indice_resultat := 0 TO l_debut_resultat + 1 DO
    g_reseau[p_couche_sortie, l_indice_resultat].sortie := l_resultat;

  (* -- traitement special de la fin: ... *) 
  l_resultat := g_reseau[p_couche_sortie, l_debut_resultat].sortie;
  FOR l_indice_resultat := l_fin_resultat + 1 TO k_signal_max DO
    g_reseau[p_couche_sortie, l_indice_resultat].sortie := l_resultat;
END;

PROCEDURE affiche_signal(p_titre: t_string_80; p_couche: INTEGER);
VAR l_neurone: INTEGER;
BEGIN
  WRITE(p_titre, '': 15 - LENGTH(p_titre));
  FOR l_neurone:= 89 TO 100 DO
    WRITE(g_reseau[p_couche, l_neurone].sortie:5:2);
  WRITELN;
END;

PROCEDURE go_texte;
VAR l_couche, l_neurone: INTEGER;
BEGIN
  (* la couche 0 est ici la couche en entree *)
  FOR l_neurone := 0 TO k_signal_max DO
    g_reseau[0, l_neurone].sortie := kt_table_signal[l_neurone];

  (* *)
  (* *)
  FOR l_couche:= 1 TO k_couche_max DO
    FOR l_neurone := 0 TO k_signal_max DO
      WITH g_reseau[l_couche, l_neurone] DO
      BEGIN
        biais := k_biais; poids := kt_table_poids; transfert := @zero_un;
      END;

  affiche_signal('entree', 0);

  FOR l_couche := 1 TO k_couche_max DO
  BEGIN
    propage_signal(l_couche);
    affiche_signal('iteration', l_couche);
  END;
END;

PROCEDURE dessine(p_y: INTEGER; p_couche: INTEGER);
VAR l_x: INTEGER;
BEGIN
  MOVETO(0, p_y - TRUNC(g_reseau[p_couche, 0].sortie * 80));
  FOR l_x:= 0 TO k_signal_max DO
  BEGIN
    LINETO(l_x * 4, p_y - TRUNC(g_reseau[p_couche, l_x].sortie * 80));
  END;
END;

PROCEDURE go_graphique(p_imprime: STRING);
VAR l_couche, l_neurone: INTEGER;
BEGIN
  (* la couche 0 est ici la couche en entree *)
  FOR l_neurone := 0 TO k_signal_max DO
    g_reseau[0, l_neurone].sortie := kt_table_signal[l_neurone];

  (* *)
  (* *)
  FOR l_couche:= 1 TO k_couche_max DO
    FOR l_neurone := 0 TO k_signal_max DO
      WITH g_reseau[l_couche, l_neurone] DO
      BEGIN
        biais := k_biais; poids := kt_table_poids; transfert := @zero_un;
      END;

  FOR l_couche := 1 TO k_couche_max DO
  BEGIN
    propage_signal(l_couche);
  
    initialise_mode_graphique;
    dessine(100, 0);
    dessine(200, l_couche);
    IF p_imprime <> ''
      THEN imprime_avec_tampon(p_imprime);
    READLN;
    CLOSEGRAPH;
  END;
END;

BEGIN (* principal *)
  REPEAT
    WRITELN;
    WRITE('Texte, Graphique, Fichier, Imprime fichier, Quitte ?');
    g_choix := READKEY; WRITELN(g_choix);
    CASE g_choix OF
      ' ': CLRSCR;
      't': go_texte;
      'g': go_graphique('');
      'f': go_graphique('a:e');
      'i': imprime_fichier('a:e');
    END;
  UNTIL g_choix='q';
END. (* principal *)
