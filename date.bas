#include "date.bi"

Declare Function IsLeapYear(theYear As Integer) As Boolean

' Default constructor for TDate object

Constructor TDate()
End Constructor

' Constructor for a TDate from a DateSerial

Constructor TDate(theDate As Double)

    This._year = Year(theDate)
    This._month = Month(theDate)
    This._day = Day(theDate)
End Constructor

' Constructor for a TDate object that parses a string in
' the format dd/mm/yyyy

Constructor TDate(theDate As String)

    Dim firstSeparator As Integer = Instr(theDate, "/")
    Dim secondSeparator As Integer = Instr(firstSeparator + 1, theDate, "/")
    
    This._day = Valint(Left(theDate, firstSeparator - 1))
    This._month = Valint(Mid(theDate, firstSeparator + 1, secondSeparator - firstSeparator - 1))
    This._year = Valint(Mid(theDate, secondSeparator + 1))
End Constructor

' Constructor for a TDate object that sets the specified year, month
' and day.

Constructor TDate(theYear As Integer, theMonth As Integer, theDay As Integer)

    This._year = theYear
    This._month = theMonth
    This._day = theDay
End Constructor

' Compare two dates

Function TDate.Compare(firstDate As TDate, secondDate As TDate) As Boolean

    If firstDate._year > secondDate._year Then Return false
    If firstDate._month > secondDate._month Then Return false
    If firstDate._day > secondDate._day Then Return false
    Return true
End Function

' Return a string representation of a date in
' the format dd/mm/yyyy.

Property TDate.ToString() As String

    Return Str(This._day) + "/" + Str(This._month) + "/" + Str(This._year)
End Property

' Returns the last day of the specified month

Function TDate.LastDay(theMonth As Integer, theYear As Integer) As Integer
    Dim theDay As Integer = 31

    If (theMonth = 9 Or theMonth = 4 Or theMonth = 6 Or theMonth = 11) And theDay > 30 Then
        theDay = 30
    End If
    If theMonth = 2 Then
        If Not IsLeapYear(theYear) And CBool(theDay > 28) Then
            theDay = 28
        End If
        If IsLeapYear(theYear) And CBool(theDay > 29) Then
            theDay = 29
        End If
    End If
    Return theDay
End Function

' Return whether the specified year is a leap year

Private Function IsLeapYear(theYear As Integer) As Boolean

    Return ((theYear MOD 4 = 0) And (theYear MOD 100 <> 0)) Or (theYear MOD 400 = 0)
End Function

