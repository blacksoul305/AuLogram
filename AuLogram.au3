#cs ----------------------------------------------------------------------------

 AutoIt Version : 3.3.12.0
 Auteur:         		blacksoul305 et Uranium de autoitscript.fr

 Fonction du Script :	Support image pour hologrammes.

#ce ----------------------------------------------------------------------------

#pragma compile(Icon, C:\Program Files (x86)\AutoIt3\Icons\au3.ico)

#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>

Global $i_WIN_WIDTH = 800, $i_WIN_HEIGHT = 800
Global $i_TRG_TOP = 30, $i_TRG_BOT = 180, $i_TRG_HEIGHT = 105

 Local $hGDIGraph, $hGDIPen

_GDIPlus_Startup()

Local $hForm1 = GUICreate("AuLogram", $i_WIN_WIDTH, $i_WIN_HEIGHT)
$hGDIGraph = _GDIPlus_GraphicsCreateFromHWND($hForm1)
GUISetState(@SW_SHOW)

$hGDIMatrix = _GDIPlus_MatrixCreate()
$hGDIPen = _GDIPlus_PenCreate(0xFFFFFFFF) ; white pen
_GDIPlus_GraphicsClear($hGDIGraph)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			_GDIPlus_GraphicsDispose($hGDIGraph)
			_GDIPlus_PenDispose($hGDIPen)
			_GDIPlus_Shutdown()
			Exit
		Case $GUI_EVENT_PRIMARYDOWN ; Left-mouse button clears the graphic.
			_GDIPlus_GraphicsClear($hGDIGraph)
		Case $GUI_EVENT_SECONDARYDOWN ; Right-mouse button draws the hologram patron.
			_DrawHologramMask($hGDIGraph, $hGDIPen, $i_WIN_WIDTH/2, $i_WIN_HEIGHT/2, 2.5)
	EndSwitch
WEnd

;~  - - - FUNCTIONS - - -

Func _DrawTriangularMask($hGraph, $hPen, $iX, $iY, $fScale = 1)
	Local $aFigPoints[5][2] = [ [4, 4], _
								[($iX - ($fScale * $i_TRG_TOP/2)), $iY], _
								[($iX + ($fScale * $i_TRG_TOP/2)), $iY], _
								[($iX + ($fScale * $i_TRG_BOT/2)), (($iY - $fScale * $i_TRG_HEIGHT))], _
								[($iX - ($fScale * $i_TRG_BOT/2)), (($iY - $fScale * $i_TRG_HEIGHT))] ]
	_GDIPlus_GraphicsDrawPolygon($hGraph, $aFigPoints, $hPen)
EndFunc

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
