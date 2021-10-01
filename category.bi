#include "statement.bi"

' A category of expenses

Type TCategory
Private:
    _name As String
    _value As Double

Public:
    Declare Constructor()
    Declare Constructor(As String, As Double)
    Declare Property Name() As String
    Declare Property Value() As Double
    Declare Property Value(ByRef newValue As Double)
End Type

