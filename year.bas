#include "utils.bi"
#include "account.bi"
#include "vbcompat.bi"
#include "forms.bi"
#include "globals.bi"

' Display summary for the current year

Sub CurrentYear(ByRef account As TAccount)

    ShowYear(account, Year(Now()))
End Sub

' Display summary for the specified year

Sub ShowYear(ByRef account as TAccount, thisYear As Integer)
    Dim list() As TCategory
    Dim form As TForm = TForm(TForm.Simple + TForm.CanPrint)
    Dim rowIndex As Integer = 4
    Dim index As Integer
    Dim didSwap As Boolean
    Dim result As TDisplayFormResult

    ShowTitle("Summary for " + Str(thisYear))
    account.Categories(thisYear, list())

    ' Show explanation if the summary is for the current or future years
    If thisYear >= Year(Now()) Then
        form.AddLabel(rowIndex, 4, "The summary displayed is the projected expenditure for this year based")
        form.AddLabel(rowIndex + 1, 4, "on current fixed outgoings and incomes and statements to date.")
        rowIndex = rowIndex + 3
    End If

    ' Entry and exit balance for year
    form.AddLabel(rowIndex, 4, "Entry Balance for " + Str(thisYear))
    form.AddLabel(rowIndex, 30, 10, TAlign.Right, Format(account.Get(thisYear, 1)->EntryBalance, "0.00"))
    form.AddLabel(rowIndex + 1, 4, "Exit Balance for " + Str(thisYear))
    form.AddLabel(rowIndex + 1, 30, 10, TAlign.Right, Format(account.Get(thisYear, 12)->ExitBalance, "0.00"))
    rowIndex = rowIndex + 3

    ' Headers
    form.AddLabel(rowIndex, 4, "_Category")
    form.AddLabel(rowIndex, 30, 10, TAlign.Right, "_Total")
    rowIndex = rowIndex + 2

    ' Sort by name
    Do
        didSwap = false
        For index = 1 To UBound(list) - 1
            If UCase(list(index).Name) > UCase(list(index + 1).Name) Then
                Dim tempName As TCategory = list(index)
                list(index) = list(index + 1)
                list(index + 1) = tempName
                didSwap = true
            End If
        Next
    Loop Until Not didSwap

    ' Summary of expenses
    For index = 1 To UBound(list)
        form.AddLabel(rowIndex, 4, list(index).Name)
        form.AddLabel(rowIndex, 30, 10, TAlign.Right, Format(list(index).Value, "0.00"))
        rowIndex = rowIndex + 1
    Next

    Do
        result = Form.DisplayForm()

        ' Print the summary to the default print device

        If result = TDisplayFormResult.DoPrint Then
            Dim PrintFileNum As Integer = FreeFile        

            Open Lpt "LPT:" As #PrintFileNum
            Print #PrintFileNum, "Summary For " + Str(thisYear)
            Print #PrintFileNum, ""
            Print #PrintFileNum, "Entry Balance : " + Format(account.Get(thisYear, 1)->EntryBalance, "0.00")
            Print #PrintFileNum, "Exit Balance  : " + Format(account.Get(thisYear, 12)->ExitBalance, "0.00")
            Print #PrintFileNum, ""
            Print #PrintFileNum, "Category                       Total"
            Print #PrintFileNum, "========                       ====="
            For index = 1 To UBound(list)
                Dim nameField As String = Left(list(index).Name + Space(26), 26)
                Dim valueField As String = Right(Space(10) + Format(list(index).Value, "0.00"), 10)

                Print #PrintFileNum, nameField + valueField
            Next
            Close #PrintFileNum
        End If
    Loop Until result = TDisplayFormResult.Cancel
End Sub

