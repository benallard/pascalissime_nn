unit ugrafbor;

interface

procedure initialise_mode_graphique(p_x: Boolean);
procedure termine_mode_graphique;

implementation
Uses ptcGraph;

procedure initialise_mode_graphique(p_x: Boolean);
  var l_carte, l_mode: Integer;
      l_err: ShortInt;
  begin
    l_carte := D8bit;
	l_mode := m640x480;
	InitGraph(l_carte, l_mode, '');
    l_err := graphResult;
    if (l_err <> grOk) then
      begin
        Writeln('640x480x256 not supported');
        halt(1);
      end;
  end;

procedure termine_mode_graphique;
  begin
    CloseGraph;
  end;

end.

begin;

end.