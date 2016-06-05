#cs ----------------------------------------------------------------------------

 AutoIt Version : 3.3.12.0
 Auteur:         		blacksoul305 et Uranium de autoitscript.fr

 Fonction du Script :	Support image pour hologrammes.

#ce ----------------------------------------------------------------------------

#pragma compile(Icon, C:\Program Files (x86)\AutoIt3\Icons\au3.ico)

#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>

Global Const $i_WIN_WIDTH = 800, $i_WIN_HEIGHT = 800
Global Const $i_TRG_TOP = 30, $i_TRG_BOT = 180, $i_TRG_HEIGHT = 105
Global Const $s_IN_PATH = @ScriptDir & "\data\in\", $s_OUT_PATH = @ScriptDir & "\data\out\"

 Local $hGDIGraph, $hGDIPen, $hGDIBitmap
 Local $sImagePath = $s_IN_PATH & "bird.jpg"

_GDIPlus_Startup()

Local $hForm1 = GUICreate("AuLogram", $i_WIN_WIDTH, $i_WIN_HEIGHT)
$hGDIGraph = _GDIPlus_GraphicsCreateFromHWND($hForm1)
GUISetState(@SW_SHOW)

$hGDIMatrix = _GDIPlus_MatrixCreate()
$hGDIPen = _GDIPlus_PenCreate(0xFFFFFFFF) ; white pen
$hGDIBitmap = _GDIPlus_BitmapCreateFromFile($sImagePath)
_GDIPlus_GraphicsClear($hGDIGraph) ; black background

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_GDIPlus_GraphicsDispose($hGDIGraph)
			_GDIPlus_PenDispose($hGDIPen)
			_GDIPlus_BitmapDispose($hGDIBitmap)
			_GDIPlus_Shutdown()
			Exit
		Case $GUI_EVENT_PRIMARYDOWN ; Left-mouse button clears the graphic.
			_GDIPlus_GraphicsClear($hGDIGraph)
		Case $GUI_EVENT_SECONDARYDOWN ; Right-mouse button draws the hologram patron.
			_DrawHologramMask($hGDIGraph, $hGDIPen, $i_WIN_WIDTH/2, $i_WIN_HEIGHT/2, 2.5)
			_DrawHologram($hGDIGraph, $hGDIBitmap,  $i_WIN_WIDTH/2, $i_WIN_HEIGHT/2, 2.5)
;~ 			_GDIPlus_GraphicsDrawImage($hGDIGraph, $hGDIBitmap, -$i_WIN_WIDTH/2, -$i_WIN_HEIGHT/2)
	EndSwitch
WEnd

;~  - - - FUNCTIONS - - -

;~ Description : 	Draws a triangular mask at the couple ($iX;$iY) coordinate on a graph.
;~ Arguments : 		$hGraph is the handle of a Graphic Object.
;~ 					$hPen is the handle of a Pen Object.
;~ 					$iX is the X coordinate where the triangular mask has to be drawn.
;~ 					$iY is the Y coordinate where the triangular mask has to be drawn.
;~ 					$fScale is scaling coefficient.
;~ Author : 		blacksoul305
Func _DrawTriangularMask($hGraph, $hPen, $iX, $iY, $fScale = 1)
	Local $aFigPoints[5][2] = [ [4, 4], _
								[($iX - ($fScale * $i_TRG_TOP/2)), $iY], _
								[($iX + ($fScale * $i_TRG_TOP/2)), $iY], _
								[($iX + ($fScale * $i_TRG_BOT/2)), (($iY - $fScale * $i_TRG_HEIGHT))], _
								[($iX - ($fScale * $i_TRG_BOT/2)), (($iY - $fScale * $i_TRG_HEIGHT))] ]
	_GDIPlus_GraphicsDrawPolygon($hGraph, $aFigPoints, $hPen)
EndFunc

;~ Description : 	Draws the hologram mask at the couple ($iX;$iY) coordinate on a graph.
;~ Arguments : 		$hGraph is the handle of a Graphic Object.
;~ 					$hPen is the handle of a Pen Object.
;~ 					$iX is the X coordinate where the hologram mask has to be drawn.
;~ 					$iY is the Y coordinate where the hologram mask has to be drawn.
;~ 					$fScale is scaling coefficient.
;~ Author : 		blacksoul305
Func _DrawHologramMask($hGraph, $hPen, $iX, $iY, $fScale = 1)
	Local $hMatrix, $hBitmap, $hTmpGraph
	$hMatrix = _GDIPlus_MatrixCreate() ; creates a transformation matrix (identity)
	_GDIPlus_MatrixTranslate($hMatrix,$iX + $fScale * ($i_TRG_TOP/2), $iY + $fScale * ($i_TRG_TOP/2))
	For $i = 0 To 3
		Switch $i
			Case 0
				_GDIPlus_MatrixTranslate($hMatrix, 0, ($fScale * (-$i_TRG_TOP/2)))
			Case 1
				_GDIPlus_MatrixTranslate($hMatrix, 0, ($fScale * ($i_TRG_TOP/2)))
				_GDIPlus_MatrixTranslate($hMatrix, ($fScale * ($i_TRG_TOP/2)), 0)
			Case 2
				_GDIPlus_MatrixTranslate($hMatrix, ($fScale * ($i_TRG_TOP/2)), 0)
				_GDIPlus_MatrixTranslate($hMatrix, 0, ($fScale * ($i_TRG_TOP/2)))
			Case 3
				_GDIPlus_MatrixTranslate($hMatrix, 0, ($fScale * ($i_TRG_TOP/2)))
				_GDIPlus_MatrixTranslate($hMatrix, ($fScale * ($i_TRG_TOP/2)), 0)
		EndSwitch

		_GDIPlus_MatrixRotate($hMatrix, 90) ; products between the old matrix and this one
		_GDIPlus_GraphicsSetTransform($hGraph, $hMatrix) ; applies transformation to what is drawn on $hGraph with the $hMatrix transformation.
		_DrawTriangularMask($hGraph, $hPen, 0, 0, $fScale) ; draws on $hGraph
;~ 		ConsoleWrite(90 & @CRLF)
;~ 		MsgBox(0,"",$i)
	Next
	_GDIPlus_MatrixDispose($hMatrix) ; frees the matrix
EndFunc

Func _DrawImageIntoTriangularMask($hGraph, $hBitmap, $iX, $iY, $fScale = 1)
	Local $iBitmapWidth = _GDIPlus_ImageGetWidth($hBitmap), $iBitmapHeight = _GDIPlus_ImageGetHeight($hBitmap), $fImageScale = _GetResizingCoeff($iBitmapWidth, $iBitmapHeight), $hTmpBitmap = _GDIPlus_ImageScale($hBitmap, $fImageScale, $fImageScale)
;~ 	Local $iCenteredX = $iX + ($fScale * $i_TRG_BOT/2) - ($fImageScale * $iBitmapWidth), $iCenteredY = $iY + ($fScale * $i_TRG_HEIGHT/2) - ($fImageScale * $iBitmapHeight)
	_GDIPlus_GraphicsDrawImage($hGraph, $hTmpBitmap, 0, 0)
	MsgBox(0,"","drawn")
	_GDIPlus_BitmapDispose($hTmpBitmap)
EndFunc

Func _DrawHologram($hGraph, $hBitmap, $iX, $iY, $fScale = 1)
	Local $hMatrix, $hTmpGraph
	$hMatrix = _GDIPlus_MatrixCreate() ; creates a transformation matrix (identity)
	_GDIPlus_MatrixTranslate($hMatrix,$iX + $fScale * ($i_TRG_TOP/2), $iY + $fScale * ($i_TRG_TOP/2))
	For $i = 0 To 3
;~ 		Switch $i
;~ 			Case 0
;~ 				_GDIPlus_MatrixTranslate($hMatrix, 0, ($fScale * ($i_TRG_HEIGHT/2)))
;~ 			Case 1
;~ 				_GDIPlus_MatrixTranslate($hMatrix, 0, -($fScale * ($i_TRG_HEIGHT/2)))
;~ 				_GDIPlus_MatrixTranslate($hMatrix, 0, ($fScale * ($i_TRG_TOP/2)))
;~ 				_GDIPlus_MatrixTranslate($hMatrix, ($fScale * ($i_TRG_TOP/2)), 0)
;~ 			Case 2
;~ 				_GDIPlus_MatrixTranslate($hMatrix, ($fScale * ($i_TRG_TOP/2)), 0)
;~ 				_GDIPlus_MatrixTranslate($hMatrix, 0, ($fScale * ($i_TRG_TOP/2)))
;~ 			Case 3
;~ 				_GDIPlus_MatrixTranslate($hMatrix, 0, ($fScale * ($i_TRG_TOP/2)))
;~ 				_GDIPlus_MatrixTranslate($hMatrix, ($fScale * ($i_TRG_TOP/2)), 0)
;~ 		EndSwitch

		_GDIPlus_MatrixRotate($hMatrix, 90) ; products between the old matrix and this one
		_GDIPlus_GraphicsSetTransform($hGraph, $hMatrix) ; applies transformation to what is drawn on $hGraph with the $hMatrix transformation.
		_DrawImageIntoTriangularMask($hGraph, $hBitmap, 0, 0, $fScale) ; draws on $hGraph
;~ 		ConsoleWrite(90 & @CRLF)
;~ 		MsgBox(0,"",$i)
	Next
	_GDIPlus_MatrixDispose($hMatrix) ; frees the matrix
EndFunc

Func _GetResizingCoeff($iWidth, $iHeight)
	If ($iWidth > $iHeight) Then
		Return (($i_TRG_TOP * 3)/$iWidth)
	Else
		Return (($i_TRG_HEIGHT/2)/$iHeight)
	EndIf
EndFunc