#include "records.bi"

' A single monthly statement comprising an entry balance
' computed from previous statements and an array of records
' for all expenditure in the month.

Type TMonth
Private:
    _entryBalance As Double
    _year As Integer
    _month As Integer
    _records As TRecords

Public:
    Declare Constructor()
    Declare Constructor(As Integer, As Integer, ByRef records As TRecords) 
    Declare Property EntryBalance() As Double
    Declare Property EntryBalance(ByRef balance As Double)
    Declare Property ExitBalance() As Double
    Declare Property Records() As TRecords
    Declare Property Year() As Integer
    Declare Property Month() As Integer
End Type

