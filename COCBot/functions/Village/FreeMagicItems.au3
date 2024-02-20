; #FUNCTION# ====================================================================================================================
; Name ..........: Collect Free Magic Items from trader
; Description ...:
; Syntax ........: CollectFreeMagicItems()
; Parameters ....:
; Return values .: None
; Author ........: ProMac (03-2018)
; Modified ......: DumbGit (02-2024)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Local $g_iMidPointX = round($g_iGAME_WIDTH / 2)
Local $g_iMidPointY = round($g_iGAME_HEIGHT / 2)
Local $CocDiamondTL = 0  & "," & 0 & "|" & $g_iMidPointX & "," & 0 & "|" & $g_iMidPointX & "," & $g_iMidPointY & "|" & 0 & "," & $g_iMidPointY
Local $aCloseTraderBtn[4] = [798, 97 + $g_iMidOffsetY, 0xF38F8D, 10]

Func CollectFreeMagicItems($bTest = False, $sBuyItem = "")
	If Not $g_bChkCollectFreeMagicItems Then Return
	Local Static $iLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0]

	If $g_bFirstStart Then $iLastTimeChecked[$g_iCurAccount] = 0

	; check once a day
	If $iLastTimeChecked[$g_iCurAccount] = @MDAY And Not $bTest Then Return

	If OpenTraderPage() Then
		If $sBuyItem <> "" Then _CollectFreeMagicItems($bTest, $sBuyItem)

		; collect free item
		If ClickSideBar() Then _CollectFreeMagicItems($bTest, "")

		If _Sleep(1000) Then Return
		CloseTraderPage()

		$iLastTimeChecked[$g_iCurAccount] = @MDAY
	EndIf
EndFunc   ;==>DailyChallenges

Func OpenTraderPage()
	; Check Trader Icon on Main Village
	Local $sImgTraderImage = @ScriptDir & "\imgxml\FreeMagicItems\TraderIcon\Trader*"
	Local $sTraderArea = $CocDiamondTL ;GetDiamondFromRect("75,110,185,185")
	Local $aiTrader, $iExit = 0, $bExit = False, $bRet = False

	If Not IsMainPage() Then Return
	If _Sleep($DELAYCOLLECT2) Then Return

	While $iExit < 30 And $bExit = False
		$aiTrader = decodeSingleCoord(findImage("OpenTraderPage", $sImgTraderImage, $sTraderArea, 1, True))
		If IsArray($aiTrader) And UBound($aiTrader) = 2 Then
			SetLog("Trader image available", $COLOR_SUCCESS)
			ClickP($aiTrader)
			If _Sleep(250) Then Return
			$bExit = True
		EndIf

		$iExit += 1
		If _Sleep(200) Then Return
	WEnd

	If Not $g_bRunState Then Return

	If $iExit < 30 Then
		$iExit = 0
		$bExit = False
		While $iExit < 30 And $bExit = False
			; check Trader is opened
			If _CheckPixel($aCloseTraderBtn, True) Then
				$bExit = True
				$bRet = True
			EndIf

			If Not $g_bRunState Then Return

			$iExit += 1
			If _Sleep(200) Then Return
		WEnd
	EndIf

	If $iExit > 29 Then
		SetLog("OpenTraderPage failed", $COLOR_ACTION)
		SaveDebugDiamondImage("OpenTraderPage", $sTraderArea)
	EndIf

	Return $bRet
EndFunc

Func ClickSideBar($bSwitch = 0, $bDebugImageSave = $g_bDebugImageSave)
	SetLog("ClickSideBar")
	Local $sImgGreenGemsBtn = @ScriptDir & "\imgxml\FreeMagicItems\SideButtons\GreenGemsButton*"
	Local $sImgGreyGemsBtn = @ScriptDir & "\imgxml\FreeMagicItems\SideButtons\GreyGemsButton*"
	Local $sSearchArea = GetDiamondFromRect2(50, 173 + $g_iMidOffsetY, 110, 313 + $g_iMidOffsetY)
	Local $aiGreenGemsBtn, $aiGreyGemsBtn, $iExit = 0, $bExit = False, $bRet = False

	; check Trader is opened
	If _CheckPixel($aCloseTraderBtn, True) Then
		If $bDebugImageSave Then SaveDebugDiamondImage("ClickSideBar", $sSearchArea)
		While $iExit < 30 And $bExit = False
			Switch $bSwitch
				Case 0
				; search for green GEM side bar
				$aiGreenGemsBtn = decodeSingleCoord(findImage("OpenTraderPage", $sImgGreenGemsBtn, $sSearchArea, 1, True, Default))
				If IsArray($aiGreenGemsBtn) And Ubound($aiGreenGemsBtn, 1) = 2 Then
					SetLog("Gem Tab available", $COLOR_SUCCESS)
					$bExit = True
					$bRet = True
				Else ; search for grey GEM side bar
					$aiGreyGemsBtn = decodeSingleCoord(findImage("OpenTraderPage", $sImgGreyGemsBtn, $sSearchArea, 1, True, Default))
					If IsArray($aiGreyGemsBtn) And Ubound($aiGreyGemsBtn, 1) = 2 Then PureClickP($aiGreyGemsBtn)
				EndIf

				Case Else
					SetLog("SideBar not found")
			EndSwitch

			If Not $g_bRunState Then Return
			$iExit += 1
			If _Sleep(200) Then Return
		WEnd
	EndIf

	If $iExit > 29 Then
		SetLog("ClickSideBar failed", $COLOR_ACTION)
		SaveDebugDiamondImage("ClickSideBar", $sSearchArea)
	EndIf

	If _Sleep(1000) Then Return

	Return $bRet
EndFunc

Func _CollectFreeMagicItems($bTest = False, $sBuyItem = "", $bDebugImageSave = $g_bDebugImageSave)
	Local $aResults[3] = ["", "", ""]
	Local $aSoldOut[4] = [236, 257 + $g_iMidOffsetY, 0xAF5E0D, 10]
	Local $aiDebugXY[2], $iSlotX, $iSlotY = 325 + $g_iMidOffsetY
	Local $sItem = "FREE"
	Local $aCoin[4] = [486, 400 + $g_iMidOffsetY, 0XFDD00E, 10]

	If $sBuyItem <> "" Then
		SetLog("Buying Magic Item", $COLOR_INFO)
		$sItem = $sBuyItem
	Else
		SetLog("Collecting Free Magic Item", $COLOR_INFO)
	EndIf

	For $i = 0 To 2
		$iSlotX = 224 + $i * 204
		$aResults[$i] = getOcrAndCapture("coc-freemagicitems", 54 + $iSlotX, $iSlotY, 80, 25, True)
		;$aResults[$i] = getOcrAndCapture("coc-freemagicitems", $aOcrPositions[$i][0], $aOcrPositions[$i][1], 80, 25, True)
		;$aResults[$i] = getOcrAndCapture("coc-freemagicitems", $aOcrPositions[$i][0], $aOcrPositions[$i][1], 80, 30, True) ;CLASHIVERSARY title
		; 5D79C5 ; >Blue Background price
		; 0D997C ; >Xmas

		If $aResults[$i] <> "" Then
			If $aResults[$i] = $sItem Then
				If _CheckPixel($aSoldOut, True, Default, "CollectFreeMagicItems") Then
					SetLog("Sold Out!", $COLOR_INFO)
					$aResults[$i] = "Sold Out"
					If _Sleep(100) Then Return
				Else
					; check for grey background
					If _ColorCheck(_GetPixelColor(54 + $iSlotX, $iSlotY, True), Hex(0xA4A4A4, 6), 10) Then
						SetLog("Storage full", $COLOR_ACTION)
						$aResults[$i] = "Storage full"
					Else
						If Not $bTest Then
							Click(54 + $iSlotX, $iSlotY, 2, 500)
							If $sBuyItem <> "" Then
								If _Sleep(2000) Then Return
								If _CheckPixel($aCoin, True) Then PureClickP($aCoin)
							EndIf
						EndIf
					EndIf
					SetLog($sItem & " Item detected", $COLOR_INFO)
				EndIf
				If $bDebugImageSave Then
					$aiDebugXY[0] = 54 + $iSlotX
					$aiDebugXY[1] = $iSlotY
					SaveDebugPointImage("_CollectFreeMagicItems", $aiDebugXY)
				EndIf
				If _Sleep(500) Then Return
			Else
				If _ColorCheck(_GetPixelColor(139 + $iSlotX, 12 + $iSlotY, True), Hex(0xE5FD8E, 6), 10) Then $aResults[$i] = $aResults[$i] & " Gems"
				If $bDebugImageSave Then
					$aiDebugXY[0] = 139 + $iSlotX
					$aiDebugXY[1] = 12 + $iSlotY
					SaveDebugPointImage("_CollectFreeMagicItems", $aiDebugXY)
				EndIf
			EndIf
		Else
			If $aResults[$i] = "" Then $aResults[$i] = "N/A"
		EndIf

		If Not $g_bRunState Then Return
	Next

	SetLog("Weekly Discounts: " & $aResults[0] & " | " & $aResults[1] & " | " & $aResults[2])
EndFunc   ;==>CollectFreeMagicItems

Func CloseTraderPage()
	If $g_bDebugSetlog Then SetLog("Closing Trader Window", $COLOR_INFO)

	If _CheckPixel($aCloseTraderBtn, True) Then
		ClickP($aCloseTraderBtn, 1, 0, "#0667")
		If _Sleep(100) Then Return
	Else
		SetLog("Can't find close button", $COLOR_ERROR)
		ClickAway()
	EndIf

	Local $iExit = 0
	While $iExit < 30 And Not IsMainPage(1)
		If $g_bDebugSetlog Then SetDebugLog("Wait for Trader Window to close #" & $iExit)
		If _Sleep($DELAYRUNBOT6) Then Return
		$iExit += 1
	WEnd
EndFunc   ;==>CloseTraderPage



Local $aEventChallengeCloseBtn[4] = [804, 76 + $g_iMidOffsetY, 0xFF8587, 10]

Func EventChallenges($bTest = False)
	Local Static $asLastTimeChecked[8]
	If $g_bFirstStart Then $asLastTimeChecked[$g_iCurAccount] = ""

	checkMainScreen(False)

	If _DateIsValid($asLastTimeChecked[$g_iCurAccount]) And Not $bTest Then
		Local $iLastCheck = _DateDiff('n', $asLastTimeChecked[$g_iCurAccount], _NowCalc()) ; elapse time from last check (minutes)
		SetDebugLog("LastCheck: " & $asLastTimeChecked[$g_iCurAccount] & ", Check DateCalc: " & $iLastCheck)
		If ($iLastCheck <= 360) Then Return ; 6 hours [6*60 = 360]
	EndIf

	If OpenEventChallenges() Then
		CollectEventRewards($bTest)

		If _Sleep(1000) Then Return
		CloseEventChallenges()
	EndIf

	$asLastTimeChecked[$g_iCurAccount] = _NowCalc()
EndFunc   ;==>DailyChallenges

Func OpenEventChallenges()
	SetLog("Opening Event challenges", $COLOR_INFO)
	If Not IsMainPage() Then Return
	If _Sleep($DELAYCOLLECT2) Then Return

	Local $sImgEventImage = @ScriptDir & "\imgxml\EventChallenges\EventImage*"
	Local $sImgEventButton = @ScriptDir & "\imgxml\EventChallenges\EventButton*"
	Local $sImgEventIntro = @ScriptDir & "\imgxml\EventChallenges\EventIntro*"
	Local $sImageArea = $CocDiamondTL
	Local $sButtonArea = GetDiamondFromRect2(140, 504 + $g_iBottomOffsetY, 720, 587 + $g_iBottomOffsetY)
	Local $sIntroArea = GetDiamondFromRect2(365, 555 + $g_iMidOffsetY, 495, 615 + $g_iMidOffsetY) ; continue button
	Local $aiImage, $aiButton, $aiIntro, $iExit = 0, $bRet = False, $bExit = False

	; search for event on main screen
	While $iExit < 30 And $bExit = False
		$aiImage = decodeSingleCoord(findImage("OpenEventChallenges", $sImgEventImage, $sImageArea, 1, True))
		If IsArray($aiImage) And UBound($aiImage) = 2 Then
			SetLog("Event Image available", $COLOR_SUCCESS)
			PureClickP($aiImage)
			If _Sleep(1500) Then Return

			; search for event button
			$aiButton = decodeSingleCoord(findImage("OpenEventChallenges", $sImgEventButton, $sButtonArea, 1, True))
			If IsArray($aiButton) And UBound($aiButton) = 2 Then
				SetLog("Event Button available", $COLOR_SUCCESS)
				PureClickP($aiButton)
				If _Sleep(1500) Then Return
				$bExit = True
			EndIf
		EndIf
		$iExit += 1
		If _Sleep(200) Then Return
	WEnd

	If $iExit < 30 Then
		; check event window opened
		$iExit = 0
		While $iExit < 30 And $bRet = False
			If _CheckPixel($aEventChallengeCloseBtn, True) Then
				$bRet = True
			Else
				$aiIntro = decodeSingleCoord(findImage("OpenEventChallenges", $sImgEventIntro, $sIntroArea, 1, True))
				If IsArray($aiIntro) And UBound($aiIntro) = 2 Then
					SetLog("Event Intro available", $COLOR_SUCCESS)
					PureClickP($aiIntro)
					If _Sleep(1500) Then Return
				EndIf
			EndIf
			$iExit += 1
			If _Sleep(200) Then Return
		WEnd
	EndIf

	If $iExit > 29 Then SetLog("OpenEventChallenges failed", $COLOR_INFO)

	Return $bRet
EndFunc   ;==>OpenEventChallenges

Func CollectEventRewards($bTest = False)
	SetLog("Collecting Event Rewards...")
	Local $sImgEventClaimButton = @ScriptDir & "\imgxml\EventChallenges\EventClaimButton*"
	Local $sImgEventProgressCurrent = @ScriptDir & "\imgxml\EventChallenges\EventProgressCurrent*"
	Local $sImgEventProgressStart = @ScriptDir & "\imgxml\EventChallenges\EventProgressStart*"
	Local $sImgEventClaimBonusButton = @ScriptDir & "\imgxml\EventChallenges\EventClaimBonusButton*"
	Local $sClaimButtonArea = GetDiamondFromRect2(32, 524 + $g_iMidOffsetY, 834, 572 + $g_iMidOffsetY)
	Local $sProgressAreaLeft = GetDiamondFromRect2(755, 356 + $g_iMidOffsetY, 834, 416 + $g_iMidOffsetY)
	Local $sProgressAreaRight = GetDiamondFromRect2(32, 356 + $g_iMidOffsetY, 110, 416 + $g_iMidOffsetY)
	Local $sProgressAreaMid = GetDiamondFromRect2(410, 356 + $g_iMidOffsetY, 525, 416 + $g_iMidOffsetY)
	Local $avClaimButtons, $aiClaimButton, $aiProgressCurrentButton, $aiProgressStartButton, $bProgressEnd = False, $bExit = False, $iExit = 0

	While $iExit < 30 And $bExit = False
		SetLog("Collecting Event Rewards..." & $iExit)

		$avClaimButtons = decodeMultipleCoords(findImage("CollectEventRewards", $sImgEventClaimButton, $sClaimButtonArea, 4, True), Default, Default, 0)
		If IsArray($avClaimButtons) Then
			For $aiClaimButton In $avClaimButtons
				SetLog("Found Claim Button at : " & $aiClaimButton[0] & "," & $aiClaimButton[1], $COLOR_INFO)
				If Not $bTest Then PureClickP($aiClaimButton)
				If _Sleep(2000) Then Return False
			Next
		Else
			SetLog("Failed to locate Claim Button", $COLOR_INFO)
		EndIf

		; search for bonus track claim button
		$aiClaimButton = decodeSingleCoord(findImage("OpenEventChallenges", $sImgEventClaimBonusButton, $sProgressAreaMid, 1, True))
		If IsArray($aiClaimButton) And UBound($aiClaimButton) = 2 Then
			SetLog("Bonus Track Claim button available", $COLOR_SUCCESS)
			If Not $bTest Then PureClickP($aiClaimButton)
			;$bExit = True
		Else
			; search for progress button first
			$aiProgressCurrentButton = decodeSingleCoord(findImage("OpenEventChallenges", $sImgEventProgressCurrent, $sProgressAreaLeft, 1, True))
			If IsArray($aiProgressCurrentButton) And UBound($aiProgressCurrentButton) = 2 And $bProgressEnd = False Then
				SetLog("Progress Current Image available", $COLOR_SUCCESS)
				ClickDrag(740, 340 + $g_iMidOffsetY, 120, 340 + $g_iMidOffsetY)
				If _Sleep(1500) Then Return
			Else
				$bProgressEnd = True
				$aiProgressStartButton = decodeSingleCoord(findImage("OpenEventChallenges", $sImgEventProgressStart, $sProgressAreaRight, 1, True))
				If IsArray($aiProgressStartButton) And UBound($aiProgressStartButton) = 2 Then
					SetLog("Progress Start Image available", $COLOR_SUCCESS)
					ClickDrag(120, 340 + $g_iMidOffsetY, 740, 340 + $g_iMidOffsetY)
					If _Sleep(1500) Then Return
				Else
					$bExit = True
				EndIf
			EndIf
		EndIf

		$iExit += 1

		If _Sleep(1000) Then Return
	WEnd

	If _Sleep(1000) Then Return
EndFunc   ;==>CollectEventRewards

Func CloseEventChallenges()
	If $g_bDebugSetlog Then SetLog("Closing personal challenges", $COLOR_INFO)

	If _CheckPixel($aEventChallengeCloseBtn, True) Then
		ClickP($aEventChallengeCloseBtn, 1, 0, "#0667")
		If _Sleep(100) Then Return
		ClickAway()
	Else
		SetLog("Can't find close button", $COLOR_ERROR)
		ClickAway()
	EndIf

	Local $iExit = 0
	While $iExit < 30 And Not IsMainPage(1)
		If $g_bDebugSetlog Then SetDebugLog("Wait for Event Challenge Window to close #" & $iExit)
		If _Sleep($DELAYRUNBOT6) Then Return
		$iExit += 1
	WEnd
EndFunc   ;==>CloseEventChallenges