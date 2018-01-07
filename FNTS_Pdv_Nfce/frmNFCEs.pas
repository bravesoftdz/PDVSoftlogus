unit frmNFCEs;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Data.DB,
  ZAbstractRODataset,
  ZAbstractDataset, ZDataset, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, NxDBColumns,
  NxColumns,XMLIntf, XMLDoc, zlib, ACBrUtil,
  NxScrollControl, NxCustomGridControl, NxCustomGrid, NxDBGrid, Vcl.ImgList,
  Wwdbigrd, Wwdbgrid, Vcl.Mask, sMaskEdit, sCustomComboEdit, sTooledit,
  pcnConversao, System.ImageList, AdvMetroButton, AdvSmoothPanel,
  AdvSmoothExpanderPanel, MemDS, DBAccess, Uni, pcnAuxiliar, Vcl.OleCtrls,
  SHDocVw, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, cxNavigator,
  cxDBData, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGridLevel, cxClasses, cxGridCustomView, cxGrid, JvExDBGrids, JvDBGrid;

type
  TfrmNotasconsumidor = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ds_nfce: TDataSource;
    Button4: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edt_Numero: TEdit;
    ImageList2: TImageList;
    dataini: TsDateEdit;
    datafin: TsDateEdit;
    qrNFCE: TUniQuery;
    JvDBGrid1: TJvDBGrid;
    qrNFCENUMERO: TIntegerField;
    qrNFCEDATA: TDateField;
    qrNFCETOTAL: TFloatField;
    qrNFCECLIENTE: TStringField;
    qrNFCECHAVE: TStringField;
    qrNFCEXML: TStringField;
    qrNFCESITUACAO: TIntegerField;
    qrNFCETROCO: TFloatField;
    qrNFCEDES_SIT: TStringField;
    qrNFCEHORA: TStringField;
    Panel3: TPanel;
    Panel4: TPanel;
    lbEnvio: TLabel;
    lbCancelamento: TLabel;
    qrNFCEXML_CANCELAMENTO: TStringField;
    qrNFCECONTINGENCIA: TStringField;
    qrNFCEENVIADOCONTINGENCIA: TStringField;
    btn1: TButton;
    procedure Button4Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure AdvMetroButton1Click(Sender: TObject);
    procedure qrNFCEAfterScroll(DataSet: TDataSet);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
    procedure LoadXML(RetWS: String; MyWebBrowser: TWebBrowser);
  public
    { Public declarations }
  end;

var
  frmNotasconsumidor: TfrmNotasconsumidor;

implementation

{$R *.dfm}

uses modulo, principal, ResultadoWebService, senha_supervisor, justificativa,
  Config;

procedure TfrmNotasconsumidor.AdvMetroButton1Click(Sender: TObject);
begin
 Close;
end;

procedure TfrmNotasconsumidor.btn1Click(Sender: TObject);
   //Botao inutilizacao da NFC-e ( Concluir Depois )
var
 Modelo, Serie, Ano, NumeroInicial, NumeroFinal, Justificativa : String;
begin
 if not(InputQuery('WebServices Inutiliza��o ', 'Ano',    Ano)) then
    exit;
 if not(InputQuery('WebServices Inutiliza��o ', 'Modelo', Modelo)) then
    exit;
 if not(InputQuery('WebServices Inutiliza��o ', 'Serie',  Serie)) then
    exit;
 if not(InputQuery('WebServices Inutiliza��o ', 'N�mero Inicial', NumeroInicial)) then
    exit;
 if not(InputQuery('WebServices Inutiliza��o ', 'N�mero Final', NumeroFinal)) then
    exit;
 if not(InputQuery('WebServices Inutiliza��o ', 'Justificativa', Justificativa)) then
    exit;
  frmconfig.ACBrNFe1.WebServices.Inutiliza(frmconfig.edtEmitCNPJ.Text, Justificativa, StrToInt(Ano), StrToInt(Modelo), StrToInt(Serie), StrToInt(NumeroInicial), StrToInt(NumeroFinal));
end;

procedure TfrmNotasconsumidor.Button1Click(Sender: TObject);
var
  Chave, idLote, CNPJ, Protocolo, Justificativa: string;
begin
  if qrNFCE.RecordCount > 0 then
  begin
    if qrNFCE.FieldByName('situacao').AsInteger = 0 then
    begin
      if Application.MessageBox('Deseja realmente cancelar esta NFC-e, este processo � irrevers�vel?','Aten��o',MB_ICONQUESTION+MB_YESNO) <> mrYes then
        Exit;
      Application.CreateForm(TfrmSenha_Supervisor,frmSenha_Supervisor);
      frmSenha_Supervisor.ShowModal;
      FreeAndNil(frmSenha_Supervisor);
      if not bSupervisor_autenticado then begin
        Exit;
      end;
      Chave := qrNFCE.FieldByName('chave').AsString;
      idLote := '1';
      CNPJ := copy(Chave, 7, 14);
      Protocolo := '';
      Application.CreateForm(Tfrmjustificativa, frmjustificativa);
      frmjustificativa.ShowModal;
      Justificativa := frmjustificativa.edTexto.Lines.Text;
      FreeAndNil(frmjustificativa);
      with frmModulo do begin
        LerConfiguracao;
        ACBRNFCe.NotasFiscais.Clear;
        ACBRNFCe.NotasFiscais.LoadFromFile(qrNFCE.FieldByName('xml').AsString);

        idLote := '1';
        ACBRNFCe.EventoNFe.Evento.Clear;
        ACBRNFCe.EventoNFe.idLote := strtoint(idLote);
        with ACBRNFCe.EventoNFe.Evento.Add do begin
          infEvento.dhEvento := now;
          infEvento.tpEvento := teCancelamento;
          infEvento.detEvento.xJust := Justificativa;
        end;
        ACBRNFCe.EnviarEvento(strtoint(idLote));

        Application.CreateForm(TfrmResultadoWebService,frmResultadoWebService);
        LoadXML(ACBRNFCe.WebServices.EnvEvento.RetornoWS, frmResultadoWebService.WBResposta);
        frmResultadoWebService.pnTexto.Caption := IntToStr(ACBRNFCe.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
          .RetInfEvento.cStat) + ' - ' + ACBRNFCe.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
          .RetInfEvento.xMotivo;
        frmResultadoWebService.ShowModal;
        FreeAndNil(frmResultadoWebService);
        if ACBRNFCe.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0]
          .RetInfEvento.cStat = 135 then begin
          qrNFCE.Edit;
          qrNFCE.FieldByName('situacao').AsInteger := 1;
          qrNFCE.FieldByName('xml_cancelamento').AsString := ACBRNFCe.WebServices.EnvEvento.EventoRetorno.retEvento.Items[0].RetInfEvento.NomeArquivo;
          qrNFCE.Post;
          qrNFCE.ApplyUpdates;
          Conexao_Servidor.Commit;
          Button4.Click;
        end;
      end;
    end else begin
      Application.MessageBox('NFC-e ja est� cancelada.','Aten��o!',MB_ICONINFORMATION);
      Exit;
    end;
  end;
end;

procedure TfrmNotasconsumidor.Button2Click(Sender: TObject);
var
  bc: TBitmap;
begin
  if qrNFCE.RecordCount > 0 then
  begin
    if qrNFCE.FieldByName('situacao').AsInteger = 0 then
    begin
      with frmModulo do
      begin
        ACBRNFCe.NotasFiscais.Clear;
        ACBRNFCe.NotasFiscais.LoadFromFile(qrNFCE.FieldByName('xml').AsString);
        ACBRDANFENFCe.FastFile := 'C:\Softlogus\PDV\Schemas\DANFeNFCe.fr3';
        if FileExists(frmPrincipal.LerIni(sConfiguracoes, 'PDV',
          'CAMINHO_LOGO', '')) then
          ACBRDANFENFCe.Logo := frmPrincipal.LerIni(sConfiguracoes, 'PDV',
            'CAMINHO_LOGO', '');
        ACBRDANFENFCe.vTroco := qrNFCETROCO.AsFloat;
        ACBRDANFENFCe.Detalhado := False;
        ACBRNFCe.NotasFiscais.Imprimir;
      end;
    end;
  end;
end;

procedure TfrmNotasconsumidor.Button3Click(Sender: TObject);
begin

  if qrNFCE.RecordCount > 0 then
  begin
    with frmModulo do
    begin
      LerConfiguracao;
      ACBRNFCe.WebServices.Consulta.NFeChave :=
        qrNFCE.FieldByName('chave').AsString;
      if ACBRNFCe.WebServices.Consulta.Executar then begin
       Application.CreateForm(TfrmResultadoWebService,frmResultadoWebService);
       LoadXML(ACBRNFCe.WebServices.Consulta.RetornoWS, frmResultadoWebService.WBResposta);
       frmResultadoWebService.pnTexto.Caption := IntToStr(ACBRNFCe.WebServices.Consulta.cStat) + ' - ' + ACBRNFCe.WebServices.Consulta.xMotivo;
       frmResultadoWebService.ShowModal;
       FreeAndNil(frmResultadoWebService);
      end else begin
        Application.MessageBox('Ocorreu um erro ao efetuar a consulta.','Aten��o!',MB_ICONINFORMATION);
      end;
    end;
  end;
end;

procedure TfrmNotasconsumidor.Button4Click(Sender: TObject);
var
  filtro:String;
begin
  qrNFCE.Close;
  qrNFCE.SQL.Clear;
  qrNFCE.SQL.Add('select nf.*, case when situacao = 0 then ' + QuotedStr('Emitido') + ' else ' + QuotedStr('Cancelado') + ' end des_sit ');
  qrNFCE.SQL.Add('from NFCE nf where 1=1 ');
  if Length(edt_Numero.Text) > 0 then begin
    qrNFCE.SQL.Add('and numero = :pnumero ');
    qrNFCE.ParamByName('pnumero').AsInteger := strtoint(edt_Numero.Text);
  end;

  if dataini.Date > 0 then begin
    qrNFCE.SQL.Add('and data >= :pdataini ');
    qrNFCE.ParamByName('pdataini').AsDateTime := dataini.Date;
  end;

  if datafin.Date > 0 then begin
    qrNFCE.SQL.Add('and data <= :pdatafin ');
    qrNFCE.ParamByName('pdatafin').AsDateTime := datafin.Date;
  end;
  qrNFCE.SQL.Add('order by numero');
  qrNFCE.Open;
  qrNFCE.First;
end;

procedure TfrmNotasconsumidor.FormShow(Sender: TObject);
begin
  dataini.Date := now;
  datafin.Date := now;
  Button4.Click;
end;


procedure TfrmNotasconsumidor.LoadXML(RetWS: String; MyWebBrowser: TWebBrowser);
begin
  ACBrUtil.WriteToTXT( PathWithDelim(ExtractFileDir(application.ExeName))+'temp.xml',
                        ACBrUtil.ConverteXMLtoUTF8( RetWS ), False, False);
  MyWebBrowser.Navigate(PathWithDelim(ExtractFileDir(application.ExeName))+'temp.xml');
end;

procedure TfrmNotasconsumidor.qrNFCEAfterScroll(DataSet: TDataSet);
begin
  lbEnvio.Caption := 'XML de Envio: ' + qrNFCEXML.AsString;
  lbCancelamento.Caption := 'XML de Cancelamento: ' + qrNFCEXML_CANCELAMENTO.AsString;
end;

end.
