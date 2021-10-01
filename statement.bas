#include "utils.bi"
#include "statement.bi"

' Default constructor for a statement

Constructor TStatement()
End Constructor

' Constructor for a monthly statement with records

Constructor TStatement(theYear As Integer, theMonth As Integer, theRecords As TRecords Ptr)
    This._year = theYear
    This._month = theMonth
    This._records = theRecords
End Constructor

' Return the statement entry balance

Property TStatement.EntryBalance() As Double
    Return This._entryBalance
End Property

' Set the new statement entry balance

Property TStatement.EntryBalance(ByRef balance As Double)

    This._entryBalance = balance
End Property

' Compute the exit balance for this statement by summing the 
' records and adding to the entry balance

Property TStatement.ExitBalance() As Double
    Dim balance As Double = This._entryBalance
    Dim index As Integer

    For index = 1 To _records->Count
        balance = balance + _records->Get(index)->Value
    Next index

    Return balance
End Property

' Return the year of this statement

Property TStatement.Year() As Integer

    Return This._year
End Property

' Return the month of this statement

Property TStatement.Month() As Integer

    Return This._month
End Property

' Get the records for this statement

Property TStatement.Records() As TRecords Ptr

    Return This._records
End Property

' Set the records for this statement

Property TStatement.Records(ByRef newRecords As TRecords Ptr)

    This._records = newRecords
End Property

