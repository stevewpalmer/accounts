#include "constants.bi"
#include "forms.bi"
#include "string.bi"
#include "utils.bi"
#include "config.bi"

' Default constructor for a TForm

Constructor TForm

    Init(0)
End Constructor

' Constructor for a TForm with capabilities

Constructor TForm(caps As Integer)

    Init(caps)
End Constructor

' Common initialiser for a TForm

Private Sub TForm.Init(caps As Integer)

    This._size = 0
    This._count = 0
    This._selectedItem = 1
    This._modified = false
    This._scrollOffset = 0
    This._caps = caps
End Sub

' Add a named section to the form

Sub TForm.BeginSection(sectionName As String)

    Add(TField(0, 0, 0, sectionName, TFieldType.BeginSection))
End Sub

' Mark the end of the named section

Sub TForm.EndSection(sectionName As String)

    Add(TField(0, 0, 0, sectionName, TFieldType.EndSection))
End Sub

' Add a static label field to the form

Sub TForm.AddLabel(theRow As Integer, theColumn As Integer, theLabel As String)

    Add(TField(theRow, theColumn, Len(theLabel), theLabel, TFieldType.Label))
End Sub

' Add a static label field to the form with a width and alignment

Sub TForm.AddLabel(theRow As Integer, theColumn As Integer, theWidth As Integer, theAlign As TAlign, theLabel As String)

    Add(TField(theRow, theColumn, theWidth, theAlign, theLabel, TFieldType.Label))
End Sub

' Add a text option field to the form

Sub TForm.AddOption(theRow As Integer, theColumn As Integer, theLabel As String, theData As Object Ptr)

    Dim newField As TField = TField(theRow, theColumn, Len(theLabel), theLabel, TFieldType.Option)
    newField.Data = theData
    Add(newField)
End Sub

' Add a text option field to the form

Sub TForm.AddOption(theRow As Integer, theColumn As Integer, theLabel As String, theCh As String)

    Dim newField As TField = TField(theRow, theColumn, Len(theLabel), theLabel, TFieldType.Option)
    newField.Ch = theCh
    Add(newField)
End Sub

' Add a text field to the form

Sub TForm.AddText(theRow As Integer, theColumn As Integer, theWidth As Integer, theLabel As String)

    Add(TField(theRow, theColumn, theWidth, theLabel, TFieldType.Text))
End Sub

' Add a currency field to the form

Sub TForm.AddCurrency(theRow As Integer, theColumn As Integer, theValue As Double)

    Add(TField(theRow, theColumn, 10, TAlign.Right, Format(theValue, "0.00"), TFieldType.Currency))
End Sub

' Add a numeric input field to the form

Sub TForm.AddNumeric(theRow As Integer, theColumn As Integer, theWidth As Integer, theValue As Integer, theFormat As String)

    Add(TField(theRow, theColumn, theWidth, Str(theValue), theFormat, TFieldType.Numeric))
End Sub

' Insert a label field into the form

Sub TForm.InsertLabel(insertIndex As Integer, theRow As Integer, theColumn As Integer, theWidth As Integer, theLabel As String)

    Insert(insertIndex, TField(theRow, theColumn, theWidth, theLabel, TFieldType.Label))
End Sub

' Insert a text field into the form

Sub TForm.InsertText(insertIndex As Integer, theRow As Integer, theColumn As Integer, theWidth As Integer, theLabel As String)

    Insert(insertIndex, TField(theRow, theColumn, theWidth, theLabel, TFieldType.Text))
End Sub

' Insert a currency field into the form

Sub TForm.InsertCurrency(insertIndex As Integer, theRow As Integer, theColumn As Integer, theValue As Double)

    Insert(insertIndex, TField(theRow, theColumn, 10, TAlign.Right, Format(theValue, "0.00"), TFieldType.Currency))
End Sub

' Insert a numeric input field into the form

Sub TForm.InsertNumeric(insertIndex As Integer, theRow As Integer, theColumn As Integer, theWidth As Integer, theValue As Integer, theFormat As String)

    Insert(insertIndex, TField(theRow, theColumn, theWidth, Str(theValue), theFormat, TFieldType.Numeric))
End Sub

' Clear the form

Sub TForm.Clear()

    _count = 0
End Sub

' Add a field to the array of fields on the form

Sub TForm.Add(ByRef item As TField)

    If _count = _size Then
        _size = _size + 10
        Redim Preserve _fields (1 To _size) As TField
    End If

    _count = _count + 1
    _fields(_count) = item
End Sub

' Insert a field at the specified index on the form

Sub TForm.Insert(insertIndex As Integer, ByRef item as TField)
    Dim index As Integer

    If insertIndex < 1 Then insertIndex = 1
    If insertIndex > _count Then insertIndex = _count

    If _count = _size Then
        _size = _size + 10
        Redim Preserve _fields (1 To _size) As TField
    End If

    _count = _count + 1
    For index = _count To insertIndex + 1 Step -1
        _fields(index) = _fields(index - 1)
    Next

    _fields(insertIndex) = item
End Sub

' Delete a field at the specified index

Sub TForm.DeleteField(deleteIndex As Integer)
    Dim index As Integer

    If deleteIndex < 1 Then deleteIndex = 1
    If deleteIndex > _count Then deleteIndex = _count

    For index = deleteIndex To _count - 1
        _fields(index) = _fields(index + 1)
    Next
    _count = _count - 1
End Sub

' Return count of fields on the form

Property TForm.Count() As Integer

    Return This._count
End Property

' Return the selection

Property TForm.SelectedItem() As Integer

    Return This._selectedItem
End Property

' Set the selection

Property TForm.SelectedItem(ByRef newValue As Integer)

    This._selectedItem = newValue
End Property

' Get a single field

Function TForm.Get(index As Integer) As TField Ptr

    Return @_fields(index)
End Function

' Find a section by name and return the index of the field
' immediately after that section

Function TForm.FindSection(sectionName As String) As Integer
    Dim index As Integer
    
    For index = 1 To Count
        If _fields(index).FieldType = TFieldType.BeginSection Then
            If _fields(index).Value = sectionName Then Return index + 1
        End If
    Next

    Return 0   ' Section not found
End Function

' Return whether the form has been edited

Property TForm.IsModified() As Boolean

    Return This._modified
End Property

' Draw the form at the current scroll offset

Private Sub TForm.DrawForm()
    Dim pageHeight As Integer = HiWord(Width()) - 2
    Dim pageWidth As Integer = Loword(Width())
    Dim firstRow As Integer
    Dim lastRow As Integer
    Dim itemIndex As Integer

    firstRow = _fields(1).Row
    lastRow = _fields(_count).Row + 1
    If lastRow > pageHeight Then lastRow = pageHeight
    If firstRow <= 4 Then firstRow = 3
    ScreenClear(firstRow, 0, lastRow, pageWidth)

    For itemIndex = 1 To _count
        Dim isSelected As Boolean = itemIndex = _selectedItem

        If _fields(itemIndex).Row + _scrollOffset > 3 And _fields(itemIndex).Row + _scrollOffset <= pageHeight Then
            If Not _fields(itemIndex).IsSection Then
                _fields(itemIndex).FormattedDraw(_scrollOffset, isSelected, false)
            End If
        End If
    Next
End Sub

' Display the form and allow user navigation over the fields
' using the cursor keys. Returns the index of the selected field when
' the Enter key is pressed.

Function TForm.DisplayForm() As TDisplayFormResult
    Dim pageHeight As Integer = HiWord(Width()) - 2
    Dim itemIndex As Integer
    Dim firstRow As Integer
    Dim lastRow As Integer
    Dim opt As Integer
    Dim selectable As Boolean = true
    Dim modified As Boolean = false
    Dim footer As String = ""
    Dim diff As Integer

    ' Adjust selection if necessary
    While CBool(_selectedItem <= _count) AndAlso Not _fields(_selectedItem).IsSelectable
        _selectedItem = _selectedItem + 1
    Wend

    ' If no selection, change form behaviour
    selectable = _selectedItem <= _count
    If Not _caps And TForm.Simple Then
        footer = "F2 - Insert row | F4 - Delete row | " 
    End If
    If _caps And TForm.CanPrint Then
        footer = footer + "F6 - Print | "
    End If
    If Not _caps And TForm.Simple Then
        footer = footer + "F10 - Save and Exit | "
    End If
    footer = footer + "Esc - Exit"
    ShowFooter(footer)

    ' Set the initial scroll offset so that the selected item is visible
    diff = _fields(_count).Row - pageHeight
    If selectable AndAlso _fields(_selectedItem).Row > pageHeight AndAlso diff > 0 Then
        _scrollOffset = -diff
    End If
    DrawForm()

    Do
        Dim previousSelectedIndex As Integer = _selectedItem

        opt = GetKey
        Select Case opt
            Case cEsc
                Return TDisplayFormResult.Cancel

            Case cKeyUp
                If selectable Then
                    Dim currentRow As Integer = _fields(_selectedItem).Row
                    Dim currentColumn As Integer = _fields(_selectedItem).Column
                    Dim newIndex As Integer = _selectedItem

                    While newIndex > 1 
                        newIndex = newIndex - 1
                        If _fields(newIndex).Row < currentRow And _fields(newIndex).Column <= currentColumn Then
                            If _fields(newIndex).IsSelectable Then
                                _selectedItem = newIndex
                                Exit While
                            End If
                        End If
                    Wend
                Elseif _fields(1).Row + _scrollOffset < 4 Then
                    _scrollOffset = _scrollOffset + 1
                    DrawForm()
                End If

            Case cKeyDown
                If selectable Then
                    Dim currentRow As Integer = _fields(_selectedItem).Row
                    Dim currentColumn As Integer = _fields(_selectedItem).Column
                    Dim newIndex As Integer = _selectedItem

                    While newIndex < _count
                        newIndex = newIndex + 1
                        If _fields(newIndex).Row > currentRow And _fields(newIndex).Column >= currentColumn Then
                            If _fields(newIndex).IsSelectable Then
                                _selectedItem = newIndex
                                Exit While
                            End If
                        End If
                    Wend
                ElseIf _fields(_count).Row + _scrollOffset >= pageHeight Then
                    _scrollOffset = _scrollOffset - 1
                    DrawForm()
                End IF

            Case cKeyRight, cTab
                If selectable And CBool(_selectedItem < _count) Then
                    Dim newIndex As Integer = _selectedItem
                    
                    While newIndex < _count
                        newIndex = newIndex + 1
                        If _fields(newIndex).IsSelectable Then
                            _selectedItem = newIndex
                            Exit While
                        End If
                    Wend
                End If

            Case cKeyLeft
                If selectable And CBool(_selectedItem > 1) Then
                    Dim newIndex As Integer = _selectedItem
                    
                    While newIndex > 1
                        newIndex = newIndex - 1
                        If _fields(newIndex).IsSelectable Then
                            _selectedItem = newIndex
                            Exit While
                        End If
                    Wend
                End If

            Case cF2
                If Not _caps And TForm.Simple Then Return TDisplayFormResult.Insert

            Case cF4
                If Not _caps And TForm.Simple Then Return TDisplayFormResult.Deleted

            Case cF6
                If _caps And TForm.CanPrint Then Return TDisplayFormResult.DoPrint

            Case cF10
                If Not _caps And TForm.Simple Then Return TDisplayFormResult.Save

            Case cBackspace
                If selectable Then
                    If _fields(_selectedItem).IsEditable Then
                        Dim value As String = _fields(_selectedItem).Value

                        If Len(value) > 0 Then
                            value = Left(value, Len(value) - 1)
                            _fields(_selectedItem).Value = value
                            _fields(_selectedItem).State = TFieldState.Modified
                            _fields(_selectedItem).Draw(Value, _scrollOffset, true, True)
                        End If
                    End If
                End If

            Case Else
                If selectable Then
                    If _fields(_selectedItem).IsEditable Then
                        If _fields(_selectedItem).FieldType = TFieldType.Currency Then
                            DoCurrencyFieldChar(Chr(opt))
                        End If
                        If _fields(_selectedItem).FieldType = TFieldType.Text Then
                            DoTextFieldChar(Chr(opt))
                        End If
                        If _fields(_selectedItem).FieldType = TFieldType.Numeric Then
                            DoNumericFieldChar(Chr(opt))
                        End If
                        modified = _modified
                    Else
                        Dim optIndex As Integer = 1

                        ' Possible picker character for an option field?
                        For optIndex = 1 To _count
                            If UCase(Chr(opt)) = UCase(_fields(optIndex).Ch) Then
                               _selectedItem = optIndex
                               opt = crEnter
                               Exit For
                            End If
                        Next
                    End If
                End If

        End Select
        If selectable Then 
            If _selectedItem <> previousSelectedIndex Then
                Dim showCursor As Boolean = _fields(_selectedItem).IsEditable
                Dim diff As Integer = _fields(_selectedItem).Row + _scrollOffset

                ' Do we need to scroll?
                If diff < 4 Or diff > pageHeight Then
                    If  _fields(_count).Row + _scrollOffset > pageHeight Then
                        _scrollOffset = pageHeight - _fields(_count).Row
                        DrawForm()
                    ElseIf _fields(1).Row + _scrollOffset < 4 Then
                        _scrollOffset = 4 - _fields(1).Row
                        DrawForm()
                    End If
                End If
                If _fields(previousSelectedIndex).IsEditable Then
                    _fields(previousSelectedIndex).State = TFieldState.Original
                End If
                _fields(previousSelectedIndex).FormattedDraw(_scrollOffset, false, false)
                If _fields(_selectedItem).FieldType = TFieldType.Currency Then
                    Dim value As Double = CDbl(_fields(_selectedItem).Value)

                    _fields(_selectedItem).Value = Format(value, "0.00")
                End If
                _fields(_selectedItem).FormattedDraw(_scrollOffset, true, showCursor)
            End If
        End If
    Loop Until opt = crEnter

    ' Redraw the selected cell before we exit
    _fields(_selectedItem).FormattedDraw(_scrollOffset, true, false)
    Return TDisplayFormResult.Pick 
End Function

' Handle editing in a currency field

Sub TForm.DoCurrencyFieldChar(theChar As String)

    If theChar >= "0" And theChar <= "9" Or theChar = "." Or theChar = "-" Or theChar = "+" Then
        Dim canEdit As Boolean = true
        Dim value As String = _fields(_selectedItem).Value

        If _fields(_selectedItem).State = TFieldState.Original Then value = ""

        Dim decimalPosition As Integer = Instr(value, ".")

        If Len(value) = _fields(_selectedItem).Width Then canEdit = false
        If theChar = "." And (decimalPosition <> 0 Or Len(value) = 0) Then canEdit = false
        If theChar = "-" And value <> "" Then canEdit = false
        If theChar = "+" And value <> "" Then canEdit = false
        If theChar >= "0" And theChar <= "9" And (decimalPosition > 0 And Len(Mid(value, decimalPosition)) = 3) Then canEdit = false

        If canEdit Then
            value = value + theChar
            _fields(_selectedItem).Value = value
            _fields(_selectedItem).State = TFieldState.Modified
            _fields(_selectedItem).Draw(value, _scrollOffset, true, True)

            _modified = true
        End If
    End If
End Sub

' Handle editing in a text field

Sub TForm.DoTextFieldChar(theChar As String)

    If theChar >= " " And theChar <= "z" Then
        Dim value As String = _fields(_selectedItem).Value

        If _fields(_selectedItem).State = TFieldState.Original Then value = ""

        If Len(value) < _fields(_selectedItem).Width Then
            value = value + theChar
            _fields(_selectedItem).Value = value
            _fields(_selectedItem).State = TFieldState.Modified
            _fields(_selectedItem).Draw(value, _scrollOffset, true, True)

            _modified = true
        End If
    End If
End Sub

' Handle editing in a numeric field

Sub TForm.DoNumericFieldChar(theChar As String)

    If theChar = "-" Or theChar >= "0" And theChar <= "9" Then
        Dim value As String = _fields(_selectedItem).Value

        If _fields(_selectedItem).State = TFieldState.Original Then value = ""

        If Len(value) < _fields(_selectedItem).Width Then
            value = value + theChar
            _fields(_selectedItem).Value = value
            _fields(_selectedItem).State = TFieldState.Modified
            _fields(_selectedItem).Draw(value, _scrollOffset, true, True)

            _modified = true
        End If
    End If
End Sub

