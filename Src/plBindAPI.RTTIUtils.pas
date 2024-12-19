{*****************************************************************************}
{BindAPI                                                                      }
{Copyright (C) 2020 Paolo Morandotti                                          }
{Unit plBindAPI.RTTIUtils                                                     }
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
///   Implementation of TPlRTTIUtils.
/// </summary>
/// <remarks>
///  <c>TPlRTTIUtils</c> is a static class with a lot of function to simplify
/// RTTI operations.
///  You can use it as utility class in your projects.
/// </remarks>
unit plBindAPI.RTTIUtils;

interface

uses
  Classes, StrUtils, Rtti,
  Generics.Collections, Generics.Defaults,
  plBindAPI.Types;

type

  TPlRTTIUtils = class
  private
    /// <summary>
    /// Holds the RTTI context for the class. Used to query type information.
    /// </summary>
    class var FContext: TRttiContext;
    /// <summary>
    /// Casts the given value to an enumeration.
    /// </summary>
    /// <param name="AValue">The value to be casted.</param>
    /// <returns>The value casted as an enumeration.</returns>
    class function CastToEnumeration(AValue: TValue): TValue;
    /// <summary>
    /// Casts the given value to a floating-point number.
    /// </summary>
    /// <param name="AValue">The value to be casted.</param>
    /// <returns>The value casted as a float.</returns>
    class function CastToFloat(AValue: TValue): TValue;
    /// <summary>
    /// Casts the given value to an Int64.
    /// </summary>
    /// <param name="AValue">The value to be casted.</param>
    /// <returns>The value casted as an Int64.</returns>
    class function CastToInt64(AValue: TValue): TValue;
    /// <summary>
    /// Casts the given value to an integer.
    /// </summary>
    /// <param name="AValue">The value to be casted.</param>
    /// <returns>The value casted as an integer.</returns>
    class function CastToInteger(AValue: TValue): TValue;
    /// <summary>
    /// Casts the given value to a string.
    /// </summary>
    /// <param name="AValue">The value to be casted.</param>
    /// <returns>The value casted as a string.</returns>
    class function CastToString(AValue: TValue): TValue;
    /// <summary>
    /// Searches for a field in the specified object by node name.
    /// </summary>
    /// <param name="ARoot">The object to search within.</param>
    /// <param name="AField">The found field, if successful.</param>
    /// <param name="ANodeName">The name of the node to locate.</param>
    /// <returns>True if the field is found, otherwise False.</returns>
    class function ExtractField(ARoot: TObject; out AField: TRTTIField;
      const ANodeName: string): Boolean; static;
    /// <summary>
    /// Retrieves the type information of the specified field.
    /// </summary>
    /// <param name="AField">The field to retrieve type information from.</param>
    /// <param name="AType">The RTTI type of the field.</param>
    /// <returns>True if the type is successfully extracted, otherwise False.</returns>
    class function ExtractFieldType(AField: TRTTIField; out AType: TRttiType)
      : Boolean; static;
    /// <summary>
    /// Searches for an indexed property in the specified object by node name.
    /// </summary>
    /// <param name="ARoot">The object to search within.</param>
    /// <param name="AProp">The found indexed property, if successful.</param>
    /// <param name="ANodeName">The name of the node to locate.</param>
    /// <returns>True if the indexed property is found, otherwise False.</returns>
    class function ExtractIndexedProperty(ARoot: TObject;
      out AProp: TRttiIndexedProperty; const ANodeName: string): Boolean;
    /// <summary>
    /// Retrieves the type information of the specified indexed property.
    /// </summary>
    /// <param name="AProp">The indexed property to retrieve type information from.</param>
    /// <param name="AType">The RTTI type of the property.</param>
    /// <returns>True if the type is successfully extracted, otherwise False.</returns>
    class function ExtractIndexedPropertyType(AProp: TRttiIndexedProperty;
      out AType: TRttiType): Boolean; static;
    /// <summary>
    /// Extracts the last index or segment from a given path string.
    /// </summary>
    /// <param name="APath">The path string to process.</param>
    /// <returns>The last segment of the path.</returns>
    class function ExtractLastIndex(APath: string): string;
    (*  Delphi 12+ only.
      /// <summary>
     /// Searches for a data member or indexed property in the specified object.
     /// </summary>
     /// <param name="ARoot">The object to search within.</param>
     /// <param name="AMember">The found data member, if successful.</param>
     /// <param name="AIndexedProp">The found indexed property, if applicable.</param>
     /// <param name="ANodeName">The name of the node to locate.</param>
     /// <returns>True if a matching member is found, otherwise False.</returns>
     class function ExtractNode(ARoot: TObject; out AMember: TRTTIDataMember; out AIndexedProp: TRttiIndexedProperty; const ANodeName: string): Boolean; overload;
    *)
    /// <summary>
    /// Searches for a field, property, or indexed property in the specified object.
    /// </summary>
    /// <param name="ARoot">The object to search within.</param>
    /// <param name="AField">The found field, if applicable.</param>
    /// <param name="AProp">The found property, if applicable.</param>
    /// <param name="AnIndexedProperty">The found indexed property, if applicable.</param>
    /// <param name="ANodeName">The name of the node to locate.</param>
    /// <returns>True if any matching member is found, otherwise False.</returns>
    class function ExtractNode(ARoot: TObject; out AField: TRTTIField;
      out AProp: TRttiProperty; out AnIndexedProperty: TRttiIndexedProperty;
      const ANodeName: string): Boolean; overload;
    /// <summary>
    /// Determines the RTTI type from a field, property, or indexed property.
    /// </summary>
    /// <param name="AField">The field to inspect.</param>
    /// <param name="AProp">The property to inspect.</param>
    /// <param name="AIndexedProp">The indexed property to inspect.</param>
    /// <returns>The RTTI type of the member.</returns>
    class function ExtractNodeType(AField: TRTTIField; AProp: TRttiProperty;
      AIndexedProp: TRttiIndexedProperty): TRttiType; overload; inline;
    /// <summary>
    /// Searches for a property in the specified object by node name.
    /// </summary>
    /// <param name="ARoot">The object to search within.</param>
    /// <param name="AProp">The found property, if successful.</param>
    /// <param name="ANodeName">The name of the node to locate.</param>
    /// <returns>True if the property is found, otherwise False.</returns>
    class function ExtractProperty(ARoot: TObject; out AProp: TRttiProperty;
      const ANodeName: string): Boolean; static;
    /// <summary>
    /// Retrieves the type information of the specified property.
    /// </summary>
    /// <param name="AProp">The property to retrieve type information from.</param>
    /// <param name="AType">The RTTI type of the property.</param>
    /// <returns>True if the type is successfully extracted, otherwise False.</returns>
    class function ExtractPropertyType(AProp: TRttiProperty;
      out AType: TRttiType): Boolean; static;
    /// <summary>
    /// Retrieves the first node or segment from a path string, removing it
    /// from pathNode var parameter.
    /// </summary>
    /// <param name="pathNodes">The path string to process.</param>
    /// <returns>The first segment of the path.</returns>
    class function FirstNode(var pathNodes: string): string;
    /// <summary>
    /// Retrieves the value of a specified field in a record structure.
    /// </summary>
    /// <param name="Sender">The sender object.</param>
    /// <param name="AOwner">The owner object or record containing the field.</param>
    /// <param name="AField">The field to retrieve the value from.</param>
    /// <returns>The value of the field as a TValue.</returns>
    class function GetRecordFieldValue(Sender: TObject;
      AOwner, AField: TRTTIField): TValue; overload;
    /// <summary>
    /// Retrieves the value of a field in a record through a property owner.
    /// </summary>
    /// <param name="Sender">The sender object.</param>
    /// <param name="AOwner">The property owner of the record.</param>
    /// <param name="AField">The field to retrieve the value from.</param>
    /// <returns>The value of the field as a TValue.</returns>
    class function GetRecordFieldValue(Sender: TObject; AOwner: TRttiProperty;
      AField: TRTTIField): TValue; overload;
    /// <summary>
    /// Compares two pointers for equality.
    /// </summary>
    /// <param name="Left">The first pointer value.</param>
    /// <param name="Right">The second pointer value.</param>
    /// <returns>True if the pointers are equal, otherwise False.</returns>
    class function IsEqualPointer(Left, Right: TValue): Boolean;
    {
     /// <summary>
     /// Compares two record values for equality.
     /// </summary>
     /// <param name="Left">The first record value.</param>
     /// <param name="Right">The second record value.</param>
     /// <returns>True if the records are equal, otherwise False.</returns>
     class function IsEqualRecord(Left, Right: TValue): Boolean;

     /// <summary>
     /// Checks whether a given object is an array type.
     /// </summary>
     /// <param name="ARoot">The object to check.</param>
     /// <returns>True if the object is an array, otherwise False.</returns>
     class function IsObjectArray(ARoot: TObject): Boolean;
    }
    /// <summary>
    /// Logs a message for debugging or informational purposes.
    /// </summary>
    /// <param name="AMessage">The message to be logged.</param>
    class procedure Log(const AMessage: string);
    /// <summary>
    /// Retrieves the next node in the given path and updates the root and its members.
    /// </summary>
    /// <param name="ANodeName">The name of the current node.</param>
    /// <param name="ARoot">The root object, updated for the next node.</param>
    /// <param name="AField">The field at the current node, if applicable.</param>
    /// <param name="AProp">The property at the current node, if applicable.</param>
    /// <param name="AIndexedProp">The indexed property at the current node, if applicable.</param>
    /// <param name="APath">The remaining path to be processed.</param>
    /// <returns>The value at the current node.</returns>
    class function NextNode(const ANodeName: string; var ARoot: TObject;
      var AField: TRTTIField; var AProp: TRttiProperty;
      var AIndexedProp: TRttiIndexedProperty; var APath: string)
      : TValue; inline;
    /// <summary>
    /// Reads the value of a specified field from the given object.
    /// </summary>
    /// <param name="ARoot">The object containing the field.</param>
    /// <param name="AField">The field to read.</param>
    /// <param name="AValue">The read value of the field.</param>
    /// <returns>True if the field value is successfully read, otherwise False.</returns>
    class function ReadFieldValue(ARoot: TObject; AField: TRTTIField;
      out AValue: TValue): Boolean; static;
    /// <summary>
    /// Reads the value of a specified indexed property from the given object.
    /// </summary>
    /// <param name="ARoot">The object containing the indexed property.</param>
    /// <param name="AProp">The indexed property to read.</param>
    /// <param name="AnIndex">The index value for the property.</param>
    /// <param name="AValue">The read value of the indexed property.</param>
    /// <returns>True if the property value is successfully read, otherwise False.</returns>
    class function ReadIndexedPropertyValue(ARoot: TObject;
      AProp: TRttiIndexedProperty; const AnIndex: string; out AValue: TValue)
      : Boolean; static;
    /// <summary>
    /// Reads the value of a data member (field, property, or indexed property) from the given object.
    /// </summary>
    /// <param name="ARoot">The object containing the data member.</param>
    /// <param name="AField">The field, if applicable.</param>
    /// <param name="AProp">The property, if applicable.</param>
    /// <param name="AIndexedProp">The indexed property, if applicable.</param>
    /// <param name="AIndex">The index value for the member, if applicable.</param>
    /// <returns>The value of the data member.</returns>
    class function ReadMemberValue(ARoot: TObject; AField: TRTTIField;
      AProp: TRttiProperty; AIndexedProp: TRttiIndexedProperty;
      const AIndex: string): TValue; inline;
    /// <summary>
    /// Reads the value of a specified property from the given object.
    /// </summary>
    /// <param name="ARoot">The object containing the property.</param>
    /// <param name="AProp">The property to read.</param>
    /// <param name="AValue">The read value of the property.</param>
    /// <returns>True if the property value is successfully read, otherwise False.</returns>
    class function ReadPropertyValue(ARoot: TObject; AProp: TRttiProperty;
      out AValue: TValue): Boolean; static;
    /// <summary>
    /// Sets the value of a field within a record structure.
    /// </summary>
    /// <param name="Sender">The sender object.</param>
    /// <param name="AOwner">The owner record or object containing the field.</param>
    /// <param name="AField">The field to set the value of.</param>
    /// <param name="AValue">The value to set.</param>
    class procedure SetRecordFieldValue(Sender: TObject;
      AOwner, AField: TRTTIField; AValue: TValue); overload;
    /// <summary>
    /// Sets the value of a field within a record using a property owner.
    /// </summary>
    /// <param name="Sender">The sender object.</param>
    /// <param name="AOwner">The property owner of the record.</param>
    /// <param name="AField">The field to set the value of.</param>
    /// <param name="AValue">The value to set.</param>
    class procedure SetRecordFieldValue(Sender: TObject; AOwner: TRttiProperty;
      AField: TRTTIField; AValue: TValue); overload;
    /// <summary>
    /// Sets the value of a field in a record structure based on a specified path.
    /// </summary>
    /// <param name="ARoot">The root object.</param>
    /// <param name="APath">The property path within the record.</param>
    /// <param name="AValue">The value to set.</param>
    class procedure SetRecordPathValue(ARoot: TObject; const APath: string;
      AValue: TValue);
    /// <summary>
    /// Converts a string representation to its corresponding enumeration value.
    /// </summary>
    /// <param name="AType">The RTTI type of the enumeration.</param>
    /// <param name="AValue">The string value to convert.</param>
    /// <returns>The enumeration value corresponding to the string.</returns>
    class function StringToEnumeration(const AType: TRttiType; AValue: TValue)
      : TValue; static;
    /// <summary>
    /// Writes a value to the specified field of an object.
    /// </summary>
    /// <param name="ANode">The object containing the field.</param>
    /// <param name="AField">The field to write to.</param>
    /// <param name="AValue">The value to write.</param>
    class procedure WriteFieldValue(ANode: TObject; AField: TRTTIField;
      AValue: TValue);
    /// <summary>
    /// Writes a value to a specified indexed property of an object.
    /// </summary>
    ///  <remarks>
    ///  <note type="warning">This procedure is under development. Does not use it.
    /// Its release is planned in 0.9.0.0beta version.</note>
    ///  </remarks>
    /// <param name="ANode">The object containing the indexed property.</param>
    /// <param name="AIndexedProp">The indexed property to write to.</param>
    /// <param name="AIndex">The index value for the property.</param>
    /// <param name="AValue">The value to write.</param>
    class procedure WriteIndexedPropertyValue(ANode: TObject; AIndexedProp:
        TRttiIndexedProperty; AIndex: string; AValue: TValue); static;
    /// <summary>
    /// Writes a value to a specified data member (field, property, or indexed property).
    /// </summary>
    /// <param name="ANode">The object containing the data member.</param>
    /// <param name="AField">The field to write to, if applicable.</param>
    /// <param name="AProp">The property to write to, if applicable.</param>
    /// <param name="AIndexedProp">The indexed property to write to, if applicable.</param>
    /// <param name="APath">The path identifying the member.</param>
    /// <param name="AValue">The value to write.</param>
    class procedure WriteMemberValue(ANode: TObject; AField: TRTTIField;
      AProp: TRttiProperty; AIndexedProp: TRttiIndexedProperty;
      const APath: string; AValue: TValue); inline;
    /// <summary>
    /// Writes a value to the specified property of an object.
    /// </summary>
    /// <param name="ANode">The object containing the property.</param>
    /// <param name="AProp">The property to write to.</param>
    /// <param name="AValue">The value to write.</param>
    class procedure WritePropertyValue(ANode: TObject; AProp: TRttiProperty;
      AValue: TValue);
  public
    /// <summary>
    /// Class constructor that initializes the shared RTTI context.
    /// </summary>
    class constructor Create;
    /// <summary>
    /// Checks whether two TValue instances are equal.
    /// </summary>
    /// <param name="Left">The first value to compare.</param>
    /// <param name="Right">The second value to compare.</param>
    /// <returns>True if the values are equal; otherwise, False.</returns>
    class function AreEqual(Left, Right: TValue): Boolean;
    /// <summary>
    /// Retrieves a component from a given property path.
    /// </summary>
    /// <param name="ASource">The root component to start from.</param>
    /// <param name="APropertyPath">The property path to navigate.</param>
    /// <returns>The component found at the specified path.</returns>
    class function ComponentFromPath(ASource: TComponent;
      var APropertyPath: string): TComponent; static;
    /// <summary>
    /// Converts an enumeration value to its ordinal equivalent.
    /// </summary>
    /// <param name="AType">The RTTI type of the enumeration.</param>
    /// <param name="AValue">The enumeration value.</param>
    /// <returns>The ordinal value of the enumeration.</returns>
    class function EnumerationToOrdinal(const AType: TRttiType;
      AValue: TValue): TValue;
    /// <summary>
    /// Retrieves information about an indexed property by name.
    /// </summary>
    /// <param name="ARoot">The object containing the property.</param>
    /// <param name="APropertyName">The name of the indexed property.</param>
    /// <returns>Information about the indexed property.</returns>
    class function GetIndexedPropertyInfo(ARoot: TObject;
      const APropertyName: string): TPlIndexedPropertyInfo; overload;
    /// <summary>
    /// Retrieves information about an indexed property by its RTTI representation.
    /// </summary>
    /// <param name="AIndexedProp">The RTTI representation of the indexed property.</param>
    /// <param name="AIndex">The index value as a string.</param>
    /// <returns>Information about the indexed property.</returns>
    class function GetIndexedPropertyInfo(AIndexedProp: TRttiIndexedProperty;
      const AIndex: string): TPlIndexedPropertyInfo; overload;
    /// <summary>
    /// Gets the value from an object based on a property path.
    /// </summary>
    /// <param name="ARoot">The root object.</param>
    /// <param name="APath">The property path.</param>
    /// <returns>The value at the specified path.</returns>
    class function GetPathValue(ARoot: TObject; var APath: string): TValue;
    /// <summary>
    /// Determines the parent of a property specified by a path.
    /// </summary>
    /// <param name="ARoot">The root object.</param>
    /// <param name="APath">The property path.</param>
    /// <param name="AField">The field, if applicable.</param>
    /// <param name="AProp">The property, if applicable.</param>
    /// <param name="AIndexedProperty">The indexed property, if applicable.</param>
    /// <returns>The owner of the property.</returns>
    class function GetPropertyParent(ARoot: TObject; var APath: string;
      out AField: TRTTIField; out AProp: TRttiProperty;
      out AIndexedProperty: TRttiIndexedProperty): TValue;
    /// <summary>
    /// Retrieves the value of a field within a record structure based on a property path.
    /// </summary>
    /// <param name="ARoot">The root object.</param>
    /// <param name="APath">The property path.</param>
    /// <returns>The value found at the specified path.</returns>
    class function GetRecordPathValue(ARoot: TObject;
      var APath: string): TValue;
    /// <summary>
    /// Casts a value to a specific RTTI type.
    /// </summary>
    /// <param name="AType">The RTTI type to cast to.</param>
    /// <param name="AValue">The value to cast.</param>
    /// <returns>The cast value.</returns>
    class function InternalCastTo(const AType: TRttiType; AValue: TValue)
      : TValue; overload;
    /// <summary>
    /// Casts a value to a specific type kind.
    /// </summary>
    /// <param name="AType">The type kind to cast to.</param>
    /// <param name="AValue">The value to cast.</param>
    /// <returns>The cast value.</returns>
    class function InternalCastTo(const AType: TTypeKind; AValue: TValue)
      : TValue; overload;
    /// <summary>
    /// Invokes a method by name on a specified class or instance.
    /// </summary>
    /// <param name="AMethodName">The name of the method to invoke.</param>
    /// <param name="AClass">The class containing the method.</param>
    /// <param name="Instance">The instance to invoke the method on, if applicable.</param>
    /// <param name="Args">The arguments to pass to the method.</param>
    /// <returns>The result of the method invocation.</returns>
    class function InvokeEx(const AMethodName: string; AClass: TClass;
      Instance: TValue; const Args: array of TValue): TValue; static;
    /// <summary>
    /// Determines if a name represents an indexed property.
    /// </summary>
    /// <param name="AName">The name to check.</param>
    /// <returns>True if the name is an indexed property; otherwise, False.</returns>
    class function IsIndexedProperty(const AName: string): Boolean; overload;
    /// <summary>
    /// Determines if an object contains an indexed property with the specified name.
    /// </summary>
    /// <param name="ARoot">The object to check.</param>
    /// <param name="AName">The name of the property.</param>
    /// <returns>True if the property exists; otherwise, False.</returns>
    class function IsIndexedProperty(ARoot: TObject; const AName: string)
      : Boolean; overload;
    /// <summary>
    /// Validates a property path.
    /// </summary>
    /// <param name="ARoot">The root object.</param>
    /// <param name="APath">The path to validate.</param>
    /// <returns>True if the path is valid; otherwise, False.</returns>
    class function IsValidPath(ARoot: TObject; const APath: string): Boolean;
    /// <summary>
    /// Checks if a method is implemented for a given type by method name.
    /// </summary>
    /// <param name="ATypeInfo">Pointer to the type information.</param>
    /// <param name="AMethodName">The name of the method to check.</param>
    /// <returns>True if the method is implemented; otherwise, False.</returns>
    class function MethodIsImplemented(ATypeInfo: Pointer; AMethodName: string)
      : Boolean; overload;
    /// <summary>
    /// Checks if a method is implemented for a given class by method name.
    /// </summary>
    /// <param name="AClass">The class to inspect.</param>
    /// <param name="AMethodName">The name of the method to check.</param>
    /// <returns>True if the method is implemented; otherwise, False.</returns>
    class function MethodIsImplemented(const AClass: TClass;
      AMethodName: string): Boolean; overload;
    /// <summary>
    /// Converts an ordinal value to its corresponding enumeration value.
    /// </summary>
    /// <param name="AType">The RTTI type of the enumeration.</param>
    /// <param name="AValue">The ordinal value.</param>
    /// <returns>The enumeration value corresponding to the ordinal.</returns>
    class function OrdinalToEnumeration(const AType: TRttiType;
      AValue: TValue): TValue;
    /// <summary>
    /// Checks if a property exists for a given type by name.
    /// </summary>
    /// <param name="ATypeInfo">Pointer to the type information.</param>
    /// <param name="APropertyName">The name of the property to check.</param>
    /// <returns>True if the property exists; otherwise, False.</returns>
    class function PropertyExists(ATypeInfo: Pointer; APropertyName: string)
      : Boolean; overload;
    /// <summary>
    /// Checks if a property exists for a given class by name.
    /// </summary>
    /// <param name="AClass">The class to inspect.</param>
    /// <param name="APropertyName">The name of the property to check.</param>
    /// <returns>True if the property exists; otherwise, False.</returns>
    class function PropertyExists(const AClass: TClass; APropertyName: string)
      : Boolean; overload;
    /// <summary>
    /// Resets the specified method of an object to nil.
    /// </summary>
    /// <remarks>
    /// <para>This procedure sets the method's code and data pointers to nil, effectively unbinding
    /// the method from any assigned implementation.</para>
    /// <para>The method must be a published property of the object specified in <paramref name="ARoot"/>.</para>
    /// </remarks>
    /// <param name="ARoot">The object whose method is being reset.</param>
    /// <param name="AMethodName">The name of the method to reset.</param>
    class procedure ResetMethod(ARoot: TObject; const AMethodName: string);
    /// <summary>
    /// Verifies if a method's parameters match a given set of arguments.
    /// </summary>
    /// <param name="AParams">The array of RTTI parameter descriptors.</param>
    /// <param name="Args">The array of arguments to match.</param>
    /// <returns>True if the signature matches; otherwise, False.</returns>
    class function SameSignature(const AParams: TPlRTTIParametersArray;
      const Args: array of TValue): Boolean; static;
    /// <summary>
    /// Sets a method from a root object to target another object's method.
    /// </summary>
    /// <param name="ARoot">The root object.</param>
    /// <param name="ARootMethodPath">The method path in the root object.</param>
    /// <param name="ATarget">The target object.</param>
    /// <param name="ATargetMethodName">The name of the target method (optional).</param>
    /// <returns>True if the method was successfully set; otherwise, False.</returns>
    class function SetMethod(ARoot: TObject; const ARootMethodPath: string;
      ATarget: TObject; const ATargetMethodName: string = ''): Boolean; inline;
    /// <summary>
    /// Sets the value of a property at a specified path in an object.
    /// </summary>
    /// <param name="ARoot">The root object.</param>
    /// <param name="APath">The property path.</param>
    /// <param name="AValue">The value to set.</param>
    class procedure SetPathValue(ARoot: TObject; const APath: string;
      AValue: TValue); inline;
    (* This function is for Delphi 12 +. Not sure if it is a real advantage.
      /// <summary>
     /// Attempts to extract a node (data member or indexed property) by name.
     /// </summary>
     /// <param name="ARoot">The root object.</param>
     /// <param name="AMember">Output parameter for the data member.</param>
     /// <param name="AIndexedProp">Output parameter for the indexed property.</param>
     /// <param name="ANodeName">The name of the node to extract.</param>
     /// <returns>True if the node was successfully extracted; otherwise, False.</returns>
     class function TryExtractNode(ARoot: TObject; out AMember: TRTTIDataMember; out AIndexedProp: TRttiIndexedProperty; const ANodeName: string): Boolean; overload;
    *)
    /// <summary>
    /// Attempts to extract a node (field, property, or indexed property) by name.
    /// </summary>
    /// <param name="ARoot">The root object.</param>
    /// <param name="AField">Output parameter for the field.</param>
    /// <param name="AProp">Output parameter for the property.</param>
    /// <param name="AIndexedProp">Output parameter for the indexed property.</param>
    /// <param name="ANodeName">The name of the node to extract.</param>
    /// <returns>True if the node was successfully extracted; otherwise, False.</returns>
    class function TryExtractNode(ARoot: TObject; out AField: TRTTIField;
      out AProp: TRttiProperty; out AIndexedProp: TRttiIndexedProperty;
      const ANodeName: string): Boolean; overload;
    /// <summary>
    /// Gets the shared RTTI context.
    /// </summary>
    class property Context: TRttiContext read FContext;
  end;

resourcestring
  StrBindApi = 'BindApi';
  StrCantFind = 'Can''t find ';
  StrErrorOnSetting = 'Error on setting ';
  StrErrorsLog = 'Errors.log';
  StrInvalidFieldOrProperty = 'Invalid field or property';
  StrIsNotAPathToProperty = ' is not a path to property or field.';
  StrMethodSNotFound = 'method %s not found';
  StrMorandottiIt = 'morandotti.it';
  StrNoMemberAvailable = 'No member available.';
  StrWrongParamsNumber = 'Wrong params number.';

implementation

uses
  TypInfo, Hash, IOUtils, SysUtils, Math;

{TPlRTTIUtils}

class constructor TPlRTTIUtils.Create;
begin
  FContext := TRttiContext.Create;
end;

class function TPlRTTIUtils.AreEqual(Left, Right: TValue): Boolean;
begin
  Result := False;
  if Left.IsOrdinal then
    Exit(Left.AsOrdinal = Right.AsOrdinal);
  if Left.TypeInfo = System.TypeInfo(Single) then
    Exit(SameValue(Left.AsType<Single>(), Right.AsType<Single>()));
  if Left.TypeInfo = System.TypeInfo(Double) then
    Exit(SameValue(Left.AsType<Double>(), Right.AsType<Double>()));
  if Left.Kind in [tkChar, tkString, tkWChar, tkLString, tkWString, tkUString]
  then
    Exit(Left.AsString = Right.AsString);
  if Left.IsClass and Right.IsClass then
    Exit(Left.AsClass = Right.AsClass);
  if Left.IsObject then
    Exit(Left.AsObject = Right.AsObject);
  if (Left.Kind = tkPointer) or (Left.TypeInfo = Right.TypeInfo) then
    Exit(IsEqualPointer(Left, Right));
  if Left.TypeInfo = System.TypeInfo(Variant) then
    Exit(Left.AsVariant = Right.AsVariant);
  if Left.TypeInfo = System.TypeInfo(TGUID) then
    Exit(IsEqualGuid(Left.AsType<TGUID>, Right.AsType<TGUID>));
end;

class function TPlRTTIUtils.CastToEnumeration(AValue: TValue): TValue;
begin
  Result := AValue;
  case AValue.Kind of
    tkInteger, tkInt64:
      Result := AValue.AsOrdinal;
  end;
end;

class function TPlRTTIUtils.CastToFloat(AValue: TValue): TValue;
begin
  Result := AValue;
  case AValue.Kind of
    tkString, tkLString, tkWString, tkWChar, tkUString:
      Result := StrToFloat(AValue.AsString);
  end;
end;

class function TPlRTTIUtils.CastToInt64(AValue: TValue): TValue;
begin
  Result := AValue;
  case AValue.Kind of
    tkString, tkLString, tkWString, tkWChar, tkUString:
      Result := StrToInt64(AValue.AsString);
    tkFloat:
      Result := Trunc(AValue.AsType<Double>);
  end;
end;

class function TPlRTTIUtils.CastToInteger(AValue: TValue): TValue;
begin
  Result := AValue;
  case AValue.Kind of
    tkString, tkLString, tkWString, tkWChar, tkUString:
      Result := StrToInt(AValue.AsString);
    tkFloat:
      Result := Trunc(AValue.AsType<Double>);
  end;
end;

class function TPlRTTIUtils.CastToString(AValue: TValue): TValue;
begin
  Result := AValue;
  case AValue.Kind of
    tkString, tkLString, tkWString, tkWChar, tkUString:
      Result := AValue.AsString;
    tkFloat:
      Result := FloatToStr(AValue.AsType<Double>);
    tkInteger:
      Result := IntToStr(AValue.AsInteger);
    tkInt64:
      Result := IntToStr(AValue.AsInt64);
  end;
end;

class function TPlRTTIUtils.ComponentFromPath(ASource: TComponent;
  var APropertyPath: string): TComponent;
var
  componentName: string;
  dotIndex: Integer;
  nextComponent: TComponent;
  sourceComponent: TComponent;
begin
  sourceComponent := TComponent(ASource);
  dotIndex := Pos('.', APropertyPath);
  while dotIndex > 0 do
    begin
      componentName := Copy(APropertyPath, 1, dotIndex - 1);
      Delete(APropertyPath, 1, dotIndex);
      nextComponent := sourceComponent.FindComponent(componentName);
      if Assigned(nextComponent) then
        begin
          dotIndex := Pos('.', APropertyPath);
          sourceComponent := nextComponent;
        end
      else
        dotIndex := 0;
    end;
  Result := sourceComponent;
end;

class function TPlRTTIUtils.EnumerationToOrdinal(const AType: TRttiType;
  AValue: TValue): TValue;
begin
  Result := AValue.AsOrdinal; (*Bug#12 - Could be useless*)
end;

class function TPlRTTIUtils.ExtractField(ARoot: TObject; out AField: TRTTIField;
  const ANodeName: string): Boolean;
begin
  AField := nil;
  Result := False;
  if ANodeName <> '' then
    begin
      AField := FContext.GetType(ARoot.ClassType).GetField(ANodeName);
      Result := Assigned(AField);
    end;
end;

class function TPlRTTIUtils.ExtractFieldType(AField: TRTTIField;
  out AType: TRttiType): Boolean;
begin
  Result := Assigned(AField);
  if Result then
    AType := AField.FieldType;
end;

class function TPlRTTIUtils.ExtractIndexedProperty(ARoot: TObject;
  out AProp: TRttiIndexedProperty; const ANodeName: string): Boolean;
var
  nodeName: string;
begin
  Result := False;
  AProp := nil;
  nodeName := ANodeName.Substring(0, ANodeName.IndexOf('['));
  if nodeName <> '' then
    begin
      AProp := FContext.GetType(ARoot.ClassType).GetIndexedProperty(nodeName);
      Result := Assigned(AProp);
    end;
end;

class function TPlRTTIUtils.ExtractIndexedPropertyType
  (AProp: TRttiIndexedProperty; out AType: TRttiType): Boolean;
begin
  Result := Assigned(AProp);
  if Result then
    AType := AProp.PropertyType;
end;

class function TPlRTTIUtils.ExtractLastIndex(APath: string): string;
var
  paramsEnd: Integer;
  paramsStart: Integer;
begin
  paramsStart := APath.LastIndexOf('[');
  paramsEnd := APath.LastIndexOf(']');
  Result := APath.Substring(paramsStart + 1, paramsEnd - paramsStart - 1);
end;

class function TPlRTTIUtils.ExtractNode(ARoot: TObject; out AField: TRTTIField;
  out AProp: TRttiProperty; out AnIndexedProperty: TRttiIndexedProperty;
  const ANodeName: string): Boolean;
begin
  Result := (ExtractField(ARoot, AField, ANodeName) or ExtractProperty(ARoot,
    AProp, ANodeName) or ExtractIndexedProperty(ARoot, AnIndexedProperty,
    ANodeName));
end;

class function TPlRTTIUtils.ExtractNodeType(AField: TRTTIField;
  AProp: TRttiProperty; AIndexedProp: TRttiIndexedProperty): TRttiType;
var
  typeFound: Boolean;
begin
  Result := nil;
  typeFound := ExtractFieldType(AField, Result) or
    ExtractPropertyType(AProp, Result) or ExtractIndexedPropertyType
    (AIndexedProp, Result);
  if not typeFound then
    begin
      {$IFDEF DEBUG}Log(StrNoMemberAvailable);{$ENDIF}
      raise EPlBindApiException.Create(StrNoMemberAvailable);
    end;
end;

class function TPlRTTIUtils.ExtractProperty(ARoot: TObject;
  out AProp: TRttiProperty; const ANodeName: string): Boolean;
begin
  AProp := FContext.GetType(ARoot.ClassType).GetProperty(ANodeName);
  Result := Assigned(AProp);
end;

class function TPlRTTIUtils.ExtractPropertyType(AProp: TRttiProperty;
  out AType: TRttiType): Boolean;
begin
  Result := Assigned(AProp);
  if Result then
    AType := AProp.PropertyType;
end;

class function TPlRTTIUtils.FirstNode(var pathNodes: string): string;
var
  dotPosition: Integer;
begin
  dotPosition := pathNodes.IndexOf('.');
  if (dotPosition = -1) or (pathNodes = '') then
    begin
      Result := pathNodes;
      pathNodes := '';
    end
  else
    begin
      Result := pathNodes.Substring(0, dotPosition);
      pathNodes := pathNodes.Substring(dotPosition + 1);
    end;
end;

class function TPlRTTIUtils.GetIndexedPropertyInfo(ARoot: TObject;
  const APropertyName: string): TPlIndexedPropertyInfo;
var
  myIndexedProp: TRttiIndexedProperty;
  myPropIndex: string;
  myPropName: string;
begin
  //  splitPoint := APropertyName.IndexOf('[');
  //  myPropName := APropertyName.Substring(0, splitPoint);
  //  myPropIndex := APropertyName.Substring(splitPoint + 1,
  //    APropertyName.Length - 1);
  myPropIndex := ExtractLastIndex(APropertyName);
  myIndexedProp := FContext.GetType(ARoot.ClassType)
    .GetIndexedProperty(myPropName);
  Result := GetIndexedPropertyInfo(myIndexedProp, myPropIndex);
end;

class function TPlRTTIUtils.GetIndexedPropertyInfo(AIndexedProp
  : TRttiIndexedProperty; const AIndex: string): TPlIndexedPropertyInfo;
var
  i: Integer;
  method: TRttiMethod;
  newParam: TValue;
  params: TArray<string>;
  rttiParams: TPlRTTIParametersArray;
begin
  if Assigned(AIndexedProp) and (AIndex <> '') then
    begin
      params := AIndex.Split([',']);
      method := AIndexedProp.ReadMethod;
      if Assigned(method) then
        begin
          rttiParams := method.GetParameters;
          if Length(rttiParams) <> Length(params) then
            raise EPlBindApiException.Create(StrWrongParamsNumber);
          for i := 0 to High(rttiParams) do
            begin
              SetLength(Result.paramsTypes, Length(Result.paramsTypes) + 1);
              SetLength(Result.paramsValues, Length(Result.paramsValues) + 1);
              Result.paramsTypes[High(Result.paramsTypes)] :=
                rttiParams[i].ParamType.TypeKind;
              newParam := TValue.From<string>(params[i]);
              if (rttiParams[i].ParamType is TRttiEnumerationType) then
                begin

                end;
              Result.paramsValues[High(Result.paramsValues)] :=
                InternalCastTo(rttiParams[i].ParamType, newParam);
            end;
        end;
    end;
end;

class function TPlRTTIUtils.GetPathValue(ARoot: TObject;
  var APath: string): TValue;
var
  currentNode: TObject;
  lastNode: TValue;
  myField: TRTTIField;
  myPath: string;
  myProp: TRttiProperty;
  myIndexedProperty: TRttiIndexedProperty;
begin
  if MatchStr(APath, PL_SELF_ALIAS) then
    Exit(ARoot);

  myPath := APath;
  currentNode := ARoot;
  try
    lastNode := GetPropertyParent(currentNode, myPath, myField, myProp,
      myIndexedProperty);
  except
    {If we don't manage the exception here, the code flows with lastNode = nil}
    on e: exception do
      raise EPlBindApiException.Create(e.Message);
  end;
  if lastNode.IsObject then
    begin
      currentNode := lastNode.AsObject;
      try
        Result := ReadMemberValue(currentNode, myField, myProp,
          myIndexedProperty, ExtractLastIndex(myPath));
      except
        //sul superamento degli indici restituire un valore vuoto:
        //il bind potrebbe avvenire quando l'oggetto target non � ancora popolato
        Result := TValue.Empty;
      end;
    end
  else
    begin
      Result := GetRecordPathValue(currentNode, myPath);
      Exit;
    end;
end;

{Returns the instance of the (last - 1) object in the path}
{We assume that the very last node of the path is the property to be read}
{so this functions returns the object or record to which the property belongs.}
{Use this function to}
{verify if the path is correct}
{or}
{get the last node value}
class function TPlRTTIUtils.GetPropertyParent(ARoot: TObject; var APath: string;
  out AField: TRTTIField; out AProp: TRttiProperty;
  out AIndexedProperty: TRttiIndexedProperty): TValue;
var
  currentNode: TObject;
  myPath: string;
  nodeName: string;
  nodeType: TRttiType;
begin

  if MatchStr(APath, PL_SELF_ALIAS) then
    Exit(ARoot);

  myPath := APath;
  currentNode := ARoot;
  while myPath <> '' do
    try
      nodeName := FirstNode(myPath);
      {1. locate the first node of the path, both prop or field}
      if (not Assigned(currentNode)) or
        (not ExtractNode(currentNode, AField, AProp, AIndexedProperty, nodeName))
      then
        {Raise an exception if ARoot doesn't contain the APath.}
        raise EPlBindApiException.Create
          (Format('%s %s.%s', [StrCantFind, ARoot.ClassName, APath]));

      nodeType := ExtractNodeType(AField, AProp, AIndexedProperty);
      {2a. if there are more nodes...}
      if myPath <> '' then
        begin
          if nodeType.IsRecord then
            begin
              myPath := nodeName + IfThen(myPath <> '', '.' + myPath, '');
              Result := GetRecordPathValue(currentNode, myPath);
              Exit;
            end
          else
            {2b. if there are more Nodes manages them}
            NextNode(nodeName, currentNode, AField, AProp,
              AIndexedProperty, myPath);
        end;
    except
      {DONE 1 -oPMo -cRefactoring : Consider to raise an exception instead of return nil.}
      on e: exception do
        begin
          {Raise an exception if ARoot doesn't contain the APath.}
          {$IFDEF DEBUG}Log(e.Message);{$ENDIF}
          raise EPlBindApiException.Create(e.Message);
        end;
    end;
  {3. Eventually read the member value}
  Result := currentNode;
end;

class function TPlRTTIUtils.GetRecordFieldValue(Sender: TObject;
  AOwner, AField: TRTTIField): TValue;
begin
  Result := AField.GetValue(PByte(Sender) + AOwner.Offset);
end;

{Get record value when a is a field of a property}
class function TPlRTTIUtils.GetRecordFieldValue(Sender: TObject;
  AOwner: TRttiProperty; AField: TRTTIField): TValue;
var
  MyPointer: Pointer;
begin
  MyPointer := TRttiInstanceProperty(AOwner).PropInfo^.GetProc;
  Result := AField.GetValue(PByte(Sender) + Smallint(MyPointer));
end;

class function TPlRTTIUtils.GetRecordPathValue(ARoot: TObject;
  var APath: string): TValue;
var
  myField: TRTTIField;
  myFieldRoot: TRTTIField;
  myRecField: TRTTIField;
  myProp: TRttiProperty;
  myPropRoot: TRttiProperty;
  myPath: string;
  nodeName: string;
begin
  myPropRoot := nil;
  myProp := nil;

  myPath := APath;
  nodeName := FirstNode(myPath);
  {Find the record, both prop or field}
  myField := FContext.GetType(ARoot.ClassType).GetField(nodeName);
  myFieldRoot := myField;
  if not Assigned(myField) then
    begin
      myProp := FContext.GetType(ARoot.ClassType).GetProperty(nodeName);
      myPropRoot := myProp;
    end;
  {Loop on props tree}
  {DONE 1 -oPMo -cRefactoring : Manage properties of complex/advanced records}
  while myPath.Contains('.') do
    begin
      nodeName := FirstNode(myPath);
      if Assigned(myField) then
        myField := myField.FieldType.GetField(nodeName)
      else
        myField := myProp.PropertyType.GetField(nodeName);
    end;
  if Assigned(myField) then
    myRecField := myField.FieldType.GetField(myPath)
  else
    myRecField := myProp.PropertyType.GetField(myPath);

  try
    if Assigned(myFieldRoot) then
      Result := GetRecordFieldValue(ARoot, myFieldRoot, myRecField)
    else
      Result := GetRecordFieldValue(ARoot, myPropRoot, myRecField);
  except
    on e: exception do
      raise EPlBindApiException.CreateFmt('%s %s: %s.',
        [StrErrorOnSetting, APath, e.Message]);
  end;
end;

class function TPlRTTIUtils.InternalCastTo(const AType: TRttiType;
  AValue: TValue): TValue;
begin
  (*InternalBug#12: tkEnumeration type requires a specific cast*)
  if (AType.TypeKind = tkEnumeration) then
    begin
      if AValue.IsOrdinal then
        Result := OrdinalToEnumeration(AType, AValue)
      else if (AValue.Kind in [tkString, tkLString, tkWString, tkWChar,
        tkUString]) then
        Result := StringToEnumeration(AType, AValue)
      else
        Result := InternalCastTo(AType.TypeKind, AValue);
    end
  else if (AType.TypeKind = tkInteger) and (AValue.Kind = tkEnumeration) then
    Result := EnumerationToOrdinal(AType, AValue)
  else
    Result := InternalCastTo(AType.TypeKind, AValue);
end;

class function TPlRTTIUtils.InternalCastTo(const AType: TTypeKind;
  AValue: TValue): TValue;
begin
  Result := AValue;
  case AType of
    tkInteger:
      Result := CastToInteger(AValue);
    tkInt64:
      Result := CastToInt64(AValue);
    tkFloat:
      Result := CastToFloat(AValue);
    tkString, tkLString, tkWString, tkWChar, tkUString:
      Result := CastToString(AValue);
    tkEnumeration:
      Result := CastToEnumeration(AValue);
  end;
end;

{from https://stackoverflow.com/questions/10083448/
 trttimethod-invoke-function-doesnt-work-in-overloaded-methods}
{
 r := RttiMethodInvokeEx('Create', AClass, '', ['hello from constructor string']);
 r := RttiMethodInvokeEx('Create', AClass, '', []);
 RttiMethodInvokeEx('Add', AClass, AnObject , ['this is a string']);
}
class function TPlRTTIUtils.InvokeEx(const AMethodName: string; AClass: TClass;
  Instance: TValue; const Args: array of TValue): TValue;
var
  methodFound: Boolean;
  rMethod: TRttiMethod;
  rParams: TArray<TRttiParameter>;
  rType: TRttiInstanceType;
begin
  Result := nil;
  rMethod := nil;
  methodFound := False;
  rType := FContext.GetType(AClass) as TRttiInstanceType;
  if not Instance.IsObject then
    Instance := rType.MetaclassType;
  for rMethod in rType.GetMethods do
    if SameText(rMethod.Name, AMethodName) then
      begin
        rParams := rMethod.GetParameters;
        methodFound := SameSignature(rParams, Args);
        if methodFound then
          Break;
      end;

  if (rMethod <> nil) and methodFound then
    Result := rMethod.Invoke(Instance, Args)
  else
    raise EPlBindApiException.CreateFmt(StrMethodSNotFound, [AMethodName]);
end;

class function TPlRTTIUtils.IsEqualPointer(Left, Right: TValue): Boolean;
var
  pLeft: Pointer;
  pRight: Pointer;
begin
  pLeft := nil;
  pRight := nil;
  Left.ExtractRawDataNoCopy(pLeft);
  Right.ExtractRawDataNoCopy(pRight);
  Result := (pLeft = pRight);
end;

class function TPlRTTIUtils.IsIndexedProperty(const AName: string): Boolean;
begin
  Result := AName.IndexOf('[') > -1;
end;

class function TPlRTTIUtils.IsIndexedProperty(ARoot: TObject;
  const AName: string): Boolean;
begin
  Result := IsIndexedProperty(AName) or
    Assigned(FContext.GetType(ARoot.ClassType).GetIndexedProperty(AName));
end;

class function TPlRTTIUtils.IsValidPath(ARoot: TObject;
  const APath: string): Boolean;
var
  lastNode: TValue;
  myField: TRTTIField;
  myIndexedProperty: TRttiIndexedProperty;
  myPath: string;
  myProp: TRttiProperty;
begin
  myPath := APath;
  myField := nil;
  myProp := nil;
  myIndexedProperty := nil;
  lastNode := GetPropertyParent(ARoot, myPath, myField, myProp,
    myIndexedProperty);
  Result := (not lastNode.IsEmpty) and (Assigned(myField) or Assigned(myProp) or
    Assigned(myIndexedProperty));
end;

class procedure TPlRTTIUtils.Log(const AMessage: string);
var
  fileName: string;
begin
  {Get the filename for the logfile.
   In this case should be the Filename 'application-exename.log'?}
  fileName := TPath.GetPublicPath + TPath.DirectorySeparatorChar +
    StrMorandottiIt + TPath.DirectorySeparatorChar + StrBindApi +
    TPath.DirectorySeparatorChar + StrErrorsLog;

  if not DirectoryExists(ExtractFilePath(fileName)) then
    ForceDirectories(ExtractFilePath(fileName));

  TFile.AppendAllText(fileName, AMessage + chr(13));
end;

class function TPlRTTIUtils.MethodIsImplemented(ATypeInfo: Pointer;
  AMethodName: string): Boolean;
var
  m: TRttiMethod;
begin
  {from https://stackoverflow.com/questions/8305008/
   how-i-can-determine-if-an-abstract-method-is-implemented}
  Result := False;
  for m in FContext.GetType(ATypeInfo).GetDeclaredMethods do
    begin
      Result := CompareText(m.Name, AMethodName) = 0;
      if Result then
        Break;
    end;
end;

class function TPlRTTIUtils.MethodIsImplemented(const AClass: TClass;
  AMethodName: string): Boolean;
var
  m: TRttiMethod;
begin
  {from https://stackoverflow.com/questions/8305008/
   how-i-can-determine-if-an-abstract-method-is-implemented}
  Result := False;
  for m in FContext.GetType(AClass.ClassInfo).GetDeclaredMethods do
    begin
      Result := CompareText(m.Name, AMethodName) = 0;
      if Result then
        Break;
    end;
end;

class function TPlRTTIUtils.NextNode(const ANodeName: string;
  var ARoot: TObject; var AField: TRTTIField; var AProp: TRttiProperty;
  var AIndexedProp: TRttiIndexedProperty; var APath: string): TValue;
var
  memberType: TRttiType;
begin
  (*DONE 5 -oPMo -cDebug : Manage AIndexedProp*)
  memberType := ExtractNodeType(AField, AProp, AIndexedProp);
  Result := TValue.Empty;
  if memberType.IsRecord then
    begin
      APath := ANodeName + IfThen(APath <> '', '.' + APath, '');
      Result := GetRecordPathValue(ARoot, APath);
    end;
  if memberType.isInstance then
    ARoot := ReadMemberValue(ARoot, AField, AProp, AIndexedProp, APath)
      .AsObject;
end;

class function TPlRTTIUtils.OrdinalToEnumeration(const AType: TRttiType;
  AValue: TValue): TValue;
begin
  (*Bug#12: To be implemented*)
  Result := TValue.FromOrdinal(AType.Handle, AValue.AsInteger);
end;

class function TPlRTTIUtils.PropertyExists(ATypeInfo: Pointer;
  APropertyName: string): Boolean;
var
  rType: TRttiType;
begin
  Result := False;
  rType := FContext.GetType(ATypeInfo);
  if rType <> nil then
    begin
      Result := rType.GetProperty(APropertyName) <> nil;
      if not Result then
        Result := rType.GetIndexedProperty(APropertyName) <> nil;
    end;
end;

class function TPlRTTIUtils.PropertyExists(const AClass: TClass;
  APropertyName: string): Boolean;
begin
  Result := PropertyExists(AClass.ClassInfo, APropertyName);
end;

class function TPlRTTIUtils.ReadFieldValue(ARoot: TObject; AField: TRTTIField;
  out AValue: TValue): Boolean;
begin
  Result := Assigned(AField);
  if Result then
    case AField.FieldType.TypeKind of
      tkClass:
        AValue := AField.GetValue(ARoot).AsObject
    else
      AValue := AField.GetValue(ARoot);
    end
end;

class function TPlRTTIUtils.ReadIndexedPropertyValue(ARoot: TObject;
  AProp: TRttiIndexedProperty; const AnIndex: string;
  out AValue: TValue): Boolean;
var
  indexedPropertyInfo: TPlIndexedPropertyInfo;
begin
  Result := Assigned(AProp);
  if Result then
    begin
      indexedPropertyInfo := GetIndexedPropertyInfo(AProp, AnIndex);
      AValue := AProp.GetValue(ARoot, indexedPropertyInfo.paramsValues);
    end;
end;

class function TPlRTTIUtils.ReadMemberValue(ARoot: TObject; AField: TRTTIField;
  AProp: TRttiProperty; AIndexedProp: TRttiIndexedProperty;
  const AIndex: string): TValue;
begin
  {TODO 1 -oPMo -cRefactoring : Try to manage method}
  Result := TValue.Empty;
  if not(ReadFieldValue(ARoot, AField, Result) or ReadPropertyValue(ARoot,
    AProp, Result) or ReadIndexedPropertyValue(ARoot, AIndexedProp, AIndex,
    Result)) then
    raise EPlBindApiException.Create(StrInvalidFieldOrProperty);
end;

class function TPlRTTIUtils.ReadPropertyValue(ARoot: TObject;
  AProp: TRttiProperty; out AValue: TValue): Boolean;
var
  propertyInfo: PPropInfo;
begin
  Result := Assigned(ARoot) and Assigned(AProp);
  if Result then
    case AProp.PropertyType.TypeKind of
      tkClass:
        begin
          propertyInfo := (AProp as TRttiInstanceProperty).PropInfo;
          AValue := GetObjectProp(ARoot, propertyInfo);
        end
    else
      AValue := AProp.GetValue(ARoot);
    end;
end;

class procedure TPlRTTIUtils.ResetMethod(ARoot: TObject;
  const AMethodName: string);
var
  recMethod: TMethod;
begin
  if Assigned(ARoot) then
    begin
      recMethod.Code := nil;
      recMethod.Data := nil;
      SetMethodProp(ARoot, AMethodName, recMethod);
    end;
end;

class function TPlRTTIUtils.SameSignature(const AParams: TPlRTTIParametersArray;
  const Args: array of TValue): Boolean;
var
  rIndex: Integer;
begin
  Result := False;
  if Length(Args) = Length(AParams) then
    begin
      Result := True;
      for rIndex := 0 to Length(AParams) - 1 do
        if not(((AParams[rIndex].ParamType.TypeKind = tkClass) and
          (Args[rIndex].TypeInfo = nil)) or
          (AParams[rIndex].ParamType.Handle = Args[rIndex].TypeInfo) or
          (Args[rIndex].IsObject and Args[rIndex].AsObject.InheritsFrom(AParams
          [rIndex].ParamType.AsInstance.MetaclassType))) then
          begin
            Result := False;
            Break;
          end;
    end;
end;

class function TPlRTTIUtils.SetMethod(ARoot: TObject;
  const ARootMethodPath: string; ATarget: TObject;
  const ATargetMethodName: string): Boolean;
var
  rType: TRttiType;
  rMethod: TRttiMethod;
  methodPath: string;
  sourceObject: TObject;
  recMethod: TMethod;
begin
  Result := False;
  methodPath := ARootMethodPath;
  if (ARoot is TComponent) then
    sourceObject := ComponentFromPath(TComponent(ARoot), methodPath)
  else
    sourceObject := ARoot;
  {Extract type information for ASource's type}
  rType := FContext.GetType(ATarget.ClassType);
  rMethod := rType.GetMethod(ATargetMethodName);
  if Assigned(rMethod) then
    begin
      recMethod.Code := rMethod.CodeAddress;
      recMethod.Data := Pointer(ATarget); //(Self);
      SetMethodProp(sourceObject, methodPath, recMethod);
      Result := True;
    end;

end;

class procedure TPlRTTIUtils.SetPathValue(ARoot: TObject; const APath: string;
  AValue: TValue);
var
  currentNode: TObject;
  myField: TRTTIField;
  myIndexedProp: TRttiIndexedProperty;
  myPath: string;
  myProp: TRttiProperty;
  nodeName: string;
  nodeType: TRttiType;
begin
  currentNode := ARoot;
  myField := nil;
  myIndexedProp := nil;
  myProp := nil;
  myPath := APath;

  while myPath <> '' do
    begin
      nodeName := FirstNode(myPath);
      {First node, both prop or field}
      ExtractNode(currentNode, myField, myProp, myIndexedProp, nodeName);
      nodeType := ExtractNodeType(myField, myProp, myIndexedProp);
      {2a. if there are more nodes...}
      if myPath <> '' then
        begin
          if nodeType.IsRecord then
            begin
              myPath := nodeName + IfThen(myPath <> '', '.' + myPath, '');
              SetRecordPathValue(currentNode, myPath, AValue);
              Exit;
            end
          else
            {2b. if there are more Nodes manages them}
            NextNode(nodeName, currentNode, myField, myProp,
              myIndexedProp, myPath);
        end;
    end;
  {eventually, we set the value of the last node, if any}
  WriteMemberValue(currentNode, myField, myProp, myIndexedProp, APath, AValue);
end;

{Set record value when a is a field of a field}
class procedure TPlRTTIUtils.SetRecordFieldValue(Sender: TObject;
  AOwner, AField: TRTTIField; AValue: TValue);
begin
  if (AField.FieldType.TypeKind <> AValue.Kind) then
    AValue := InternalCastTo(AField.FieldType.TypeKind, AValue);
  AField.SetValue(PByte(Sender) + AOwner.Offset, AValue);
end;

class procedure TPlRTTIUtils.SetRecordFieldValue(Sender: TObject;
  AOwner: TRttiProperty; AField: TRTTIField; AValue: TValue);
var
  lPointer: Pointer;
begin
  if (AField.FieldType.TypeKind <> AValue.Kind) then
    AValue := InternalCastTo(AField.FieldType.TypeKind, AValue);
  lPointer := TRttiInstanceProperty(AOwner).PropInfo^.GetProc;
  AField.SetValue(PByte(Sender) + Smallint(lPointer), AValue);
end;

{Set record value when a is a field of a property
 Remember a record should not contain classes as member, nor record as prop.
 So the first Node could be a simple property or a field,
 and the following Nodes should be fields only}
class procedure TPlRTTIUtils.SetRecordPathValue(ARoot: TObject;
  const APath: string; AValue: TValue);
var
  myField: TRTTIField;
  myFieldRoot: TRTTIField;
  myRecField: TRTTIField;
  myProp: TRttiProperty;
  myPropRoot: TRttiProperty;
  myPath: string;
  nodeName: string;
begin
  myPropRoot := nil;
  myProp := nil;

  myPath := APath;
  nodeName := FirstNode(myPath);

  myField := FContext.GetType(ARoot.ClassType).GetField(nodeName);
  myFieldRoot := myField;
  if not Assigned(myField) then
    begin
      myProp := FContext.GetType(ARoot.ClassType).GetProperty(nodeName);
      myPropRoot := myProp;
    end;
  {First Node, both prop or field}
  while myPath.Contains('.') do
    begin
      nodeName := FirstNode(myPath);
      if Assigned(myField) then
        myField := myField.FieldType.GetField(nodeName)
      else
        myField := myProp.PropertyType.GetField(nodeName);
    end;
  if Assigned(myField) then
    myRecField := myField.FieldType.GetField(myPath)
  else
    myRecField := myProp.PropertyType.GetField(myPath);

  try
    if Assigned(myFieldRoot) then
      SetRecordFieldValue(ARoot, myFieldRoot, myRecField, AValue)
    else
      SetRecordFieldValue(ARoot, myPropRoot, myRecField, AValue);
  except
    on e: exception do
      raise EPlBindApiException.CreateFmt('%s %s: %s.',
        [StrErrorOnSetting, APath, e.Message]);
  end;

end;

class function TPlRTTIUtils.StringToEnumeration(const AType: TRttiType;
  AValue: TValue): TValue;
var
  intValue: Integer;
begin
  intValue := GetEnumValue(AType.Handle, AValue.AsString);
  Result := OrdinalToEnumeration(AType, intValue);
end;

class function TPlRTTIUtils.TryExtractNode(ARoot: TObject;
  out AField: TRTTIField; out AProp: TRttiProperty;
  out AIndexedProp: TRttiIndexedProperty; const ANodeName: string): Boolean;
begin
  try
    Result := ExtractNode(ARoot, AField, AProp, AIndexedProp, ANodeName);
  except
    on e: exception do
      Result := False;
  end;
end;

(*
 class function TPlRTTIUtils.TryExtractNode(ARoot: TObject;
 out AMember: TRTTIDataMember; out AIndexedProp: TRttiIndexedProperty;
 const ANodeName: string): Boolean;
 begin
 try
 Result := ExtractNode(ARoot, AMember, AIndexedProp, ANodeName);
 except
 on e: Exception do
 Result := False;
 end;
 end;
*)
class procedure TPlRTTIUtils.WriteFieldValue(ANode: TObject; AField: TRTTIField;
  AValue: TValue);
begin
  if (AField.FieldType.TypeKind <> AValue.Kind) then
    AValue := InternalCastTo(AField.FieldType, AValue);
  case AField.FieldType.TypeKind of
    tkClass:
      AField.SetValue(ANode, TObject(AValue.AsObject))
  else
    AField.SetValue(ANode, AValue);
  end;
end;

{TODO 5 -oPMo -cDebug : create a valid method to write indexed properties }
class procedure TPlRTTIUtils.WriteIndexedPropertyValue(ANode: TObject;
    AIndexedProp: TRttiIndexedProperty; AIndex: string; AValue: TValue);
var
  indexedPropertyInfo: TPlIndexedPropertyInfo;
  propertyInfo: PPropInfo;
  propTypeKind: TTypeKind;
begin
  if not Assigned(AIndexedProp) then
    Exit;
  indexedPropertyInfo := GetIndexedPropertyInfo(AIndexedProp, AIndex);
  propTypeKind := AIndexedProp.PropertyType.TypeKind;
  if (propTypeKind <> AValue.Kind) then
    AValue := InternalCastTo(AIndexedProp.PropertyType, AValue);
  case propTypeKind of
    tkClass:
      AIndexedProp.SetValue(ANode, indexedPropertyInfo.paramsValues, TObject(AValue.AsObject))
  else
    AIndexedProp.SetValue(ANode, indexedPropertyInfo.paramsValues, AValue);
  end;
end;

class procedure TPlRTTIUtils.WriteMemberValue(ANode: TObject;
  AField: TRTTIField; AProp: TRttiProperty; AIndexedProp: TRttiIndexedProperty;
  const APath: string; AValue: TValue);
begin
  if Assigned(AField) then
    WriteFieldValue(ANode, AField, AValue)
  else if Assigned(AProp) then
    WritePropertyValue(ANode, AProp, AValue)
  else if Assigned(AIndexedProp) then
    WriteIndexedPropertyValue(ANode, AIndexedProp, ExtractLastIndex(APath),
      AValue);
end;

class procedure TPlRTTIUtils.WritePropertyValue(ANode: TObject;
  AProp: TRttiProperty; AValue: TValue);
var
  propertyInfo: PPropInfo;
  propTypeKind: TTypeKind;
begin
  propTypeKind := AProp.PropertyType.TypeKind;
  if (propTypeKind <> AValue.Kind) then
    AValue := InternalCastTo(AProp.PropertyType, AValue);
  case propTypeKind of
    tkClass:
      begin
        propertyInfo := (AProp as TRttiInstanceProperty).PropInfo;
        SetObjectProp(ANode, propertyInfo, AValue.AsObject);
      end
  else
    AProp.SetValue(ANode, AValue);
  end;
end;

end.
