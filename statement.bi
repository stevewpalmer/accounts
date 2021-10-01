#include "records.bi"

' A single monthly statement comprising an entry balance
' computed from previous statements and an array of records
' for all expenditure in the month.

Type TStatement
Private:
    _entryBalance As Double
    _year As Integer
    _month As Integer
    _records As TRecords Ptr

Public:
    Declare Constructor()
    Declare Constructor(As Integer, As Integer, records As TRecords Ptr) 
    Declare Property EntryBalance() As Double
    Declare Property EntryBalance(ByRef balance As Double)
    Declare Property ExitBalance() As Double
    Declare Property Records() As TRecords Ptr
    Declare Property Records(ByRef newRecords As TRecords Ptr)
    Declare Property Year() As Integer
    Declare Property Month() As Integer
End Type

