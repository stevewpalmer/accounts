#include "utils.bi"
#include "account.bi"
#include "vbcompat.bi"
#include "forms.bi"

' Display fixed incomings and outgoings

Sub ShowFixed(ByRef account as TAccount)
    Dim fixed As TRecords Ptr
    Dim index As Integer
    Dim form As TForm
    Dim rowIndex As Integer = 4
    Dim result As TDisplayFormResult

    Const sectionName As String = "Fixed"

    ShowTitle("Fixed Incomings and Outgoings")

    ' Display instructions line
    form.AddLabel(rowIndex, 4, "Enter name and amount of incoming and outgoings. Use negative values for outgoings.")
    form.AddLabel(rowIndex + 1, 4, "For the Day, enter the day of the month when the amount is debited or credited.")
    form.AddLabel(rowIndex + 3, 4, "Note: changes here only affect future months.")
    rowIndex = rowIndex + 5

    ' Show header
    form.AddLabel(rowIndex, 4, "_Description")
    form.AddLabel(rowIndex, 28, 10, TAlign.Right, "_Amount")
    form.AddLabel(rowIndex, 44, "_Day")
    rowIndex = rowIndex + 2

    ' Show current fixed records

    fixed = account.ReadFixed()
    form.BeginSection(sectionName)

    For index = 1 To fixed->Count
        form.AddText(rowIndex, 4, 20, fixed->Get(index)->Name)
        form.AddCurrency(rowIndex, 28, fixed->Get(index)->Value)
        form.AddNumeric(rowIndex, 44, 2, fixed->Get(index)->Date._day, "")
        rowIndex = rowIndex + 1        
    Next

    ' Add a blank row for new entries
    form.AddText(rowIndex, 4, 20, "")
    form.AddCurrency(rowIndex, 28, 0)
    form.AddNumeric(rowIndex, 44, 2, 1, "")
    form.EndSection(sectionName)
    rowIndex = rowIndex + 2

    ' Add a total row
    form.AddLabel(rowIndex, 4, "Total")
    form.AddLabel(rowIndex, 28, 10, TAlign.Right, "")

    ' Start the editor
    Do

        ' Calculate the current total
        Dim total As Single = 0
        Dim totalIndex As Integer = form.Count

        For index = 1 to form.Count
            If form.Get(index)->FieldType = TFieldType.Currency Then
                Dim value As Double = CDbl(form.Get(index)->Value)

                total = total + value
            End If
            If form.Get(index)->FieldType = TFieldType.Numeric Then
                Dim value As Integer = CInt(form.Get(index)->Value)

                If value < 1 Then value = 1
                If value > 31 Then value = 31
                form.Get(index)->Value = Str(value)
            End If
        Next
        form.Get(totalIndex)->Value = Format(total, "0.00")

        ' Activate the picker
        result = form.DisplayForm()

        ' Insert a row?
        If result = TDisplayFormResult.Insert Then
            Dim insertIndex As Integer = form.SelectedItem

            ' Find the end of the current row
            While form.Get(insertIndex)->FieldType <> TFieldType.Numeric
                insertIndex = insertIndex + 1
            Wend

            form.SelectedItem = insertIndex + 1
            rowIndex = form.Get(insertIndex)->Row + 1
            form.InsertText(insertIndex + 1, rowIndex, 4, 20, "")
            form.InsertCurrency(insertIndex + 2, rowIndex, 28, 0)
            form.InsertNumeric(insertIndex + 3, rowIndex, 40, 2, 1, "")
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
            While form.Get(deleteIndex)->FieldType <> TFieldType.Text
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

        ' Cancel
        If result = TDisplayFormResult.Cancel Then
            If Not form.IsModified OrElse AskExit() Then
                Exit Do
            End If
        End If

    Loop Until result = TDisplayFormResult.Save

    ' Save the results
    if result = TDisplayFormResult.Save Then
        fixed->Clear()

        index = form.FindSection(sectionName)
        Do
            Dim theName As String = form.Get(index)->Value
            Dim theValue As Double = CDbl(form.Get(index + 1)->Value)
            Dim theDate As TDate = TDate(2019, 1, CInt(form.Get(index + 2)->Value))

            If theName <> "" Then
                fixed->Add(TRecord(theName, theValue, theDate))
            End If

            index = index + 3

        Loop Until form.Get(index)->IsSection
        account.SaveFixed(fixed)
    End If
End Sub
