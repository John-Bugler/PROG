Attribute VB_Name = "Statistiky2"
Sub Stat()
    Dim ws As Worksheet
    Dim activeTable As ListObject
    Dim outputTableName As String
    Dim startRow As Integer, startCol As Integer
    Dim i As Integer
    Dim pole_ukazatelu As Variant
    Dim ukazatelColumn As Range
    Dim timestamp As String
    Dim characteristics() As Variant
    Dim activeRange As Range
    Dim dataRange As Range
    Dim poloha_vystupni_tabulky As Range
    Dim stdevCol, varCol As Integer
    
    Dim colCount As Integer
    
    ' Z�sk�n� aktu�ln�ho listu
    Set ws = ActiveSheet
    
    ' Z�sk�n� tabulky, kter� obsahuje aktivn� bu�ku
    If ws.ListObjects.Count > 0 Then
        ' Projde v�echny tabulky na listu
        For Each activeTable In ws.ListObjects
            ' Zkontroluje, zda aktivn� bu�ka je na tomto listu a je v rozsahu tabulky
            If Not Intersect(activeTable.Range, ActiveCell) Is Nothing Then
                ' Ulo�en� rozsahu tabulky, kter� obsahuje aktivn� bu�ku
                Set activeRange = activeTable.Range
                Exit For
            End If
        Next activeTable
    End If
    
    ' Kontrola, zda byla nalezena tabulka obsahuj�c� aktivn� bu�ku
    If activeRange Is Nothing Then
        MsgBox "Aktivn� bu�ka nen� sou��st� ��dn� tabulky!", vbCritical
        Exit Sub
    End If
    
    ' V�zva k v�b�ru polohy lev�ho horn�ho rohu v�stupn� tabulky
    On Error Resume Next
    Set poloha_vystupni_tabulky = Application.InputBox("Vyberte lev� horn� roh tabulky, kam budou um�st�ny v�sledky:", Type:=8)
    On Error GoTo 0
    
    ' Kontrola, zda byla zad�na platn� poloha
    If poloha_vystupni_tabulky Is Nothing Then
        MsgBox "Nen� vybr�na ��dn� bu�ka pro um�st�n� tabulky!", vbCritical
        Exit Sub
    End If
    
    ' Generov�n� n�zvu tabulky s timestampem
    timestamp = Format(Now(), "yyyymmdd_hhmm")
    outputTableName = "stat_" & timestamp
    
    ' Ur�en� v�stupn� polohy
    startRow = poloha_vystupni_tabulky.Row
    startCol = poloha_vystupni_tabulky.Column
    
    ' Definov�n� popisn�ch charakteristik, kter� budou ve sloupc�ch
    characteristics = Array("Pr�m�r", "Minimum", "1. Kvartil", "Medi�n", "3. Kvartil", "Maximum", "Sm�rodatn� odchylka", "Rozptyl")
    
    ' Vytvo�en� hlavi�ek pro v�stupn� tabulku
    ws.Cells(startRow, startCol).Value = "Ukazatel"
    For i = LBound(characteristics) To UBound(characteristics)
        ws.Cells(startRow, startCol + i + 1).Value = characteristics(i)
    Next i
    
    ' Nastaven� ukazatel� pro v�po�ty charakteristik
    pole_ukazatelu = Array("Datum pod�n�", "Cenov� �daj", "JC [K�/m2]", "Plocha [m2]")
    
    ' Pro ka�d� ukazatel prov�st v�po�et charakteristik
    For i = LBound(pole_ukazatelu) To UBound(pole_ukazatelu)
        ' Naj�t sloupec s odpov�daj�c�m ukazatelem ve vstupn� tabulce
        On Error Resume Next
        Set ukazatelColumn = activeRange.Rows(1).Find(pole_ukazatelu(i), LookIn:=xlValues, LookAt:=xlWhole).EntireColumn
        On Error GoTo 0
        
        If Not ukazatelColumn Is Nothing Then
            ' Z�skat hodnoty ve sloupci (bez hlavi�ky)
            Set dataRange = ukazatelColumn.Resize(ukazatelColumn.Rows.Count - 1).Offset(1)
            
            ' Zapsat n�zev ukazatele do v�stupn� tabulky
            ws.Cells(startRow + i + 1, startCol).Value = pole_ukazatelu(i)
            
            ' V�po�ty charakteristik
            ws.Cells(startRow + i + 1, startCol + 1).Value = WorksheetFunction.Average(dataRange) ' Pr�m�r
            ws.Cells(startRow + i + 1, startCol + 2).Value = WorksheetFunction.Min(dataRange) ' Minimum
            ws.Cells(startRow + i + 1, startCol + 3).Value = WorksheetFunction.Percentile(dataRange, 0.25) ' 1. Kvartil
            ws.Cells(startRow + i + 1, startCol + 4).Value = WorksheetFunction.Median(dataRange) ' Medi�n
            ws.Cells(startRow + i + 1, startCol + 5).Value = WorksheetFunction.Percentile(dataRange, 0.75) ' 3. Kvartil
            ws.Cells(startRow + i + 1, startCol + 6).Value = WorksheetFunction.Max(dataRange) ' Maximum
            ws.Cells(startRow + i + 1, startCol + 7).Value = WorksheetFunction.StDev(dataRange) ' Sm�rodatn� odchylka
            ws.Cells(startRow + i + 1, startCol + 8).Value = WorksheetFunction.Var(dataRange) ' Rozptyl
            
            
            ' Ur�en� po�tu sloupc� v tabulce charakteristik
            colCount = UBound(characteristics) + 1
            
            ' Naj�t sloupec pro sm�rodatnou odchylku
            For j = 1 To colCount
                If ws.Cells(startRow, startCol + j).Value = "Sm�rodatn� odchylka" Then
                    stdevCol = startCol + j
                    Exit For
                End If
            Next j
            
            ' Naj�t sloupec pro rozptyl
            For j = 1 To colCount
                If ws.Cells(startRow, startCol + j).Value = "Rozptyl" Then
                    varCol = startCol + j
                    Exit For
                End If
            Next j
            
            
            ' Form�tov�n� bun�k na z�klad� typu ukazatele
            Select Case pole_ukazatelu(i)
                Case "Datum pod�n�"
                    For j = startCol + 1 To colCount + startCol
                        If j <> stdevCol Or j <> varCol Then
                            ws.Cells(startRow + i + 1, j).NumberFormat = "dd.mm.yyyy" ' Form�t datumu
                        End If
                    Next j
                Case "Cenov� �daj", "JC [K�/m2]"
                    For j = startCol + 1 To colCount + startCol
                        If j <> stdevCol Or j <> varCol Then
                            ws.Cells(startRow + i + 1, j).NumberFormat = "#,##0" ' Cena s odd�len�mi tis�ci
                        End If
                    Next j
                Case "Plocha [m2]"
                    For j = startCol + 1 To colCount + startCol
                        If j <> stdevCol Or j <> varCol Then
                            ws.Cells(startRow + i + 1, j).NumberFormat = "#,##0.00" ' Plocha s 2 desetinn�mi m�sty
                        End If
                    Next j
            End Select
            
            ' Nastaven� form�tu pro sm�rodatnou odchylku a rozptyl
            ws.Cells(startRow + i + 1, stdevCol).NumberFormat = "#,##0.0" ' Form�t ��sla pro sm�rodatnou odchylku
            ws.Cells(startRow + i + 1, varCol).NumberFormat = "#,##0.0" ' Form�t ��sla pro rozptyl
          
        End If
    Next i
    
    ' Nastaven� form�tov�n� pro v�stupn� tabulku
    ws.ListObjects.Add(xlSrcRange, ws.Range(ws.Cells(startRow, startCol), ws.Cells(startRow + UBound(pole_ukazatelu) + 1, startCol + UBound(characteristics) + 1)), , xlYes).Name = outputTableName
    
    MsgBox "Statistick� tabulka '" & outputTableName & "' byla �sp�n� vytvo�ena.", vbInformation
End Sub

















'' Obecn� procedura ktet� na z�klad� vstupn�ch parametr� vytvo�� tabulku se statistick�mi charakteristikami zdrojov�ch dat / zdrojov� tabulky
'
'Sub Stat()
'    Dim ws As Worksheet
'    Dim activeTable As ListObject
'    Dim outputTableName As String
'    Dim startRow As Integer, startCol As Integer
'    Dim i As Integer
'    Dim pole_ukazatelu As Variant
'    Dim ukazatelColumn As Range
'    Dim timestamp As String
'    Dim characteristics() As Variant
'    Dim activeRange As Range
'    Dim dataRange As Range
'    Dim poloha_vystupni_tabulky As Range
'
'    ' Z�sk�n� aktu�ln�ho listu
'    Set ws = ActiveSheet
'
'    ' Z�sk�n� tabulky, kter� obsahuje aktivn� bu�ku
'    If ws.ListObjects.Count > 0 Then
'        ' Projde v�echny tabulky na listu
'        For Each activeTable In ws.ListObjects
'            ' Zkontroluje, zda aktivn� bu�ka je na tomto listu a je v rozsahu tabulky
'            If Not Intersect(activeTable.Range, ActiveCell) Is Nothing Then
'                ' Ulo�en� rozsahu tabulky, kter� obsahuje aktivn� bu�ku
'                Set activeRange = activeTable.Range
'                Exit For
'            End If
'        Next activeTable
'    End If
'
'    ' Kontrola, zda byla nalezena tabulka obsahuj�c� aktivn� bu�ku
'    If activeRange Is Nothing Then
'        MsgBox "Aktivn� bu�ka nen� sou��st� ��dn� tabulky!", vbCritical
'        Exit Sub
'    End If
'
'    ' V�zva k v�b�ru polohy lev�ho horn�ho rohu v�stupn� tabulky
'    On Error Resume Next
'    Set poloha_vystupni_tabulky = Application.InputBox("Vyberte lev� horn� roh tabulky, kam budou um�st�ny v�sledky:", Type:=8)
'    On Error GoTo 0
'
'    ' Kontrola, zda byla zad�na platn� poloha
'    If poloha_vystupni_tabulky Is Nothing Then
'        MsgBox "Nen� vybr�na ��dn� bu�ka pro um�st�n� tabulky!", vbCritical
'        Exit Sub
'    End If
'
'    ' Generov�n� n�zvu tabulky s timestampem
'    timestamp = Format(Now(), "yyyymmdd_hhmm")
'    outputTableName = "stat_" & timestamp
'
'    ' Ur�en� v�stupn� polohy
'    startRow = poloha_vystupni_tabulky.Row
'    startCol = poloha_vystupni_tabulky.Column
'
'    ' Definov�n� popisn�ch charakteristik, kter� budou ve sloupc�ch
'    characteristics = Array("Pr�m�r", "Minimum", "1. Kvartil", "Medi�n", "3. Kvartil", "Maximum", "Sm�rodatn� odchylka")
'
'    ' Vytvo�en� hlavi�ek pro v�stupn� tabulku
'    ws.Cells(startRow, startCol).Value = "Ukazatel"
'    For i = LBound(characteristics) To UBound(characteristics)
'        ws.Cells(startRow, startCol + i + 1).Value = characteristics(i)
'    Next i
'
'
'    ' Nastaven� ukazatel� pro v�po�ty charakteristik
'    pole_ukazatelu = Array("Datum pod�n�", "Cenov� �daj", "JC [K�/m2]", "Plocha [m2]")
'
'
'    ' Pro ka�d� ukazatel prov�st v�po�et charakteristik
'    For i = LBound(pole_ukazatelu) To UBound(pole_ukazatelu)
'        ' Naj�t sloupec s odpov�daj�c�m ukazatelem ve vstupn� tabulce
'        On Error Resume Next
'        Set ukazatelColumn = activeRange.Rows(1).Find(pole_ukazatelu(i), LookIn:=xlValues, LookAt:=xlWhole).EntireColumn
'        On Error GoTo 0
'
'        If Not ukazatelColumn Is Nothing Then
'            ' Z�skat hodnoty ve sloupci (bez hlavi�ky)
'            Set dataRange = ukazatelColumn.Resize(ukazatelColumn.Rows.Count - 1).Offset(1)
'
'            ' Zapsat n�zev ukazatele do v�stupn� tabulky
'            ws.Cells(startRow + i + 1, startCol).Value = pole_ukazatelu(i)
'
'            ' V�po�ty charakteristik
'            ws.Cells(startRow + i + 1, startCol + 1).Value = WorksheetFunction.Average(dataRange) ' Pr�m�r
'            ws.Cells(startRow + i + 1, startCol + 2).Value = WorksheetFunction.Min(dataRange) ' Minimum
'            ws.Cells(startRow + i + 1, startCol + 3).Value = WorksheetFunction.Percentile(dataRange, 0.25) ' 1. Kvartil
'            ws.Cells(startRow + i + 1, startCol + 4).Value = WorksheetFunction.Median(dataRange) ' Medi�n
'            ws.Cells(startRow + i + 1, startCol + 5).Value = WorksheetFunction.Percentile(dataRange, 0.75) ' 3. Kvartil
'            ws.Cells(startRow + i + 1, startCol + 6).Value = WorksheetFunction.Max(dataRange) ' Maximum
'            ws.Cells(startRow + i + 1, startCol + 7).Value = WorksheetFunction.StDev(dataRange) ' Sm�rodatn� odchylka
'        End If
'    Next i
'
'    ' Nastaven� form�tov�n� pro v�stupn� tabulku
'    ws.ListObjects.Add(xlSrcRange, ws.Range(ws.Cells(startRow, startCol), ws.Cells(startRow + UBound(pole_ukazatelu) + 1, startCol + UBound(characteristics) + 1)), , xlYes).Name = outputTableName
'
'    MsgBox "Statistick� tabulka '" & outputTableName & "' byla �sp�n� vytvo�ena.", vbInformation
'End Sub
'

