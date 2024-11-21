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
/// <summary>
///   Implementation of types used across the framework.
/// </summary>
unit plBindAPI.Types;

interface

uses
  Classes, SysUtils, TypInfo, Rtti,
  Generics.Collections,
  plBindAPI.Attributes;

type

{$REGION 'Enuberables'}
  /// <summary>
  ///   Some sets used for binding definition
  /// </summary>
  TPlBindAPIOptions = record
  public type
    AutoBindOptions = (Recursive); // To be continued...
    BindDirection = (LeftToRight, RightToLeft, LeftToRightToLeft,
      RightToLeftToRight); // future use
    BindOptions = (Singleton, Deferred, AutoBind);
  end;

  TPlAutoBindOptionSet = set of TPlBindAPIOptions.AutoBindOptions;
  TPlBindOptionsSet = set of TPlBindAPIOptions.BindOptions;

  /// <summary>
  ///   Describes the Status of the binder.
  /// </summary>
  TPlBinderStatus = (bsStopped, bsRunning);
{$ENDREGION}

{$REGION 'CommonTypes'}
  TPlBoundObjects = TArray<TObject>;
  TPlCreateParams = array of TValue;

  /// <summary>
  ///   Small set of info about the binder - for debug purposes.
  /// </summary>
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
  /// <summary>
  ///   Info about the index id a IndexedProperty
  /// </summary>
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
  /// <summary>
  /// (In progress) Interface for automatically binding properties between objects.
  /// </summary>
  IPlAutoBinder = interface
    ['{64BF1986-35A2-48D4-9558-2EBDB345EFEB}']

    /// <summary>
    /// Binds a property of a source object to a property of a target object.
    /// </summary>
    /// <param name="ASource">The source object containing the property to bind.</param>
    /// <param name="APropertySource">The name of the property in the source object.</param>
    /// <param name="ATarget">The target object containing the property to bind to.</param>
    /// <param name="APropertyTarget">The name of the property in the target object.</param>
    /// <param name="AFunction">Optional. A function to apply transformations during binding.</param>
    procedure Bind(ASource: TObject; const APropertySource: string;
      ATarget: TObject; const APropertyTarget: string;
      AFunction: TPlBridgeFunction = nil);

    /// <summary>
    /// Binds two objects using a binding class attribute.
    /// </summary>
    /// <param name="ASource">The source object to bind.</param>
    /// <param name="ATarget">The target object to bind.</param>
    /// <param name="AnAttribute">The attribute defining the binding rules.</param>
    procedure BindObject(ASource, ATarget: TObject;
      AnAttribute: BindClassAttribute);

    /// <summary>
    /// Gets the number of active bindings.
    /// </summary>
    /// <returns>The total count of current binding sources.</returns>
    function Count: integer;

    /// <summary>
    /// Starts the automatic binding process.
    /// </summary>
    /// <param name="SleepInterval">
    /// The interval in milliseconds for periodic updates of bound values.
    /// </param>
    procedure Start(const SleepInterval: integer);

    /// <summary>
    /// Stops the automatic binding process.
    /// </summary>
    procedure Stop;

    /// <summary>
    /// Unbinds all bindings for a given source object.
    /// </summary>
    /// <param name="ASource">The source object to unbind.</param>
    procedure UnbindSource(ASource: TObject);

    /// <summary>
    /// Unbinds all bindings for a given target object.
    /// </summary>
    /// <param name="ATarget">The target object to unbind.</param>
    procedure UnbindTarget(ATarget: TObject);

    /// <summary>
    /// Forces an update of all bound properties.
    /// </summary>
    procedure UpdateValues;
  end;
{$ENDREGION}

const
  PL_SELF_ALIAS: array[0..2] of string = ('', '.', 'Self');

implementation

end.
