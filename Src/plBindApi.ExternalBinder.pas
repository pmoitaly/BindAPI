unit plBindApi.ExternalBinder;
{*****************************************************************************}
{                                                                             }
{Copyright (C) 2020-2024 Paolo Morandotti                                     }
{Unit plBindAPI.ExternalBinder    - IN PROGRESS, DON'T USE                    }
{*****************************************************************************}
{                                                                             }
{Permission is hereby granted, free of charge, to any person obtaining        }
{a copy of this software and associated documentation files (the "Software"), }
{to deal in the Software without restriction, including without limitation    }
{the rights to use, copy, modify, merge, publish, distribute, sublicense,     }
{and/or sell copies of the Software, and to permit persons to whom the        }
{Software is furnished to do so, subject to the following conditions:         }
{                                                                             }
{The above copyright notice and this permission notice shall be included in   }
{all copies or substantial portions of the Software.                          }
{                                                                             }
{THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS      }
{OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,  }
{FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  }
{AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       }
{LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING      }
{FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS }
{IN THE SOFTWARE.                                                             }
{*****************************************************************************}
{* questa dovrebbe essere una classe che rende semplice
   il bind esterno, ovvero attraverso il collegamento di 
   elementi via codice. Potrebbe essere utile creare un
   contenitore di queste classi di cui poi si richiama
   il metodo ExecuteBind in un colpo solo.
   Opzionalmente, si potrebbe passare come parametro 
   di Create un oggetto binder?
*}

interface

uses
  plBindApi.CoreBinder;

type
  TExternalBinder = class
  protected
    FBinder: TPlBinder;
    FController: TInterfacedObject;
    FFreeOnDestroy: boolean;
    FSource: TObject;
  protected
    FInterval: integer;
    procedure ExecuteBind; virtual;
  public
    constructor Create; overload;
    constructor Create(ABinder: TplBinder); overload;
    destructor Destroy; override;
    procedure Execute(Source: TObject; Controller: TInterfacedObject; const AnInterval: integer = 500);
    procedure StartBind(const AnInterval: integer);
    procedure StopBind;
    procedure TerminateBind;
  end;


implementation

uses
  SysUtils;

constructor TExternalBinder.Create;
begin
  inherited;
  FBinder := TPlBinder.Create;
  FFreeOnDestroy := True;
end;

constructor TExternalBinder.Create(ABinder: TplBinder);
begin
  inherited Create;
  FBinder := ABinder;
  FFreeOnDestroy := False;
end;

destructor TExternalBinder.Destroy;
begin
  FBinder.Stop;
  FBinder.Free;
  inherited;
end;

procedure TExternalBinder.Execute(Source: TObject; Controller: TInterfacedObject; const AnInterval: integer = 500);
begin
  FSource := Source;
  FController := Controller;
  FInterval := AnInterval;
  ExecuteBind;
  if AnInterval > -1 then
    StartBind(AnInterval);
end;

{ TExternalBinder }

procedure TExternalBinder.ExecuteBind;
begin
  // override with binds you need
end;

procedure TExternalBinder.StartBind(const AnInterval: integer);
begin
  FBinder.Start(AnInterval);
end;

procedure TExternalBinder.StopBind;
begin
  FBinder.Stop;
end;

procedure TExternalBinder.TerminateBind;
begin
  StopBind;
  FBinder.Clear;
end;

end.
