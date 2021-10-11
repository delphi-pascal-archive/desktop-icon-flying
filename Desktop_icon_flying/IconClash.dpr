program IconClash;

uses
  Forms,
  MIconClash in 'MIconClash.pas' {FIconClash};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFIconClash, FIconClash);
  Application.Run;
end.
