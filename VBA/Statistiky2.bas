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
    
    ' Získání aktuálního listu
    Set ws = ActiveSheet
    
    ' Získání tabulky, která obsahuje aktivní buòku
    If ws.ListObjects.Count > 0 Then
        ' Projde všechny tabulky na listu
        For Each activeTable In ws.ListObjects
            ' Zkontroluje, zda aktivní buòka je na tomto listu a je v rozsahu tabulky
            If Not Intersect(activeTable.Range, ActiveCell) Is Nothing Then
                ' Uložení rozsahu tabulky, která obsahuje aktivní buòku
                Set activeRange = activeTable.Range
                Exit For
            End If
        Next activeTable
    End If
    
    ' Kontrola, zda byla nalezena tabulka obsahující aktivní buòku
    If activeRange Is Nothing Then
        MsgBox "Aktivní buòka není souèástí žádné tabulky!", vbCritical
        Exit Sub
    End If
    
    ' Výzva k výbìru polohy levého horního rohu výstupní tabulky
    On Error Resume Next
    Set poloha_vystupni_tabulky = Application.InputBox("Vyberte levý horní roh tabulky, kam budou umístìny výsledky:", Type:=8)
    On Error GoTo 0
    
    ' Kontrola, zda byla zadána platná poloha
    If poloha_vystupni_tabulky Is Nothing Then
        MsgBox "Není vybrána žádná buòka pro umístìní tabulky!", vbCritical
        Exit Sub
    End If
    
    ' Generování názvu tabulky s timestampem
    timestamp = Format(Now(), "yyyymmdd_hhmm")
    outputTableName = "stat_" & timestamp
    
    ' Urèení výstupní polohy
    startRow = poloha_vystupni_tabulky.Row
    startCol = poloha_vystupni_tabulky.Column
    
    ' Definování popisných charakteristik, které budou ve sloupcích
    characteristics = Array("Prùmìr", "Minimum", "1. Kvartil", "Medián", "3. Kvartil", "Maximum", "Smìrodatná odchylka", "Rozptyl")
    
    ' Vytvoøení hlavièek pro výstupní tabulku
    ws.Cells(startRow, startCol).Value = "Ukazatel"
    For i = LBound(characteristics) To UBound(characteristics)
        ws.Cells(startRow, startCol + i + 1).Value = characteristics(i)
    Next i
    
    ' Nastavení ukazatelù pro výpoèty charakteristik
    pole_ukazatelu = Array("Datum podání", "Cenový údaj", "JC [Kè/m2]", "Plocha [m2]")
    
    ' Pro každý ukazatel provést výpoèet charakteristik
    For i = LBound(pole_ukazatelu) To UBound(pole_ukazatelu)
        ' Najít sloupec s odpovídajícím ukazatelem ve vstupní tabulce
        On Error Resume Next
        Set ukazatelColumn = activeRange.Rows(1).Find(pole_ukazatelu(i), LookIn:=xlValues, LookAt:=xlWhole).EntireColumn
        On Error GoTo 0
        
        If Not ukazatelColumn Is Nothing Then
            ' Získat hodnoty ve sloupci (bez hlavièky)
            Set dataRange = ukazatelColumn.Resize(ukazatelColumn.Rows.Count - 1).Offset(1)
            
            ' Zapsat název ukazatele do výstupní tabulky
            ws.Cells(startRow + i + 1, startCol).Value = pole_ukazatelu(i)
            
            ' Výpoèty charakteristik
            ws.Cells(startRow + i + 1, startCol + 1).Value = WorksheetFunction.Average(dataRange) ' Prùmìr
            ws.Cells(startRow + i + 1, startCol + 2).Value = WorksheetFunction.Min(dataRange) ' Minimum
            ws.Cells(startRow + i + 1, startCol + 3).Value = WorksheetFunction.Percentile(dataRange, 0.25) ' 1. Kvartil
            ws.Cells(startRow + i + 1, startCol + 4).Value = WorksheetFunction.Median(dataRange) ' Medián
            ws.Cells(startRow + i + 1, startCol + 5).Value = WorksheetFunction.Percentile(dataRange, 0.75) ' 3. Kvartil
            ws.Cells(startRow + i + 1, startCol + 6).Value = WorksheetFunction.Max(dataRange) ' Maximum
            ws.Cells(startRow + i + 1, startCol + 7).Value = WorksheetFunction.StDev(dataRange) ' Smìrodatná odchylka
            ws.Cells(startRow + i + 1, startCol + 8).Value = WorksheetFunction.Var(dataRange) ' Rozptyl
            
            
            ' Urèení poètu sloupcù v tabulce charakteristik
            colCount = UBound(characteristics) + 1
            
            ' Najít sloupec pro smìrodatnou odchylku
            For j = 1 To colCount
                If ws.Cells(startRow, startCol + j).Value = "Smìrodatná odchylka" Then
                    stdevCol = startCol + j
                    Exit For
                End If
            Next j
            
            ' Najít sloupec pro rozptyl
            For j = 1 To colCount
                If ws.Cells(startRow, startCol + j).Value = "Rozptyl" Then
                    varCol = startCol + j
                    Exit For
                End If
            Next j
            
            
            ' Formátování bunìk na základì typu ukazatele
            Select Case pole_ukazatelu(i)
                Case "Datum podání"
                    For j = startCol + 1 To colCount + startCol
                        If j <> stdevCol Or j <> varCol Then
                            ws.Cells(startRow + i + 1, j).NumberFormat = "dd.mm.yyyy" ' Formát datumu
                        End If
                    Next j
                Case "Cenový údaj", "JC [Kè/m2]"
                    For j = startCol + 1 To colCount + startCol
                        If j <> stdevCol Or j <> varCol Then
                            ws.Cells(startRow + i + 1, j).NumberFormat = "#,##0" ' Cena s oddìlenými tisíci
                        End If
                    Next j
                Case "Plocha [m2]"
                    For j = startCol + 1 To colCount + startCol
                        If j <> stdevCol Or j <> varCol Then
                            ws.Cells(startRow + i + 1, j).NumberFormat = "#,##0.00" ' Plocha s 2 desetinnými místy
                        End If
                    Next j
            End Select
            
            ' Nastavení formátu pro smìrodatnou odchylku a rozptyl
            ws.Cells(startRow + i + 1, stdevCol).NumberFormat = "#,##0.0" ' Formát èísla pro smìrodatnou odchylku
            ws.Cells(startRow + i + 1, varCol).NumberFormat = "#,##0.0" ' Formát èísla pro rozptyl
          
        End If
    Next i
    
    ' Nastavení formátování pro výstupní tabulku
    ws.ListObjects.Add(xlSrcRange, ws.Range(ws.Cells(startRow, startCol), ws.Cells(startRow + UBound(pole_ukazatelu) + 1, startCol + UBound(characteristics) + 1)), , xlYes).Name = outputTableName
    
    MsgBox "Statistická tabulka '" & outputTableName & "' byla úspìšnì vytvoøena.", vbInformation
End Sub

















'' Obecná procedura ktetá na základì vstupních parametrù vytvoøí tabulku se statistickými charakteristikami zdrojových dat / zdrojové tabulky
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
'    ' Získání aktuálního listu
'    Set ws = ActiveSheet
'
'    ' Získání tabulky, která obsahuje aktivní buòku
'    If ws.ListObjects.Count > 0 Then
'        ' Projde všechny tabulky na listu
'        For Each activeTable In ws.ListObjects
'            ' Zkontroluje, zda aktivní buòka je na tomto listu a je v rozsahu tabulky
'            If Not Intersect(activeTable.Range, ActiveCell) Is Nothing Then
'                ' Uložení rozsahu tabulky, která obsahuje aktivní buòku
'                Set activeRange = activeTable.Range
'                Exit For
'            End If
'        Next activeTable
'    End If
'
'    ' Kontrola, zda byla nalezena tabulka obsahující aktivní buòku
'    If activeRange Is Nothing Then
'        MsgBox "Aktivní buòka není souèástí žádné tabulky!", vbCritical
'        Exit Sub
'    End If
'
'    ' Výzva k výbìru polohy levého horního rohu výstupní tabulky
'    On Error Resume Next
'    Set poloha_vystupni_tabulky = Application.InputBox("Vyberte levý horní roh tabulky, kam budou umístìny výsledky:", Type:=8)
'    On Error GoTo 0
'
'    ' Kontrola, zda byla zadána platná poloha
'    If poloha_vystupni_tabulky Is Nothing Then
'        MsgBox "Není vybrána žádná buòka pro umístìní tabulky!", vbCritical
'        Exit Sub
'    End If
'
'    ' Generování názvu tabulky s timestampem
'    timestamp = Format(Now(), "yyyymmdd_hhmm")
'    outputTableName = "stat_" & timestamp
'
'    ' Urèení výstupní polohy
'    startRow = poloha_vystupni_tabulky.Row
'    startCol = poloha_vystupni_tabulky.Column
'
'    ' Definování popisných charakteristik, které budou ve sloupcích
'    characteristics = Array("Prùmìr", "Minimum", "1. Kvartil", "Medián", "3. Kvartil", "Maximum", "Smìrodatná odchylka")
'
'    ' Vytvoøení hlavièek pro výstupní tabulku
'    ws.Cells(startRow, startCol).Value = "Ukazatel"
'    For i = LBound(characteristics) To UBound(characteristics)
'        ws.Cells(startRow, startCol + i + 1).Value = characteristics(i)
'    Next i
'
'
'    ' Nastavení ukazatelù pro výpoèty charakteristik
'    pole_ukazatelu = Array("Datum podání", "Cenový údaj", "JC [Kè/m2]", "Plocha [m2]")
'
'
'    ' Pro každý ukazatel provést výpoèet charakteristik
'    For i = LBound(pole_ukazatelu) To UBound(pole_ukazatelu)
'        ' Najít sloupec s odpovídajícím ukazatelem ve vstupní tabulce
'        On Error Resume Next
'        Set ukazatelColumn = activeRange.Rows(1).Find(pole_ukazatelu(i), LookIn:=xlValues, LookAt:=xlWhole).EntireColumn
'        On Error GoTo 0
'
'        If Not ukazatelColumn Is Nothing Then
'            ' Získat hodnoty ve sloupci (bez hlavièky)
'            Set dataRange = ukazatelColumn.Resize(ukazatelColumn.Rows.Count - 1).Offset(1)
'
'            ' Zapsat název ukazatele do výstupní tabulky
'            ws.Cells(startRow + i + 1, startCol).Value = pole_ukazatelu(i)
'
'            ' Výpoèty charakteristik
'            ws.Cells(startRow + i + 1, startCol + 1).Value = WorksheetFunction.Average(dataRange) ' Prùmìr
'            ws.Cells(startRow + i + 1, startCol + 2).Value = WorksheetFunction.Min(dataRange) ' Minimum
'            ws.Cells(startRow + i + 1, startCol + 3).Value = WorksheetFunction.Percentile(dataRange, 0.25) ' 1. Kvartil
'            ws.Cells(startRow + i + 1, startCol + 4).Value = WorksheetFunction.Median(dataRange) ' Medián
'            ws.Cells(startRow + i + 1, startCol + 5).Value = WorksheetFunction.Percentile(dataRange, 0.75) ' 3. Kvartil
'            ws.Cells(startRow + i + 1, startCol + 6).Value = WorksheetFunction.Max(dataRange) ' Maximum
'            ws.Cells(startRow + i + 1, startCol + 7).Value = WorksheetFunction.StDev(dataRange) ' Smìrodatná odchylka
'        End If
'    Next i
'
'    ' Nastavení formátování pro výstupní tabulku
'    ws.ListObjects.Add(xlSrcRange, ws.Range(ws.Cells(startRow, startCol), ws.Cells(startRow + UBound(pole_ukazatelu) + 1, startCol + UBound(characteristics) + 1)), , xlYes).Name = outputTableName
'
'    MsgBox "Statistická tabulka '" & outputTableName & "' byla úspìšnì vytvoøena.", vbInformation
'End Sub
'

