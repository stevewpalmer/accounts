#include "constants.bi"
#include "utils.bi"
#include "forms.bi"
#include "menu.bi"
#include "account.bi"
#include "globals.bi"

Dim account As TAccount
Dim result As TDisplayFormResult
Dim selectedItem As Integer = 1
Dim ch As String

' Create the main menu.

Dim mainMenu(1 To 7) As TMenuItem
mainMenu(1) = TMenuItem.Make("C", "Current Month", "Display statement for the current Month")
mainMenu(2) = TMenuItem.Make("A", "Annual", "Show the annual summary")
mainMenu(3) = TMenuItem.Make("F", "Fixed", "Edit fixed income and outgoings")
mainMenu(4) = TMenuItem.Make("L", "Calendar", "Show the statements calendar")
mainMenu(5) = TMenuItem.Make("V", "Savings", "View and edit savings plans")
mainMenu(6) = TMenuItem.Make("S", "Search", "Search statements for payments")
mainMenu(7) = TMenuItem.Make("E", "Exit", "Exit the " + ProgramName + " program")

' Initialise

account.Init()
account.ReadAccounts()

' Main menu loop

Do
    Dim form As TForm = TForm(TForm.Simple)
    Dim menuStrings(1 To 6) As String
    Dim index As Integer

    ShowTitle("Main Menu")

    form.SelectedItem = selectedItem

    For index = 1 To UBound(mainMenu)
        Dim screenWidth As Integer = LoWord(Width())
        Dim itemString As String
        Dim rowIndex As Integer
        Dim columnIndex As Integer

        itemString = Left(" " + UCase(mainMenu(index).ch) + Space(6), 6)
        itemString = itemString + Left(" " + UCase(mainMenu(index).name) + Space(16), 16)
        itemString = itemString + Left(" -  " + mainMenu(index).title + Space(50), 50)

        ' Center in the screen
        rowIndex = 4 + (index * 2)
        columnIndex = (screenWidth - Len(itemString)) / 2
        
        form.AddOption(rowIndex, columnIndex, itemString, mainMenu(index).ch) 
    Next

    result = form.DisplayForm()
    selectedItem = form.SelectedItem

    If result = TDisplayFormResult.Pick Then
        ch = form.Get(form.SelectedItem)->Ch
        If ch = "C" Then CurrentMonth(account)
        If ch = "A" Then CurrentYear(account)
        If ch = "F" Then ShowFixed(account)
        If ch = "L" Then ShowCalendar(account)
        If ch = "V" Then Savings(account)
        If ch = "S" Then SearchStatements(account)
    End If

Loop Until ch = "E" Or result = TDisplayFormResult.Cancel
Cls

