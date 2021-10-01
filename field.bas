#include "forms.bi"
#include "string.bi"
#include "utils.bi"
#include "config.bi"

' Default constructor for a TField with all
' uninitialised items.

Constructor TField

    Init(1, 1, 10, TAlign.Left, "", "", TFieldType.Text)
End Constructor

' Constructor for a TField initialised with the specified
' field data.

Constructor TField(theRow As Integer, theColumn As Integer, theValue As String)

    Init(theRow, theColumn, Len(theValue), TAlign.Left, theValue, "", TFieldType.Text)
End Constructor

' Constructor for a TField initialised with the specified
' field data and type.

Constructor TField(theRow As Integer, theColumn As Integer, theWidth As Integer, theValue As String, theType As TFieldType)

    Init(theRow, theColumn, theWidth, TAlign.Left, theValue, "", theType)
End Constructor

' Constructor for a TField initialised with the specified
' field data, format and type.

Constructor TField(theRow As Integer, theColumn As Integer, theWidth As Integer, theValue As String, theFormat As String, theType As TFieldType)

    Init(theRow, theColumn, theWidth, TAlign.Left, theValue, theFormat, theType)
End Constructor

' Constructor for a TField initialised with the specified
' field alignment, data and type.

Constructor TField(theRow As Integer, theColumn As Integer, theWidth As Integer, theAlign As TAlign, theValue As String, theType As TFieldType)

    Init(theRow, theColumn, theWidth, theAlign, theValue, "", theType)
End Constructor

' Common initialisation method

Private Sub TField.Init(theRow As Integer, theColumn As Integer, theWidth As Integer, theAlign As TAlign, theValue As String, theFormat As String, theType As TFieldType)

    This._row = theRow
    This._column = theColumn
    This._width = theWidth
    This._value = theValue
    This._type = theType
    This._state = TFieldState.Original
    This._data = 0
    This._align = theAlign
    This._format = theFormat
End Sub

' Return the row property

Property TField.Row() As Integer

    Return This._row
End Property

' Set the row property

Property TField.Row(ByRef newValue As Integer)

    This._row = newValue
End Property

' Return the column property

Property TField.Column() As Integer

    Return This._column
End Property

' Return the width property

Property TField.Width() As Integer

    Return This._width
End Property

' Return the align property

Property TField.Align() As TAlign

    Return This._align
End Property

' Return the type property

Property TField.FieldType() As TFieldType

    Return This._type
End Property

' Return the option character

Property TField.Ch() As String

    Return This._ch
End Property

' Set the option character

Property TField.Ch(ByRef newCh As String)

    This._ch = newCh
End Property

' Return whether this field is a modifiable type field
' where the user can edit the contents

Property TField.IsEditable() As Boolean

    Return This._type = TFieldType.Currency Or This._type = TFieldType.Text Or This._type = TFieldType.Numeric
End Property

' Return whether this field is a selectable type

Property TField.IsSelectable() As Boolean

    Return IsEditable Or CBool(This._type = TFieldType.Option)
End Property

' Return whether this field is a section marker

Property TField.IsSection() As Boolean

    Return This._type = TFieldType.BeginSection Or This._type = TFieldType.EndSection
End Property

' Return the field state

Property TField.State() As TFieldState

    Return This._state
End Property

' Set the state property

Property TField.State(ByRef newState As TFieldState)

    This._state = newState
End Property

' Return the value property

Property TField.Value() As String

    Return This._value
End Property

' Set the value property

Property TField.Value(ByRef newValue As String)

    This._value = newValue
End Property

' Return the data property

Property TField.Data() As Object Ptr

    Return This._data
End Property

' Set the data property

Property TField.Data(ByRef newData As Object Ptr)

    This._data = newData
End Property

' Return the format string

Property TField.FormatString() As String

    Return This._format
End Property

' Set a new format string

Property TField.FormatString(ByRef newFormat As String)

    This._format = newFormat
End Property

' Do a formatted draw of a single field in either selected
' or unselected style as specified

Sub TField.FormattedDraw(offset As Integer, isSelected As Boolean, showCursor As Boolean)
    Dim text As String = Value

    If FieldType = TFieldType.Currency Then
        Dim thisValue As Double = CDbl(Value)

        Value = Format(thisValue, "0.00")
    End If
    If FormatString <> "" Then
        text = ReplaceString(FormatString, "{0}", Value)
    End If
    Draw(text, offset, isSelected, showCursor)
End Sub

' Draw a single field in either selected or unselected
' style as specified

Sub TField.Draw(formattedText As String, offset As Integer, isSelected As Boolean, showCursor As Boolean)
    Dim fgColour As Integer = ForegroundColour
    Dim cursorColumn As Integer
    Dim currentBg As Integer = Color() Shr 16
    Dim currentFg As Integer = Color() And &HFF

    If Left(formattedText, 1) = "_" Then
        formattedText = Mid(formattedText, 2)
        fgColour = TitleColour
    End If

    formattedText = " " + formattedText + " "

    If isSelected Then Color BackgroundColour,ReverseColour Else Color fgColour,BackgroundColour
    Locate Row + offset, Column, 0

    Select Case Align
        Case TAlign.Right
            Print Right(Space(Width) + formattedText, Width + 2)
            cursorColumn = Column + Width + 1

        Case TAlign.Left
            Print Left(formattedText + Space(Width), Width + 2)
            cursorColumn = Column + Len(_value) + 1
    End Select

    If showCursor Then
        Locate Row + offset, cursorColumn, 1
    End If
    Color currentFg, currentBg
End Sub

