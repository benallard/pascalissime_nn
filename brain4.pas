(* 001 brain4 *)
(* 23 avr 94  *)

(*$r+*)
program brain;
uses Crt,
     uerreur,
     uosortie;

const k_neurone_max=47;
type t_entree = array[0..k_neurone_max] of real;
     t_intermediaire = array[0..k_neurone_max] of 
                       record
                         poids: array[0..k_neurone_max] of real;
                       end;
     t_sortie = t_entree;

type t_chaine_entree= array[0..3*16+1] of Char;
const k_element_max = 18;
      k_elements: array[1..k_element_max] of t_chaine_entree =
      (
        (* -- panne       type             action*)
        (* -- batterie *)
        '++++++++-------- ................ ................',
        (* -- broute *)
        '----++++----++++ ................ ................',
        (* -- tableau *)
        '+-+-+-+-+-+-+-+- ................ ................',

        (* -- pneu *)
        '--++--++--++--++ ................ ................',
        (* -- tole *)
        '++++----++++---- ................ ................',
        (* -- noie *)
        '+--++--++--++--+ ................ ................',

        (* --             electrique *)
        '................ +-+-+-+-+-+-+-+- ................',
        (* --             mecanique *)
        '................ --++--++--++--++ ................',

        (* --                              garage *)
        '................ ................ +--++--++--++--+',
        (* --                              bricole *)
        '................ ................ --------++++++++',

        (* -- batteries -> electrique *)
        '++++++++-------- +-+-+-+-+-+-+-+- ................',
        (* -- broute -> electrique *)
        '----++++----++++ +-+-+-+-+-+-+-+- ................',
        (* -- tableau -> electrique *)
        '+-+-+-+-+-+-+-+- +-+-+-+-+-+-+-+- ................',

        (* -- pneu -> mecanique *)
        '--++--++--++--++ --++--++--++--++ ................',
        (* -- tole -> mecanique *)
        '++++----++++---- --++--++--++--++ ................',
        (* -- noie -> mecanique *)
        '+--++--++--++--+ --++--++--++--++ ................',

        (* -- electrique -> garage *)
        '................ +-+-+-+-+-+-+-+- +--++--++--++--+',
        (* -- mecanique -> bricole *)
        '................ --++--++--++--++ --------++++++++');

var g_reseau: record
                entree: t_entree;
                intermediaire: t_intermediaire;
                sortie: t_sortie;
              end;

procedure entraine;
  
  const (* -- parametres d'affichage *)
        k_ligne_min = 3;
        k_colonne = 20;

        (* -- nombre de passes d'apprentissage *)
        k_apprentissage_max = 40;

        (* -- suivi de l'apprentissage *)
        k_affiche_apprentissage = 39;
        k_neurone_affiche = 0;
        k_exemple_affiche = 11;

        (* -- convergence par la formule d'Andersen *)
        k_itere_correction_max = 1;

        (* -- coefficients de la formule d'Andersen *)
        k_limite = 1.3;
        k_alpha = 1.0;
        k_beta = 0.8;
        k_gamma = 0.9;

        (* -- echelle d'initialisation des poids *)
        k_valeur_initiale = 0.0001;
        (* -- coefficient de Widrow Hoff pour apprendre les poids *)
        k_apprentissage = 0.0001;

  procedure initialise_reseau;
    var l_neurone, l_neurone_2: Word;
    begin
      with g_reseau do
      begin
        FillChar(entree, SizeOf(entree), 0);

        (* -- apprentissage de Hebb *)
        FillChar(intermediaire, SizeOf(intermediaire), 0);

        (* -- apprentissage de Widrow Hoff *)
        for l_neurone := 0 to k_neurone_max do
          for l_neurone_2 := 0 to k_neurone_max do
            intermediaire[l_neurone].poids[l_neurone_2] := k_valeur_initiale * (-1 + 2 * Random);
      end;
    end; (* initialise_reseau *)

  procedure convertis_chaine_en_entree(p_chaine_entree: t_chaine_entree;
                                       var pv_entree: t_entree);
    (* -- calcule la premiere entree a partir de p_chaine_entree *)
    var l_neurone, l_indice_element: Word;
        l_entree: Real;
    begin
      for l_neurone := 0 to k_neurone_max do
      begin
        (* -- indice dans la chaine: tenir compte des expaces separateurs *)
        l_indice_element := l_neurone + (l_neurone div 16);

        case p_chaine_entree[l_indice_element] of
          '+': l_entree := 1;
          '.': l_entree := 0;
          '-': l_entree := -1;
          else Write('erreur');
        end;
        pv_entree[l_neurone] := l_entree;
      end;
    end; (* convertis_chaine_en_entree *)

  procedure affiche_en_clair(p_entree: t_entree; p_ligne: Word;
                             p_seuil_1, p_seuil_2, p_seuil_3: Real);
    (* -- esaye d'afficher le nom de l'exemplaire *)
    const k_maximum = 8;
    const k_affiche = False;

    function f_plus_proche(p_indice_table_min, p_indice_table_max,
                           p_indice_chaine, p_indice_sortie: Word; p_seuil: Real): Word;

      function f_distance(p_indice_table, p_indice_chaine, p_indice_sortie: Word): Word;
        var l_indice: Word;
            l_distance: Integer;
        begin
          l_distance := 0;

          for l_indice := 0 to 15 do
          begin
            case k_elements[p_indice_table, p_indice_chaine + l_indice] of
              '+': if Abs(p_entree[p_indice_sortie + l_indice]) < p_seuil
                     then Inc(l_distance, 1)
                     else
                       if p_entree[p_indice_sortie + l_indice] < -p_seuil
                         then Inc(l_distance, 2);
              '.' : if Abs(p_entree[p_indice_sortie + l_indice]) < p_seuil
                     then Inc(l_distance, 1);
              '-': if Abs(p_entree[p_indice_sortie + l_indice]) < p_seuil
                     then Inc(l_distance, 1)
                     else
                       if p_entree[p_indice_sortie + l_indice] > p_seuil
                         then Inc(l_distance, 2);
            end; (* case *)
            if k_affiche
              then Write(l_distance, ' ');
          end; (* for *)

        f_distance := l_distance;
      end; (* f_distance *)

      var l_plus_proche, l_indice_table: Word;
          l_distance, l_minimum: Word;

      begin (* f_plus_proche *)
        l_minimum := 16 * 2;
        l_plus_proche := 0;

        for l_indice_table := p_indice_table_min to p_indice_table_max do
        begin
          l_distance := f_distance(l_indice_table, p_indice_chaine, p_indice_sortie);

          if k_affiche
            then Write(' -> ', l_distance, ' ');
          if l_distance < l_minimum
            then
              begin
                l_plus_proche := l_indice_table;
                l_minimum := l_distance;
              end;
        end; (* for *)

        if k_affiche
          then begin
              Write('=> ', l_plus_proche);
              stoppe; GotoXY(1, 22); ClrEol;
            end;

        if l_minimum > k_maximum
          then l_plus_proche := 0;
        f_plus_proche := l_plus_proche;
      end; (* f_plus_proche *)

    begin (* affiche_en_clair *)
      GotoXY(1, p_ligne); ClrEol;

      (* -- le premier element *)
      case f_plus_proche(1, 6, 1, 1, p_seuil_1) of
        0: Write('........');
        1: Write('batterie');
        2: Write('broute');
        3: Write('tableau');
        4: Write('pneu');
        5: Write('tole');
        6: Write('noie');
        else Write (' A ');
      end;

      GotoXY(21, p_ligne);
      (* -- le second element *)
      case f_plus_proche(7, 8, 17, 16, p_seuil_2) of
        0: Write('........');
        7: Write('electrique');
        8: Write('mecanique')
        else Write (' B ');
      end;

      GotoXY(41, p_ligne);
      (* -- le troisieme element *)
      case f_plus_proche(9, 10, 34, 32, p_seuil_3) of
        0: Write('........');
        9: Write('garage');
        10: Write('bricole');
        else Write (' C ');
      end;
    end; (* affiche_en_clair *)

  procedure affiche_reseau(p_indice_exemple: Word);
    (* -- affiche pour un exemplaire les poids du neurone 0 *)
    (* -- permet d'analyser la convergence *)
    var l_neurone, l_indice_element: Word;
        l_entree: t_entree;
    begin
      with g_reseau do
      begin
        convertis_chaine_en_entree(k_elements[p_indice_exemple], l_entree);

        affiche_en_clair(l_entree, 2, 0.5, 0.5, 0.5);

        for l_neurone := 0 to k_neurone_max do
        begin
          (* -- affiche l'entree *)
          l_indice_element := l_neurone + (l_neurone div 16);
          GotoXY(1 + (l_neurone div 16) * k_colonne, k_ligne_min + (l_neurone mod 16));
          Write(k_elements[k_exemple_affiche, l_indice_element],
                intermediaire[0].poids[l_neurone]: 7: 3,
                sortie[l_neurone]: 9: 5);
        end;
      end; (* with *)
    end; (* affiche_reseau *)

  procedure calcule_sortie(p_chaine_entree: t_chaine_entree; p_iterations: Word);
    var l_entree_0: t_entree;

    procedure propage_entree_vers_sortie;
      var l_neurone: Word;
          l_sortie: Real;
          l_intermediaire: Word;
          l_sortie_brute: Real;
      begin
        with g_reseau do
        begin
          (* -- propage l'entree vers la sortie *)
          for l_neurone := 0 to k_neurone_max do
          begin
            l_sortie := 0;
            for l_intermediaire := 0 to k_neurone_max do
              l_sortie := l_sortie + 
                intermediaire[l_neurone].poids[l_intermediaire] * entree[l_intermediaire];

            (* -- la formule d'Andersen *)
            l_sortie_brute := k_alpha * l_sortie + k_beta * entree[l_neurone]
                + k_gamma * l_entree_0[l_neurone];

            (* -- brida a [-k_limite..k_limite] *)
            if l_sortie_brute < -k_limite
              then sortie[l_neurone] := -k_limite
              else
                if l_sortie_brute > k_limite
                  then sortie[l_neurone] := k_limite
                  else sortie[l_neurone] := l_sortie_brute;
          end; (* for *)
        end; (* with *)
      end; (* propage_entree_vers_sortie *)

    var l_converge: Word;

    begin (* calcule_sortie *)
      with g_reseau do
      begin
        FillChar(sortie, SizeOf(sortie), 0);
        convertis_chaine_en_entree(p_chaine_entree, entree);
        (* -- memorise pour formule d'Andersen *)
        l_entree_0 := entree;

        for l_converge := 1 to k_itere_correction_max do
        begin
          propage_entree_vers_sortie;
          (* -- reinjecte sortie a l'entree *)
          entree := sortie;
        end; (* for *)
      end; (* with *)
    end; (* calcule_sortie *)
  
  procedure entraine_reseau(p_apprentissage: Word; p_affiche: Boolean);
    (* -- presente les exemplaires d'inferences un a un *)
    (* -- et corrige les poids *)

    procedure mets_a_jour_poids;
      var l_neurone_1, l_neurone_2: Word;
          l_sortie_calculee: Real;
          l_erreur: array[0..k_neurone_max] of Real;
      begin
        with g_reseau do
        begin
          (* -- calcule le vecteur d'erreur *)
          for l_neurone_1 := 0 to k_neurone_max do
          begin
            (* -- calcule la sortie Entree * Poids *)
            l_sortie_calculee := 0;
            for l_neurone_2 := 0 to k_neurone_max do
              l_sortie_calculee := l_sortie_calculee
                + intermediaire[l_neurone_1].poids[l_neurone_2] * entree[l_neurone_2];
            (* -- pour un reseau auto-associatif, sortie desiree = entree *)
            (* -- Erreur := Sortie desiree - sortie calculee *)
            l_erreur[l_neurone_1] := entree[l_neurone_1] - l_sortie_calculee;
          end;

          (* -- mise a jour des poids *)
          for l_neurone_1 := 0 to k_neurone_max do
          begin
            for l_neurone_2 := 0 to k_neurone_max do
              intermediaire[l_neurone_1].poids[l_neurone_2] :=
                intermediaire[l_neurone_1].poids[l_neurone_2] +
                k_apprentissage * l_erreur[l_neurone_1] * entree[l_neurone_2];
          end;
        end; (* with *)
      end; (* mets_a_jour_poids *)

    var l_element: Word;

    begin (* entraine_reseau *)
      with g_reseau do
      begin
        (* -- 11 est la premiere interference *)
        for l_element := 11 to k_element_max do
        begin
          calcule_sortie(k_elements[l_element], k_itere_correction_max);
          mets_a_jour_poids;

          if l_element = k_exemple_affiche
            then affiche_reseau(l_element);
        end; (* for *)
      end; (* with *)
    end; (* entraine_reseau *)
    
  var l_apprentissage: Word;
      l_essai: Word;
      l_affiche: Boolean;

  begin (* entraine *)
    initialise_reseau;
    ClrScr;

    with g_reseau do
      FillChar(sortie, SizeOf(sortie), 0);
    affiche_reseau(1);

    for l_apprentissage := 1 to k_apprentissage_max do
    begin
      GotoXY(1, 1); Write('APPRENDS ', l_apprentissage);
      l_affiche := False;
      entraine_reseau(l_apprentissage, l_affiche);
    end;

    stoppe;

    for l_essai := 1 to 6 do
    begin
      GotoXY(1, 1); ClrEol; Write('ESSAI ', l_essai);
      calcule_sortie(k_elements[l_essai], k_itere_correction_max * 10);
      affiche_reseau(l_essai);

      affiche_en_clair(g_reseau.sortie, 18 + l_essai, 0.5, 0.001, 0.0005);
      stoppe;
    end;
    GotoXY(1, 25); ReadLn;
  end; (* entraine *)

procedure initialise;
  begin
  end;

var g_choix: Char;

begin (* brain *)
  initialise;

  repeat
    WriteLn;
    Write('Sortie, Entraine, ');
    Write('Quitter ? ');
    g_choix := UpCase(ReadKey);WriteLn(g_choix);
    case g_choix of
      ' ': ClrScr;
      'S': g_pt_sortie^.choisis_sortie;
      'E': entraine;
    end;
  until  g_choix = 'Q';

  g_pt_sortie^.ferme_sortie;
end. (* brain *)