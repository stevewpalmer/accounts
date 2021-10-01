#include "utils.bi"
#include "account.bi"
#include "vbcompat.bi"
#include "forms.bi"
#include "globals.bi"

' Display calendar of accounts

Sub ShowCalendar(account As TAccount)
    Dim result As TDisplayFormResult
    Dim selectedItem As Integer = 1

    Do
        Dim form As TForm = TForm(TForm.Simple)
        Dim years() As Integer
        Dim yearIndex As Integer
        Dim rowIndex As Integer = 4

        ShowTitle("Calendar")

        ' Display instructions line
        form.AddLabel(rowIndex, 4, "_Choose a year to see the summary for that year. Choose a month to")
        form.AddLabel(rowIndex + 1, 4, "_view and edit the accounts for that month.")
        rowIndex = rowIndex + 3

        account.ListYears(years())

        For yearIndex = LBound(years) To UBound(years)
            Dim monthIndex As Integer
            Dim columnIndex As Integer = 5
            Dim obj As Object Ptr = Cast(Object Ptr, new TDate(years(yearIndex), 0, 0))

            form.AddOption(rowIndex, columnIndex, Str(years(yearIndex)), obj)

            For monthIndex = 1 To 12
                Dim title As String = MonthName(monthIndex)
                Dim As Integer screenWidth = LoWord(Width())

                ' Handle wrapping
                If columnIndex + Len(title) + 2 > screenWidth Then
                    columnIndex = 5
                    rowIndex = rowIndex + 1
                End If

                obj = Cast(Object Ptr, new TDate(years(yearIndex), monthIndex, 0))
                form.AddOption(rowIndex + 2, columnIndex, title, obj)

                columnIndex = columnIndex + Len(title) + 2
            Next

            rowIndex = rowIndex + 4
        Next
        
        form.SelectedItem = selectedItem

        result = form.DisplayForm()

        If result = TDisplayFormResult.Pick Then
            Dim selectedDate As TDate Ptr

            selectedItem = form.SelectedItem
            selectedDate = Cast(TDate Ptr, form.Get(selectedItem)->Data)
            If selectedDate->_month > 0 Then
                ShowMonth(account, selectedDate->_year, selectedDate->_month)
            Else
                ShowYear(account, selectedDate->_year)
            End If
        End If
    Loop Until result = TDisplayFormResult.Cancel
End Sub


