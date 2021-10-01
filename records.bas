#include "utils.bi"
#include "vbcompat.bi"
#include "records.bi"

' Default constructor for TRecord object

Constructor TRecord()
End Constructor

' Constructor for a TRecord object with specified values

Constructor TRecord(theName As String, theValue As Double, theDate As TDate)

    This._name = theName
    This._value = theValue
    This._date = theDate
End Constructor

' Return the name field of a record

Property TRecord.Name() As String

    Return This._name
End Property

' Return the value field of a record

Property TRecord.Value() As Double

    Return This._value
End Property

' Return the date field of a record

Property TRecord.Date() As TDate

    Return This._date
End Property

' Change the date field of a record

Property TRecord.Date(ByRef newDate As TDate)

    This._date = newDate
End Property

' Return count of records

Property TRecords.Count() As Integer

    Return This._count
End Property

' Get a single record

Function TRecords.Get(index As Integer) As TRecord Ptr

    Return @_records(index)
End Function

' Add a record to the list of records

Sub TRecords.Add(ByRef item As TRecord)

    If This._count = This._size Then
        This._size = This._size + 10
        Redim Preserve This._records (1 To This._size) As TRecord
    End If

    This._count = This._count + 1
    This._records(This._count) = item
End Sub

' Sort records by date

Sub TRecords.Sort()
    Dim index As Integer
    Dim didSwap As Boolean

    Do
        didSwap = false
        For index = 1 To This._count - 1
            If Not TDate.Compare(This._records(index).Date, This._records(index + 1).Date) Then
                Dim tempRecord As TRecord = This._records(index)
                This._records(index) = This._records(index + 1)
                This._records(index + 1) = tempRecord
                didSwap = true
            End If
        Next
    Loop Until Not didSwap
End Sub

' Clear all existing records

Sub TRecords.Clear()

    This._count = 0
End Sub

