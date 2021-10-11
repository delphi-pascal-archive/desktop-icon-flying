object FIconClash: TFIconClash
  Left = 219
  Top = 124
  Width = 834
  Height = 640
  Caption = 'Vos icones du bureau s'#39'envolent...'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  DesignSize = (
    826
    612)
  PixelsPerInch = 120
  TextHeight = 16
  object Ecran: TImage
    Left = 8
    Top = 8
    Width = 809
    Height = 593
  end
  object SB: TTrackBar
    Left = 16
    Top = 560
    Width = 209
    Height = 25
    Anchors = [akLeft, akBottom]
    Max = 20
    Position = 4
    TabOrder = 1
    TickStyle = tsNone
  end
  object Stop: TButton
    Left = 336
    Top = 560
    Width = 97
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Stop'
    TabOrder = 2
    Visible = False
    OnClick = StopClick
  end
  object Start: TButton
    Left = 232
    Top = 560
    Width = 97
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = 'Start'
    TabOrder = 0
    OnClick = StartClick
  end
  object ILIcone: TImageList
    Left = 408
    Top = 24
  end
  object ILFinal: TImageList
    BlendColor = clBlack
    BkColor = clBlack
    Left = 440
    Top = 24
  end
end
