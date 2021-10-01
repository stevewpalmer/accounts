#include "forms.bi"
#include "account.bi"
#include "utils.bi"

' Search statements for payments by name or value

Sub SearchStatements(ByRef account As TAccount)
    Dim form As TForm = TForm(TForm.Simple)
    Dim result as TDisplayFormResult
    Dim maxRowIndex As Integer

    ShowTitle("Search Statements")

    Do
        Dim searchText As String
        Dim searchFieldIndex As Integer
        Dim rowIndex As Integer = 4

        form.AddLabel(rowIndex, 4, "Enter payment or amount to search for:")
        form.AddText(rowIndex + 2, 4, 50, "")
        searchFieldIndex = form.Count

        form.SelectedItem = searchFieldIndex
        result = form.DisplayForm()
        If result = TDisplayFormResult.Pick Then

            ' Get the text to search for
            searchText = form.Get(searchFieldIndex)->Value
            searchText = Trim(searchText)

            If searchText <> "" Then
                Dim index As Integer
                Dim hasHeader As Boolean = False
                Dim total As Double = 0

                form.Clear()

                rowIndex = 8
                ScreenClear(rowIndex, 4, maxRowIndex, 80)
                For index = 1 To account.Count
                    Dim statement As TStatement Ptr = account.Get(index)
                    Dim recordIndex As Integer

                    For recordIndex = 1 To statement->Records->Count
                        Dim theName As String = statement->Records->Get(recordIndex)->Name
                        Dim theValue As Double = statement->Records->Get(recordIndex)->Value
                        Dim theDate As TDate = statement->Records->Get(recordIndex)->Date

                        If Instr(UCase(theName), UCase(searchText)) > 0 Or Str(theValue) = searchText Then
                            If Not hasHeader Then
                                form.AddLabel(rowIndex, 4, 6, TAlign.Left, "_Date")
                                form.AddLabel(rowIndex, 12, 20, TAlign.Left, "_Description")
                                form.AddLabel(rowIndex, 36, 10, TAlign.Right, "_Amount")
                                rowIndex = rowIndex + 2
                                hasHeader = true
                            End If                
        
                            form.AddLabel(rowIndex, 4, 6, TAlign.Left, Str(theDate._day) + "-" + Left(MonthName(statement->Month), 3))
                            form.AddLabel(rowIndex, 12, 20, TAlign.Left, theName)
                            form.AddLabel(rowIndex, 36, 10, TAlign.Right, Format(theValue, "0.00"))
                            rowIndex = rowIndex + 1

                            total = total + theValue
                        End If
                    Next
                Next

                ' Show total if we found any results
                If hasHeader Then
                    form.AddLabel(rowIndex + 1, 4, "_Total")
                    form.AddLabel(rowIndex + 1, 36, 10, TAlign.Right, Format(total, "0.00"))
                    rowIndex = rowIndex + 1
                Else
                    form.AddLabel(rowIndex, 4, "No results found for " + searchText)
                End If

                maxRowIndex = rowIndex
            End If

            ' Clear search field
            form.Get(searchFieldIndex)->Value = ""
        End If

    Loop Until result = TDisplayFormResult.Cancel
End Sub

