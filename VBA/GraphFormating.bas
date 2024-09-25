Attribute VB_Name = "GraphFormating"
Sub ChartNormalize()
    Dim chrt As Chart
    Dim srs As Series
    Dim trendlineExists As Boolean
    
    Dim msg As String
    
    Dim xValues As String
    Dim yValues As String
    
    Dim formulaParts As Variant
    
    Dim xColumn As Long
    Dim yColumn As Long
    Dim firstRow As Long     ' radek kde zacinaji data v tabulce ze ktere ke graf
  

    ' Promìnné pro formatovani os x,y aby byl graf hezky uprostred
    Dim xVal As Variant
    Dim yVal As Variant
    Dim minX As Double, maxX As Double
    Dim minY As Double, maxY As Double
    Dim bufferX As Double, bufferY As Double


    ' Vypnout aktualizaci obrazovky, varovné hlášky a automatické pøepoèty
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False
    Application.Calculation = xlCalculationManual


    On Error Resume Next
    Set chrt = ActiveChart ' vybrany / aktivni graf do variablu

    If chrt Is Nothing Then
        MsgBox "Please select a chart first."
        Exit Sub
    End If

     'aplikovani sablony na graf - KDYZ JE SABLONA SPATNA TAK PADA EXCEL
    'chrt.ApplyChartTemplate ( _
     '   "C:\Users\ijttr\AppData\Roaming\Microsoft\Templates\Charts\Graf regrese 2.crtx" _
      '  )


    'x,y jako vychozi rozmery jednotlivych prvku grafu, pouzji se pro hlavni okno a pomerove dalsi prvky
    Dim x, y, n As Single
    x = 300
    y = 210
    n = 0  'nulovani posunu vzorce trendline
    

    'velikost hlavniho okna grafu
    chrt.Parent.Width = x
    chrt.Parent.Height = y
    
    'velikost grafu - datova cast, osy x,y
    chrt.PlotArea.Width = x * 0.8
    chrt.PlotArea.Height = y * 0.75
    chrt.PlotArea.Left = x * 0.1
    chrt.PlotArea.Top = y * 0.15
    
  
    
    'osa - x,y  meze
    'ActiveChart.Axes(xlCategory).MinimumScale = 0
    chrt.Axes(xlCategory).MaximumScaleIsAuto = True
    chrt.Axes(xlCategory).MinimumScaleIsAuto = True
    
    ' Odstranìní legendy
    chrt.SetElement (msoElementLegendNone)
     

    msg = "Chart Data Source Information:" & vbCrLf & vbCrLf
   

    ' Loop through each series in the chart
    For Each srs In chrt.SeriesCollection
        msg = msg & "Series Name: " & srs.Name & vbCrLf

        ' ziskani vzorce rady - poloha rady
        formulaParts = Split(srs.Formula, ",")

        ' ziskani hodnot X souradnice rady
        If UBound(formulaParts) >= 1 Then
            xValues = formulaParts(1)
            xColumn = GetColumnNumber(xValues, firstRow)
            chrt.Axes(xlCategory, xlPrimary).AxisTitle.Text = GetAxisName(xValues)
        Else
            xValues = "N/A"
            xColumn = -1
        End If
        msg = msg & "X Values: " & xValues & " (Column " & xColumn & ")" & vbCrLf

        ' ziskani hodnot Y souradnice rady
        If UBound(formulaParts) >= 2 Then
            yValues = formulaParts(2)
            yColumn = GetColumnNumber(yValues, firstRow)
            chrt.Axes(xlValue, xlPrimary).AxisTitle.Text = GetAxisName(yValues)
        Else
            yValues = "N/A"
            yColumn = -1
        End If
        msg = msg & "Y Values: " & yValues & " (Column " & yColumn & ")" & vbCrLf
        msg = msg & "First Row:" & firstRow & vbCrLf
        msg = msg & vbCrLf
        
    
         ' obarveni sloupce y souradnice podminenym formatovanim
        Range(yValues).Select
        
        Selection.FormatConditions.AddColorScale ColorScaleType:=3
        Selection.FormatConditions(Selection.FormatConditions.Count).SetFirstPriority
        Selection.FormatConditions(1).ColorScaleCriteria(1).Type = _
            xlConditionValueLowestValue
        With Selection.FormatConditions(1).ColorScaleCriteria(1).FormatColor
            .Color = 7039480
            .TintAndShade = 0
        End With
        Selection.FormatConditions(1).ColorScaleCriteria(2).Type = _
            xlConditionValuePercentile
        Selection.FormatConditions(1).ColorScaleCriteria(2).Value = 50
        With Selection.FormatConditions(1).ColorScaleCriteria(2).FormatColor
            .Color = 8711167
            .TintAndShade = 0
        End With
        Selection.FormatConditions(1).ColorScaleCriteria(3).Type = _
            xlConditionValueHighestValue
        With Selection.FormatConditions(1).ColorScaleCriteria(3).FormatColor
            .Color = 8109667
            .TintAndShade = 0
        End With
        
    
       'obarveni budu v grafu podle podmineneho formatovani ve sloupci tabulky y souradnice (dat y souradnice)
        Dim s As Series
        Dim i As Integer
           
        Set s = chrt.FullSeriesCollection(srs.Name)
        For i = 1 To s.Points.Count
            'posun o n radku dolu kde zacinaji data v tabulce a n sloupcu doprava
            s.Points(i).Format.Fill.ForeColor.RGB = Cells(firstRow - 1 + i, yColumn).DisplayFormat.Interior.Color
        Next i


'       ' smaze vsechny pripadne trendlines
'        With srs.Trendlines
'           For i = .Count To 1 Step -1
'              .Item(i).Delete
'           Next i
'        End With
'
'
'       ' Pokud trendline neexistuje, pøidáme novou
'        chrt.FullSeriesCollection(srs.Name).Trendlines.Add
'
'        chrt.FullSeriesCollection(srs.Name).Trendlines(1).Select
'        Selection.Forward = 0
'        Selection.Backward = 0
'        With Selection.Format.Line
'            .Visible = msoTrue
'            .DashStyle = msoLineDash
'            .ForeColor.RGB = RGB(255, 0, 0)
'            .Transparency = 0
'            .Weight = 2#
'        End With
'        Selection.Format.Line.EndArrowheadStyle = msoArrowheadTriangle

        
     
        'vzorce trendline a poloha vzorce trend-line
        chrt.FullSeriesCollection(srs.Name).Trendlines(1).DisplayEquation = True
        chrt.FullSeriesCollection(srs.Name).Trendlines(1).DisplayRSquared = True
        chrt.FullSeriesCollection(srs.Name).Trendlines(1).DataLabel.Left = x * 0.7
        chrt.FullSeriesCollection(srs.Name).Trendlines(1).DataLabel.Top = y * 0.1 + n
        n = n + 30 ' posun dolu pro rovnici dalsi rady

  

       ' Nastavení rozsahu hodnot pro osu X a Y
        xVal = chrt.FullSeriesCollection(srs.Name).xValues
        yVal = chrt.FullSeriesCollection(srs.Name).Values
        
        
       ' Zjištìní minimálních a maximálních hodnot na osách X a Y
        minX = Application.WorksheetFunction.Min(xVal)
        maxX = Application.WorksheetFunction.Max(xVal)
        minY = Application.WorksheetFunction.Min(yVal)
        maxY = Application.WorksheetFunction.Max(yVal)
         
       ' Pøidání bufferu (rezervy) k rozsahùm osy
       bufferX = (maxX - minX) * 0.1 ' Rezerva 10% k rozsahu osy X
       bufferY = (maxY - minY) * 0.1 ' Rezerva 10% k rozsahu osy Y
         
       ' Nastavení minimálních a maximálních hodnot osy X s pøidaným bufferem
       With chrt.Axes(xlCategory)
           .MinimumScale = Application.WorksheetFunction.RoundDown(minX - bufferX, 0)
           .MaximumScale = Application.WorksheetFunction.RoundUp(maxX + bufferX, 0)
       End With
       
        
       ' Nastavení minimálních a maximálních hodnot osy Y s pøidaným bufferem
       With chrt.Axes(xlValue)
           .MinimumScale = Application.WorksheetFunction.RoundDown(minY - bufferY, -3) ' -3 je zaokrouhlení na tisíce, klasika
           .MaximumScale = Application.WorksheetFunction.RoundUp(maxY + bufferY, -3)
       End With

       ' Primární hlavní vodorovná møížka
       ' chrt.SetElement (msoElementPrimaryValueGridLinesMajor)



    Next srs

    Application.ScreenUpdating = True
    Application.DisplayAlerts = True
    Application.Calculation = xlAutomatic



    ' Display the message
    MsgBox msg
End Sub

Function GetColumnNumber(cellAddress As String, ByRef firstRow As Long) As Long
    Dim colLetter As String
    Dim colNumber As Long

    ' Remove sheet reference if present
    If InStr(cellAddress, "!") > 0 Then
        cellAddress = Split(cellAddress, "!")(1)
    End If

    ' Remove absolute reference symbols if present
    cellAddress = Replace(cellAddress, "$", "")

    ' Get the first cell address
    Dim firstCell As String
    firstCell = Split(cellAddress, ":")(0)

    ' Separate column letters and row number
    Dim i As Long
    For i = 1 To Len(firstCell)
        If IsNumeric(Mid(firstCell, i, 1)) Then
            colLetter = Left(firstCell, i - 1)
            firstRow = CLng(Mid(firstCell, i))
            Exit For
        End If
    Next i

    ' Convert column letters to column number
    colNumber = Range(colLetter & "1").Column

    GetColumnNumber = colNumber
End Function


Function GetAxisName(cellAddress As String) As String
    Dim firstColumn As String
    Dim colLetter As String
    Dim rowNumber As Long
    Dim AxisName, AxisNameColumn As String
    Dim i As Integer
    

    ' Remove sheet reference if present
    If InStr(cellAddress, "!") > 0 Then
        cellAddress = Split(cellAddress, "!")(1)
    End If

    ' Remove absolute reference symbols if present
    cellAddress = Replace(cellAddress, "$", "")

    ' Get the column letters
    firstColumn = Split(cellAddress, ":")(0)
    
    
    ' Najít pozici prvního èísla v øetìzci
    For i = 1 To Len(firstColumn)
        If IsNumeric(Mid(firstColumn, i, 1)) Then
            Exit For
        End If
    Next i

    ' Rozdìlit øetìzec na sloupec a øádek
    colLetter = Left(firstColumn, i - 1)
    rowNumber = Mid(firstColumn, i)
    
    'posun o 1 radek nahoru = zahlavi = nazev sloupce rady
    AxisNameColumn = colLetter & rowNumber - 1
    AxisName = Range(AxisNameColumn).Value

    GetAxisName = AxisName
End Function



