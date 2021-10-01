#include "constants.bi" 
#include "dir.bi"

Const None = -1
Const Black = 0
Const Yellow = 6
Const White = 7
Const BrightCyan = 11

' Globals

Common Shared ReverseColour As Integer 
Common Shared BackgroundColour As Integer
Common Shared ForegroundColour As Integer
Common Shared TitleColour As Integer

' Default colours which can be overridden in the
' configuration file.

ReverseColour = Yellow
BackgroundColour = Black
ForegroundColour = White
TitleColour = BrightCyan

Declare Sub PrintBar(As String)

' Return the program's folder path

Function ProgramFolder() As String
    Return Environ("HOME") + "/.accounts"
End Function

' Return the program's data folder path

Function DataFolder() As String
    Return ProgramFolder() + "/data"
End Function

' Show the program title, version and section name at the top of the
' screen

Sub ShowTitle(sectionName As String)
    Cls
    Locate 1,1,0
    PrintBar(UCase(ProgramName) + "     " + UCase(sectionName))
End Sub

' Show the footer

Sub ShowFooter(text As String)
    Dim As Integer screenHeight = HiWord(Width())

    Locate screenHeight,1,0
    PrintBar(text)
End Sub

' Ask whether to exit without saving

Function AskExit() As Boolean
    Dim As Integer screenHeight = HiWord(Width())

    Locate screenHeight,1,0
    PrintBar("Exit without saving? Are you sure? (Y/N)")
   
    Return UCase(Chr(GetKey())) = "Y" 
End Function

' Clear an area of the screen

Sub ScreenClear(topRow As Integer, leftColumn As Integer, bottomRow As Integer, rightColumn As Integer)
    Dim index As Integer

    For index = topRow to bottomRow
        Locate index, leftColumn
        Print Space(rightColumn - leftColumn)
    Next 
End Sub

' Display the specified text at the current cursor location in a coloured
' bar that extends the screen width

Private Sub PrintBar(barText As String)
    Dim screenWidth As Integer = LoWord(Width())
    Dim currentBg As Integer = Color() Shr 16
    Dim currentFg As Integer = Color() And &HFF
    
    Color BackgroundColour,ReverseColour
    Print " " + barText + Space(screenWidth - Len(barText) - 1);
    Color currentFg,currentBg
End Sub

' Check for existence of a directory

Function DirExists(dirName As String) As Boolean
    Dim attr As Integer
    Dim dirResult As String = Dir(dirName, fbDirectory, attr)

    If attr = fbDirectory Then return true else return false
End Function

' Return the max of two numbers

Function Max(first As Double, second As Double) As Double

    If first > second Then Return first Else Return second
End Function

' Sort an integer array

Sub SortArray(arrayToSort() As Integer)
    Dim index As Integer
    Dim didSwap As Boolean

    Do
        didSwap = false
        For index = LBound(arrayToSort) To UBound(arrayToSort) - 1
            If arrayToSort(index) > arrayToSort(index + 1) Then
                Dim tempValue As Integer = arrayToSort(index)
                arrayToSort(index) = arrayToSort(index + 1)
                arrayToSort(index + 1) = tempValue
                didSwap = true
            End If
        Next
    Loop Until Not didSwap
End Sub

'Replaces all substrings s2 in s1 by s3 and returns the changed string

Function ReplaceString(s1 As String, s2 As String, s3 As String) As String
   Dim As Integer i
   Dim As String s
   
   s = s1
   i = 0
   Do
      i = i + 1
      If Mid(s, i, Len(s2)) = s2 Then
         s = Left(s, i - 1) + s3 + Right(s, Len(s) - i - Len(s2) + 1)
         i = i + Len(s3) - 1
      End If
   Loop Until i >= Len(s)
   
   Return s
End Function

' Return a right-justified string

Function RightSet(ByRef s1 As String, theWidth As Integer) As String

    Return Right(Space(theWidth) + s1, theWidth)
End Function

