unit uAgenda;

interface
uses Classes;

type TAgenda = class
private

protected

public
  Facao :Integer;
  Fcontrole :Integer;
  Fcodigo_profissional :Integer;
  Femp_profissional    :Integer;
  Fhora                :Integer;
  Ffim                 :Integer;
  Fdata                :String;
  Fid_Web              :Integer;
  FstatusA             :String;
  Fcontrole_web :Integer;
  Fservicos :String;
  FclienteIdWeb :Integer;
  FprofissionalIdWeb :Integer;
  FsalaoIdWeb :Integer;
  FservicoIdWeb :Integer;
  Fstatus :String;

published 

end;

type Agendas = array of TAgenda;

implementation

end.
