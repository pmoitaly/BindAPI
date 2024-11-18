{*****************************************************************************}
{       BindAPI                                                               }
{       Copyright (C) 2020 Paolo Morandotti                                   }
{       Unit plBindAPI.DeferredBinding                                        }
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
///   Implementation of TPlDeferredBinding.
/// </summary>
/// <remarks>
///  <c>TPlDeferredBinding</c> is the class that handles deferred mappings.
/// A deferred mapping is set by request or when a class interested in a binding
///  is not yet registered.
/// It periodically checks if the class is registered and then set the binding.
/// </remarks>
unit plBindAPI.DeferredBinding;

interface

uses
  Classes, Rtti, Generics.Collections,
  plBindAPI.Types, plBindAPI.Attributes, plBindAPI.AutoBinder;

type
/// <summary>
/// Represents a deferred binding element with its attribute and source object.
/// </summary>
TPlDeferredElement = record
  /// <summary>
  /// The <see cref="BindClassAttribute">binding class attribute</see> associated with this element.
  /// </summary>
  Attribute: BindClassAttribute;

  /// <summary>
  /// The source object for this deferred binding element.
  /// </summary>
  Source: TObject;
end;

/// <summary>
/// Provides functionality for managing deferred bindings.
/// </summary>
TPlDeferredBinding = class
private
  /// <summary>
  /// List of deferred binding elements, indexed by a string key.
  /// </summary>
  class var DeferredList: TDictionary<string, TPlDeferredElement>;

public
  /// <summary>
  /// Initializes the deferred bindings system. Called automatically when the class is first used.
  /// </summary>
  class constructor Create;

  /// <summary>
  /// Cleans up resources used by the deferred bindings system. Called automatically when the class is no longer needed.
  /// </summary>
  class destructor Destroy;

  /// <summary>
  /// Adds a source object to the deferred list.
  /// </summary>
  /// <param name="ASource">The source object to add.</param>
  /// <returns>The added source object.</returns>
  class function Add(ASource: TObject): TObject; overload;

  /// <summary>
  /// Adds a deferred binding element to the deferred list.
  /// </summary>
  /// <param name="ADeferredElement">The deferred element to add.</param>
  /// <returns>The added deferred element.</returns>
  class function Add(ADeferredElement: TPlDeferredElement): TPlDeferredElement; overload;

  /// <summary>
  /// Clears all elements from the deferred list.
  /// </summary>
  class procedure Clear;

  /// <summary>Counts the number of current bindings.</summary>
  /// <returns>The total number of bindings.</returns>
  class function Count: integer;

  /// <summary>
  /// Processes all deferred bindings.
  /// </summary>
  class procedure ProcessDeferred;
end;

implementation

uses
  plBindAPI.RTTIUtils, plBindAPI.BindManagement, plBindAPI.ClassFactory;

{$REGION 'TPlDeferredBinding'}

class function TPlDeferredBinding.Add(ADeferredElement: TPlDeferredElement)
  : TPlDeferredElement;
begin
  DeferredList.Add(ADeferredElement.Attribute.TargetClassName,
    ADeferredElement);
  Result := ADeferredElement;
end;

class function TPlDeferredBinding.Add(ASource: TObject): TObject;
var
  deferredElement: TPlDeferredElement;
  rType: TRttiType;
  rAttr: TCustomAttribute;
begin
  deferredElement.Source := ASource;
  rType := TplRTTIUtils.Context.GetType(ASource.ClassType);
  for rAttr in rType.GetAttributes do
    if rAttr is BindClassAttribute then
      begin
        deferredElement.Attribute := BindClassAttribute(rAttr);
        Add(deferredElement);
      end;
  Result := ASource;
end;

class procedure TPlDeferredBinding.Clear;
begin
  DeferredList.Clear;
end;

class function TPlDeferredBinding.Count: integer;
begin
  Result := DeferredList.Count;
end;

class constructor TPlDeferredBinding.Create;
begin
  DeferredList := TDictionary<string, TPlDeferredElement>.Create;
end;

class destructor TPlDeferredBinding.Destroy;
begin
  DeferredList.Free;
end;

class procedure TPlDeferredBinding.ProcessDeferred;
var
  className: string;
  deferredElement: TPlDeferredElement;
begin
  for className in DeferredList.Keys do
    if TplClassManager.IsRegistered(className) then
      begin
        // Force binding, then remove the element from the list
        deferredElement := DeferredList.Items[className];
        TplBindManager.AddBind(deferredElement.Source,
          deferredElement.Attribute);
        DeferredList.Remove(className);
      end;
end;

{$ENDREGION}

end.
