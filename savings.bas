#include "utils.bi"
#include "account.bi"
#include "vbcompat.bi"
#include "forms.bi"
#include "globals.bi"

' Display savings plan

Sub Savings(ByRef account as TAccount)
    Dim form As TForm = TForm(TForm.Simple + TForm.CanPrint)
    Dim rowIndex As Integer = 4
    Dim result As TDisplayFormResult
    Dim records As TRecords Ptr
    Dim index As Integer

    Const sectionName = "Savings"

    ShowTitle("Savings Plan")

    ' Headers
    form.AddLabel(rowIndex, 4, "_Description")
    form.AddLabel(rowIndex, 30, 10, TAlign.Right, "_Growth")
    rowIndex = rowIndex + 2

    ' Add existing savings
    records = account.ReadSavings()

    ' Fill out
    form.BeginSection(sectionName)

    For index = 1 To records->Count
        form.AddText(rowIndex, 4, 20, records->Get(index)->Name)
        form.AddCurrency(rowIndex, 30, records->Get(index)->Value)
        rowIndex = rowIndex + 1        
    Next

    ' Add a blank row for new entries
    form.AddText(rowIndex, 4, 20, "")
    form.AddCurrency(rowIndex, 30, 0)
    form.EndSection(sectionName)
    rowIndex = rowIndex + 2

    Do
        result = Form.DisplayForm()

    Loop Until result = TDisplayFormResult.Cancel
End Sub

