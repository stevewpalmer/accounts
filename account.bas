#include "account.bi"
#include "vbcompat.bi"
#include "constants.bi"
#include "utils.bi"
#include "config.bi"

' Initialise the program data directory in the user's
' home directory.

Sub TAccount.Init()
    Dim As String programFolderPath = ProgramFolder()
    Dim As String dataFolderPath = DataFolder()
    Dim As String thisYear = Str(Year(Now()))
    Dim As String yearFolderPath = dataFolderPath + "/" + thisYear

    If Not DirExists(programFolderPath) Then Mkdir(programFolderPath)
    If Not DirExists(dataFolderPath) Then Mkdir(dataFolderPath)

    ' Make sure there's a folder for the current year
    If Not DirExists(yearFolderPath) Then Mkdir(yearFolderPath)

    ' Initialise
    _fixed = 0

    ' Read configuration
    ReadConfig() 
End Sub

' Read configuration file

Sub TAccount.ReadConfig()
    Dim fileHandle As Integer = FreeFile()

    If Open(ProgramFolder() + "/config" For Input As #fileHandle) = 0 Then
        Do Until EOF(fileHandle)
            Dim theName As String
            Dim theValue As String

            Line Input #fileHandle, theName
            Line Input #fileHandle, theValue

            Select Case theName
                Case "StartBalance"
                    This._startBalance = CDbl(theValue)

                Case "ReverseColour"
                    ReverseColour = CInt(theValue)

                Case "ForegroundColour"
                    ForegroundColour = CInt(theValue)

                Case "BackgroundColour"
                    BackgroundColour = CInt(theValue)

                Case "TitleColour"
                    TitleColour = CInt(theValue)
            End Select
        Loop
    End If
    Close
End Sub

' Add a statement to the account

Sub TAccount.Add(ByRef statement As TStatement)

    If _count = _size Then
        _size = _size + 10
        Redim Preserve _statements (1 To _size) As TStatement
    End If

    _count = _count + 1
    _statements(_count) = statement
End Sub

' Return the total number of statements

Property TAccount.Count() As Integer

    Return _count
End Property

' Return the monthly statement at the specified index

Function TAccount.Get(index As Integer) As TStatement Ptr
    Dim statementPtr As TStatement Ptr = @_statements(index)
    Dim isFuture As Boolean = statementPtr->Year >= Year(Now()) AndAlso statementPtr->Month > Month(Now())

    ' Initialised with fixed records for future months
    If statementPtr->Records->Count = 0 And isFuture Then
        statementPtr->Records = ReadFixed()
    End If

    ' Sort the statement by date
    statementPtr->Records->Sort()

    ' Recalculate the entry balance
    UpdateEntryBalances()

    Return statementPtr
End Function

' Return the monthly statement for the given year and month, or
' null if none is found

Function TAccount.Get(theYear As Integer, theMonth As Integer) As TStatement Ptr
    Dim index As Integer
    
    For index = 1 To _count
        If _statements(index).Year = theYear And _statements(index).Month = theMonth Then
            Return Get(index)
        End If
    Next
    Return 0
End Function

' Recalculate the entry balances for all records. This assumes that the
' records are in order of year and month within the year.

Private Sub TAccount.UpdateEntryBalances()
    Dim entryBalance As Double = _startBalance
    Dim index As Integer

    For index = 1 To _count
        _statements(index).EntryBalance = entryBalance
        If _statements(index).Records->Count = 0 Then
            _statements(index).Records = ReadFixed()
        End If
        entryBalance = _statements(index).ExitBalance
    Next
End Sub

' Read all statements and compute the entry and exit balances for
' each month.

Sub TAccount.ReadAccounts()
    Dim entryBalance As Double = _startBalance
    Dim currentYear As Integer = Year(Now())
    Dim theYear As Integer = currentYear
    Dim startMonth As Integer = 13
    Dim yearIndex As Integer
    Dim years() As Integer

    ListYears(years())
    If UBound(years) > 0 Then
        If years(1) < theYear Then theYear = years(1)
    End If

    While theYear <= currentYear
        Dim months() As Integer
        Dim monthIndex As Integer
        Dim theMonth As Integer

        ListMonths(theYear, months())
        If UBound(months) > 0 Then
            If months(1) < startMonth Then startMonth = months(1)
        Endif
        If startMonth = 13 Then startMonth = 1

        For theMonth = startMonth To 12
            Dim records As TRecords Ptr
            Dim oneMonth As TStatement

            records = ReadMonth(theYear, theMonth)

            oneMonth = TStatement(theYear, theMonth, records)
            oneMonth.EntryBalance = entryBalance
            entryBalance = oneMonth.ExitBalance

            Add(oneMonth)
        Next

        theYear = theYear + 1
    Wend
End Sub

' Return an array of categorised expenditures

Sub TAccount.Categories(theYear As Integer, list() As TCategory)
    Dim index As Integer
    Dim size As Integer = 0
    Dim listCount As Integer = 0

    For index = 1 to _count
        If _statements(index).Year = theYear Then
            Dim itemIndex As Integer        

            If _statements(index).Records->Count = 0 Then
                _statements(index).Records = ReadFixed()
            End If

            For itemIndex = 1 To _statements(index).Records->Count
                Dim itemName As String = _statements(index).Records->Get(itemIndex)->Name
                Dim itemValue As Double = _statements(index).Records->Get(itemIndex)->Value
                Dim listIndex As Integer
                Dim found As Boolean = false

                For listIndex = 1 To listCount
                    If list(listIndex).Name = itemName Then
                        list(listIndex).Value = list(listIndex).Value + Abs(itemValue)
                        found = true
                        Exit For
                    End If
                Next

                If Not found Then
                    If listCount = size Then
                        Redim Preserve list(1 To size + 10) As TCategory
                        size = size + 10
                    End If
                    listCount = listCount + 1
                    list(listCount) = TCategory(itemName, Abs(itemValue))
                End If
            Next    
        End If
    Next
    If listCount > 0 Then Redim Preserve list(1 To listCount) As TCategory
End Sub

' The filename of the fixed incomings and outgoings data

Function TAccount.FixedDataFile() As String

    Return DataFolder() + "/fixed"
End Function

' Read the savings file

Function TAccount.ReadSavings() As TRecords Ptr
    Dim fileName As String = DataFolder() + "/savings"

    Return ReadDataFile(fileName)
End Function

' Read the fixed incomings and outgoings entries record

Function TAccount.ReadFixed() As TRecords Ptr

    If _fixed = 0 Then
        _fixed = ReadDataFile(FixedDataFile())
    End If
    Return _fixed
End Function

' Read the statement for the specified year and month

Function TAccount.ReadMonth(theYear As Integer, theMonth As Integer) As TRecords Ptr
    Dim fileName As String = DataFolder() + "/" + Str(theYear) + "/" + Str(theMonth)

    Return ReadDataFile(fileName)
End Function

' Read a single data file

Function TAccount.ReadDataFile(fileName As String) As TRecords Ptr
    Dim fileHandle As Integer = FreeFile()
    Dim records As TRecords Ptr = new TRecords()    

    If Open(fileName For Input As #fileHandle) = 0 Then
        Do Until EOF(fileHandle)
            Dim theLabel As String
            Dim theValue As String
            Dim theDate As String

            Line Input #fileHandle, theLabel
            Line Input #fileHandle, theValue
            Line Input #fileHandle, theDate

            If theLabel <> "" And theValue <> "" And theDate <> "" Then
                records->Add(TRecord(theLabel, CDbl(theValue), TDate(theDate)))
            End If
        Loop
    End If
    Close

    Return records
End Function

' Save the fixed incomings and outgoings entries record

Sub TAccount.SaveFixed(ByRef record As TRecords Ptr)
    Dim backupFile As String = FixedDataFile() + ".bak"
    Dim fileHandle As Integer = FreeFile()
    Dim index As Integer

    ' Make a backup first
    FileCopy FixedDataFile(), backupFile

    If Open(FixedDataFile() For Output As #fileHandle) = 0 Then
        For index = 1 to record->Count
            Print #fileHandle, record->Get(index)->Name
            Print #fileHandle, Str(record->Get(index)->Value)
            Print #fileHandle, record->Get(index)->Date.ToString
        Next
    End If
    Close

End Sub

' Save the specified statement

Sub TAccount.SaveStatement(statement As TStatement Ptr)
    Dim fileName As String = DataFolder() + "/" + Str(statement->Year) + "/" + Str(statement->Month)
    Dim backupFile As String = fileName + ".bak"
    Dim fileHandle As Integer = FreeFile()
    Dim index As Integer

    ' Make a backup first
    FileCopy fileName, backupFile

    If Open(filename For Output As #fileHandle) = 0 Then
        For index = 1 to statement->Records->Count
            Print #fileHandle, statement->Records->Get(index)->Name
            Print #fileHandle, Str(statement->Records->Get(index)->Value)
            Print #fileHandle, TDate(statement->Year, statement->Month, statement->Records->Get(index)->Date._day).ToString
        Next
    End If
    Close

End Sub

' Return an integer array of all the saved years
' in the account data folder.

Sub TAccount.ListYears(years () As Integer)
    Dim As String dirName = Dir(DataFolder() + "/*", fbDirectory)
    Dim As Integer index = 1

    Do While Len(dirName) > 0
        If index > UBound(years) Then
            Redim Preserve years(1 To index + 10)
        End if
        years(index) = Valint(dirName)
        index = index + 1
        dirName = Dir()
    Loop

    If index > 1 Then Redim Preserve years(1 To index - 1) As Integer
    SortArray(years())
End Sub

' Return an integer array of all the saved months in
' the specified year in the account data folder.

Sub TAccount.ListMonths(theYear As Integer, months () As Integer)
    Dim As String dirName = Dir(DataFolder() + "/" + Str(theYear) + "/*", fbNormal)
    Dim As Integer index = 1

    Do While Len(dirName) > 0
        If index > UBound(months) Then
            Redim Preserve months(1 To index + 10)
        End if
        months(index) = Valint(dirName)
        index = index + 1
        dirName = Dir()
    Loop

    If index > 1 Then Redim Preserve months(1 To index - 1) As Integer
    SortArray(months())
End Sub
