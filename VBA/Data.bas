Attribute VB_Name = "Data"
' globalni promene

Dim tblData_All As ListObject

Sub NacteniDatValuo()
    ' Prom�nn�
    Dim FolderPath As String
    Dim FileName As String
    Dim TargetWs As Worksheet
    Dim FilePath As String
    Dim TotalFiles As Long
    Dim TotalRows As Long
    Dim ProcessedFiles As Long
    Dim lastRow As Long
    Dim NextRow As Long
    Dim wb As Workbook
    Dim sheetName As String
    
    Dim timestamp As String
    
    ' Nastavit aktu�ln� se�it jako c�lov� se�it
    Set wb = ActiveWorkbook
    
    ' Vytvo�it �asov� raz�tko
    timestamp = Format(Now, "yyyymmdd_HHmm")
    sheetName = "data_all_" & timestamp
    
    ' Vyberte slo�ku, kde se nach�zej� soubory
    With Application.FileDialog(msoFileDialogFolderPicker)
        .Title = "Vyberte slo�ku, kde se nach�zej� Excel soubory"
        If .Show = -1 Then
            FolderPath = .SelectedItems(1) & "\"
        Else
            MsgBox "Nebyla vybr�na ��dn� slo�ka.", vbExclamation
            Exit Sub
        End If
    End With

    ' Vypnout aktualizaci obrazovky, varovn� hl�ky a automatick� p�epo�ty
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
    Application.Calculation = xlCalculationManual
    
    ' Zkontrolovat, zda ji� existuje list s n�zvem "data_all", a v p��pad� pot�eby p�ejmenovat
    On Error Resume Next
    Set TargetWs = wb.Sheets(sheetName)
    On Error GoTo 0
    
    If TargetWs Is Nothing Then
        ' Pokud list neexistuje, vytvo�te nov�
        Set TargetWs = wb.Sheets.Add
        TargetWs.Name = sheetName
        Debug.Print "Vytvo�en nov� list s n�zvem: " & sheetName
    Else
        ' Pokud list ji� existuje, vyma�te jeho obsah
        TargetWs.Cells.Clear
        Debug.Print "Existuj�c� list s n�zvem: " & sheetName & " vymaz�n."
    End If
    
    ' Nastavit po��tadla
    TotalFiles = 0
    TotalRows = 0
    ProcessedFiles = 0
    NextRow = 1 ' Nastavit po��te�n� ��dek pro vkl�d�n� dat
    
    ' Hlavn� cyklus pro na��t�n� v�ech Excel soubor� v zadan� slo�ce
    FileName = Dir(FolderPath & "*.xlsx")
    
    Do While FileName <> ""
        FilePath = FolderPath & FileName
        
        ' Zobrazit n�zev aktu�ln� zpracov�van�ho souboru
        Debug.Print "--------------------------------------------------"
        Debug.Print "Na��t�n� souboru: " & FileName
        Debug.Print "--------------------------------------------------"
        
        ' Na��st data z ka�d�ho souboru
        lastRow = ImportData(FilePath, "Worksheet", TargetWs, NextRow)
        
        ' Pokud byly data �sp�n� vlo�ena
        If lastRow > 0 Then
            ProcessedFiles = ProcessedFiles + 1
            TotalRows = TotalRows + lastRow
            NextRow = NextRow + lastRow ' Aktualizovat ��dek pro dal�� vkl�d�n� dat
            'MsgBox "Soubor: " & FileName & vbCrLf & _
            '       "Po�et ��dk�: " & lastRow & vbCrLf & _
            '       "Data byla �sp�n� vlo�ena." & vbCrLf & _
            '       "Pokra�ujte na dal�� soubor.", vbInformation
        Else
            'MsgBox "Soubor: " & FileName & vbCrLf & _
            '       "��dn� data ke vlo�en� nebo chyba p�i na��t�n�.", vbExclamation
        End If
        
        ' Dal�� soubor
        FileName = Dir
        TotalFiles = TotalFiles + 1
    Loop

    ' Obnovit p�vodn� nastaven�
    Application.ScreenUpdating = True
    Application.DisplayAlerts = True
    Application.Calculation = xlCalculationAutomatic

    ' Upozorn�n�, �e makro dokon�ilo na��t�n� dat
    MsgBox "Na�ten� dat dokon�eno!" & vbCrLf & _
           "Celkov� po�et zpracovan�ch soubor�: " & ProcessedFiles & vbCrLf & _
           "Celkov� po�et ��dk�: " & TotalRows, vbInformation



    ' Vol�n� procedury pro �pravu a form�tov�n� dat v hlavni tabulce data_all
    Call UpravitTabulkuData_All(TargetWs)
    
    ' Vizu�ln� form�tov�n� tabulky
    Call FormatTable(sheetName, tblData_All.Name)

    
    
    ' Kop�rov�n� hlavn� tabulky data_all na novou a extrakce z�znam� dle parametr�
    ' n�zev nov� tabulky + timestamp, list zdrojov� tabulky, prom�nn� typu object zdrojov� tabulky, n�zev sloupce pro �pravu z�znam�, z�znam kter� chci ponmechat
    
     
     
'     Dim pokracovat As VbMsgBoxResult
'
'    ' Dotaz na u�ivatele, zda chce spustit dal�� proceduru
'     pokracovat = MsgBox("Chcete p�idat list jen s byty?", vbYesNo + vbQuestion, "Potvrzen�")
'
'     If pokracovat = vbYes Then
'        Call CopyAndModifyTable("data_byty_", timestamp, "data_byty", tblData_All, "Typ", "byt")
'     End If
'
'
'     ' Dotaz na u�ivatele, zda chce spustit dal�� proceduru
'     pokracovat = MsgBox("Chcete p�idat list jen s rodinn�mi domy?", vbYesNo + vbQuestion, "Potvrzen�")
'
'     If pokracovat = vbYes Then
'        Call CopyAndModifyTable("data_rd_", timestamp, "data_rd", tblData_All, "Typ", "rodinn� d�m")
'     End If
'
'
'     ' Dotaz na u�ivatele, zda chce spustit dal�� proceduru
'     pokracovat = MsgBox("Chcete p�idat list jen s pozemky?", vbYesNo + vbQuestion, "Potvrzen�")
'
'     If pokracovat = vbYes Then
'        Call CopyAndModifyTable("data_pozemky_", timestamp, "data_pozemky", tblData_All, "Nemovitost", "parcela")
'     End If
'
'     ' Dotaz na u�ivatele, zda chce spustit dal�� proceduru
'     pokracovat = MsgBox("Chcete p�idat list jen s gar�emi?", vbYesNo + vbQuestion, "Potvrzen�")
'
'     If pokracovat = vbYes Then
'        Call CopyAndModifyTable("data_garaze_", timestamp, "data_garaze", tblData_All, "Typ", "gar�")
'     End If
'

    
End Sub


' Funkce na�ita postupn� data ze v�ech .xlsx souboru ve zvolen� slo�ce
Function ImportData(FilePath As String, sheetName As String, TargetWs As Worksheet, NextRow As Long) As Long
    ' Prom�nn�
    Dim ConnString As String
    Dim Conn As Object
    Dim SQLQuery As String
    Dim rs As Object
    Dim ColumnCount As Long
    Dim DataRow As Long
    Dim FieldNames As String
    Dim RowCount As Long
    
    ' P�ipojen� ke zdrojov�mu Excel souboru
    ConnString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & FilePath & ";Extended Properties=""Excel 12.0 Xml;HDR=Yes"";"
    Set Conn = CreateObject("ADODB.Connection")
    On Error GoTo ErrorHandler
    Conn.Open ConnString
    
    ' Zobrazit p�ipojovac� �et�zec
    Debug.Print "P�ipojeno k: " & FilePath
    
    ' SQL dotaz pro na�ten� dat
    SQLQuery = "SELECT * FROM [" & sheetName & "$]"
    Debug.Print "Dotaz: " & SQLQuery
    
    Set rs = CreateObject("ADODB.Recordset")
    rs.Open SQLQuery, Conn
    
    ' Zkontrolovat, zda jsou data v rekordsetu
    If rs.EOF Then
        Debug.Print "��dn� data v souboru: " & FilePath
        rs.Close
        Conn.Close
        Set rs = Nothing
        Set Conn = Nothing
        ImportData = 0
        Exit Function
    End If
    
    ' Vlo�en� dat do c�lov�ho listu
    If Not rs.EOF Then
        ' Pokud je c�lov� list pr�zdn�, vlo�it z�hlav�
        If NextRow = 1 Then
            ' Vlo�it z�hlav�
            FieldNames = "Z�hlav�: "
            For ColumnCount = 0 To rs.Fields.Count - 1
                TargetWs.Cells(NextRow, ColumnCount + 1).Value = rs.Fields(ColumnCount).Name
                FieldNames = FieldNames & rs.Fields(ColumnCount).Name & ", "
            Next ColumnCount
            FieldNames = Left(FieldNames, Len(FieldNames) - 2) ' Odstranit posledn� ��rku
            Debug.Print FieldNames
            NextRow = NextRow + 1
        End If
        
        ' Vlo�it data
        DataRow = NextRow
        RowCount = 0
        Do Until rs.EOF
            Dim RowData As String
            RowData = "��dek " & DataRow - NextRow + 1 & ": "
            For ColumnCount = 0 To rs.Fields.Count - 1
                TargetWs.Cells(DataRow, ColumnCount + 1).Value = rs.Fields(ColumnCount).Value
                RowData = RowData & rs.Fields(ColumnCount).Value & ", "
            Next ColumnCount
            RowData = Left(RowData, Len(RowData) - 2) ' Odstranit posledn� ��rku
            Debug.Print RowData
            DataRow = DataRow + 1
            rs.MoveNext
            RowCount = RowCount + 1
        Loop
        Debug.Print "Data vlo�ena ze souboru: " & FilePath
        ImportData = RowCount
    End If
    
    ' Zav��t p�ipojen�
    rs.Close
    Conn.Close
    Set rs = Nothing
    Set Conn = Nothing
    Exit Function

ErrorHandler:
    MsgBox "Chyba p�i na��t�n� souboru: " & FilePath & vbCrLf & "Chyba: " & Err.Description, vbExclamation
    If Not rs Is Nothing Then
        If rs.State = adStateOpen Then rs.Close
    End If
    If Not Conn Is Nothing Then
        If Conn.State = adStateOpen Then Conn.Close
    End If
    Set rs = Nothing
    Set Conn = Nothing
    ImportData = 0
End Function


Sub UpravitTabulkuData_All(TargetWs As Worksheet)
    ' Hlavni/vsechna data nactena z valuo souboru upravena a naformatovana
   
    Dim headerRange As Range
    Dim firstColumnRange As Range
    
   
    Dim noveSloupce As Variant
    Dim pozice As Integer
    Dim vzorec As String
    Dim i As Long
    
    ' Definovat rozsah dat
    ' TargetWs.Range("A1"): Toto ozna�uje bu�ku A1 na listu TargetWs.
    ' CurrentRegion: Tato vlastnost vrac� oblast soused�c�ch bun�k, kter� obsahuje data a je ohrani�ena pr�zdn�mi ��dky a sloupci.
    ' Jin�mi slovy, CurrentRegion zahrnuje v�echny bu�ky, kter� jsou spojeny s bu�kou A1 a obsahuj� data.
    
    Set headerRange = TargetWs.Range("A1").CurrentRegion
    
    
    ' Toto ozna�uje rozsah od bu�ky A2 a� po posledn� ��dek v prvn�m sloupci, kter� obsahuje data.
    Set firstColumnRange = TargetWs.Range("A2:A" & headerRange.Rows.Count)
    
    ' Vytvo�it tabulku
    ' TargetWs.ListObjects.Add: Tato metoda p�id� nov� objekt tabulky (ListObject) na list TargetWs.
    ' xlSrcRange: Tento argument specifikuje, �e zdroj dat pro tabulku je rozsah bun�k.
    ' headerRange: Tento argument specifikuje rozsah bun�k, kter� budou pou�ity jako zdroj dat pro tabulku.
    ' xlYes: Tento argument specifikuje, �e prvn� ��dek headerRange obsahuje z�hlav� sloupc�.
    
    Set tblData_All = TargetWs.ListObjects.Add(xlSrcRange, headerRange, , xlYes)
    tblData_All.Name = "data_all"
    
    ' Prejmenov�n� sloupce s plochou
    tblData_All.ListColumns("Plocha (v m2)").Name = "Plocha [m2]"
    
    
    '------------------------------------------------------------------------------------------------
    pozice = 7 ' M�sto, kam p�idat nov� sloupce (za 7 sloupec, coz je adresa)
    
    ' Definujte nov� n�zvy sloupc�
    noveSloupce = Array("LAT", "LON", "Vzd�lenost [Km]")
    
    ' Definujte vzorec pro p�idan� sloupec Vzd�lenost [Km]
    vzorec = "=6371*ARCCOS(COS(RADIANS([@LAT]))*COS(RADIANS($AC$1))*COS(RADIANS($AC$2)-RADIANS([@LON]))+SIN(RADIANS([@LAT]))*SIN(RADIANS($AC$1)))"
    
    ' P�idat nov� sloupce
    For i = 0 To UBound(noveSloupce)
        tblData_All.ListColumns.Add (pozice + i)
        tblData_All.ListColumns(pozice + i).Name = noveSloupce(i)
    Next i
    
    ' Vlo�en� vzorce pro vzd�lenost
    
     With tblData_All.ListColumns(pozice + 2).DataBodyRange
        .Formula = vzorec
     End With
    '------------------------------------------------------------------------------------------------
    
    
    
    
    

    ' P�idat nov� sloupce s v�po�ty
    With tblData_All
        .ListColumns.Add.Name = "nem"
        .ListColumns("nem").DataBodyRange.Formula = "=COUNTIF([��slo vkladu],[@[��slo vkladu]])"

        .ListColumns.Add.Name = "jednotka"
        .ListColumns("jednotka").DataBodyRange.Formula = "=COUNTIFS([��slo vkladu],[@[��slo vkladu]],[Nemovitost],""jednotka"")"
        
        
        .ListColumns.Add.Name = "byt"
        .ListColumns("byt").DataBodyRange.Formula = "=COUNTIFS([��slo vkladu],[@[��slo vkladu]],[Typ],""byt"")+COUNTIFS([��slo vkladu],[@[��slo vkladu]],[Typ],""ateli�r"")"


        .ListColumns.Add.Name = "budova"
        .ListColumns("budova").DataBodyRange.Formula = "=COUNTIFS([��slo vkladu],[@[��slo vkladu]],[Nemovitost],""budova"")"

        .ListColumns.Add.Name = "parcela"
        .ListColumns("parcela").DataBodyRange.Formula = "=COUNTIFS([��slo vkladu],[@[��slo vkladu]],[Nemovitost],""parcela"")"

        .ListColumns.Add.Name = "rd"
        .ListColumns("rd").DataBodyRange.Formula = "=COUNTIFS([��slo vkladu],[@[��slo vkladu]],[Typ],""rodinn� d�m"")"

        .ListColumns.Add.Name = "gar�"
        .ListColumns("gar�").DataBodyRange.Formula = "=COUNTIFS([��slo vkladu],[@[��slo vkladu]],[Typ],""gar�"")"

        .ListColumns.Add.Name = "SUM Plocha byt� dle ��zen� [m2]"
        .ListColumns("SUM Plocha byt� dle ��zen� [m2]").DataBodyRange.Formula = "=SUMIFS([Plocha '[m2']],[��slo vkladu],[@[��slo vkladu]],[Typ],""byt"") + SUMIFS([Plocha '[m2']],[��slo vkladu],[@[��slo vkladu]],[Typ],""ateli�r"")"

        .ListColumns.Add.Name = "SUM Cena byt� dle ��zen� [K�]"
        .ListColumns("SUM Cena byt� dle ��zen� [K�]").DataBodyRange.Formula = "=IFERROR(AVERAGEIFS([Cenov� �daj],[��slo vkladu],[@[��slo vkladu]],[Typ],""byt""),0) + IFERROR(AVERAGEIFS([Cenov� �daj],[��slo vkladu],[@[��slo vkladu]],[Typ],""ateli�r""),0)"

        .ListColumns.Add.Name = "JC byty [K�/m2]"
        .ListColumns("JC byty [K�/m2]").DataBodyRange.Formula2 = "=IFERROR(KDY�(A([@byt]>0),[@[SUM Cena byt� dle ��zen� '[K�']]]/[@[SUM Plocha byt� dle ��zen� '[m2']]],""""),0)"

        .ListColumns.Add.Name = "Q_JC byty"
        .ListColumns("Q_JC byty").DataBodyRange.Formula = "=KDY�([@[JC byty '[K�/m2']]]<=PERCENTIL.INC([JC byty '[K�/m2']], 0.25), 1,KDY�([@[JC byty '[K�/m2']]]<=PERCENTIL.INC([JC byty '[K�/m2']], 0.5), 2,KDY�([@[JC byty '[K�/m2']]]<=PERCENTIL.INC([JC byty '[K�/m2']], 0.75), 3, 4)))"
       
        
        .ListColumns.Add.Name = "SUM Plocha gar�� dle ��zen� [m2]"
        .ListColumns("SUM Plocha gar�� dle ��zen� [m2]").DataBodyRange.Formula = "=SUMIFS([Plocha '[m2']],[��slo vkladu],[@[��slo vkladu]],[Typ],""gar�"")"

        .ListColumns.Add.Name = "SUM Cena gar�� dle ��zen� [K�]"
        .ListColumns("SUM Cena gar�� dle ��zen� [K�]").DataBodyRange.Formula = "=IFERROR(AVERAGEIFS([Cenov� �daj],[��slo vkladu],[@[��slo vkladu]],[Typ],""gar�""),0)"

        .ListColumns.Add.Name = "JC gar�e [K�/m2]"
        .ListColumns("JC gar�e [K�/m2]").DataBodyRange.Formula2 = "=IFERROR(KDY�(A([@gar�]>0,[@nem]=[@gar�]),[@[SUM Cena gar�� dle ��zen� '[K�']]]/[@[SUM Plocha gar�� dle ��zen� '[m2']]],""""),0)"

        .ListColumns.Add.Name = "SUM Plocha pozemk� dle ��zen� [m2]"
        .ListColumns("SUM Plocha pozemk� dle ��zen� [m2]").DataBodyRange.Formula = "=SUMIFS([Plocha '[m2']],[��slo vkladu],[@[��slo vkladu]],[Nemovitost],""parcela"")"

        .ListColumns.Add.Name = "SUM Cena pozemk� dle ��zen� [K�]"
        .ListColumns("SUM Cena pozemk� dle ��zen� [K�]").DataBodyRange.Formula = "=IFERROR(AVERAGEIFS([Cenov� �daj],[��slo vkladu],[@[��slo vkladu]],[Nemovitost],""parcela""),"""")"

        .ListColumns.Add.Name = "JC pozemky [K�/m2]"
        .ListColumns("JC pozemky [K�/m2]").DataBodyRange.Formula2 = "=IFERROR(KDY�(A([@parcela]>0,[@nem]=[@parcela]),[@[SUM Cena pozemk� dle ��zen� '[K�']]]/[@[SUM Plocha pozemk� dle ��zen� '[m2']]],""""),"""")"

    End With


    
        '.ListColumns.Add.Name = "JC quartily"
        '.ListColumns("JC quartily").DataBodyRange.Formula = "=SVYHLEDAT([@[JC '[K�/m2']]],$AK$2:$AL$6,$AL$2:$AL$6)"
    
    Debug.Print "Tabulka " & tblData_All.Name & " vytvo�ena a upravena."
End Sub


   
Sub FormatTable(sheetName As String, tableName As String)
    Dim ws As Worksheet
    Dim tbl As ListObject
    
    ' Nastaven� listu podle n�zvu
    Set ws = ActiveWorkbook.Sheets(Trim(sheetName))
    
    ' Nastaven� tabulky podle n�zvu
    On Error Resume Next ' Zamezen� chybov�ho hl�en�, pokud tabulka neexistuje
    Set tbl = ws.ListObjects(tableName)
    On Error GoTo 0 ' Obnoven� standardn�ho re�imu chyb
    
    ' Kontrola, zda byla tabulka nalezena
    If Not tbl Is Nothing Then
            ' Nastaven� stylu tabulky
            ActiveSheet.ListObjects(tblData_All.Name).TableStyle = "TableStyleLight8"
            
           
            
            ' Nastavit barvu z�hlav� na �edou
            tbl.HeaderRowRange.Interior.Color = RGB(150, 150, 150) ' �ed� barva
            
            
            ' Nastavit barvu prvn�ho sloupce na �edou
            tbl.ListColumns(1).DataBodyRange.Interior.Color = RGB(150, 150, 150) ' �ed� barva

            ' Zmena barev nekterych sloupcu v zahlavi
            With tbl.HeaderRowRange
                ' Zm�na barvy p�sma
                '.Find("byt").Font.Color = RGB(0, 0, 0)
                
                ' hleda presny obsah zahlavi "nem" nikoliv zahlavi bunky kde "nem" muze byt jen soucasti nazvu
                .Find(What:="nem", LookIn:=xlValues, LookAt:=xlWhole).Interior.Color = RGB(0, 102, 255)
                
                
                .Find("jednotka").Interior.Color = RGB(255, 165, 0)
                .Find("byt").Interior.Color = RGB(210, 210, 0)
                .Find("parcela").Interior.Color = RGB(51, 204, 51)
                .Find("rd").Interior.Color = RGB(173, 216, 230)
                .Find("gar�").Interior.Color = RGB(216, 109, 205)
                
                .Find("SUM Plocha byt� dle ��zen� [m2]").Interior.Color = RGB(210, 210, 0)
                .Find("SUM Cena byt� dle ��zen� [K�]").Interior.Color = RGB(210, 210, 0)
                .Find("JC byty [K�/m2]").Interior.Color = RGB(210, 210, 0)
                .Find("Q_JC byty").Interior.Color = RGB(210, 210, 0)
                
                
                .Find("SUM Plocha gar�� dle ��zen� [m2]").Interior.Color = RGB(216, 109, 205)
                .Find("SUM Cena gar�� dle ��zen� [K�]").Interior.Color = RGB(216, 109, 205)
                .Find("JC gar�e [K�/m2]").Interior.Color = RGB(216, 109, 205)
               
                .Find("SUM Plocha pozemk� dle ��zen� [m2]").Interior.Color = RGB(51, 204, 51)
                .Find("SUM Cena pozemk� dle ��zen� [K�]").Interior.Color = RGB(51, 204, 51)
                .Find("JC pozemky [K�/m2]").Interior.Color = RGB(51, 204, 51)
                
                
            End With
                    
            
            
            ' Nastavit form�tov�n� sloupc�
            With tblData_All.ListColumns("Datum pod�n�").DataBodyRange
                .NumberFormat = "m/d/yyyy"
            End With
            With tblData_All.ListColumns("Datum zplatn�n�").DataBodyRange
                .NumberFormat = "m/d/yyyy"
            End With
            With tblData_All.ListColumns("Cenov� �daj").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            With tblData_All.ListColumns("Plocha [m2]").DataBodyRange
                .NumberFormat = "#,##0.00"
            End With
            
            With tblData_All.ListColumns("SUM Plocha byt� dle ��zen� [m2]").DataBodyRange
                .NumberFormat = "#,##0.00"
            End With
            With tblData_All.ListColumns("SUM Cena byt� dle ��zen� [K�]").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            With tblData_All.ListColumns("JC byty [K�/m2]").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            With tblData_All.ListColumns("SUM Plocha gar�� dle ��zen� [m2]").DataBodyRange
                .NumberFormat = "#,##0.00"
            End With
            With tblData_All.ListColumns("SUM Cena gar�� dle ��zen� [K�]").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            With tblData_All.ListColumns("JC gar�e [K�/m2]").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            With tblData_All.ListColumns("SUM Plocha pozemk� dle ��zen� [m2]").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            With tblData_All.ListColumns("SUM Cena pozemk� dle ��zen� [K�]").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            With tblData_All.ListColumns("JC pozemky [K�/m2]").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            
            
            
            
            
            ' P�idat podm�n�n� form�tov�n� pro sloupec "Nemovitost"
            With tblData_All.ListColumns("Nemovitost").DataBodyRange
                .FormatConditions.Delete ' Odstranit existuj�c� podm�n�n� form�tov�n�
            
                ' Form�tov�n� pro "budova" - sv�tle modr�
                .FormatConditions.Add Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""budova"""
                With .FormatConditions(.FormatConditions.Count).Interior
                    .PatternColorIndex = xlAutomatic
                    .Color = RGB(173, 216, 230) ' Sv�tle modr� barva
                End With
                
                ' Form�tov�n� pro "jednotka" - oran�ov�
                .FormatConditions.Add Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""jednotka"""
                With .FormatConditions(.FormatConditions.Count).Interior
                    .PatternColorIndex = xlAutomatic
                    .Color = RGB(255, 165, 0) ' Oran�ov� barva
                End With
                
                ' Form�tov�n� pro "parcela" - sv�tle zelen�
                .FormatConditions.Add Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""parcela"""
                With .FormatConditions(.FormatConditions.Count).Interior
                    .PatternColorIndex = xlAutomatic
                    .Color = RGB(144, 238, 144) ' Sv�tle zelen� barva
                End With
            End With
                
                
            ' P�idat podm�n�n� form�tov�n� pro sloupec "Typ"
            With tblData_All.ListColumns("Typ").DataBodyRange
                .FormatConditions.Delete ' Odstranit existuj�c� podm�n�n� form�tov�n�
            
                ' Form�tov�n� pro "byt" - �lut�
                .FormatConditions.Add Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""byt"""
                With .FormatConditions(.FormatConditions.Count).Interior
                    .PatternColorIndex = xlAutomatic
                    .Color = RGB(210, 210, 0) ' �lut� barva
                End With
                
                ' Form�tov�n� pro "ateli�r" - sv�tle �lut�
                .FormatConditions.Add Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""ateli�r"""
                With .FormatConditions(.FormatConditions.Count).Interior
                    .PatternColorIndex = xlAutomatic
                    .Color = RGB(255, 255, 153) ' Sv�tle �lut� barva
                End With
            End With
        End If
    
    Debug.Print "Tabulka " & tbl.Name; " byla naform�tov�na."
End Sub


Public Sub CopyAndModifyTable(newSheetName As String, timestamp As String, newTableName As String, sourceTable As ListObject, columnToFilter As String, valueToKeep As Variant)
    Dim wsSource As Worksheet
    Dim wsNew As Worksheet
    Dim tblNew As ListObject
    Dim columnIndex As Long
    Dim lastRow As Long
    Dim i As Long

    
    Dim noveSloupce As Variant
    Dim pozice As Integer
    Dim vzorec As String
    
    
    ' Z�sk�n� listu s tabulkou
    Set wsSource = sourceTable.Parent
    
    ' Vytvo�en� nov�ho listu
    Set wsNew = ActiveWorkbook.Sheets.Add(After:=ActiveWorkbook.Sheets(ActiveWorkbook.Sheets.Count))
    wsNew.Name = newSheetName + timestamp
    
    ' Zkop�rov�n� tabulky na nov� list
    sourceTable.Range.Copy Destination:=wsNew.Range("A1")
    
    ' P�ejmenov�n� tabulky
    Set tblNew = wsNew.ListObjects(1)
    tblNew.Name = newTableName
    
    ' Zjistit index sloupce podle n�zvu
    columnIndex = tblNew.ListColumns(columnToFilter).Index
    
    Debug.Print "------------------------------------------------------------"
    Debug.Print "Nov� list = " & wsNew.Name
    Debug.Print "Nov� tabulka = " & tblNew.Name
    Debug.Print "Sloupec dle kter�ho se modifikuje = " & tblNew.ListColumns(columnToFilter).Name
    Debug.Print "Index sloupce dle kter�ho se modifikuje = " & columnIndex
    Debug.Print "Hodnota ve sloupci kter� se ponech�v� = " & valueToKeep
    Debug.Print "------------------------------------------------------------"
    
    ' Vymazat v�echny ��dky, kter� neodpov�daj� hodnot� v ur�en�m sloupci
    lastRow = tblNew.ListRows.Count
    For i = lastRow To 1 Step -1
        If tblNew.ListRows(i).Range.Cells(1, columnIndex).Value <> valueToKeep Then
            tblNew.ListRows(i).Delete
        End If
    Next i
    
    ' Nastavte n�zev tabulky a pozici, kde chcete p�idat nov� sloupce
   
    pozice = 7 ' M�sto, kam p�idat nov� sloupce (za 7 sloupec, coz je adresa)
    
    ' Definujte nov� n�zvy sloupc�
    noveSloupce = Array("LAT", "LON", "Vzd�lenost [Km]")
    
    ' Definujte vzorec pro p�idan� sloupec Vzd�lenost [Km]
    vzorec = "=6371*ARCCOS(COS(RADIANS([@LAT]))*COS(RADIANS($AC$1))*COS(RADIANS($AC$2)-RADIANS([@LON]))+SIN(RADIANS([@LAT]))*SIN(RADIANS($AC$1)))"
    
    ' P�idat nov� sloupce
    For i = 0 To UBound(noveSloupce)
        tblNew.ListColumns.Add (pozice + i)
        tblNew.ListColumns(pozice + i).Name = noveSloupce(i)
    Next i
    
    ' Vlo�en� vzorce pro vzd�lenost
    
     With tblNew.ListColumns(pozice + 2).DataBodyRange
        .Formula = vzorec
     End With
    
    
    
    Debug.Print "Tabulka " & tblNew.Name; " byla vytvo�ena."
End Sub





Sub BodovyGraf(xSloupecN�zev As String, ySloupecN�zev As String)
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim xColumn As ListColumn
    Dim yColumn As ListColumn
    Dim graf As ChartObject
    Dim serie As Series
    
    ' Nastavte aktivn� list
    Set ws = ActiveSheet
    
    ' Naj�t tabulku, kde je aktivn� bu�ka
    On Error Resume Next
    Set tbl = ws.ListObjects(ws.Cells(ActiveCell.Row, ActiveCell.Column).ListObject.Name)
    On Error GoTo 0
    
    If tbl Is Nothing Then
        MsgBox "Aktivn� bu�ka nen� sou��st� tabulky."
        Exit Sub
    End If
    
    ' Naj�t sloupec pro osu X podle zadan�ho n�zvu
    On Error Resume Next
    Set xColumn = tbl.ListColumns(xSloupecN�zev)
    On Error GoTo 0
    
    If xColumn Is Nothing Then
        MsgBox "Sloupec '" & xSloupecN�zev & "' nebyl nalezen."
        Exit Sub
    End If
    
    ' Naj�t sloupec pro osu Y podle zadan�ho n�zvu
    On Error Resume Next
    Set yColumn = tbl.ListColumns(ySloupecN�zev)
    On Error GoTo 0
    
    If yColumn Is Nothing Then
        MsgBox "Sloupec '" & ySloupecN�zev & "' nebyl nalezen."
        Exit Sub
    End If
    
    ' Vytvo�it nov� graf
    Set graf = ws.ChartObjects.Add(Left:=100, Width:=375, Top:=50, Height:=225)
    With graf.Chart
        ' Nastaven� typu grafu na bodov� (scatter)
        .ChartType = xlXYScatter
        
        ' Nastaven� x-ov�ch grid lines
        .Axes(xlValue).MajorGridlines.Format.Line.Visible = msoTrue
        .Axes(xlValue).MajorGridlines.Format.Line.DashStyle = msoLineSysDot
        .Axes(xlValue).MajorGridlines.Format.Line.Weight = 0.5
        
   
        
        
        ' Odebrat v�echny existuj�c� �ady (pro jistotu)
        Do While .SeriesCollection.Count > 0
            .SeriesCollection(1).Delete
        Loop
        
        ' P�id�n� nov� datov� �ady
        Set serie = .SeriesCollection.NewSeries
        With serie
            .Name = ySloupecN�zev ' Nastaven� n�zvu �ady podle sloupce Y
            .xValues = xColumn.DataBodyRange ' Hodnoty pro osu X
            .Values = yColumn.DataBodyRange ' Hodnoty pro osu Y
        End With
        
        ' Nastaven� n�zv� os
        .Axes(xlCategory, xlPrimary).HasTitle = True
        .Axes(xlCategory, xlPrimary).AxisTitle.Text = xSloupecN�zev
        
        .Axes(xlValue, xlPrimary).HasTitle = True
        .Axes(xlValue, xlPrimary).AxisTitle.Text = ySloupecN�zev
        
        ' Nastaven� n�zvu grafu
        .HasTitle = True
        .ChartTitle.Text = xSloupecN�zev & " vs " & ySloupecN�zev
    End With
End Sub


Sub VytvorGrafy()
    Call BodovyGraf("Plocha [m2]", "JC [K�/m2]")
    Call BodovyGraf("Datum pod�n�", "JC [K�/m2]")
    Call BodovyGraf("Vzd�lenost [Km]", "JC [K�/m2]")
End Sub













