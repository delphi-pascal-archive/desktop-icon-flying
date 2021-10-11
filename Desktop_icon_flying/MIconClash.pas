////////////////////////////////////////////////////////////////////////////
{ by cantador and Bacterius 07/07/09 - pulsar3000@wanadoo.fr }
////////////////////////////////////////////////////////////////////////////

unit MIconClash;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, CommCtrl, StdCtrls, Registry, ImgList, ShellAPI,
  ExtCtrls, Jpeg;

type
  TIcone = record
    w, h: integer; {dimensions de l'image}
    Theta: single; {angle de déplacemennt}
    speed: single; {vitesse de déplacement}
    x, y: single; {coordonnées de l'image}
    PRect: Trect; {rectangle de l'icone et de l'image}
  end;


type
  TFIconClash = class(TForm)
    ILIcone: TImageList;
    ILFinal: TImageList;
    Ecran: TImage;
    Start: TButton;
    SB: TTrackBar;
    Stop: TButton;
    procedure FormCreate(Sender: TObject);
    procedure StartClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Déclarations privées }
    procedure Direction(num: integer);
    function ReboundAngleVariation: single;
    procedure IconePaint;
    procedure PictureStorage;
    procedure IconStorage(h: HIcon; num: integer);
    procedure ReadFile(CurDir: string);
    procedure Init(n: integer);
    procedure MoveIcone(N: integer);
    procedure Animation;
  public
    { Déclarations publiques }
  end;

var
  FIconClash: TFIconClash;
  num: integer;
  DirPath: string;
  bk: TBitmap; {Fond de l'écran}
  Icone: array of TIcone; {tableau des icones du bureau}
  dt: Extended;
  dx, dy: single;

implementation

{$R *.dfm}

procedure TFIconClash.Direction(num: integer);
begin
  with Icone[num] do
  begin
    dx := x + speed * sin(Theta);
    dy := y + speed * cos(Theta);
  end;
end;

procedure LoadJPEG(Nom: string; Bmp: TBitMap);
var
  ImageJPEG: TJPEGImage;

begin
  ImageJPEG := TJPEGImage.Create; {On crée le jpg}

  try

    ImageJPEG.LoadFromFile(Nom); {On  charge le .jpg}
    Bmp.Assign(ImageJPEG); {On l'affecte au Bmp}

  finally
    ImageJPEG.Free; {On libère le jpg}
  end;

end;

function Middle(const ALeftOrTop, ARightOrBottom: integer): integer;
begin
  {    du pur f0xi

   Calcul du millieu d'une droite.
   shr 1 = div 2
  }
  result := (ARightOrBottom - ALeftOrTop) shr 1;
end;

procedure TFIconClash.ReadFile(CurDir: string);
var
  searchResult: TSearchRec;
  num: integer;
  lpiIcon: word;
begin {on boucle sur tous les fichiers du bureau dont on extrait l'icone avec}

  num := 0; {l'api ExtractAssociatedIcon}

  SetCurrentDir(CurDir); {on lit le dossier des icones}

  if FindFirst('*.*', faAnyFile, searchResult) = 0 then
  begin
    repeat
      IconStorage(ExtractAssociatedIcon(HInstance, PChar(searchResult.Name), lpiIcon), num);
      Inc(num);
    until FindNext(searchResult) <> 0;

    FindClose(searchResult);
  end;
end;

function DossierBureau: string;
var
  Reg: TRegistry; {Récupération du dossier qui contient le bureau en lisant la base de registre}
begin {au bon endroit..}
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', false);
    result := Reg.ReadString('Desktop') + '\';
  finally
    Reg.Closekey;
    Reg.free;
  end;
end;

procedure TFIconClash.IconStorage(h: HIcon; num: integer);
var
  Ic: TIcon;
begin
  Ic := TIcon.Create;
  try
    Ic.Handle := h;
    ILIcone.AddIcon(Ic); {on stocke les icones dans un TImageList}
  finally
    Ic.Free;
  end;
end;

procedure TFIconClash.PictureStorage;
var
  MonIcon: TIcon;
  BmpIm,BmpIc: TBitmap;
  MonImage: TImage;
  i: integer;
begin

  BmpIm := TBitmap.Create; {on crée le bitmap temporaire}
  BmpIc := TBitmap.Create; {on crée le bitmap temporaire}
  MonIcon := TIcon.Create; {on crée l'icone temporaire}
  MonImage := TImage.Create(self); {on crée l'image temporaire}

  try
    for i := 0 to ILIcone.Count - 1 do {Ici, on fait une fusion entre une image avec un joli cercle et l'icone}
    begin
//      LoadJPEG(DirPath + 'circle2.jpg', Bmp);  {pas bon car laisse plein de traces..}

      BmpIm.LoadFromFile(DirPath + 'circle.bmp'); {on charge l'image du cercle classiquement}
      ILIcone.GetIcon(i, MonIcon); {on stocke l'icone}
      BmpIc.Height := MonIcon.Height;
      BmpIc.Width := MonIcon.Width;

      BmpIm.Canvas.Draw(BmpIm.Height div 4, BmpIm.width div 4, MonIcon);

      ILFinal.Add(BmpIm, nil); {On crée chaque image avec son cercle - nil car pas de Mask}
    end;

  finally
    MonIcon.Free; {on libère l'icone temporaire}
    BmpIm.Free;  {on libère le bitmap temporaire}
    BmpIc.Free; {on libère le bitmap temporaire}
    MonImage.Free; {on libère l'image temporaire}
  end;    
end;

procedure TFIconClash.FormCreate(Sender: TObject);
begin
  dt := 0.1;
  Ecran.Anchors := Ecran.Anchors + [akLeft]; {ancrage de l'écran à gauche}
  Ecran.Anchors := Ecran.Anchors + [akTop]; {ancrage de l'écran en haut}
  Ecran.Anchors := Ecran.Anchors - [akRight]; {désancrage de l'écran à droite}
  Ecran.Anchors := Ecran.Anchors + [akBottom]; {ancrage de l'écran en bas}

  DoubleBuffered := true; {ralentit mais apporte de la souplesse - cruel dilemme !}

  ILFinal.Height := 80;
  ILFinal.Width := 80;
  ILIcone.Height := 32;
  ILIcone.Width := 32;
  DirPath := ExtractFilePath(Application.ExeName); {dossier de l'exécutable de l'application}
  bk := TBitmap.create;

  LoadJPEG(DirPath + 'fond.jpg', bk); {on charge l'image du fond en jpg donc moins lourde}

  Stop.bringtofront; {bouton stop en avant plan}
  ReadFile(DossierBureau); {on lit le bon dossier}
  PictureStorage; {toutes les images finales sont stockées dans ILFinal}
  SetLength(Icone, ILFinal.Count); {on dimensionne le Tableau Icone au nombre d'icones trouvé}
end;

function TFIconClash.ReboundAngleVariation: single;
begin
  Result := random * 2 * pi; {direction du rebond fantaisiste et non plus physique}
end;

procedure TFIconClash.Init(n: integer);
var
  bmp: TBitmap;
  fCoord: TPoint;
begin
  bmp := TBitmap.create; {on crée le Bitmap}
  try

    with Icone[n] do
    begin
      Theta := ReboundAngleVariation; {direction du rebond}

      speed := 4 + random(10); {vitesse aléatoire avec un mini quand random renvoie 0}

      with bmp do
      begin
        width := ILFinal.width;
        height := ILFinal.height;

        ILFinal.GetBitmap(n, bmp); {on récupère chaque image de ILFinal}

        w := width; {on stocke sa largeur}
        h := height; {on stocke sa hauteur}

        {Astuce empruntée à f0xi pour le démarrage afin que les icones
        explosent en plein milieu de l'écran au démarrage}
        fCoord := Point(Middle(Ecran.Left, Ecran.Width), Middle(Ecran.Top, Ecran.Height));

       {on affecte les coordonnées}
        x := fCoord.X;
        y := fCoord.Y;

      end;
    end;

  finally
    bmp.free; {on libère le Bitmap temporaire}
  end;
end;

procedure TFIconClash.MoveIcone(n: integer);
begin
  with Icone[n] do

  begin
    if (x < 0) or (x + w > Ecran.width) or
      (y < 0) or (y + h > Ecran.height) then {si l'icone déborde de l'écran alors on le renvoie}

    begin {dans une autre direction dx, dy}

      repeat

        Theta := ReboundAngleVariation; {angle du rebond}
        Direction(n);

   { se répète jusqu'à ce que l'icone soit dans l'écran  }

      until (dx >= 0) and (dx + w <= Ecran.width)
        and (dy >= 0) and (dy + h <= Ecran.height);

    end

    else

    begin
      Direction(n);

  { si l'icone est dans l'écran alors on conserve sa position }

    end;

    x := dx; {affectation des résultats}
    y := dy;
  end;

end;

procedure TFIconClash.Animation;
var
  i: integer;
begin
  tag := 0; {tag = 0 puisqu'il y a animation}
  stop.visible := true; {Bouton stop visible, il passe devant le start}

  for i := 0 to ILFinal.Count - 1 do
    Init(i); {Initialisation}

  with Ecran do
    canvas.stretchdraw(rect(0, 0, width, height), bk); {on copie le background sur le canvas de l'écran}
                                                       {évitant la recharge des icones}

  with bk do
  begin
    width := Ecran.width;
    height := Ecran.height; {on efface les traces des images en redessinant}
    canvas.draw(0, 0, Ecran.picture.bitmap); {le fond à la taille de l'écran}
  end;


  while tag = 0 do {on teste le tag mis à un par StopClick(Sender}
  begin

    for i := 0 to ILFinal.Count - 1 do
      MoveIcone(i); {déplacement des images}

    IconePaint; {dessin des images}

    application.processmessages; {obligatoire pour voir quelque chose..}

    sleep(20 - (SB.position)); {Temporisation qui tient compte de la }

  end; {vitesse affichée sur le TrackBar}


  stop.visible := false; {Bouton stop invisible, il passe derrière le start}
end;

procedure TFIconClash.IconePaint;
var
  i: integer;
  newx, newy: integer;
  bmp: TBitmap;
begin
  bmp := TBItmap.Create; {on crée le Bitmap temporaire}

  try
    if ILFinal.count = 0 then {si il n'y pas d'icone (ça arrive!) }
      exit; {on sort}

    for i := 0 to ILFinal.Count - 1 do

      with Icone[i], Ecran.canvas do
        copyrect(PRect, bk.canvas, PRect); {on efface les anciennes positions
                                                      {en copiant leurs rectangles}

    for i := 0 to ILFinal.Count - 1 do {on ajoute les nouvelles images}
      with Icone[i], PRect do
      begin
        newx := trunc(x); {on sauvegarde les ccordonnées des images}
        newy := trunc(y);

        left := newx; {on affecte les nouvelles}
        top := newy;
        right := newx + w;
        bottom := newy + h;

        ILFinal.GetBitmap(i, Bmp); {on récupère chaque image}
        Bmp.TransparentColor := clWhite; {couleur de transparence}
        Bmp.Transparent := True; {on la rend Transparente}

        Ecran.Picture.Bitmap.Canvas.Draw(newx, newy, Bmp); {on dessine la nouvelle image sur le canvas de l'écran}
      end; {à la nouvelle position}

  finally
    bmp.Free; {on libère le Bitmap temporaire}
  end;
end;

procedure TFIconClash.StartClick(Sender: TObject);
begin
  randomize;
  Animation;
end;

procedure TFIconClash.FormActivate(Sender: TObject);
begin
  windowstate := wsmaximized;
end;

procedure TFIconClash.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  StopClick(sender);
  canclose := true;
end;

procedure TFIconClash.FormResize(Sender: TObject);
begin
  tag := 1; {on arrête l'animation si on change la taille de la forme}
  with Ecran do {sinon ça m...pas mal}
  begin
    width := FIconClash.clientwidth - (2 * left); {on centre l'image puisqu'on ne peut la mettre en full}
    picture.bitmap.width := width; {à cause des boutons}
    picture.bitmap.height := height;
    canvas.stretchdraw(rect(0, 0, width, height), bk); {on redessine le fond à la nouvelle taille}
  end;
end;

procedure TFIconClash.StopClick(Sender: TObject);
begin
  tag := 1;
end;

procedure TFIconClash.FormDestroy(Sender: TObject);
begin
  bk.Free; {on libère le bitmap du fond}
end;

end.

