#include "vbcompat.bi"

' Date type

Type TDate Extends Object
    _year As Integer
    _month As Integer
    _day As Integer

    Declare Constructor()
    Declare Constructor(As Double)
    Declare Constructor(As String)
    Declare Constructor(As Integer, As Integer, As Integer)

    Declare Static Function Compare(As TDate, As TDate) As Boolean
    Declare Static Function LastDay(As Integer, As Integer) As Integer

    Declare Property ToString() As String
End Type
