#include "field.bi"

' Return value from DisplayForm

Enum TDisplayFormResult
    Pick,
    Cancel,
    Save,
    Insert,
    Deleted,
    DoPrint
End Enum

' A form

Type TForm
Private:
    _count As Integer
    _size As Integer
    _selectedItem As Integer
    _modified As Boolean
    _scrollOffset As Integer
    _fields(Any) As TField
    _caps As Integer

    Declare Sub Init(caps As Integer)
    Declare Sub DoCurrencyFieldChar(As String)
    Declare Sub DoTextFieldChar(As String)
    Declare Sub DoNumericFieldChar(As String)
    Declare Sub DrawForm()

Public:

    ' Form editing capability

    Const Simple = 1
    Const CanPrint = 2

    Declare Constructor()
    Declare Constructor(As Integer)
    Declare Sub Clear()
    Declare Sub Add(ByRef As TField)
    Declare Sub Insert(As Integer, ByRef As TField)
    Declare Sub DeleteField(deleteIndex As Integer)
    Declare Sub AddLabel(As Integer, As Integer, As String)
    Declare Sub AddLabel(As Integer, As Integer, As Integer, As String)
    Declare Sub AddLabel(As Integer, As Integer, As Integer, As TAlign, As String)
    Declare Sub AddOption(As Integer, As Integer, As String, As Object Ptr)
    Declare Sub AddOption(theRow As Integer, theColumn As Integer, theLabel As String, theCh As String)
    Declare Sub AddText(As Integer, As Integer, As Integer, As String)
    Declare Sub AddNumeric(As Integer, As Integer, As Integer, As Integer, As String)
    Declare Sub AddCurrency(As Integer, As Integer, As Double)
    Declare Sub AddCurrency(As Integer, As Integer, As TAlign, As Double, As String)
    Declare Sub InsertLabel(As Integer, As Integer, As Integer, As Integer, As String)
    Declare Sub InsertText(As Integer, As Integer, As Integer, As Integer, As String)
    Declare Sub InsertNumeric(As Integer, As Integer, As Integer, As Integer, As Integer, As String)
    Declare Sub InsertCurrency(As Integer, As Integer, As Integer, As Double)
    Declare Sub BeginSection(As String)
    Declare Sub EndSection(As String)
    Declare Function Get(As Integer) As TField Ptr
    Declare Property Count() As Integer
    Declare Property SelectedItem() As Integer
    Declare Property SelectedItem(ByRef newValue As Integer)
    Declare Property IsModified() As Boolean
    Declare Function DisplayForm() As TDisplayFormResult
    Declare Function FindSection(As String) As Integer
End Type

