Attribute VB_Name = "Data"
' globalni promene

Dim tblData_All As ListObject

Sub NacteniDatValuo()
    ' Promìnné
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
    
    ' Nastavit aktuální sešit jako cílový sešit
    Set wb = ActiveWorkbook
    
    ' Vytvoøit èasové razítko
    timestamp = Format(Now, "yyyymmdd_HHmm")
    sheetName = "data_all_" & timestamp
    
    ' Vyberte složku, kde se nacházejí soubory
    With Application.FileDialog(msoFileDialogFolderPicker)
        .Title = "Vyberte složku, kde se nacházejí Excel soubory"
        If .Show = -1 Then
            FolderPath = .SelectedItems(1) & "\"
        Else
            MsgBox "Nebyla vybrána žádná složka.", vbExclamation
            Exit Sub
        End If
    End With

    ' Vypnout aktualizaci obrazovky, varovné hlášky a automatické pøepoèty
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
    Application.Calculation = xlCalculationManual
    
    ' Zkontrolovat, zda již existuje list s názvem "data_all", a v pøípadì potøeby pøejmenovat
    On Error Resume Next
    Set TargetWs = wb.Sheets(sheetName)
    On Error GoTo 0
    
    If TargetWs Is Nothing Then
        ' Pokud list neexistuje, vytvoøte nový
        Set TargetWs = wb.Sheets.Add
        TargetWs.Name = sheetName
        Debug.Print "Vytvoøen nový list s názvem: " & sheetName
    Else
        ' Pokud list již existuje, vymažte jeho obsah
        TargetWs.Cells.Clear
        Debug.Print "Existující list s názvem: " & sheetName & " vymazán."
    End If
    
    ' Nastavit poèítadla
    TotalFiles = 0
    TotalRows = 0
    ProcessedFiles = 0
    NextRow = 1 ' Nastavit poèáteèní øádek pro vkládání dat
    
    ' Hlavní cyklus pro naèítání všech Excel souborù v zadané složce
    FileName = Dir(FolderPath & "*.xlsx")
    
    Do While FileName <> ""
        FilePath = FolderPath & FileName
        
        ' Zobrazit název aktuálnì zpracovávaného souboru
        Debug.Print "--------------------------------------------------"
        Debug.Print "Naèítání souboru: " & FileName
        Debug.Print "--------------------------------------------------"
        
        ' Naèíst data z každého souboru
        lastRow = ImportData(FilePath, "Worksheet", TargetWs, NextRow)
        
        ' Pokud byly data úspìšnì vložena
        If lastRow > 0 Then
            ProcessedFiles = ProcessedFiles + 1
            TotalRows = TotalRows + lastRow
            NextRow = NextRow + lastRow ' Aktualizovat øádek pro další vkládání dat
            'MsgBox "Soubor: " & FileName & vbCrLf & _
            '       "Poèet øádkù: " & lastRow & vbCrLf & _
            '       "Data byla úspìšnì vložena." & vbCrLf & _
            '       "Pokraèujte na další soubor.", vbInformation
        Else
            'MsgBox "Soubor: " & FileName & vbCrLf & _
            '       "Žádná data ke vložení nebo chyba pøi naèítání.", vbExclamation
        End If
        
        ' Další soubor
        FileName = Dir
        TotalFiles = TotalFiles + 1
    Loop

    ' Obnovit pùvodní nastavení
    Application.ScreenUpdating = True
    Application.DisplayAlerts = True
    Application.Calculation = xlCalculationAutomatic

    ' Upozornìní, že makro dokonèilo naèítání dat
    MsgBox "Naètení dat dokonèeno!" & vbCrLf & _
           "Celkový poèet zpracovaných souborù: " & ProcessedFiles & vbCrLf & _
           "Celkový poèet øádkù: " & TotalRows, vbInformation



    ' Volání procedury pro úpravu a formátování dat v hlavni tabulce data_all
    Call UpravitTabulkuData_All(TargetWs)
    
    ' Vizuální formátování tabulky
    Call FormatTable(sheetName, tblData_All.Name)

    
    
    ' Kopírování hlavní tabulky data_all na novou a extrakce záznamù dle parametrù
    ' název nové tabulky + timestamp, list zdrojové tabulky, promìnná typu object zdrojové tabulky, název sloupce pro úpravu záznamù, záznam který chci ponmechat
    
     
     
'     Dim pokracovat As VbMsgBoxResult
'
'    ' Dotaz na uživatele, zda chce spustit další proceduru
'     pokracovat = MsgBox("Chcete pøidat list jen s byty?", vbYesNo + vbQuestion, "Potvrzení")
'
'     If pokracovat = vbYes Then
'        Call CopyAndModifyTable("data_byty_", timestamp, "data_byty", tblData_All, "Typ", "byt")
'     End If
'
'
'     ' Dotaz na uživatele, zda chce spustit další proceduru
'     pokracovat = MsgBox("Chcete pøidat list jen s rodinnými domy?", vbYesNo + vbQuestion, "Potvrzení")
'
'     If pokracovat = vbYes Then
'        Call CopyAndModifyTable("data_rd_", timestamp, "data_rd", tblData_All, "Typ", "rodinný dùm")
'     End If
'
'
'     ' Dotaz na uživatele, zda chce spustit další proceduru
'     pokracovat = MsgBox("Chcete pøidat list jen s pozemky?", vbYesNo + vbQuestion, "Potvrzení")
'
'     If pokracovat = vbYes Then
'        Call CopyAndModifyTable("data_pozemky_", timestamp, "data_pozemky", tblData_All, "Nemovitost", "parcela")
'     End If
'
'     ' Dotaz na uživatele, zda chce spustit další proceduru
'     pokracovat = MsgBox("Chcete pøidat list jen s garážemi?", vbYesNo + vbQuestion, "Potvrzení")
'
'     If pokracovat = vbYes Then
'        Call CopyAndModifyTable("data_garaze_", timestamp, "data_garaze", tblData_All, "Typ", "garáž")
'     End If
'

    
End Sub


' Funkce naèita postupnì data ze všech .xlsx souboru ve zvolené složce
Function ImportData(FilePath As String, sheetName As String, TargetWs As Worksheet, NextRow As Long) As Long
    ' Promìnné
    Dim ConnString As String
    Dim Conn As Object
    Dim SQLQuery As String
    Dim rs As Object
    Dim ColumnCount As Long
    Dim DataRow As Long
    Dim FieldNames As String
    Dim RowCount As Long
    
    ' Pøipojení ke zdrojovému Excel souboru
    ConnString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=" & FilePath & ";Extended Properties=""Excel 12.0 Xml;HDR=Yes"";"
    Set Conn = CreateObject("ADODB.Connection")
    On Error GoTo ErrorHandler
    Conn.Open ConnString
    
    ' Zobrazit pøipojovací øetìzec
    Debug.Print "Pøipojeno k: " & FilePath
    
    ' SQL dotaz pro naètení dat
    SQLQuery = "SELECT * FROM [" & sheetName & "$]"
    Debug.Print "Dotaz: " & SQLQuery
    
    Set rs = CreateObject("ADODB.Recordset")
    rs.Open SQLQuery, Conn
    
    ' Zkontrolovat, zda jsou data v rekordsetu
    If rs.EOF Then
        Debug.Print "Žádná data v souboru: " & FilePath
        rs.Close
        Conn.Close
        Set rs = Nothing
        Set Conn = Nothing
        ImportData = 0
        Exit Function
    End If
    
    ' Vložení dat do cílového listu
    If Not rs.EOF Then
        ' Pokud je cílový list prázdný, vložit záhlaví
        If NextRow = 1 Then
            ' Vložit záhlaví
            FieldNames = "Záhlaví: "
            For ColumnCount = 0 To rs.Fields.Count - 1
                TargetWs.Cells(NextRow, ColumnCount + 1).Value = rs.Fields(ColumnCount).Name
                FieldNames = FieldNames & rs.Fields(ColumnCount).Name & ", "
            Next ColumnCount
            FieldNames = Left(FieldNames, Len(FieldNames) - 2) ' Odstranit poslední èárku
            Debug.Print FieldNames
            NextRow = NextRow + 1
        End If
        
        ' Vložit data
        DataRow = NextRow
        RowCount = 0
        Do Until rs.EOF
            Dim RowData As String
            RowData = "Øádek " & DataRow - NextRow + 1 & ": "
            For ColumnCount = 0 To rs.Fields.Count - 1
                TargetWs.Cells(DataRow, ColumnCount + 1).Value = rs.Fields(ColumnCount).Value
                RowData = RowData & rs.Fields(ColumnCount).Value & ", "
            Next ColumnCount
            RowData = Left(RowData, Len(RowData) - 2) ' Odstranit poslední èárku
            Debug.Print RowData
            DataRow = DataRow + 1
            rs.MoveNext
            RowCount = RowCount + 1
        Loop
        Debug.Print "Data vložena ze souboru: " & FilePath
        ImportData = RowCount
    End If
    
    ' Zavøít pøipojení
    rs.Close
    Conn.Close
    Set rs = Nothing
    Set Conn = Nothing
    Exit Function

ErrorHandler:
    MsgBox "Chyba pøi naèítání souboru: " & FilePath & vbCrLf & "Chyba: " & Err.Description, vbExclamation
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
    ' TargetWs.Range("A1"): Toto oznaèuje buòku A1 na listu TargetWs.
    ' CurrentRegion: Tato vlastnost vrací oblast sousedících bunìk, která obsahuje data a je ohranièena prázdnými øádky a sloupci.
    ' Jinými slovy, CurrentRegion zahrnuje všechny buòky, které jsou spojeny s buòkou A1 a obsahují data.
    
    Set headerRange = TargetWs.Range("A1").CurrentRegion
    
    
    ' Toto oznaèuje rozsah od buòky A2 až po poslední øádek v prvním sloupci, který obsahuje data.
    Set firstColumnRange = TargetWs.Range("A2:A" & headerRange.Rows.Count)
    
    ' Vytvoøit tabulku
    ' TargetWs.ListObjects.Add: Tato metoda pøidá nový objekt tabulky (ListObject) na list TargetWs.
    ' xlSrcRange: Tento argument specifikuje, že zdroj dat pro tabulku je rozsah bunìk.
    ' headerRange: Tento argument specifikuje rozsah bunìk, které budou použity jako zdroj dat pro tabulku.
    ' xlYes: Tento argument specifikuje, že první øádek headerRange obsahuje záhlaví sloupcù.
    
    Set tblData_All = TargetWs.ListObjects.Add(xlSrcRange, headerRange, , xlYes)
    tblData_All.Name = "data_all"
    
    ' Prejmenování sloupce s plochou
    tblData_All.ListColumns("Plocha (v m2)").Name = "Plocha [m2]"
    
    
    '------------------------------------------------------------------------------------------------
    pozice = 7 ' Místo, kam pøidat nové sloupce (za 7 sloupec, coz je adresa)
    
    ' Definujte nové názvy sloupcù
    noveSloupce = Array("LAT", "LON", "Vzdálenost [Km]")
    
    ' Definujte vzorec pro pøidaný sloupec Vzdálenost [Km]
    vzorec = "=6371*ARCCOS(COS(RADIANS([@LAT]))*COS(RADIANS($AC$1))*COS(RADIANS($AC$2)-RADIANS([@LON]))+SIN(RADIANS([@LAT]))*SIN(RADIANS($AC$1)))"
    
    ' Pøidat nové sloupce
    For i = 0 To UBound(noveSloupce)
        tblData_All.ListColumns.Add (pozice + i)
        tblData_All.ListColumns(pozice + i).Name = noveSloupce(i)
    Next i
    
    ' Vložení vzorce pro vzdálenost
    
     With tblData_All.ListColumns(pozice + 2).DataBodyRange
        .Formula = vzorec
     End With
    '------------------------------------------------------------------------------------------------
    
    
    
    
    

    ' Pøidat nové sloupce s výpoèty
    With tblData_All
        .ListColumns.Add.Name = "nem"
        .ListColumns("nem").DataBodyRange.Formula = "=COUNTIF([Èíslo vkladu],[@[Èíslo vkladu]])"

        .ListColumns.Add.Name = "jednotka"
        .ListColumns("jednotka").DataBodyRange.Formula = "=COUNTIFS([Èíslo vkladu],[@[Èíslo vkladu]],[Nemovitost],""jednotka"")"
        
        
        .ListColumns.Add.Name = "byt"
        .ListColumns("byt").DataBodyRange.Formula = "=COUNTIFS([Èíslo vkladu],[@[Èíslo vkladu]],[Typ],""byt"")+COUNTIFS([Èíslo vkladu],[@[Èíslo vkladu]],[Typ],""ateliér"")"


        .ListColumns.Add.Name = "budova"
        .ListColumns("budova").DataBodyRange.Formula = "=COUNTIFS([Èíslo vkladu],[@[Èíslo vkladu]],[Nemovitost],""budova"")"

        .ListColumns.Add.Name = "parcela"
        .ListColumns("parcela").DataBodyRange.Formula = "=COUNTIFS([Èíslo vkladu],[@[Èíslo vkladu]],[Nemovitost],""parcela"")"

        .ListColumns.Add.Name = "rd"
        .ListColumns("rd").DataBodyRange.Formula = "=COUNTIFS([Èíslo vkladu],[@[Èíslo vkladu]],[Typ],""rodinný dùm"")"

        .ListColumns.Add.Name = "garáž"
        .ListColumns("garáž").DataBodyRange.Formula = "=COUNTIFS([Èíslo vkladu],[@[Èíslo vkladu]],[Typ],""garáž"")"

        .ListColumns.Add.Name = "SUM Plocha bytù dle øízení [m2]"
        .ListColumns("SUM Plocha bytù dle øízení [m2]").DataBodyRange.Formula = "=SUMIFS([Plocha '[m2']],[Èíslo vkladu],[@[Èíslo vkladu]],[Typ],""byt"") + SUMIFS([Plocha '[m2']],[Èíslo vkladu],[@[Èíslo vkladu]],[Typ],""ateliér"")"

        .ListColumns.Add.Name = "SUM Cena bytù dle øízení [Kè]"
        .ListColumns("SUM Cena bytù dle øízení [Kè]").DataBodyRange.Formula = "=IFERROR(AVERAGEIFS([Cenový údaj],[Èíslo vkladu],[@[Èíslo vkladu]],[Typ],""byt""),0) + IFERROR(AVERAGEIFS([Cenový údaj],[Èíslo vkladu],[@[Èíslo vkladu]],[Typ],""ateliér""),0)"

        .ListColumns.Add.Name = "JC byty [Kè/m2]"
        .ListColumns("JC byty [Kè/m2]").DataBodyRange.Formula2 = "=IFERROR(KDYŽ(A([@byt]>0),[@[SUM Cena bytù dle øízení '[Kè']]]/[@[SUM Plocha bytù dle øízení '[m2']]],""""),0)"

        .ListColumns.Add.Name = "Q_JC byty"
        .ListColumns("Q_JC byty").DataBodyRange.Formula = "=KDYŽ([@[JC byty '[Kè/m2']]]<=PERCENTIL.INC([JC byty '[Kè/m2']], 0.25), 1,KDYŽ([@[JC byty '[Kè/m2']]]<=PERCENTIL.INC([JC byty '[Kè/m2']], 0.5), 2,KDYŽ([@[JC byty '[Kè/m2']]]<=PERCENTIL.INC([JC byty '[Kè/m2']], 0.75), 3, 4)))"
       
        
        .ListColumns.Add.Name = "SUM Plocha garáží dle øízení [m2]"
        .ListColumns("SUM Plocha garáží dle øízení [m2]").DataBodyRange.Formula = "=SUMIFS([Plocha '[m2']],[Èíslo vkladu],[@[Èíslo vkladu]],[Typ],""garáž"")"

        .ListColumns.Add.Name = "SUM Cena garáží dle øízení [Kè]"
        .ListColumns("SUM Cena garáží dle øízení [Kè]").DataBodyRange.Formula = "=IFERROR(AVERAGEIFS([Cenový údaj],[Èíslo vkladu],[@[Èíslo vkladu]],[Typ],""garáž""),0)"

        .ListColumns.Add.Name = "JC garáže [Kè/m2]"
        .ListColumns("JC garáže [Kè/m2]").DataBodyRange.Formula2 = "=IFERROR(KDYŽ(A([@garáž]>0,[@nem]=[@garáž]),[@[SUM Cena garáží dle øízení '[Kè']]]/[@[SUM Plocha garáží dle øízení '[m2']]],""""),0)"

        .ListColumns.Add.Name = "SUM Plocha pozemkù dle øízení [m2]"
        .ListColumns("SUM Plocha pozemkù dle øízení [m2]").DataBodyRange.Formula = "=SUMIFS([Plocha '[m2']],[Èíslo vkladu],[@[Èíslo vkladu]],[Nemovitost],""parcela"")"

        .ListColumns.Add.Name = "SUM Cena pozemkù dle øízení [Kè]"
        .ListColumns("SUM Cena pozemkù dle øízení [Kè]").DataBodyRange.Formula = "=IFERROR(AVERAGEIFS([Cenový údaj],[Èíslo vkladu],[@[Èíslo vkladu]],[Nemovitost],""parcela""),"""")"

        .ListColumns.Add.Name = "JC pozemky [Kè/m2]"
        .ListColumns("JC pozemky [Kè/m2]").DataBodyRange.Formula2 = "=IFERROR(KDYŽ(A([@parcela]>0,[@nem]=[@parcela]),[@[SUM Cena pozemkù dle øízení '[Kè']]]/[@[SUM Plocha pozemkù dle øízení '[m2']]],""""),"""")"

    End With


    
        '.ListColumns.Add.Name = "JC quartily"
        '.ListColumns("JC quartily").DataBodyRange.Formula = "=SVYHLEDAT([@[JC '[Kè/m2']]],$AK$2:$AL$6,$AL$2:$AL$6)"
    
    Debug.Print "Tabulka " & tblData_All.Name & " vytvoøena a upravena."
End Sub


   
Sub FormatTable(sheetName As String, tableName As String)
    Dim ws As Worksheet
    Dim tbl As ListObject
    
    ' Nastavení listu podle názvu
    Set ws = ActiveWorkbook.Sheets(Trim(sheetName))
    
    ' Nastavení tabulky podle názvu
    On Error Resume Next ' Zamezení chybového hlášení, pokud tabulka neexistuje
    Set tbl = ws.ListObjects(tableName)
    On Error GoTo 0 ' Obnovení standardního režimu chyb
    
    ' Kontrola, zda byla tabulka nalezena
    If Not tbl Is Nothing Then
            ' Nastavení stylu tabulky
            ActiveSheet.ListObjects(tblData_All.Name).TableStyle = "TableStyleLight8"
            
           
            
            ' Nastavit barvu záhlaví na šedou
            tbl.HeaderRowRange.Interior.Color = RGB(150, 150, 150) ' šedá barva
            
            
            ' Nastavit barvu prvního sloupce na šedou
            tbl.ListColumns(1).DataBodyRange.Interior.Color = RGB(150, 150, 150) ' šedá barva

            ' Zmena barev nekterych sloupcu v zahlavi
            With tbl.HeaderRowRange
                ' Zmìna barvy písma
                '.Find("byt").Font.Color = RGB(0, 0, 0)
                
                ' hleda presny obsah zahlavi "nem" nikoliv zahlavi bunky kde "nem" muze byt jen soucasti nazvu
                .Find(What:="nem", LookIn:=xlValues, LookAt:=xlWhole).Interior.Color = RGB(0, 102, 255)
                
                
                .Find("jednotka").Interior.Color = RGB(255, 165, 0)
                .Find("byt").Interior.Color = RGB(210, 210, 0)
                .Find("parcela").Interior.Color = RGB(51, 204, 51)
                .Find("rd").Interior.Color = RGB(173, 216, 230)
                .Find("garáž").Interior.Color = RGB(216, 109, 205)
                
                .Find("SUM Plocha bytù dle øízení [m2]").Interior.Color = RGB(210, 210, 0)
                .Find("SUM Cena bytù dle øízení [Kè]").Interior.Color = RGB(210, 210, 0)
                .Find("JC byty [Kè/m2]").Interior.Color = RGB(210, 210, 0)
                .Find("Q_JC byty").Interior.Color = RGB(210, 210, 0)
                
                
                .Find("SUM Plocha garáží dle øízení [m2]").Interior.Color = RGB(216, 109, 205)
                .Find("SUM Cena garáží dle øízení [Kè]").Interior.Color = RGB(216, 109, 205)
                .Find("JC garáže [Kè/m2]").Interior.Color = RGB(216, 109, 205)
               
                .Find("SUM Plocha pozemkù dle øízení [m2]").Interior.Color = RGB(51, 204, 51)
                .Find("SUM Cena pozemkù dle øízení [Kè]").Interior.Color = RGB(51, 204, 51)
                .Find("JC pozemky [Kè/m2]").Interior.Color = RGB(51, 204, 51)
                
                
            End With
                    
            
            
            ' Nastavit formátování sloupcù
            With tblData_All.ListColumns("Datum podání").DataBodyRange
                .NumberFormat = "m/d/yyyy"
            End With
            With tblData_All.ListColumns("Datum zplatnìní").DataBodyRange
                .NumberFormat = "m/d/yyyy"
            End With
            With tblData_All.ListColumns("Cenový údaj").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            With tblData_All.ListColumns("Plocha [m2]").DataBodyRange
                .NumberFormat = "#,##0.00"
            End With
            
            With tblData_All.ListColumns("SUM Plocha bytù dle øízení [m2]").DataBodyRange
                .NumberFormat = "#,##0.00"
            End With
            With tblData_All.ListColumns("SUM Cena bytù dle øízení [Kè]").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            With tblData_All.ListColumns("JC byty [Kè/m2]").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            With tblData_All.ListColumns("SUM Plocha garáží dle øízení [m2]").DataBodyRange
                .NumberFormat = "#,##0.00"
            End With
            With tblData_All.ListColumns("SUM Cena garáží dle øízení [Kè]").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            With tblData_All.ListColumns("JC garáže [Kè/m2]").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            With tblData_All.ListColumns("SUM Plocha pozemkù dle øízení [m2]").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            With tblData_All.ListColumns("SUM Cena pozemkù dle øízení [Kè]").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            With tblData_All.ListColumns("JC pozemky [Kè/m2]").DataBodyRange
                .NumberFormat = "#,##0"
            End With
            
            
            
            
            
            ' Pøidat podmínìné formátování pro sloupec "Nemovitost"
            With tblData_All.ListColumns("Nemovitost").DataBodyRange
                .FormatConditions.Delete ' Odstranit existující podmínìné formátování
            
                ' Formátování pro "budova" - svìtle modrá
                .FormatConditions.Add Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""budova"""
                With .FormatConditions(.FormatConditions.Count).Interior
                    .PatternColorIndex = xlAutomatic
                    .Color = RGB(173, 216, 230) ' Svìtle modrá barva
                End With
                
                ' Formátování pro "jednotka" - oranžová
                .FormatConditions.Add Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""jednotka"""
                With .FormatConditions(.FormatConditions.Count).Interior
                    .PatternColorIndex = xlAutomatic
                    .Color = RGB(255, 165, 0) ' Oranžová barva
                End With
                
                ' Formátování pro "parcela" - svìtle zelená
                .FormatConditions.Add Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""parcela"""
                With .FormatConditions(.FormatConditions.Count).Interior
                    .PatternColorIndex = xlAutomatic
                    .Color = RGB(144, 238, 144) ' Svìtle zelená barva
                End With
            End With
                
                
            ' Pøidat podmínìné formátování pro sloupec "Typ"
            With tblData_All.ListColumns("Typ").DataBodyRange
                .FormatConditions.Delete ' Odstranit existující podmínìné formátování
            
                ' Formátování pro "byt" - žlutá
                .FormatConditions.Add Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""byt"""
                With .FormatConditions(.FormatConditions.Count).Interior
                    .PatternColorIndex = xlAutomatic
                    .Color = RGB(210, 210, 0) ' Žlutá barva
                End With
                
                ' Formátování pro "ateliér" - svìtle žlutá
                .FormatConditions.Add Type:=xlCellValue, Operator:=xlEqual, Formula1:="=""ateliér"""
                With .FormatConditions(.FormatConditions.Count).Interior
                    .PatternColorIndex = xlAutomatic
                    .Color = RGB(255, 255, 153) ' Svìtle žlutá barva
                End With
            End With
        End If
    
    Debug.Print "Tabulka " & tbl.Name; " byla naformátována."
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
    
    
    ' Získání listu s tabulkou
    Set wsSource = sourceTable.Parent
    
    ' Vytvoøení nového listu
    Set wsNew = ActiveWorkbook.Sheets.Add(After:=ActiveWorkbook.Sheets(ActiveWorkbook.Sheets.Count))
    wsNew.Name = newSheetName + timestamp
    
    ' Zkopírování tabulky na nový list
    sourceTable.Range.Copy Destination:=wsNew.Range("A1")
    
    ' Pøejmenování tabulky
    Set tblNew = wsNew.ListObjects(1)
    tblNew.Name = newTableName
    
    ' Zjistit index sloupce podle názvu
    columnIndex = tblNew.ListColumns(columnToFilter).Index
    
    Debug.Print "------------------------------------------------------------"
    Debug.Print "Nový list = " & wsNew.Name
    Debug.Print "Nová tabulka = " & tblNew.Name
    Debug.Print "Sloupec dle kterého se modifikuje = " & tblNew.ListColumns(columnToFilter).Name
    Debug.Print "Index sloupce dle kterého se modifikuje = " & columnIndex
    Debug.Print "Hodnota ve sloupci která se ponechává = " & valueToKeep
    Debug.Print "------------------------------------------------------------"
    
    ' Vymazat všechny øádky, které neodpovídají hodnotì v urèeném sloupci
    lastRow = tblNew.ListRows.Count
    For i = lastRow To 1 Step -1
        If tblNew.ListRows(i).Range.Cells(1, columnIndex).Value <> valueToKeep Then
            tblNew.ListRows(i).Delete
        End If
    Next i
    
    ' Nastavte název tabulky a pozici, kde chcete pøidat nové sloupce
   
    pozice = 7 ' Místo, kam pøidat nové sloupce (za 7 sloupec, coz je adresa)
    
    ' Definujte nové názvy sloupcù
    noveSloupce = Array("LAT", "LON", "Vzdálenost [Km]")
    
    ' Definujte vzorec pro pøidaný sloupec Vzdálenost [Km]
    vzorec = "=6371*ARCCOS(COS(RADIANS([@LAT]))*COS(RADIANS($AC$1))*COS(RADIANS($AC$2)-RADIANS([@LON]))+SIN(RADIANS([@LAT]))*SIN(RADIANS($AC$1)))"
    
    ' Pøidat nové sloupce
    For i = 0 To UBound(noveSloupce)
        tblNew.ListColumns.Add (pozice + i)
        tblNew.ListColumns(pozice + i).Name = noveSloupce(i)
    Next i
    
    ' Vložení vzorce pro vzdálenost
    
     With tblNew.ListColumns(pozice + 2).DataBodyRange
        .Formula = vzorec
     End With
    
    
    
    Debug.Print "Tabulka " & tblNew.Name; " byla vytvoøena."
End Sub





Sub BodovyGraf(xSloupecNázev As String, ySloupecNázev As String)
    Dim ws As Worksheet
    Dim tbl As ListObject
    Dim xColumn As ListColumn
    Dim yColumn As ListColumn
    Dim graf As ChartObject
    Dim serie As Series
    
    ' Nastavte aktivní list
    Set ws = ActiveSheet
    
    ' Najít tabulku, kde je aktivní buòka
    On Error Resume Next
    Set tbl = ws.ListObjects(ws.Cells(ActiveCell.Row, ActiveCell.Column).ListObject.Name)
    On Error GoTo 0
    
    If tbl Is Nothing Then
        MsgBox "Aktivní buòka není souèástí tabulky."
        Exit Sub
    End If
    
    ' Najít sloupec pro osu X podle zadaného názvu
    On Error Resume Next
    Set xColumn = tbl.ListColumns(xSloupecNázev)
    On Error GoTo 0
    
    If xColumn Is Nothing Then
        MsgBox "Sloupec '" & xSloupecNázev & "' nebyl nalezen."
        Exit Sub
    End If
    
    ' Najít sloupec pro osu Y podle zadaného názvu
    On Error Resume Next
    Set yColumn = tbl.ListColumns(ySloupecNázev)
    On Error GoTo 0
    
    If yColumn Is Nothing Then
        MsgBox "Sloupec '" & ySloupecNázev & "' nebyl nalezen."
        Exit Sub
    End If
    
    ' Vytvoøit nový graf
    Set graf = ws.ChartObjects.Add(Left:=100, Width:=375, Top:=50, Height:=225)
    With graf.Chart
        ' Nastavení typu grafu na bodový (scatter)
        .ChartType = xlXYScatter
        
        ' Nastavení x-ových grid lines
        .Axes(xlValue).MajorGridlines.Format.Line.Visible = msoTrue
        .Axes(xlValue).MajorGridlines.Format.Line.DashStyle = msoLineSysDot
        .Axes(xlValue).MajorGridlines.Format.Line.Weight = 0.5
        
   
        
        
        ' Odebrat všechny existující øady (pro jistotu)
        Do While .SeriesCollection.Count > 0
            .SeriesCollection(1).Delete
        Loop
        
        ' Pøidání nové datové øady
        Set serie = .SeriesCollection.NewSeries
        With serie
            .Name = ySloupecNázev ' Nastavení názvu øady podle sloupce Y
            .xValues = xColumn.DataBodyRange ' Hodnoty pro osu X
            .Values = yColumn.DataBodyRange ' Hodnoty pro osu Y
        End With
        
        ' Nastavení názvù os
        .Axes(xlCategory, xlPrimary).HasTitle = True
        .Axes(xlCategory, xlPrimary).AxisTitle.Text = xSloupecNázev
        
        .Axes(xlValue, xlPrimary).HasTitle = True
        .Axes(xlValue, xlPrimary).AxisTitle.Text = ySloupecNázev
        
        ' Nastavení názvu grafu
        .HasTitle = True
        .ChartTitle.Text = xSloupecNázev & " vs " & ySloupecNázev
    End With
End Sub


Sub VytvorGrafy()
    Call BodovyGraf("Plocha [m2]", "JC [Kè/m2]")
    Call BodovyGraf("Datum podání", "JC [Kè/m2]")
    Call BodovyGraf("Vzdálenost [Km]", "JC [Kè/m2]")
End Sub













