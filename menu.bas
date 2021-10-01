#include "menu.bi"

' Create a new TMenuItem from the given values

Function TMenuItem.Make(newCh As String, newName As String, newTitle As String) As TMenuItem
    Dim newMenu As TMenuItem
    newMenu.ch = newCh
    newMenu.name = newName
    newMenu.title = newTitle
    Return newMenu
End Function

