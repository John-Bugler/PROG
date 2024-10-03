Attribute VB_Name = "Statistiky1"
' podrobne statistiky

Sub GenerujStatistiky()
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim statsRange As Range
    
    ' Nastavení aktivního listu a tabulky
    Set ws = ActiveSheet
    On Error Resume Next
    Set tbl = ActiveCell.ListObject
    On Error GoTo 0
    
    If tbl Is Nothing Then
        MsgBox "Aktivní bunka není v žádné tabulce.", vbExclamation
        Exit Sub
    End If
    
    ' Nastavení oblasti pro statistický souhrn
    Set statsRange = ws.Range("AJ2")
    
    ' Vymazání starých statistik
    ws.Range("AJ:AT").Clear
    
    ' Vložení základních informací
    ws.Range("AF1").Value = "LAT ="
    ws.Range("AH1").Value = "LON ="
    
    ' Generování základních statistik
    GenerujZakladniStatistiky ws, tbl, statsRange
    
    ' Generování podrobných statistik
    GenerujPodrobneStatistiky ws, tbl, statsRange
    

End Sub

Sub GenerujZakladniStatistiky(ws As Worksheet, tbl As ListObject, statsRange As Range)
    ' Velikost vzorku
    statsRange.Value = "Velikost vzorku : "
    statsRange.Font.Bold = True
    statsRange.Offset(0, 1).Formula = "=ROWS(" & tbl.DataBodyRange.Address & ")"
    statsRange.Offset(0, 1).Font.Bold = True
    
    ' Pocet unikátních adres
    statsRange.Offset(1, 0).Value = "Pocet unikátních adres :"
    statsRange.Offset(1, 0).Font.Bold = True
    statsRange.Offset(1, 1).Formula = "=SUMPRODUCT(1/COUNTIF(" & tbl.ListColumns("Adresa").DataBodyRange.Address & "," & tbl.ListColumns("Adresa").DataBodyRange.Address & "))"
    statsRange.Offset(1, 1).Font.Bold = True
    
    ' Poèet unikátních hodnot v sloupci "Kat# území"
    statsRange.Offset(2, 0).Value = "Poèet zastoupených Katastrálních území :"
    statsRange.Offset(2, 0).Font.Bold = True
    statsRange.Offset(2, 1).Formula = "=SUMPRODUCT(1/COUNTIF(" & tbl.ListColumns("Kat# území").DataBodyRange.Address & "," & tbl.ListColumns("Kat# území").DataBodyRange.Address & "))"
    statsRange.Offset(2, 1).Font.Bold = True
    
    
'     ' Inicializace slovníku
'    Set dict = CreateObject("Scripting.Dictionary")
'
'    ' Získání sloupce "Kat# území"
'    Set katUzemColumn = tbl.ListColumns("Kat# území")
'
'    ' Procházení hodnot v sloupci a pøidání do slovníku
'    For Each cell In katUzemColumn.DataBodyRange
'        If Not IsEmpty(cell.Value) Then
'            If dict.exists(cell.Value) Then
'                dict(cell.Value) = dict(cell.Value) + 1
'            Else
'                dict.Add cell.Value, 1
'            End If
'        End If
'    Next cell
'
'    ' Urèení výstupního rozsahu
'    Set outputRange = statsRange.Offset(4, 0)
'
'    ' Zápis do listu
'    outputRange.Value = "Katastrální území"
'    outputRange.Font.Bold = True
'
'    outputRange.Offset(0, 1).Value = "Poèet"
'    outputRange.Offset(0, 1).Font.Bold = True
'
'    r = 1
'    For Each Key In dict.keys
'        outputRange.Offset(r, 0).Value = Key
'        outputRange.Offset(r, 1).Value = dict(Key)
'        r = r + 1
'    Next Key
'
'    ' Vyèištìní slovníku
'    Set dict = Nothing
'
    
    ' Inicializace slovníku
    Set dict = CreateObject("Scripting.Dictionary")
    
    ' Získání sloupce "Kat# území" a dalších potøebných sloupcù
    Set katUzemColumn = tbl.ListColumns("Kat# území").DataBodyRange
    Set plochaColumn = tbl.ListColumns("Plocha [m2]").DataBodyRange
    Set jcColumn = tbl.ListColumns("JC [Kè/m2]").DataBodyRange
    
    ' Struktura pro ukládání souvisejících dat (souèet ploch, ceny, poèty atd.)
    Set dataDict = CreateObject("Scripting.Dictionary")
    
    ' Procházení hodnot v sloupci a pøidání do slovníku
    For i = 1 To katUzemColumn.Rows.Count
        katUzem = katUzemColumn.Cells(i, 1).Value
        plocha = plochaColumn.Cells(i, 1).Value
        jc = jcColumn.Cells(i, 1).Value
        
        If Not IsEmpty(katUzem) Then
            ' Inicializace datových polí pro každé katastrální území
            If Not dataDict.exists(katUzem) Then
                dataDict.Add katUzem, Array(0, 0, 0, 0, 0, 0, 0, 0, 0, 0) ' (count, sumPlocha, minPlocha, maxPlocha, sumJC, minJC, maxJC, sumJCQ4, countJCQ4)
            End If
            
            ' Získání existujících dat
            uzemniData = dataDict(katUzem)
            
            ' Aktualizace poètu a souètu ploch
            uzemniData(0) = uzemniData(0) + 1 ' Poèet záznamù
            uzemniData(1) = uzemniData(1) + plocha ' Souèet ploch
            
            ' Aktualizace min a max plochy
            If uzemniData(2) = 0 Or plocha < uzemniData(2) Then uzemniData(2) = plocha ' Min Plocha
            If plocha > uzemniData(3) Then uzemniData(3) = plocha ' Max Plocha
            
            ' Aktualizace souètu a min/max JC
            uzemniData(4) = uzemniData(4) + jc ' Souèet JC
            If uzemniData(5) = 0 Or jc < uzemniData(5) Then uzemniData(5) = jc ' Min JC
            If jc > uzemniData(6) Then uzemniData(6) = jc ' Max JC
            
            ' Aktualizace souètu JC pro 4. kvartil
            If jc >= Application.WorksheetFunction.Quartile(jcColumn, 3) Then ' Hodnota ve 4. kvartilu
                uzemniData(7) = uzemniData(7) + jc ' Souèet JC pro 4. kvartil
                uzemniData(8) = uzemniData(8) + 1 ' Poèet JC ve 4. kvartilu
            End If
            
            ' Uložení zpìt do slovníku
            dataDict(katUzem) = uzemniData
        End If
    Next i
    
    ' Urèení výstupního rozsahu
    Set outputRange = statsRange.Offset(4, 0)
    
    ' Zápis hlavièek do listu s formátováním

    outputRange.Value = "Katastrální území"
    outputRange.Font.Bold = True
    
    outputRange.Offset(0, 1).Value = "Poèet"
    outputRange.Offset(0, 1).Font.Bold = True
    
    outputRange.Offset(0, 2).Value = "Min Plocha [m2]"
    outputRange.Offset(0, 2).Font.Bold = True
    
    outputRange.Offset(0, 3).Value = "AVG Plocha [m2]"
    outputRange.Offset(0, 3).Font.Bold = True
    
    
    outputRange.Offset(0, 4).Value = "Max Plocha [m2]"
    outputRange.Offset(0, 4).Font.Bold = True
    
    
    outputRange.Offset(0, 5).Value = "Min JC [Kè/m2]"
    outputRange.Offset(0, 5).Font.Bold = True
    
    
    outputRange.Offset(0, 6).Value = "AVG JC [Kè/m2]"
    outputRange.Offset(0, 6).Font.Bold = True
    
    
    outputRange.Offset(0, 7).Value = "Max JC [Kè/m2]"
    outputRange.Offset(0, 7).Font.Bold = True
    
    
    outputRange.Offset(0, 8).Value = "Poèet JC (Q4)"
    outputRange.Offset(0, 8).Font.Bold = True
    
    
    outputRange.Offset(0, 9).Value = "AVG JC (Q4) [Kè/m2]"
    outputRange.Offset(0, 9).Font.Bold = True
    
    
    
    ' Procházení výsledkù a zápis do listu
    r = 1
    For Each Key In dataDict.keys
        uzemniData = dataDict(Key)
        
        outputRange.Offset(r, 0).Value = Key ' Katastrální území
        outputRange.Offset(r, 1).Value = uzemniData(0) ' Poèet
        
        ' Zaokrouhlení plochy na 2 desetinná místa
        outputRange.Offset(r, 2).Value = Round(uzemniData(2), 2) ' Min Plocha
        outputRange.Offset(r, 3).Value = Round(uzemniData(1) / uzemniData(0), 2) ' AVG Plocha
        outputRange.Offset(r, 4).Value = Round(uzemniData(3), 2) ' Max Plocha
        
        ' Zaokrouhlení JC na celá èísla s oddìlovaèem tisícù
        outputRange.Offset(r, 5).Value = Round(uzemniData(5), 0) ' Min JC
        outputRange.Offset(r, 5).NumberFormat = "#,##0" ' Formát pro oddìlení tisícù
        
        outputRange.Offset(r, 6).Value = Round(uzemniData(4) / uzemniData(0), 0) ' AVG JC
        outputRange.Offset(r, 6).NumberFormat = "#,##0" ' Formát pro oddìlení tisícù
        
        outputRange.Offset(r, 7).Value = Round(uzemniData(6), 0) ' Max JC
        outputRange.Offset(r, 7).NumberFormat = "#,##0" ' Formát pro oddìlení tisícù
        
        ' Poèet JC ve 4. kvartilu
        outputRange.Offset(r, 8).Value = uzemniData(8) ' Poèet JC ve 4. kvartilu
        
        ' Prùmìr JC ve 4. kvartilu, pokud existují hodnoty
        If uzemniData(8) > 0 Then
            outputRange.Offset(r, 9).Value = Round(uzemniData(7) / uzemniData(8), 0) ' AVG JC pro 4. kvartil
            outputRange.Offset(r, 9).NumberFormat = "#,##0" ' Formát pro oddìlení tisícù
        Else
            outputRange.Offset(r, 9).Value = "N/A" ' Pokud nejsou žádné hodnoty ve 4. kvartilu
        End If
        
        r = r + 1
    Next Key
    
    ' Vyèištìní slovníkù
    Set dict = Nothing
    Set dataDict = Nothing
    

    
End Sub

Sub GenerujPodrobneStatistiky(ws As Worksheet, tbl As ListObject, statsRange As Range)
    Dim headers As Variant
    Dim columns As Variant
    Dim i As Integer
    Dim rowOffset As Integer
    Dim colOffset As Integer
    
    ' Nastavení hlavicek a sloupcu pro statistiky
    headers = Array("Prùmìr", "Minimum", "První kvartil", "Medián", "Tøetí kvartil", "Maximum")
    columns = Array("Datum podání", "Plocha [m2]", "JC [Kè/m2]", "Vzdálenost [Km]", "Cenový údaj")
    
    ' Vytvorení záhlaví parametru vzorku (Prumer, Minimum atd.)
    rowOffset = 15
    statsRange.Offset(rowOffset - 1, 0).Value = "Charakteristiky vzorku jako celku"
    statsRange.Offset(rowOffset - 1, 0).Font.Bold = True
    For i = LBound(headers) To UBound(headers)
        statsRange.Offset(rowOffset, 0).Value = headers(i)
        statsRange.Offset(rowOffset, 0).Font.Bold = True
        rowOffset = rowOffset + 1
    Next i
    
    ' Vytvorení sloupcu pro jednotlivé hodnoty (Datum podání, Plocha atd.)
    colOffset = 1
    For i = LBound(columns) To UBound(columns)
        ' Záhlaví sloupcu
        statsRange.Offset(rowOffset - UBound(headers) - 2, colOffset).Value = columns(i)
        statsRange.Offset(rowOffset - UBound(headers) - 2, colOffset).Font.Bold = True
        
        ' Vyplnení statistik pro každý parametr vzorku
        VyplnStatistikySloupce ws, tbl, statsRange, CStr(columns(i)), colOffset, rowOffset - UBound(headers) - 2
        
        ' Posunout o jeden sloupec pro další hodnoty
        colOffset = colOffset + 1
    Next i
    
        ' Generování statistik pro intervaly
     GenerujIntervaloveStatistiky ws, tbl, statsRange, rowOffset
     
    
End Sub


Sub VyplnStatistikySloupce(ws As Worksheet, tbl As ListObject, statsRange As Range, columnName As String, colOffset As Integer, rowOffset As Integer)
    Dim col As ListColumn
    On Error Resume Next
    Set col = tbl.ListColumns(columnName)
    On Error GoTo 0
    
    ' Zkontrolujte, zda sloupec existuje
    If col Is Nothing Then
        MsgBox "Sloupec '" & columnName & "' nebyl nalezen v tabulce.", vbExclamation
        Exit Sub
    End If
    
    ' Nastavení vzorcù
    With statsRange
        .Offset(rowOffset + 1, colOffset).Formula = "=AVERAGE(" & col.DataBodyRange.Address(True, True, xlA1, True) & ")"
        .Offset(rowOffset + 2, colOffset).Formula = "=MIN(" & col.DataBodyRange.Address(True, True, xlA1, True) & ")"
        .Offset(rowOffset + 3, colOffset).Formula = "=QUARTILE(" & col.DataBodyRange.Address(True, True, xlA1, True) & ", 1)"
        .Offset(rowOffset + 4, colOffset).Formula = "=MEDIAN(" & col.DataBodyRange.Address(True, True, xlA1, True) & ")"
        .Offset(rowOffset + 5, colOffset).Formula = "=QUARTILE(" & col.DataBodyRange.Address(True, True, xlA1, True) & ", 3)"
        .Offset(rowOffset + 6, colOffset).Formula = "=MAX(" & col.DataBodyRange.Address(True, True, xlA1, True) & ")"
    End With

    ' Aplikace formátování
    Dim rng As Range
 
    Set rng = statsRange.Resize(6, 1).Offset(rowOffset, colOffset)
    
    Select Case columnName
        Case "Datum podání"
            rng.NumberFormat = "d/m/yyyy"  ' Krátké datum
        Case "Plocha [m2]", "Vzdálenost [Km]"
            rng.NumberFormat = "#,##0.00"  ' Èísla s dvìma desetinnými místy
        Case "JC [Kè/m2]", "Cenový údaj"
            rng.NumberFormat = "#,##0"  ' Èísla bez desetinných míst
    End Select
    
End Sub


Sub GenerujIntervaloveStatistiky(ws As Worksheet, tbl As ListObject, statsRange As Range, rowOffset As Integer)
    Dim intervals As Variant
    Dim intervalNames As Variant
    Dim intervalStatsRange As Range
    Dim intervalRowOffset As Integer
    Dim intervalColOffset As Integer
    Dim i As Integer

    ' Definování intervalù a jejich názvù
    intervals = Array(0, 42, 67, 87, 122)
    intervalNames = Array("0 - 41,99 [m2], (1 pokoj)", "42 - 66,99 [m2], (2 pokoje)", "67 - 86,99 [m2], (3 pokoje)", "87 - 121,99 [m2], (4 pokoje)", "> 122 [m2], (5 a více pokojù)")

    statsRange.Offset(rowOffset + 2, 0).Value = "Charakteristiky vzorku dle dispozic"
    statsRange.Offset(rowOffset + 2, 0).Font.Bold = True
    
    ' Nastavení oblasti pro statistiky intervalù
    Set intervalStatsRange = statsRange.Offset(rowOffset + 2, 0)
    intervalRowOffset = 1
    intervalColOffset = 1
    
    ' Zadejte názvy parametrù pouze jednou do prvního sloupce
    intervalStatsRange.Offset(intervalRowOffset, 0).Value = "Poèet záznamù"
    intervalStatsRange.Offset(intervalRowOffset + 1, 0).Value = "Prùmìrná plocha [m2]"
    intervalStatsRange.Offset(intervalRowOffset + 2, 0).Value = "Prùmìrná JC [Kè/m2]"
    intervalStatsRange.Offset(intervalRowOffset + 3, 0).Value = "Prùmìrná cena [Kè]"
    
    intervalStatsRange.Offset(intervalRowOffset, 0).Font.Bold = True
    intervalStatsRange.Offset(intervalRowOffset + 1, 0).Font.Bold = True
    intervalStatsRange.Offset(intervalRowOffset + 2, 0).Font.Bold = True
    intervalStatsRange.Offset(intervalRowOffset + 3, 0).Font.Bold = True

    
    
    For i = LBound(intervals) To UBound(intervals)
        ' Nastavení názvu intervalu
        intervalStatsRange.Offset(0, intervalColOffset).Value = intervalNames(i)
        intervalStatsRange.Offset(0, intervalColOffset).Font.Bold = True
        
        ' Poèet záznamù
        If i = UBound(intervals) Then
            intervalStatsRange.Offset(1, intervalColOffset).Formula = "=COUNTIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ")"
        Else
            intervalStatsRange.Offset(1, intervalColOffset).Formula = "=COUNTIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", ""<"" & " & intervals(i + 1) & ")"
        End If
        intervalStatsRange.Offset(1, intervalColOffset).NumberFormat = "#,##"
        
        ' Prùmìrná plocha [m2]
        If i = UBound(intervals) Then
            intervalStatsRange.Offset(2, intervalColOffset).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ")"
        Else
            intervalStatsRange.Offset(2, intervalColOffset).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", ""<"" & " & intervals(i + 1) & ")"
        End If
        intervalStatsRange.Offset(2, intervalColOffset).NumberFormat = "#,##0.00"
        
        ' Prùmìrná JC [Kè/m2]
        If i = UBound(intervals) Then
            intervalStatsRange.Offset(3, intervalColOffset).Formula = "=AVERAGEIFS(" & tbl.ListColumns("JC [Kè/m2]").DataBodyRange.Address(True, True, xlA1, True) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ")"
        Else
            intervalStatsRange.Offset(3, intervalColOffset).Formula = "=AVERAGEIFS(" & tbl.ListColumns("JC [Kè/m2]").DataBodyRange.Address(True, True, xlA1, True) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", ""<"" & " & intervals(i + 1) & ")"
        End If
        intervalStatsRange.Offset(3, intervalColOffset).NumberFormat = "#,##0"
        
        ' Prùmìrná cena [Kè]
        If i = UBound(intervals) Then
            intervalStatsRange.Offset(4, intervalColOffset).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Cenový údaj").DataBodyRange.Address(True, True, xlA1, True) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ")"
        Else
            intervalStatsRange.Offset(4, intervalColOffset).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Cenový údaj").DataBodyRange.Address(True, True, xlA1, True) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", ""<"" & " & intervals(i + 1) & ")"
        End If
        intervalStatsRange.Offset(4, intervalColOffset).NumberFormat = "#,##0"
        
        ' Posun na další interval (každý interval zabere 1 sloupec)
        intervalColOffset = intervalColOffset + 1
    Next i
End Sub






'******************************************************************************************

'Sub GenerateStatistics()
'    Dim ws As Worksheet
'    Dim tbl As ListObject
'    Dim rng As Range
'    Dim lastRow As Long
'    Dim statsRange As Range
'    Dim columnIndex As Long
'    Dim headers As Variant
'    Dim columns As Variant
'    Dim i As Integer
'    Dim rowOffset As Integer
'
'    ' Nastavení aktivního listu a tabulky
'    Set ws = ActiveSheet
'
'    ' Zjištìní, ve které tabulce se nachází aktivní buòka
'    On Error Resume Next
'    Set tbl = ActiveCell.ListObject
'    On Error GoTo 0
'
'    If tbl Is Nothing Then
'        MsgBox "Aktivní buòka není v žádné tabulce.", vbExclamation
'        Exit Sub
'    End If
'
'    ' Nastavení polohy kde bude následnì vložena GPS souradnice oceòované nemovitosti
'    ws.Range("AB1").Value = "LAT ="
'    ws.Range("AB2").Value = "LON ="
'
'
'    ' Nastavení oblasti pro statistický souhrn
'    Set statsRange = ws.Range("AF1")
'
'    ' Vymazání starých statistik
'    ws.Range("AF:AH").Clear
'
'
'
'    ' Velikost vzorku
'    statsRange.Value = "Velikost vzorku : "
'    statsRange.Font.Bold = True
'    statsRange.Offset(0, 1).Formula = "=ROWS(" & tbl.DataBodyRange.Address & ")"
'    statsRange.Offset(0, 1).Font.Bold = True
'
'
'    ' Poèet unikátních adres
'    statsRange.Offset(1, 0).Value = "Poèet unikátních adres :"
'    statsRange.Offset(1, 0).Font.Bold = True
'    statsRange.Offset(1, 1).Formula = "=SUMPRODUCT(1/COUNTIF(" & tbl.ListColumns("Adresa").DataBodyRange.Address & "," & tbl.ListColumns("Adresa").DataBodyRange.Address & "))"
'    statsRange.Offset(1, 1).Font.Bold = True
'
'    ' Nastavení hlavièek a sloupcù pro statistiky
'    headers = Array("Datum podání", "Plocha [m2]", "JC [Kè/m2]", "Vzdálenost [Km]", "Cenový údaj [Kè]")
'    columns = Array("Datum podání", "Plocha [m2]", "JC [Kè/m2]", "Vzdálenost [Km]", "Cenový údaj")
'
'    ' Vyplnìní statistik
'    rowOffset = 3 ' Zaèíná na øádku 2 pod nadpisem
'    For i = LBound(headers) To UBound(headers)
'        ' Název parametru
'        statsRange.Offset(rowOffset, 0).Value = headers(i)
'        statsRange.Offset(rowOffset, 0).Font.Bold = True
'        rowOffset = rowOffset + 1
'
'        ' Nastavení sloupce pro vzorce
'        columnIndex = tbl.ListColumns(columns(i)).Index
'
'        ' Vypoèítat prùmìr
'        statsRange.Offset(rowOffset, 0).Value = "Prùmìr"
'        With statsRange.Offset(rowOffset, 1)
'            .Formula = "=AVERAGE(" & tbl.ListColumns(columns(i)).DataBodyRange.Address & ")"
'            If headers(i) = "Datum podání" Then
'                .NumberFormat = "dd/mm/yyyy"
'            ElseIf headers(i) = "Plocha [m2]" Or headers(i) = "Vzdálenost [Km]" Then
'                .NumberFormat = "#,##0.00"
'            ElseIf headers(i) = "JC [Kè/m2]" Or headers(i) = "Cenový údaj" Then
'                .NumberFormat = "#,##0"
'            End If
'        End With
'        rowOffset = rowOffset + 1
'
'        ' Minimum
'        statsRange.Offset(rowOffset, 0).Value = "Minimum"
'        With statsRange.Offset(rowOffset, 1)
'            .Formula = "=MIN(" & tbl.ListColumns(columns(i)).DataBodyRange.Address & ")"
'            If headers(i) = "Datum podání" Then
'                .NumberFormat = "dd/mm/yyyy"
'            ElseIf headers(i) = "Plocha [m2]" Or headers(i) = "Vzdálenost [Km]" Then
'                .NumberFormat = "#,##0.00"
'            ElseIf headers(i) = "JC [Kè/m2]" Or headers(i) = "Cenový údaj" Then
'                .NumberFormat = "#,##0"
'            End If
'        End With
'        rowOffset = rowOffset + 1
'
'        ' První kvartil
'        statsRange.Offset(rowOffset, 0).Value = "První kvartil"
'        With statsRange.Offset(rowOffset, 1)
'            .Formula = "=QUARTILE(" & tbl.ListColumns(columns(i)).DataBodyRange.Address & ", 1)"
'            If headers(i) = "Datum podání" Then
'                .NumberFormat = "dd/mm/yyyy"
'            ElseIf headers(i) = "Plocha [m2]" Or headers(i) = "Vzdálenost [Km]" Then
'                .NumberFormat = "#,##0.00"
'            ElseIf headers(i) = "JC [Kè/m2]" Or headers(i) = "Cenový údaj" Then
'                .NumberFormat = "#,##0"
'            End If
'        End With
'        rowOffset = rowOffset + 1
'
'        ' Medián
'        statsRange.Offset(rowOffset, 0).Value = "Medián"
'        With statsRange.Offset(rowOffset, 1)
'            .Formula = "=MEDIAN(" & tbl.ListColumns(columns(i)).DataBodyRange.Address & ")"
'            If headers(i) = "Datum podání" Then
'                .NumberFormat = "dd/mm/yyyy"
'            ElseIf headers(i) = "Plocha [m2]" Or headers(i) = "Vzdálenost [Km]" Then
'                .NumberFormat = "#,##0.00"
'            ElseIf headers(i) = "JC [Kè/m2]" Or headers(i) = "Cenový údaj" Then
'                .NumberFormat = "#,##0"
'            End If
'        End With
'        rowOffset = rowOffset + 1
'
'        ' Tøetí kvartil
'        statsRange.Offset(rowOffset, 0).Value = "Tøetí kvartil"
'        With statsRange.Offset(rowOffset, 1)
'            .Formula = "=QUARTILE(" & tbl.ListColumns(columns(i)).DataBodyRange.Address & ", 3)"
'            If headers(i) = "Datum podání" Then
'                .NumberFormat = "dd/mm/yyyy"
'            ElseIf headers(i) = "Plocha [m2]" Or headers(i) = "Vzdálenost [Km]" Then
'                .NumberFormat = "#,##0.00"
'            ElseIf headers(i) = "JC [Kè/m2]" Or headers(i) = "Cenový údaj" Then
'                .NumberFormat = "#,##0"
'            End If
'        End With
'        rowOffset = rowOffset + 1
'
'        ' Maximum
'        statsRange.Offset(rowOffset, 0).Value = "Maximum"
'        With statsRange.Offset(rowOffset, 1)
'            .Formula = "=MAX(" & tbl.ListColumns(columns(i)).DataBodyRange.Address & ")"
'            If headers(i) = "Datum podání" Then
'                .NumberFormat = "dd/mm/yyyy"
'            ElseIf headers(i) = "Plocha [m2]" Or headers(i) = "Vzdálenost [Km]" Then
'                .NumberFormat = "#,##0.00"
'            ElseIf headers(i) = "JC [Kè/m2]" Or headers(i) = "Cenový údaj" Then
'                .NumberFormat = "#,##0"
'            End If
'        End With
'        rowOffset = rowOffset + 1
'
'        ' Pøesun na další sekci
'        rowOffset = rowOffset + 1
'    Next i
'
'    ' Statistika pro intervaly plochy
'    Dim intervals As Variant
'    Dim intervalNames As Variant
'    Dim intervalStatsRange As Range
'    Dim intervalRowOffset As Integer
'
'    intervals = Array(0, 42, 67, 87, 122)
'    intervalNames = Array("0 - 41,99 [m2], (1 pokoj)", "42 - 66,99 [m2], (2 pokoje)", "67 - 86,99 [m2], (3 pokoje)", "87 - 121,99 [m2], (4 pokoje)", "> 122 [m2], (5 a více pokojù)")
'
'    Set intervalStatsRange = ws.Range("AF" & rowOffset + 2)
'    intervalRowOffset = 0
'
'    For i = LBound(intervals) To UBound(intervals)
'        intervalStatsRange.Offset(intervalRowOffset, 0).Value = intervalNames(i)
'        intervalStatsRange.Offset(intervalRowOffset, 0).Font.Bold = True
'        intervalRowOffset = intervalRowOffset + 1
'
'        ' Poèet záznamù
'        intervalStatsRange.Offset(intervalRowOffset, 0).Value = "Poèet záznamù"
'        If i = UBound(intervals) Then
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=COUNTIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ")"
'        Else
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=COUNTIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", ""<"" & " & intervals(i + 1) & ")"
'        End If
'        intervalStatsRange.Offset(intervalRowOffset, 1).NumberFormat = "#,##"
'        intervalRowOffset = intervalRowOffset + 1
'
'
'        ' Prùmìrná plocha [m2]
'        intervalStatsRange.Offset(intervalRowOffset, 0).Value = "Prùmìrná plocha [m2]"
'        If i = UBound(intervals) Then
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ")"
'        Else
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", ""<"" & " & intervals(i + 1) & ")"
'        End If
'        intervalStatsRange.Offset(intervalRowOffset, 1).NumberFormat = "#,##0.00"
'        intervalRowOffset = intervalRowOffset + 1
'
'
'        ' Prùmìrná JC
'        intervalStatsRange.Offset(intervalRowOffset, 0).Value = "Prùmìrná JC [Kè/m2]"
'        If i = UBound(intervals) Then
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=AVERAGEIFS(" & tbl.ListColumns("JC [Kè/m2]").DataBodyRange.Address & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ")"
'        Else
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=AVERAGEIFS(" & tbl.ListColumns("JC [Kè/m2]").DataBodyRange.Address & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", ""<"" & " & intervals(i + 1) & ")"
'        End If
'        intervalStatsRange.Offset(intervalRowOffset, 1).NumberFormat = "#,##0"
'        intervalRowOffset = intervalRowOffset + 1
'
'
'        ' Prùmìrný cenový údaj
'        intervalStatsRange.Offset(intervalRowOffset, 0).Value = "Prùmìrná cena [Kè]"
'        If i = UBound(intervals) Then
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Cenový údaj").DataBodyRange.Address & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ")"
'        Else
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Cenový údaj").DataBodyRange.Address & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", ""<"" & " & intervals(i + 1) & ")"
'        End If
'        intervalStatsRange.Offset(intervalRowOffset, 1).NumberFormat = "#,##0"
'        intervalRowOffset = intervalRowOffset + 1
'
'
'
'        ' Pøesun na další sekci
'        intervalRowOffset = intervalRowOffset + 1
'    Next i
'End Sub

