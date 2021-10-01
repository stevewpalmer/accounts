' A form field type

Enum TFieldType
    Text,
    Numeric,
    Label,
    Option,
    Currency,
    BeginSection,
    EndSection
End Enum

' A form field state

Enum TFieldState
    Original,
    Modified
End Enum

' Field alignment

Enum TAlign
    Left,
    Right
End Enum

' A single field in a form

Type TField
Private:
    _row As Integer
    _column As Integer
    _value As String
    _width As Integer
    _type As TFieldType
    _state As TFieldState
    _data As Object Ptr
    _align As TAlign
    _format As String
    _ch As String

    Declare Sub Init(As Integer, As Integer, As Integer, title As String)
    Declare Sub Init(As Integer, As Integer, As Integer, As TAlign, As String, As String, As TFieldType)

Public:
    Declare Constructor()
    Declare Constructor(As Integer, As Integer, As String)
    Declare Constructor(As Integer, As Integer, As Integer, As String, As TFieldType)
    Declare Constructor(As Integer, As Integer, As Integer, As String, As String, As TFieldType)
    Declare Constructor(As Integer, As Integer, As Integer, As TAlign, As String, As TFieldType)

    Declare Sub Draw(As String, As Integer, As Boolean, As Boolean)
    Declare Sub FormattedDraw(As Integer, As Boolean, As Boolean)

    Declare Property Row() As Integer
    Declare Property Row(ByRef newValue As Integer)
    Declare Property Column() As Integer
    Declare Property Width() As Integer
    Declare Property Value() As String
    Declare Property Value(ByRef newValue As String)
    Declare Property Align() As TAlign
    Declare Property State() As TFieldState
    Declare Property State(ByRef newState As TFieldState)
    Declare Property Data() As Object Ptr
    Declare Property Data(ByRef newData As Object Ptr)
    Declare Property FormatString() As String
    Declare Property FormatString(ByRef newFormat As String)
    Declare Property FieldType() As TFieldType
    Declare Property IsEditable() As Boolean
    Declare Property IsSelectable() As Boolean
    Declare Property IsSection() As Boolean
    Declare Property Ch() As String
    Declare Property Ch(ByRef newCh As String)
End Type

