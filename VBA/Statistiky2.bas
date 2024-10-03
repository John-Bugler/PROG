Attribute VB_Name = "Statistiky1"
' podrobne statistiky

Sub GenerujStatistiky()
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim statsRange As Range
    
    ' Nastaven� aktivn�ho listu a tabulky
    Set ws = ActiveSheet
    On Error Resume Next
    Set tbl = ActiveCell.ListObject
    On Error GoTo 0
    
    If tbl Is Nothing Then
        MsgBox "Aktivn� bunka nen� v ��dn� tabulce.", vbExclamation
        Exit Sub
    End If
    
    ' Nastaven� oblasti pro statistick� souhrn
    Set statsRange = ws.Range("AJ2")
    
    ' Vymaz�n� star�ch statistik
    ws.Range("AJ:AT").Clear
    
    ' Vlo�en� z�kladn�ch informac�
    ws.Range("AF1").Value = "LAT ="
    ws.Range("AH1").Value = "LON ="
    
    ' Generov�n� z�kladn�ch statistik
    GenerujZakladniStatistiky ws, tbl, statsRange
    
    ' Generov�n� podrobn�ch statistik
    GenerujPodrobneStatistiky ws, tbl, statsRange
    

End Sub

Sub GenerujZakladniStatistiky(ws As Worksheet, tbl As ListObject, statsRange As Range)
    ' Velikost vzorku
    statsRange.Value = "Velikost vzorku : "
    statsRange.Font.Bold = True
    statsRange.Offset(0, 1).Formula = "=ROWS(" & tbl.DataBodyRange.Address & ")"
    statsRange.Offset(0, 1).Font.Bold = True
    
    ' Pocet unik�tn�ch adres
    statsRange.Offset(1, 0).Value = "Pocet unik�tn�ch adres :"
    statsRange.Offset(1, 0).Font.Bold = True
    statsRange.Offset(1, 1).Formula = "=SUMPRODUCT(1/COUNTIF(" & tbl.ListColumns("Adresa").DataBodyRange.Address & "," & tbl.ListColumns("Adresa").DataBodyRange.Address & "))"
    statsRange.Offset(1, 1).Font.Bold = True
    
    ' Po�et unik�tn�ch hodnot v sloupci "Kat# �zem�"
    statsRange.Offset(2, 0).Value = "Po�et zastoupen�ch Katastr�ln�ch �zem� :"
    statsRange.Offset(2, 0).Font.Bold = True
    statsRange.Offset(2, 1).Formula = "=SUMPRODUCT(1/COUNTIF(" & tbl.ListColumns("Kat# �zem�").DataBodyRange.Address & "," & tbl.ListColumns("Kat# �zem�").DataBodyRange.Address & "))"
    statsRange.Offset(2, 1).Font.Bold = True
    
    
'     ' Inicializace slovn�ku
'    Set dict = CreateObject("Scripting.Dictionary")
'
'    ' Z�sk�n� sloupce "Kat# �zem�"
'    Set katUzemColumn = tbl.ListColumns("Kat# �zem�")
'
'    ' Proch�zen� hodnot v sloupci a p�id�n� do slovn�ku
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
'    ' Ur�en� v�stupn�ho rozsahu
'    Set outputRange = statsRange.Offset(4, 0)
'
'    ' Z�pis do listu
'    outputRange.Value = "Katastr�ln� �zem�"
'    outputRange.Font.Bold = True
'
'    outputRange.Offset(0, 1).Value = "Po�et"
'    outputRange.Offset(0, 1).Font.Bold = True
'
'    r = 1
'    For Each Key In dict.keys
'        outputRange.Offset(r, 0).Value = Key
'        outputRange.Offset(r, 1).Value = dict(Key)
'        r = r + 1
'    Next Key
'
'    ' Vy�i�t�n� slovn�ku
'    Set dict = Nothing
'
    
    ' Inicializace slovn�ku
    Set dict = CreateObject("Scripting.Dictionary")
    
    ' Z�sk�n� sloupce "Kat# �zem�" a dal��ch pot�ebn�ch sloupc�
    Set katUzemColumn = tbl.ListColumns("Kat# �zem�").DataBodyRange
    Set plochaColumn = tbl.ListColumns("Plocha [m2]").DataBodyRange
    Set jcColumn = tbl.ListColumns("JC [K�/m2]").DataBodyRange
    
    ' Struktura pro ukl�d�n� souvisej�c�ch dat (sou�et ploch, ceny, po�ty atd.)
    Set dataDict = CreateObject("Scripting.Dictionary")
    
    ' Proch�zen� hodnot v sloupci a p�id�n� do slovn�ku
    For i = 1 To katUzemColumn.Rows.Count
        katUzem = katUzemColumn.Cells(i, 1).Value
        plocha = plochaColumn.Cells(i, 1).Value
        jc = jcColumn.Cells(i, 1).Value
        
        If Not IsEmpty(katUzem) Then
            ' Inicializace datov�ch pol� pro ka�d� katastr�ln� �zem�
            If Not dataDict.exists(katUzem) Then
                dataDict.Add katUzem, Array(0, 0, 0, 0, 0, 0, 0, 0, 0, 0) ' (count, sumPlocha, minPlocha, maxPlocha, sumJC, minJC, maxJC, sumJCQ4, countJCQ4)
            End If
            
            ' Z�sk�n� existuj�c�ch dat
            uzemniData = dataDict(katUzem)
            
            ' Aktualizace po�tu a sou�tu ploch
            uzemniData(0) = uzemniData(0) + 1 ' Po�et z�znam�
            uzemniData(1) = uzemniData(1) + plocha ' Sou�et ploch
            
            ' Aktualizace min a max plochy
            If uzemniData(2) = 0 Or plocha < uzemniData(2) Then uzemniData(2) = plocha ' Min Plocha
            If plocha > uzemniData(3) Then uzemniData(3) = plocha ' Max Plocha
            
            ' Aktualizace sou�tu a min/max JC
            uzemniData(4) = uzemniData(4) + jc ' Sou�et JC
            If uzemniData(5) = 0 Or jc < uzemniData(5) Then uzemniData(5) = jc ' Min JC
            If jc > uzemniData(6) Then uzemniData(6) = jc ' Max JC
            
            ' Aktualizace sou�tu JC pro 4. kvartil
            If jc >= Application.WorksheetFunction.Quartile(jcColumn, 3) Then ' Hodnota ve 4. kvartilu
                uzemniData(7) = uzemniData(7) + jc ' Sou�et JC pro 4. kvartil
                uzemniData(8) = uzemniData(8) + 1 ' Po�et JC ve 4. kvartilu
            End If
            
            ' Ulo�en� zp�t do slovn�ku
            dataDict(katUzem) = uzemniData
        End If
    Next i
    
    ' Ur�en� v�stupn�ho rozsahu
    Set outputRange = statsRange.Offset(4, 0)
    
    ' Z�pis hlavi�ek do listu s form�tov�n�m

    outputRange.Value = "Katastr�ln� �zem�"
    outputRange.Font.Bold = True
    
    outputRange.Offset(0, 1).Value = "Po�et"
    outputRange.Offset(0, 1).Font.Bold = True
    
    outputRange.Offset(0, 2).Value = "Min Plocha [m2]"
    outputRange.Offset(0, 2).Font.Bold = True
    
    outputRange.Offset(0, 3).Value = "AVG Plocha [m2]"
    outputRange.Offset(0, 3).Font.Bold = True
    
    
    outputRange.Offset(0, 4).Value = "Max Plocha [m2]"
    outputRange.Offset(0, 4).Font.Bold = True
    
    
    outputRange.Offset(0, 5).Value = "Min JC [K�/m2]"
    outputRange.Offset(0, 5).Font.Bold = True
    
    
    outputRange.Offset(0, 6).Value = "AVG JC [K�/m2]"
    outputRange.Offset(0, 6).Font.Bold = True
    
    
    outputRange.Offset(0, 7).Value = "Max JC [K�/m2]"
    outputRange.Offset(0, 7).Font.Bold = True
    
    
    outputRange.Offset(0, 8).Value = "Po�et JC (Q4)"
    outputRange.Offset(0, 8).Font.Bold = True
    
    
    outputRange.Offset(0, 9).Value = "AVG JC (Q4) [K�/m2]"
    outputRange.Offset(0, 9).Font.Bold = True
    
    
    
    ' Proch�zen� v�sledk� a z�pis do listu
    r = 1
    For Each Key In dataDict.keys
        uzemniData = dataDict(Key)
        
        outputRange.Offset(r, 0).Value = Key ' Katastr�ln� �zem�
        outputRange.Offset(r, 1).Value = uzemniData(0) ' Po�et
        
        ' Zaokrouhlen� plochy na 2 desetinn� m�sta
        outputRange.Offset(r, 2).Value = Round(uzemniData(2), 2) ' Min Plocha
        outputRange.Offset(r, 3).Value = Round(uzemniData(1) / uzemniData(0), 2) ' AVG Plocha
        outputRange.Offset(r, 4).Value = Round(uzemniData(3), 2) ' Max Plocha
        
        ' Zaokrouhlen� JC na cel� ��sla s odd�lova�em tis�c�
        outputRange.Offset(r, 5).Value = Round(uzemniData(5), 0) ' Min JC
        outputRange.Offset(r, 5).NumberFormat = "#,##0" ' Form�t pro odd�len� tis�c�
        
        outputRange.Offset(r, 6).Value = Round(uzemniData(4) / uzemniData(0), 0) ' AVG JC
        outputRange.Offset(r, 6).NumberFormat = "#,##0" ' Form�t pro odd�len� tis�c�
        
        outputRange.Offset(r, 7).Value = Round(uzemniData(6), 0) ' Max JC
        outputRange.Offset(r, 7).NumberFormat = "#,##0" ' Form�t pro odd�len� tis�c�
        
        ' Po�et JC ve 4. kvartilu
        outputRange.Offset(r, 8).Value = uzemniData(8) ' Po�et JC ve 4. kvartilu
        
        ' Pr�m�r JC ve 4. kvartilu, pokud existuj� hodnoty
        If uzemniData(8) > 0 Then
            outputRange.Offset(r, 9).Value = Round(uzemniData(7) / uzemniData(8), 0) ' AVG JC pro 4. kvartil
            outputRange.Offset(r, 9).NumberFormat = "#,##0" ' Form�t pro odd�len� tis�c�
        Else
            outputRange.Offset(r, 9).Value = "N/A" ' Pokud nejsou ��dn� hodnoty ve 4. kvartilu
        End If
        
        r = r + 1
    Next Key
    
    ' Vy�i�t�n� slovn�k�
    Set dict = Nothing
    Set dataDict = Nothing
    

    
End Sub

Sub GenerujPodrobneStatistiky(ws As Worksheet, tbl As ListObject, statsRange As Range)
    Dim headers As Variant
    Dim columns As Variant
    Dim i As Integer
    Dim rowOffset As Integer
    Dim colOffset As Integer
    
    ' Nastaven� hlavicek a sloupcu pro statistiky
    headers = Array("Pr�m�r", "Minimum", "Prvn� kvartil", "Medi�n", "T�et� kvartil", "Maximum")
    columns = Array("Datum pod�n�", "Plocha [m2]", "JC [K�/m2]", "Vzd�lenost [Km]", "Cenov� �daj")
    
    ' Vytvoren� z�hlav� parametru vzorku (Prumer, Minimum atd.)
    rowOffset = 15
    statsRange.Offset(rowOffset - 1, 0).Value = "Charakteristiky vzorku jako celku"
    statsRange.Offset(rowOffset - 1, 0).Font.Bold = True
    For i = LBound(headers) To UBound(headers)
        statsRange.Offset(rowOffset, 0).Value = headers(i)
        statsRange.Offset(rowOffset, 0).Font.Bold = True
        rowOffset = rowOffset + 1
    Next i
    
    ' Vytvoren� sloupcu pro jednotliv� hodnoty (Datum pod�n�, Plocha atd.)
    colOffset = 1
    For i = LBound(columns) To UBound(columns)
        ' Z�hlav� sloupcu
        statsRange.Offset(rowOffset - UBound(headers) - 2, colOffset).Value = columns(i)
        statsRange.Offset(rowOffset - UBound(headers) - 2, colOffset).Font.Bold = True
        
        ' Vyplnen� statistik pro ka�d� parametr vzorku
        VyplnStatistikySloupce ws, tbl, statsRange, CStr(columns(i)), colOffset, rowOffset - UBound(headers) - 2
        
        ' Posunout o jeden sloupec pro dal�� hodnoty
        colOffset = colOffset + 1
    Next i
    
        ' Generov�n� statistik pro intervaly
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
    
    ' Nastaven� vzorc�
    With statsRange
        .Offset(rowOffset + 1, colOffset).Formula = "=AVERAGE(" & col.DataBodyRange.Address(True, True, xlA1, True) & ")"
        .Offset(rowOffset + 2, colOffset).Formula = "=MIN(" & col.DataBodyRange.Address(True, True, xlA1, True) & ")"
        .Offset(rowOffset + 3, colOffset).Formula = "=QUARTILE(" & col.DataBodyRange.Address(True, True, xlA1, True) & ", 1)"
        .Offset(rowOffset + 4, colOffset).Formula = "=MEDIAN(" & col.DataBodyRange.Address(True, True, xlA1, True) & ")"
        .Offset(rowOffset + 5, colOffset).Formula = "=QUARTILE(" & col.DataBodyRange.Address(True, True, xlA1, True) & ", 3)"
        .Offset(rowOffset + 6, colOffset).Formula = "=MAX(" & col.DataBodyRange.Address(True, True, xlA1, True) & ")"
    End With

    ' Aplikace form�tov�n�
    Dim rng As Range
 
    Set rng = statsRange.Resize(6, 1).Offset(rowOffset, colOffset)
    
    Select Case columnName
        Case "Datum pod�n�"
            rng.NumberFormat = "d/m/yyyy"  ' Kr�tk� datum
        Case "Plocha [m2]", "Vzd�lenost [Km]"
            rng.NumberFormat = "#,##0.00"  ' ��sla s dv�ma desetinn�mi m�sty
        Case "JC [K�/m2]", "Cenov� �daj"
            rng.NumberFormat = "#,##0"  ' ��sla bez desetinn�ch m�st
    End Select
    
End Sub


Sub GenerujIntervaloveStatistiky(ws As Worksheet, tbl As ListObject, statsRange As Range, rowOffset As Integer)
    Dim intervals As Variant
    Dim intervalNames As Variant
    Dim intervalStatsRange As Range
    Dim intervalRowOffset As Integer
    Dim intervalColOffset As Integer
    Dim i As Integer

    ' Definov�n� interval� a jejich n�zv�
    intervals = Array(0, 42, 67, 87, 122)
    intervalNames = Array("0 - 41,99 [m2], (1 pokoj)", "42 - 66,99 [m2], (2 pokoje)", "67 - 86,99 [m2], (3 pokoje)", "87 - 121,99 [m2], (4 pokoje)", "> 122 [m2], (5 a v�ce pokoj�)")

    statsRange.Offset(rowOffset + 2, 0).Value = "Charakteristiky vzorku dle dispozic"
    statsRange.Offset(rowOffset + 2, 0).Font.Bold = True
    
    ' Nastaven� oblasti pro statistiky interval�
    Set intervalStatsRange = statsRange.Offset(rowOffset + 2, 0)
    intervalRowOffset = 1
    intervalColOffset = 1
    
    ' Zadejte n�zvy parametr� pouze jednou do prvn�ho sloupce
    intervalStatsRange.Offset(intervalRowOffset, 0).Value = "Po�et z�znam�"
    intervalStatsRange.Offset(intervalRowOffset + 1, 0).Value = "Pr�m�rn� plocha [m2]"
    intervalStatsRange.Offset(intervalRowOffset + 2, 0).Value = "Pr�m�rn� JC [K�/m2]"
    intervalStatsRange.Offset(intervalRowOffset + 3, 0).Value = "Pr�m�rn� cena [K�]"
    
    intervalStatsRange.Offset(intervalRowOffset, 0).Font.Bold = True
    intervalStatsRange.Offset(intervalRowOffset + 1, 0).Font.Bold = True
    intervalStatsRange.Offset(intervalRowOffset + 2, 0).Font.Bold = True
    intervalStatsRange.Offset(intervalRowOffset + 3, 0).Font.Bold = True

    
    
    For i = LBound(intervals) To UBound(intervals)
        ' Nastaven� n�zvu intervalu
        intervalStatsRange.Offset(0, intervalColOffset).Value = intervalNames(i)
        intervalStatsRange.Offset(0, intervalColOffset).Font.Bold = True
        
        ' Po�et z�znam�
        If i = UBound(intervals) Then
            intervalStatsRange.Offset(1, intervalColOffset).Formula = "=COUNTIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ")"
        Else
            intervalStatsRange.Offset(1, intervalColOffset).Formula = "=COUNTIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", ""<"" & " & intervals(i + 1) & ")"
        End If
        intervalStatsRange.Offset(1, intervalColOffset).NumberFormat = "#,##"
        
        ' Pr�m�rn� plocha [m2]
        If i = UBound(intervals) Then
            intervalStatsRange.Offset(2, intervalColOffset).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ")"
        Else
            intervalStatsRange.Offset(2, intervalColOffset).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", ""<"" & " & intervals(i + 1) & ")"
        End If
        intervalStatsRange.Offset(2, intervalColOffset).NumberFormat = "#,##0.00"
        
        ' Pr�m�rn� JC [K�/m2]
        If i = UBound(intervals) Then
            intervalStatsRange.Offset(3, intervalColOffset).Formula = "=AVERAGEIFS(" & tbl.ListColumns("JC [K�/m2]").DataBodyRange.Address(True, True, xlA1, True) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ")"
        Else
            intervalStatsRange.Offset(3, intervalColOffset).Formula = "=AVERAGEIFS(" & tbl.ListColumns("JC [K�/m2]").DataBodyRange.Address(True, True, xlA1, True) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", ""<"" & " & intervals(i + 1) & ")"
        End If
        intervalStatsRange.Offset(3, intervalColOffset).NumberFormat = "#,##0"
        
        ' Pr�m�rn� cena [K�]
        If i = UBound(intervals) Then
            intervalStatsRange.Offset(4, intervalColOffset).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Cenov� �daj").DataBodyRange.Address(True, True, xlA1, True) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ")"
        Else
            intervalStatsRange.Offset(4, intervalColOffset).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Cenov� �daj").DataBodyRange.Address(True, True, xlA1, True) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address(True, True, xlA1, True) & ", ""<"" & " & intervals(i + 1) & ")"
        End If
        intervalStatsRange.Offset(4, intervalColOffset).NumberFormat = "#,##0"
        
        ' Posun na dal�� interval (ka�d� interval zabere 1 sloupec)
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
'    ' Nastaven� aktivn�ho listu a tabulky
'    Set ws = ActiveSheet
'
'    ' Zji�t�n�, ve kter� tabulce se nach�z� aktivn� bu�ka
'    On Error Resume Next
'    Set tbl = ActiveCell.ListObject
'    On Error GoTo 0
'
'    If tbl Is Nothing Then
'        MsgBox "Aktivn� bu�ka nen� v ��dn� tabulce.", vbExclamation
'        Exit Sub
'    End If
'
'    ' Nastaven� polohy kde bude n�sledn� vlo�ena GPS souradnice oce�ovan� nemovitosti
'    ws.Range("AB1").Value = "LAT ="
'    ws.Range("AB2").Value = "LON ="
'
'
'    ' Nastaven� oblasti pro statistick� souhrn
'    Set statsRange = ws.Range("AF1")
'
'    ' Vymaz�n� star�ch statistik
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
'    ' Po�et unik�tn�ch adres
'    statsRange.Offset(1, 0).Value = "Po�et unik�tn�ch adres :"
'    statsRange.Offset(1, 0).Font.Bold = True
'    statsRange.Offset(1, 1).Formula = "=SUMPRODUCT(1/COUNTIF(" & tbl.ListColumns("Adresa").DataBodyRange.Address & "," & tbl.ListColumns("Adresa").DataBodyRange.Address & "))"
'    statsRange.Offset(1, 1).Font.Bold = True
'
'    ' Nastaven� hlavi�ek a sloupc� pro statistiky
'    headers = Array("Datum pod�n�", "Plocha [m2]", "JC [K�/m2]", "Vzd�lenost [Km]", "Cenov� �daj [K�]")
'    columns = Array("Datum pod�n�", "Plocha [m2]", "JC [K�/m2]", "Vzd�lenost [Km]", "Cenov� �daj")
'
'    ' Vypln�n� statistik
'    rowOffset = 3 ' Za��n� na ��dku 2 pod nadpisem
'    For i = LBound(headers) To UBound(headers)
'        ' N�zev parametru
'        statsRange.Offset(rowOffset, 0).Value = headers(i)
'        statsRange.Offset(rowOffset, 0).Font.Bold = True
'        rowOffset = rowOffset + 1
'
'        ' Nastaven� sloupce pro vzorce
'        columnIndex = tbl.ListColumns(columns(i)).Index
'
'        ' Vypo��tat pr�m�r
'        statsRange.Offset(rowOffset, 0).Value = "Pr�m�r"
'        With statsRange.Offset(rowOffset, 1)
'            .Formula = "=AVERAGE(" & tbl.ListColumns(columns(i)).DataBodyRange.Address & ")"
'            If headers(i) = "Datum pod�n�" Then
'                .NumberFormat = "dd/mm/yyyy"
'            ElseIf headers(i) = "Plocha [m2]" Or headers(i) = "Vzd�lenost [Km]" Then
'                .NumberFormat = "#,##0.00"
'            ElseIf headers(i) = "JC [K�/m2]" Or headers(i) = "Cenov� �daj" Then
'                .NumberFormat = "#,##0"
'            End If
'        End With
'        rowOffset = rowOffset + 1
'
'        ' Minimum
'        statsRange.Offset(rowOffset, 0).Value = "Minimum"
'        With statsRange.Offset(rowOffset, 1)
'            .Formula = "=MIN(" & tbl.ListColumns(columns(i)).DataBodyRange.Address & ")"
'            If headers(i) = "Datum pod�n�" Then
'                .NumberFormat = "dd/mm/yyyy"
'            ElseIf headers(i) = "Plocha [m2]" Or headers(i) = "Vzd�lenost [Km]" Then
'                .NumberFormat = "#,##0.00"
'            ElseIf headers(i) = "JC [K�/m2]" Or headers(i) = "Cenov� �daj" Then
'                .NumberFormat = "#,##0"
'            End If
'        End With
'        rowOffset = rowOffset + 1
'
'        ' Prvn� kvartil
'        statsRange.Offset(rowOffset, 0).Value = "Prvn� kvartil"
'        With statsRange.Offset(rowOffset, 1)
'            .Formula = "=QUARTILE(" & tbl.ListColumns(columns(i)).DataBodyRange.Address & ", 1)"
'            If headers(i) = "Datum pod�n�" Then
'                .NumberFormat = "dd/mm/yyyy"
'            ElseIf headers(i) = "Plocha [m2]" Or headers(i) = "Vzd�lenost [Km]" Then
'                .NumberFormat = "#,##0.00"
'            ElseIf headers(i) = "JC [K�/m2]" Or headers(i) = "Cenov� �daj" Then
'                .NumberFormat = "#,##0"
'            End If
'        End With
'        rowOffset = rowOffset + 1
'
'        ' Medi�n
'        statsRange.Offset(rowOffset, 0).Value = "Medi�n"
'        With statsRange.Offset(rowOffset, 1)
'            .Formula = "=MEDIAN(" & tbl.ListColumns(columns(i)).DataBodyRange.Address & ")"
'            If headers(i) = "Datum pod�n�" Then
'                .NumberFormat = "dd/mm/yyyy"
'            ElseIf headers(i) = "Plocha [m2]" Or headers(i) = "Vzd�lenost [Km]" Then
'                .NumberFormat = "#,##0.00"
'            ElseIf headers(i) = "JC [K�/m2]" Or headers(i) = "Cenov� �daj" Then
'                .NumberFormat = "#,##0"
'            End If
'        End With
'        rowOffset = rowOffset + 1
'
'        ' T�et� kvartil
'        statsRange.Offset(rowOffset, 0).Value = "T�et� kvartil"
'        With statsRange.Offset(rowOffset, 1)
'            .Formula = "=QUARTILE(" & tbl.ListColumns(columns(i)).DataBodyRange.Address & ", 3)"
'            If headers(i) = "Datum pod�n�" Then
'                .NumberFormat = "dd/mm/yyyy"
'            ElseIf headers(i) = "Plocha [m2]" Or headers(i) = "Vzd�lenost [Km]" Then
'                .NumberFormat = "#,##0.00"
'            ElseIf headers(i) = "JC [K�/m2]" Or headers(i) = "Cenov� �daj" Then
'                .NumberFormat = "#,##0"
'            End If
'        End With
'        rowOffset = rowOffset + 1
'
'        ' Maximum
'        statsRange.Offset(rowOffset, 0).Value = "Maximum"
'        With statsRange.Offset(rowOffset, 1)
'            .Formula = "=MAX(" & tbl.ListColumns(columns(i)).DataBodyRange.Address & ")"
'            If headers(i) = "Datum pod�n�" Then
'                .NumberFormat = "dd/mm/yyyy"
'            ElseIf headers(i) = "Plocha [m2]" Or headers(i) = "Vzd�lenost [Km]" Then
'                .NumberFormat = "#,##0.00"
'            ElseIf headers(i) = "JC [K�/m2]" Or headers(i) = "Cenov� �daj" Then
'                .NumberFormat = "#,##0"
'            End If
'        End With
'        rowOffset = rowOffset + 1
'
'        ' P�esun na dal�� sekci
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
'    intervalNames = Array("0 - 41,99 [m2], (1 pokoj)", "42 - 66,99 [m2], (2 pokoje)", "67 - 86,99 [m2], (3 pokoje)", "87 - 121,99 [m2], (4 pokoje)", "> 122 [m2], (5 a v�ce pokoj�)")
'
'    Set intervalStatsRange = ws.Range("AF" & rowOffset + 2)
'    intervalRowOffset = 0
'
'    For i = LBound(intervals) To UBound(intervals)
'        intervalStatsRange.Offset(intervalRowOffset, 0).Value = intervalNames(i)
'        intervalStatsRange.Offset(intervalRowOffset, 0).Font.Bold = True
'        intervalRowOffset = intervalRowOffset + 1
'
'        ' Po�et z�znam�
'        intervalStatsRange.Offset(intervalRowOffset, 0).Value = "Po�et z�znam�"
'        If i = UBound(intervals) Then
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=COUNTIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ")"
'        Else
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=COUNTIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", ""<"" & " & intervals(i + 1) & ")"
'        End If
'        intervalStatsRange.Offset(intervalRowOffset, 1).NumberFormat = "#,##"
'        intervalRowOffset = intervalRowOffset + 1
'
'
'        ' Pr�m�rn� plocha [m2]
'        intervalStatsRange.Offset(intervalRowOffset, 0).Value = "Pr�m�rn� plocha [m2]"
'        If i = UBound(intervals) Then
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ")"
'        Else
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", ""<"" & " & intervals(i + 1) & ")"
'        End If
'        intervalStatsRange.Offset(intervalRowOffset, 1).NumberFormat = "#,##0.00"
'        intervalRowOffset = intervalRowOffset + 1
'
'
'        ' Pr�m�rn� JC
'        intervalStatsRange.Offset(intervalRowOffset, 0).Value = "Pr�m�rn� JC [K�/m2]"
'        If i = UBound(intervals) Then
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=AVERAGEIFS(" & tbl.ListColumns("JC [K�/m2]").DataBodyRange.Address & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ")"
'        Else
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=AVERAGEIFS(" & tbl.ListColumns("JC [K�/m2]").DataBodyRange.Address & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", ""<"" & " & intervals(i + 1) & ")"
'        End If
'        intervalStatsRange.Offset(intervalRowOffset, 1).NumberFormat = "#,##0"
'        intervalRowOffset = intervalRowOffset + 1
'
'
'        ' Pr�m�rn� cenov� �daj
'        intervalStatsRange.Offset(intervalRowOffset, 0).Value = "Pr�m�rn� cena [K�]"
'        If i = UBound(intervals) Then
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Cenov� �daj").DataBodyRange.Address & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ")"
'        Else
'            intervalStatsRange.Offset(intervalRowOffset, 1).Formula = "=AVERAGEIFS(" & tbl.ListColumns("Cenov� �daj").DataBodyRange.Address & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", "">="" & " & intervals(i) & ", " & tbl.ListColumns("Plocha [m2]").DataBodyRange.Address & ", ""<"" & " & intervals(i + 1) & ")"
'        End If
'        intervalStatsRange.Offset(intervalRowOffset, 1).NumberFormat = "#,##0"
'        intervalRowOffset = intervalRowOffset + 1
'
'
'
'        ' P�esun na dal�� sekci
'        intervalRowOffset = intervalRowOffset + 1
'    Next i
'End Sub

