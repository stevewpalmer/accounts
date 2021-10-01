#include "utils.bi"
#include "account.bi"
#include "forms.bi"
#include "vbcompat.bi"
#include "globals.bi"

' Display statement for the current month

Sub CurrentMonth(account As TAccount)
    Dim thisMonth As Integer = Month(Now())
    Dim thisYear As Integer = Year(Now())

    ShowMonth(account, thisYear, thisMonth)    
End Sub

' Display statement for the specified year and month

Sub ShowMonth(ByRef account as TAccount, thisYear As Integer, thisMonth As Integer)
    Dim statement As TStatement Ptr
    Dim index As Integer
    Dim form As TForm = TForm(TForm.CanPrint)
    Dim rowIndex As Integer = 4
    Dim result As TDisplayFormResult
    Dim selectedItem As Integer = -1
    Dim insertDay As Integer = Day(Now())

    Const sectionName As String = "Fixed"

    ShowTitle("Statement for " + MonthName(thisMonth) + " " + Str(thisYear))

    ' Display instructions line
    form.AddLabel(rowIndex, 4, "Here you can add and remove entries for this month. Use negative values for outgoings.")
    rowIndex = rowIndex + 2

    ' For prior months, insertDay is the end of the month
    If thisYear < Year(Now()) Or thisYear = Year(Now()) And thisMonth < Month(Now()) Then
        insertDay = TDate.LastDay(thisMonth, thisYear)
    End If

    ' Show header
    form.AddLabel(rowIndex, 4, "_Date")
    form.AddLabel(rowIndex, 12, "_Description")
    form.AddLabel(rowIndex, 36, 10, TAlign.Right, "_Amount")
    rowIndex = rowIndex + 2

    ' Get the statement for this year and month
    statement = account.Get(thisYear, thisMonth)

    ' Show entry balance
    form.AddLabel(rowIndex, 12, "Entry Balance")
    form.AddLabel(rowIndex, 36, 10, TAlign.Right, Format(statement->EntryBalance, "0.00"))
    rowIndex = rowIndex + 2

    form.BeginSection(sectionName)
    For index = 1 To statement->Records->Count

        ' Find insertion point
        If statement->Records->Get(index)->Date._day > insertDay And selectedItem = -1 Then
            form.AddNumeric(rowIndex, 4, 6, Day(Now()), "{0}-" + Left(MonthName(thisMonth), 3))
            form.AddText(rowIndex, 12, 20, "")
            form.AddCurrency(rowIndex, 36, 0)
            selectedItem = form.Count - 1
            rowIndex = rowIndex + 1
        End If

        form.AddNumeric(rowIndex, 4, 6, statement->Records->Get(index)->Date._day, "{0}-" + Left(MonthName(thisMonth), 3))
        form.AddText(rowIndex, 12, 20, statement->Records->Get(index)->Name)
        form.AddCurrency(rowIndex, 36, statement->Records->Get(index)->Value)

        rowIndex = rowIndex + 1        
    Next

    ' Set selection to the text field
    If selectedItem = -1 Then
        form.AddNumeric(rowIndex, 4, 6, insertDay, "{0}-" + Left(MonthName(thisMonth), 3))
        form.AddText(rowIndex, 12, 20, "")
        form.AddCurrency(rowIndex, 36, 0)
        selectedItem = form.Count - 1
    End If
    form.EndSection(sectionName)
    form.selectedItem = selectedItem

    ' Show overspend balance
    rowIndex = rowIndex + 2
    form.AddLabel(rowIndex, 12, "Overspend")
    form.AddLabel(rowIndex, 36, 10, TAlign.Right, "")
    rowIndex = rowIndex + 2

    ' Show exit balance at the end
    form.AddLabel(rowIndex, 12, "Exit Balance")
    form.AddLabel(rowIndex, 36, 10, TAlign.Right, "")

    ' Start the editor
    Do

        ' Calculate the current total
        Dim total As Double = statement->EntryBalance
        Dim totalIndex As Integer = form.Count
        Dim overspendIndex As Integer = totalIndex - 2
        Dim overspend As Double

        For index = 1 to form.Count
            If form.Get(index)->FieldType = TFieldType.Currency Then
                Dim value As Double = CDbl(form.Get(index)->Value)

                total = total + value
            End If
        Next
        form.Get(totalIndex)->Value = Format(total, "0.00")

        ' Show overspend
        overspend = Abs(Max(0, statement->EntryBalance - total))
        form.Get(overspendIndex)->Value = Format(overspend, "0.00")

        ' Activate the picker
        result = form.DisplayForm()

        ' Insert a row?
        If result = TDisplayFormResult.Insert Then
            Dim insertIndex As Integer = form.SelectedItem

            ' Find the end of the current row
            While form.Get(insertIndex)->FieldType <> TFieldType.Currency
                insertIndex = insertIndex + 1
            Wend

            form.SelectedItem = insertIndex + 1
            rowIndex = form.Get(insertIndex)->Row + 1
            form.InsertNumeric(insertIndex + 1, rowIndex, 4, 6, TDate(Now())._day, "{0}-" + Left(MonthName(thisMonth), 3))
            form.InsertText(insertIndex + 2, rowIndex, 12, 20, "")
            form.InsertCurrency(insertIndex + 3, rowIndex, 36, 0)
            insertIndex = insertIndex + 4

            ' Adjust row positions of rest of form
            While insertIndex <= form.Count
                form.Get(insertIndex)->Row = form.Get(insertIndex)->Row + 1
                insertIndex = insertIndex + 1
            Wend
        End If

        ' Delete current row?
        If result = TDisplayFormResult.Deleted Then
            Dim deleteIndex As Integer = form.SelectedItem

            ' Find the start of the current row
            While form.Get(deleteIndex)->FieldType <> TFieldType.Numeric
                deleteIndex = deleteIndex - 1
            Wend

            ' Don't delete the last row
            If Not (form.Get(deleteIndex - 1)->IsSection And form.Get(deleteIndex + 3)->IsSection) Then

                ' Reset selection
                If form.Get(deleteIndex + 3)->IsSection Then form.SelectedItem = deleteIndex - 3
                form.DeleteField(deleteIndex)
                form.DeleteField(deleteIndex)
                form.DeleteField(deleteIndex)

                ' Adjust row positions of rest of form
                While deleteIndex <= form.Count
                    form.Get(deleteIndex)->Row = form.Get(deleteIndex)->Row - 1
                    deleteIndex = deleteIndex + 1
                Wend
            End If
        End If

        ' Print month to the default printer device

        If result = TDisplayFormResult.DoPrint Then
            Dim PrintFileNum As Integer = FreeFile        

            Open Lpt "LPT:" As #PrintFileNum
            Print #PrintFileNum, "Statement For " + Str(MonthName(thisMonth)) + " " + Str(thisYear)
            Print #PrintFileNum, ""
            Print #PrintFileNum, "Date      Description                   Amount"
            Print #PrintFileNum, "====      ===========                   ======"

            Print #PrintFileNum, "          Entry Balance             " + RightSet(Format(statement->EntryBalance, "0.00"), 10)
            Print #PrintFileNum, ""

            For index = 1 To statement->Records->Count
                Dim theDate As String = Str(statement->Records->Get(index)->Date._day) + " " + Left(MonthName(thisMonth), 3) 
                Dim dateField As String = Left(theDate + Space(10), 10)
                Dim nameField As String = Left(statement->Records->Get(index)->Name + Space(26), 26)
                Dim valueField As String = RightSet(Format(statement->Records->Get(index)->Value, "0.00"), 10)

                Print #PrintFileNum, dateField + nameField + valueField
            Next
            Print #PrintFileNum, ""
            Print #PrintFileNum, "          Overspend                 " + RightSet(Format(overspend, "0.00"), 10)
            Print #PrintFileNum, "          Exit Balance              " + RightSet(Format(total, "0.00"), 10)
            Close #PrintFileNum
        End If

        ' Cancel
        If result = TDisplayFormResult.Cancel Then
            If Not form.IsModified OrElse AskExit() Then
                Exit Do
            End If
        End If

    Loop Until result = TDisplayFormResult.Save

    ' Save the results
    if result = TDisplayFormResult.Save Then
        statement->Records = new TRecords()

        index = form.FindSection(sectionName)
        Do
            Dim theDay As Integer = CInt(form.Get(index)->Value)
            Dim theName As String = form.Get(index + 1)->Value
            Dim theValue As Double = CDbl(form.Get(index + 2)->Value)
            Dim theDate As TDate = TDate(thisYear, thisMonth, theDay)

            If theName <> "" Then
                statement->Records->Add(TRecord(theName, theValue, theDate))
            End If

            index = index + 3

        Loop Until form.Get(index)->IsSection

        account.SaveStatement(statement)
    End If
End Sub

