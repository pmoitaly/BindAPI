{*****************************************************************************}
{BindAPI                                                                      }
{Copyright (C) 2020 Paolo Morandotti                                          }
{Unit plBindAPI.Types                                                         }
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
  Classes, SysUtils, TypInfo, Rtti,
  Generics.Collections,
  plBindAPI.Attributes;

type

{$REGION 'Enuberables'}
  TPlBindAPIOptions = record
  public type
    AutoBindOptions = (Recursive); // To be continued...
    BindDirection = (LeftToRight, RightToLeft, LeftToRightToLeft,
      RightToLeftToRight); // future use
    BindOptions = (Singleton, Deferred, AutoBind);
  end;

  TPlAutoBindOptionSet = set of TPlBindAPIOptions.AutoBindOptions;
  TPlBindOptionsSet = set of TPlBindAPIOptions.BindOptions;

  TPlBinderStatus = (bsStopped, bsRunning);
{$ENDREGION}

{$REGION 'CommonTypes'}
  TPlBoundObjects = TArray<TObject>;
  TPlCreateParams = array of TValue;

  TPlBindDebugInfo = record
    Active: boolean;
    Interval: integer;
    Count: integer;
  end;

  TarAttributes = TArray<TCustomAttribute>;
  TarFields = TArray<TRttiField>;
  TarMethods = TArray<TRttiMethod>;
  TarProperties = TArray<TRttiProperty>;
  TPlRTTIParametersArray = TArray<TRttiParameter>;
  TPlBindParametersType = TArray<TTypeKind>;
  TPlBindParametersTypeInfo = TArray<TTypeInfo>;
  TPlIndexedPropertyInfo = record
    paramsTypes: TPlBindParametersType;
    paramsTypInfo: TPlBindParametersTypeInfo;
    paramsValues: TPlCreateParams;
  end;
  TPlListObjects = TList<TObject>;
{$ENDREGION}

{$REGION 'Exceptions'}
  EPlBindApiException = Exception;
{$ENDREGION}

{$REGION 'Methods'}
  TPlBridgeFunction = function(const NewValue, OldValue: TValue)
    : TValue of object;
  TPlCallbackProcedure = TNotifyEvent;
{$ENDREGION}

{$REGION 'Interfaces'}
  IPlAutoBinder = interface
    ['{64BF1986-35A2-48D4-9558-2EBDB345EFEB}']
    procedure Bind(ASource: TObject; const APropertySource: string;
      ATarget: TObject; const APropertyTarget: string;
      AFunction: TPlBridgeFunction = nil);
    procedure BindObject(ASource, ATarget: TObject;
      AnAttribute: BindClassAttribute);
    function Count: integer;
    procedure Start(const SleepInterval: integer);
    procedure Stop;
    procedure UnbindSource(ASource: TObject);
    procedure UnbindTarget(ATarget: TObject);
    procedure UpdateValues;
  end;
{$ENDREGION}

const
  PL_SELF_ALIAS: array[0..2] of string = ('', '.', 'Self');
implementation

end.
