#include "category.bi"

' Default category constructor

Constructor TCategory()
End Constructor

' Constructor for a category with a name and a value

Constructor TCategory(theName As String, theValue as Double)
    
    This._name = theName
    This._value = theValue
End Constructor

' Return the category name

Property TCategory.Name() As String

    Return This._name
End Property

' Return the category value

Property TCategory.Value() As Double

    Return This._value
End Property

' Set a category value

Property TCategory.Value(ByRef newValue As Double)

    This._value = newValue
End Property
