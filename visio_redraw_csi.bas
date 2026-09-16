Attribute VB_Name = "RedrawCSI"
Option Explicit

Private Const PI As Double = 3.14159265358979

Public Sub BuildCSIPreprocessingFigure()
    Dim pg As Visio.Page
    Set pg = ActivePage

    pg.PageSheet.CellsU("PageWidth").FormulaU = "16 in"
    pg.PageSheet.CellsU("PageHeight").FormulaU = "6 in"

    Dim sh As Visio.Shape

    ' Panel backgrounds
    Set sh = AddBox(pg, 0.12, 0.18, 6.18, 5.82, "", 248, 249, 250, -1, -1, -1, 1, False)
    Set sh = AddBox(pg, 6.28, 0.18, 9.05, 5.82, "", 255, 255, 255, -1, -1, -1, 1, False)
    Set sh = AddBox(pg, 9.15, 0.18, 12.78, 5.82, "", 255, 255, 255, -1, -1, -1, 1, False)
    Set sh = AddBox(pg, 12.88, 0.18, 15.88, 5.82, "", 255, 255, 255, -1, -1, -1, 1, False)

    ' ---------------- Panel A ----------------
    Set sh = AddText(pg, 0.38, 5.38, 5.95, 5.72, "(a) Raw CSI 硬件漂移与相位误差影响示意", 11, True, 35, 35, 35, 1)

    AddLine pg, 0.62, 0.82, 5.92, 0.82, 20, 20, 20, 1.4, False, True
    AddLine pg, 0.62, 0.82, 0.62, 5.18, 20, 20, 20, 1.4, False, True
    Set sh = AddText(pg, 2.52, 0.28, 4.02, 0.68, "时间 Time", 10, True, 35, 35, 35, 1)
    Set sh = AddText(pg, 0.02, 2.15, 0.48, 4.25, "CSI Amplitude in English", 9, True, 35, 35, 35, 1)
    sh.CellsU("Angle").FormulaU = "90 deg"

    AddLine pg, 0.70, 1.15, 5.78, 2.34, 95, 95, 95, 1, True, False
    Set sh = AddText(pg, 0.94, 0.92, 2.78, 1.42, "硬件基线漂移" & vbCrLf & "Hardware baseline drift", 7.5, True, 45, 45, 45, 1)
    DrawRawWave pg, 0.78, 1.52, 5.05, 2.78

    AddLine pg, 3.03, 1.56, 3.03, 4.46, 218, 45, 45, 2.5, False, False
    AddLine pg, 3.10, 1.64, 3.10, 4.52, 240, 82, 55, 1, False, False
    Set sh = AddText(pg, 2.72, 4.52, 3.68, 4.88, "noise 脉冲噪声", 7.5, True, 65, 65, 65, 1)
    AddLine pg, 3.26, 4.48, 3.10, 4.18, 65, 65, 65, 0.8, False, True

    Set sh = AddText(pg, 0.72, 4.05, 2.40, 4.44, "Human motion response", 7.5, False, 45, 45, 45, 1)
    AddLine pg, 1.62, 4.02, 1.44, 3.55, 60, 60, 60, 0.8, False, True

    Set sh = AddText(pg, 4.78, 4.64, 5.92, 5.16, "AGC增益漂移" & vbCrLf & "AGC gain drift", 8, True, 45, 45, 45, 1)
    AddLine pg, 5.22, 4.60, 5.34, 4.15, 60, 60, 60, 0.8, False, True

    Set sh = AddText(pg, 3.94, 1.12, 5.66, 1.62, "相位误差引入的ICI噪声" & vbCrLf & "Phase error induced ICI noise", 7.3, True, 45, 45, 45, 1)
    AddLine pg, 4.64, 1.66, 4.38, 2.10, 60, 60, 60, 0.8, False, True

    ' ---------------- Panel B ----------------
    Set sh = AddText(pg, 6.38, 5.30, 8.95, 5.70, "(b) Preprocessing imposes" & vbCrLf & "assumptions", 9.2, True, 55, 55, 55, 1)
    Set sh = AddText(pg, 6.62, 4.93, 8.72, 5.18, "sensing-centric pipeline", 6.5, False, 120, 120, 120, 1)
    Set sh = AddBox(pg, 6.78, 4.45, 8.53, 4.79, "Raw CSI", 245, 248, 250, 150, 160, 170, 7.5, False)
    sh.CellsU("Rounding").FormulaU = "0 in"

    Dim bTop As Double, bBot As Double, i As Integer
    Dim steps(0 To 4) As String
    steps(0) = "Denoising"
    steps(1) = "Outlier handling"
    steps(2) = "Phase calibration"
    steps(3) = "Normalization"
    steps(4) = "Interpolation"
    For i = 0 To 4
        bTop = 4.12 - i * 0.78
        bBot = bTop - 0.43
        Set sh = AddBox(pg, 6.58, bBot, 8.72, bTop, steps(i), 248, 253, 255, 86, 176, 198, 7.5, False)
        If i = 0 Then
            AddLine pg, 7.65, 4.45, 7.65, bTop, 65, 65, 65, 0.9, False, True
        Else
            AddLine pg, 7.65, 4.12 - (i - 1) * 0.78 - 0.43, 7.65, bTop, 65, 65, 65, 0.9, False, True
        End If
    Next i
    AddLine pg, 7.65, 0.57, 7.65, 0.32, 65, 65, 65, 0.9, False, True

    ' ---------------- Panel C ----------------
    Set sh = AddText(pg, 9.28, 5.28, 12.65, 5.70, "(c) Different preprocessing" & vbCrLf & "preserves different information", 9, True, 224, 145, 45, 1)

    DrawInfoCard pg, 9.36, 3.92, 12.56, 5.05, 1, "Proper preprocessing", 70, 165, 105, 0
    DrawInfoCard pg, 9.36, 2.50, 12.56, 3.63, 2, "Over-processing", 235, 155, 55, 1
    DrawInfoCard pg, 9.36, 0.66, 12.56, 2.20, 3, "Phase distortion", 215, 70, 70, 2

    Set sh = AddText(pg, 9.70, 1.54, 12.25, 1.86, "φcal(t) = φraw(t) + φfit(t)", 7.4, True, 75, 75, 75, 1)
    AddLine pg, 10.96, 1.49, 10.96, 1.20, 70, 70, 70, 0.8, False, True
    Set sh = AddText(pg, 9.66, 0.82, 12.28, 1.18, "Calibration may alter a" & vbCrLf & "phase-related sensing cue.", 6.7, False, 110, 110, 110, 1)

    ' ---------------- Panel D ----------------
    Set sh = AddText(pg, 12.98, 5.28, 15.76, 5.70, "(d) Same model, different" & vbCrLf & "conclusions", 9.2, True, 66, 133, 190, 1)

    DrawInputBox pg, 13.10, 4.05, 13.86, 4.72, 70, 165, 105, 0
    DrawInputBox pg, 13.10, 2.72, 13.86, 3.39, 235, 155, 55, 1
    DrawInputBox pg, 13.10, 1.39, 13.86, 2.06, 215, 70, 70, 2

    Set sh = AddBox(pg, 14.28, 1.72, 15.08, 4.38, "Same" & vbCrLf & "downstream" & vbCrLf & "model", 252, 253, 254, 140, 150, 165, 7.3, True)
    AddNetwork pg, 14.40, 2.02, 14.95, 2.90

    AddLine pg, 13.86, 4.38, 14.28, 4.02, 75, 75, 75, 0.9, False, True
    AddLine pg, 13.86, 3.05, 14.28, 3.05, 75, 75, 75, 0.9, False, True
    AddLine pg, 13.86, 1.72, 14.28, 2.08, 75, 75, 75, 0.9, False, True

    Set sh = AddBox(pg, 15.35, 3.92, 15.78, 4.42, "High", 250, 255, 251, 70, 165, 105, 7, True)
    Set sh = AddBox(pg, 15.35, 2.72, 15.78, 3.22, "Med", 255, 252, 247, 235, 155, 55, 7, True)
    Set sh = AddBox(pg, 15.35, 1.52, 15.78, 2.02, "Low", 255, 250, 250, 215, 70, 70, 7, True)
    AddLine pg, 15.08, 3.60, 15.35, 4.17, 75, 75, 75, 0.9, False, True
    AddLine pg, 15.08, 3.05, 15.35, 2.97, 75, 75, 75, 0.9, False, True
    AddLine pg, 15.08, 2.48, 15.35, 1.77, 75, 75, 75, 0.9, False, True

    MsgBox "CSI preprocessing figure created.", vbInformation
End Sub

Private Function AddBox(pg As Visio.Page, ByVal x1 As Double, ByVal y1 As Double, ByVal x2 As Double, ByVal y2 As Double, ByVal txt As String, ByVal fr As Long, ByVal fg As Long, ByVal fb As Long, ByVal lr As Long, ByVal lg As Long, ByVal lb As Long, ByVal fs As Double, ByVal isBold As Boolean) As Visio.Shape
    Dim sh As Visio.Shape
    Set sh = pg.DrawRectangle(x1, y1, x2, y2)
    sh.Text = txt
    If fr < 0 Then
        sh.CellsU("FillPattern").FormulaU = "0"
    Else
        sh.CellsU("FillPattern").FormulaU = "1"
        sh.CellsU("FillForegnd").FormulaU = "RGB(" & fr & "," & fg & "," & fb & ")"
    End If
    If lr < 0 Then
        sh.CellsU("LinePattern").FormulaU = "0"
    Else
        sh.CellsU("LinePattern").FormulaU = "1"
        sh.CellsU("LineColor").FormulaU = "RGB(" & lr & "," & lg & "," & lb & ")"
        sh.CellsU("LineWeight").FormulaU = "1 pt"
    End If
    sh.CellsU("Rounding").FormulaU = "0.07 in"
    sh.CellsU("Char.Size").FormulaU = fs & " pt"
    If isBold Then sh.CellsU("Char.Style").FormulaU = "1"
    sh.CellsU("Para.HorzAlign").FormulaU = "1"
    sh.CellsU("VerticalAlign").FormulaU = "1"
    sh.CellsU("TxtLeftMargin").FormulaU = "0.03 in"
    sh.CellsU("TxtRightMargin").FormulaU = "0.03 in"
    Set AddBox = sh
End Function

Private Function AddText(pg As Visio.Page, ByVal x1 As Double, ByVal y1 As Double, ByVal x2 As Double, ByVal y2 As Double, ByVal txt As String, ByVal fs As Double, ByVal isBold As Boolean, ByVal cr As Long, ByVal cg As Long, ByVal cb As Long, ByVal align As Integer) As Visio.Shape
    Dim sh As Visio.Shape
    Set sh = AddBox(pg, x1, y1, x2, y2, txt, -1, -1, -1, -1, -1, -1, fs, isBold)
    sh.CellsU("Char.Color").FormulaU = "RGB(" & cr & "," & cg & "," & cb & ")"
    sh.CellsU("Para.HorzAlign").FormulaU = CStr(align)
    Set AddText = sh
End Function

Private Sub AddLine(pg As Visio.Page, ByVal x1 As Double, ByVal y1 As Double, ByVal x2 As Double, ByVal y2 As Double, ByVal cr As Long, ByVal cg As Long, ByVal cb As Long, ByVal wt As Double, ByVal dashed As Boolean, ByVal arrowEnd As Boolean)
    Dim sh As Visio.Shape
    Set sh = pg.DrawLine(x1, y1, x2, y2)
    sh.CellsU("LineColor").FormulaU = "RGB(" & cr & "," & cg & "," & cb & ")"
    sh.CellsU("LineWeight").FormulaU = wt & " pt"
    If dashed Then sh.CellsU("LinePattern").FormulaU = "2"
    If arrowEnd Then sh.CellsU("EndArrow").FormulaU = "13"
End Sub

Private Sub DrawRawWave(pg As Visio.Page, ByVal x0 As Double, ByVal y0 As Double, ByVal w As Double, ByVal h As Double)
    Dim i As Integer, n As Integer
    Dim t1 As Double, t2 As Double, x1 As Double, x2 As Double, y1 As Double, y2 As Double
    Dim drift1 As Double, drift2 As Double
    n = 80
    For i = 0 To n - 1
        t1 = i / n: t2 = (i + 1) / n
        drift1 = 0.42 * t1 + IIf(t1 > 0.64, 0.32 + 0.38 * (t1 - 0.64), 0)
        drift2 = 0.42 * t2 + IIf(t2 > 0.64, 0.32 + 0.38 * (t2 - 0.64), 0)
        x1 = x0 + w * t1: x2 = x0 + w * t2
        y1 = y0 + h * (0.43 + 0.26 * Sin(2 * PI * 9 * t1) + 0.055 * Sin(2 * PI * 31 * t1) + drift1)
        y2 = y0 + h * (0.43 + 0.26 * Sin(2 * PI * 9 * t2) + 0.055 * Sin(2 * PI * 31 * t2) + drift2)
        AddLine pg, x1, y1, x2, y2, 52, 137, 194, 1.3, False, False
    Next i
End Sub

Private Sub DrawInfoCard(pg As Visio.Page, ByVal x1 As Double, ByVal y1 As Double, ByVal x2 As Double, ByVal y2 As Double, ByVal num As Integer, ByVal heading As String, ByVal cr As Long, ByVal cg As Long, ByVal cb As Long, ByVal mode As Integer)
    Dim sh As Visio.Shape
    Set sh = AddBox(pg, x1, y1, x2, y2, "", 255, 255, 255, cr, cg, cb, 7, False)
    Set sh = pg.DrawOval(x1 + 0.12, y2 - 0.34, x1 + 0.38, y2 - 0.08)
    sh.Text = CStr(num)
    sh.CellsU("FillForegnd").FormulaU = "RGB(" & cr & "," & cg & "," & cb & ")"
    sh.CellsU("LinePattern").FormulaU = "0"
    sh.CellsU("Char.Color").FormulaU = "RGB(255,255,255)"
    sh.CellsU("Char.Size").FormulaU = "6 pt"
    sh.CellsU("Char.Style").FormulaU = "1"
    sh.CellsU("Para.HorzAlign").FormulaU = "1"
    sh.CellsU("VerticalAlign").FormulaU = "1"
    Set sh = AddText(pg, x1 + 0.46, y2 - 0.36, x2 - 0.10, y2 - 0.06, heading, 7.6, True, cr, cg, cb, 0)
    If mode < 2 Then
        Set sh = AddText(pg, x1 + 0.15, y1 + 0.40, x1 + 0.58, y1 + 0.70, "|CSI|", 6.5, False, 80, 80, 80, 1)
        DrawSpark pg, x1 + 0.60, y1 + 0.42, x2 - 0.20, y1 + 0.76, cr, cg, cb, mode
        AddLine pg, x1 + 0.60, y1 + 0.40, x2 - 0.18, y1 + 0.40, 150, 150, 150, 0.5, False, False
        If mode = 0 Then
            Set sh = AddText(pg, x1 + 0.60, y1 + 0.07, x2 - 0.14, y1 + 0.34, "Noise reduced, motion structure preserved", 5.8, False, 110, 110, 110, 1)
        Else
            Set sh = AddText(pg, x1 + 0.60, y1 + 0.07, x2 - 0.14, y1 + 0.34, "Motion peaks weakened or removed", 5.8, False, 110, 110, 110, 1)
        End If
    End If
End Sub

Private Sub DrawSpark(pg As Visio.Page, ByVal x1 As Double, ByVal y1 As Double, ByVal x2 As Double, ByVal y2 As Double, ByVal cr As Long, ByVal cg As Long, ByVal cb As Long, ByVal mode As Integer)
    Dim i As Integer, n As Integer
    Dim t1 As Double, t2 As Double, py1 As Double, py2 As Double
    n = 22
    For i = 0 To n - 1
        t1 = i / n: t2 = (i + 1) / n
        If mode = 0 Then
            py1 = (Sin(2 * PI * 5 * t1) + 0.28 * Sin(2 * PI * 13 * t1)) * 0.33
            py2 = (Sin(2 * PI * 5 * t2) + 0.28 * Sin(2 * PI * 13 * t2)) * 0.33
        Else
            py1 = Sin(2 * PI * 2 * t1) * 0.12
            py2 = Sin(2 * PI * 2 * t2) * 0.12
        End If
        AddLine pg, x1 + (x2 - x1) * t1, (y1 + y2) / 2 + py1 * (y2 - y1), x1 + (x2 - x1) * t2, (y1 + y2) / 2 + py2 * (y2 - y1), cr, cg, cb, 1.05, False, False
    Next i
End Sub

Private Sub DrawInputBox(pg As Visio.Page, ByVal x1 As Double, ByVal y1 As Double, ByVal x2 As Double, ByVal y2 As Double, ByVal cr As Long, ByVal cg As Long, ByVal cb As Long, ByVal mode As Integer)
    Dim sh As Visio.Shape
    Set sh = AddBox(pg, x1, y1, x2, y2, "", 255, 255, 255, cr, cg, cb, 7, False)
    DrawSpark pg, x1 + 0.10, y1 + 0.14, x2 - 0.10, y2 - 0.14, cr, cg, cb, mode
End Sub

Private Sub AddNetwork(pg As Visio.Page, ByVal x1 As Double, ByVal y1 As Double, ByVal x2 As Double, ByVal y2 As Double)
    Dim a(0 To 2) As Double, b(0 To 1) As Double, i As Integer, j As Integer
    a(0) = y1 + 0.12: a(1) = (y1 + y2) / 2: a(2) = y2 - 0.12
    b(0) = y1 + 0.26: b(1) = y2 - 0.26
    For i = 0 To 2
        For j = 0 To 1
            AddLine pg, x1 + 0.08, a(i), x2 - 0.08, b(j), 150, 160, 175, 0.55, False, False
        Next j
    Next i
    For i = 0 To 2
        AddNode pg, x1, a(i)
    Next i
    For j = 0 To 1
        AddNode pg, x2, b(j)
    Next j
End Sub

Private Sub AddNode(pg As Visio.Page, ByVal x As Double, ByVal y As Double)
    Dim sh As Visio.Shape
    Set sh = pg.DrawOval(x - 0.07, y - 0.07, x + 0.07, y + 0.07)
    sh.CellsU("FillForegnd").FormulaU = "RGB(255,255,255)"
    sh.CellsU("LineColor").FormulaU = "RGB(135,145,160)"
    sh.CellsU("LineWeight").FormulaU = "0.7 pt"
End Sub
