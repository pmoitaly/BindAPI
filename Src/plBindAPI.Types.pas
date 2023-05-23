{*****************************************************************************}
{       BindAPI                                                               }
{       Copyright (C) 2020 Paolo Morandotti                                   }
{       Unit plBindAPI.Types                                                  }
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
unit plBindAPI.Types;

interface

uses
  {$IFDEF FPC}
  Classes, SysUtils, Generics.Collections, Rtti;
  {$ELSE}
  System.Generics.Collections,
  System.Classes, System.SysUtils, System.Rtti;
  {$ENDIF}
type

{$REGION 'Enuberables'}
  TPlBindDirection = (bdLeftToRight, bdRightToLeft, bdLeftToRightToLeft, bdRightToLeftToRight);
  TPlBindOptions = (boSingleton, boDeferred);
  TPlBindOptionsSet = set of TPlBindOptions;
{$ENDREGION}

{$REGION 'CommonTypes'}
  TPlBoundObjects = TArray<TObject>;
  TPlCreateParams = array of TValue;
  TPlBindDebugInfo = record
    Active: boolean;
    Interval: integer;
    Count: integer;
  end;



{$ENDREGION}

{$REGION 'Exceptions'}
  EPlBindApiException = Exception;
{$ENDREGION}

{$REGION 'Methods'}
  TPlBridgeFunction = function(const NewValue, OldValue: TValue): TValue of object;
  TPlCallbackProcedure = TNotifyEvent;
{$ENDREGION}

{$REGION 'Interfaces'}
  IPlAutoBinder = interface
    ['{64BF1986-35A2-48D4-9558-2EBDB345EFEB}']
    procedure Bind(ASource: TObject; const APropertySource: string; ATarget: TObject; const APropertyTarget: string; AFunction: TplBridgeFunction = nil);
    procedure BindObject(ASource, aTarget: TObject; const AnAlias: string);
    function Count: integer;
    procedure Start(const SleepInterval: Integer);
    procedure Stop;
    procedure UnbindSource(ASource: TObject);
    procedure UnbindTarget(ATarget: TObject);
    procedure UpdateValues;
  end;
{$ENDREGION}

implementation

end.
