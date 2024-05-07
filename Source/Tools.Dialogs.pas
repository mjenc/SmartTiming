unit Tools.Dialogs;

interface

uses
  FMX.Forms, SysUtils;

type
  TApplicationHelper = class  helper for TApplication
  public
    function ExeName: String;
    class procedure Confirm(const AMessage: String; const SetConfirmationResult: TProc<Boolean>);
    class procedure InfoMessage(const AMessage: String);
  end;

implementation

uses
  {$IFDEF ANDROID}
  Androidapi.Helpers, //for TAndroidHelper, JStringToString
  Androidapi.Jni.JavaTypes, //to avoid "H2443 Inline function 'JStringToString' has not been expanded"
  {$ENDIF}
  System.UITypes, //for TMsgDlgType
  FMX.DialogService, //for TDialogService
  FMX.Dialogs; //for mbYesNo


//from https://gist.github.com/freeonterminate/2f7b2e29e40fa30ed3c4
function TApplicationHelper.ExeName: String;
begin
  Result := ParamStr(0);

  {$IFDEF ANDROID}
  if (Result.IsEmpty) then
    Result := JStringToString(TAndroidHelper.Context.getPackageCodePath);
  {$ENDIF}
end;

//based on https://stackoverflow.com/questions/42852945/delphi-correctly-displaying-a-message-dialog-in-firemonkey-and-returning-the-m
class procedure TApplicationHelper.Confirm(const AMessage: String; const SetConfirmationResult: TProc<Boolean>);
begin
  with TDialogService do
  begin
    PreferredMode := TPreferredMode.Platform;
    MessageDialog(AMessage, TMsgDlgType.mtConfirmation, mbYesNo, TMsgDlgBtn.mbNo, 0,
      procedure(const AResult: TModalResult)
      begin
        //Note: assuming this is executed on the main/UI thread later on, so we just call the "SetResult" callback procedure passing it the dialog result value
        case AResult of
          mrYes: SetConfirmationResult(true);
          mrNo: SetConfirmationResult(false);
        end;
      end
    );
  end;
end;

class procedure TApplicationHelper.InfoMessage(const AMessage: String);
begin
  with TDialogService do
  begin
    PreferredMode := TPreferredMode.Platform;
    MessageDialog(AMessage, TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOk, 0, nil);
  end;
end;

end.
