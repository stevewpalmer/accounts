#include "date.bi"

' Single incoming or outgoing expense record
' with name and the optional date of the
' transaction.

Type TRecord
Private:
    _name As String
    _value As Double
    _date As TDate

Public:
    Declare Constructor()
    Declare Constructor(As String, As Double, As TDate)

    Declare Property Name() As String
    Declare Property Value() As Double
    Declare Property Date() As TDate
    Declare Property Date(ByRef newDate As TDate)
End Type

' Fixed incoming or outgoing entries record

Type TRecords
Private:
    _count As Integer
    _size As Integer
    _records(Any) As TRecord

Public:
    Declare Function Get(As Integer) As TRecord Ptr
    Declare Sub Add(ByRef item As TRecord)
    Declare Sub Clear()
    Declare Sub Sort()
    Declare Property Count() As Integer
End Type

