#include "category.bi"

' An account is a collection of monthly statements

Type TAccount
Private:
    _count As Integer
    _size As Integer
    _fixed As TRecords Ptr
    _statements(Any) As TStatement
    _startBalance As Double

    Declare Sub ReadConfig()
    Declare Function FixedDataFile() As String
    Declare Function ReadDataFile(fileName As String) As TRecords Ptr
    Declare Sub UpdateEntryBalances()

Public:
    Declare Sub Init()
    Declare Sub Add(ByRef theMonth As TStatement)
    Declare Property Count() As Integer
    Declare Sub ReadAccounts()
    Declare Function ReadFixed As TRecords Ptr
    Declare Function ReadSavings As TRecords Ptr
    Declare Function ReadMonth(As Integer, As Integer) As TRecords Ptr
    Declare Sub SaveFixed(ByRef record As TRecords Ptr)
    Declare Sub SaveStatement(statement As TStatement Ptr)
    Declare Sub ListYears(directories() As Integer)
    Declare Sub ListMonths(As Integer, directories () As Integer)
    Declare Function Get(As Integer, As Integer) As TStatement Ptr
    Declare Function Get(index As Integer) As TStatement Ptr
    Declare Sub Categories(As Integer, categories() As TCategory)
End Type

