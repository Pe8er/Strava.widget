-- Strava API documentation: http://strava.github.io/api/

-- Set a few global variables because I'm lazy, please don't touch.
global scriptStart, scriptEnd, myID, unit


on run (arguments)
	-- grab arguments from input
	set myID to item 1 of arguments
	set token to item 2 of arguments
	set unit to item 3 of arguments
	set yDistGoal to item 4 of arguments
	
	set scriptStart to "curl -G https://www.strava.com/api/v3/athlete"
	set scriptEnd to " -H 'Authorization: Bearer " & token & "'"
	set wDistGoal to yDistGoal / 52
	set wNumber to (do shell script "date '+%V'") as number
	set dGoal to wDistGoal / 7
	set dNumber to (do shell script "date '+%u'") as number
	
	------------------------------------------------
	---------------MAIN CALCULATIONS----------------
	------------------------------------------------
	
	
	try
		set wDistance to getwDistance()
		set wProgress to makePercent(wDistance / wDistGoal)
		set wGoal to makePercent((dNumber * dGoal) / wDistGoal)
		set yDistance to getyDistance()
		
		set yProgress to makePercent(yDistance / yDistGoal)
		set yGoal to makePercent((wNumber * wDistGoal) / yDistGoal)
		
		
		--return toMiles(yDistance)
		if unit is "M" then
			set wDistance to toMiles(wDistance)
			set yDistance to toMiles(yDistance)
		end if
		
		
		return Â
			wDistance & space & unit & "~" & Â
			wProgress & "~" & Â
			wGoal & "~" & Â
			yDistance & space & unit & "~" & Â
			yProgress & "~" & Â
			yGoal Â
				as string
	on error e
		logEvent(e)
		return "NA"
	end try
end run


--------------------------------------------------------
---------------SUBROUTINES GALORE--------------
--------------------------------------------------------



on getwDistance()
	set wDistance to 0
	try
		set wDistanceRaw to do shell script scriptStart & "/activities" & scriptEnd & " -d after=" & (do shell script "date -v-Mon -v 0H -v 0M -v 0S +%s")
		set AppleScript's text item delimiters to "\"distance\":"
		set wDistanceRaw to text items 2 thru -1 of wDistanceRaw
	on error e
		logEvent(e)
		set AppleScript's text item delimiters to ""
		return 0
	end try
	repeat with aDay in wDistanceRaw
		set AppleScript's text item delimiters to ","
		set aDistance to text item 1 of aDay
		set wDistance to (aDistance / 1000) + wDistance
	end repeat
	set AppleScript's text item delimiters to ""
	return round_truncate(wDistance, 2)
end getwDistance

on getyDistance()
	try
		set totalsRaw to do shell script scriptStart & "s/" & myID & "/stats" & scriptEnd
		set AppleScript's text item delimiters to "ytd_ride_totals\":{\"count\""
		set totalsRaw to text item 2 of totalsRaw
		set AppleScript's text item delimiters to ":"
		set totalsRaw to text item 3 of totalsRaw
		set AppleScript's text item delimiters to ","
		set yDistance to (text item 1 of totalsRaw)
		set AppleScript's text item delimiters to ""
		set yDistance to yDistance as meters as kilometers as string
		return round_truncate(yDistance, 2)
	on error e
		logEvent(e)
		return 0
	end try
end getyDistance

on makePercent(thisNumber)
	return round_truncate(thisNumber * 100, 2) & "%" as string
end makePercent

on round_truncate(this_number, decimal_places)
	if decimal_places is 0 then
		set this_number to this_number + 0.5
		return number_to_string(this_number div 1)
	end if
	
	set the rounding_value to "5"
	repeat decimal_places times
		set the rounding_value to "0" & the rounding_value
	end repeat
	set the rounding_value to ("." & the rounding_value) as number
	
	set this_number to this_number + rounding_value
	
	set the mod_value to "1"
	repeat decimal_places - 1 times
		set the mod_value to "0" & the mod_value
	end repeat
	set the mod_value to ("." & the mod_value) as number
	
	set second_part to (this_number mod 1) div the mod_value
	if the length of (the second_part as text) is less than the decimal_places then
		repeat decimal_places - (the length of (the second_part as text)) times
			set second_part to ("0" & second_part) as string
		end repeat
	end if
	
	set first_part to this_number div 1
	set first_part to number_to_string(first_part)
	set this_number to (first_part & "." & second_part)
	
	set theChars to reverse of (characters of (this_number as string))
	set newNum to ""
	set charCount to count of theChars
	repeat with i from 1 to charCount
		set y to item i of theChars
		set newNum to newNum & y
		if i ­ charCount Â
			and i mod 3 = 0 Â
			and y is not "." then Â
			set newNum to newNum & ","
	end repeat
	return reverse of (characters of newNum) as string
end round_truncate

on toMiles(n)
	set n to n as number
	return round_truncate(n as kilometers as miles as number, 2)
end toMiles

on number_to_string(this_number)
	set this_number to this_number as string
	if this_number contains "E+" then
		set x to the offset of "." in this_number
		set y to the offset of "+" in this_number
		set z to the offset of "E" in this_number
		set the decimal_adjust to characters (y - (length of this_number)) thru Â
			-1 of this_number as string as number
		if x is not 0 then
			set the first_part to characters 1 thru (x - 1) of this_number as string
		else
			set the first_part to ""
		end if
		set the second_part to characters (x + 1) thru (z - 1) of this_number as string
		set the converted_number to the first_part
		repeat with i from 1 to the decimal_adjust
			try
				set the converted_number to Â
					the converted_number & character i of the second_part
			on error
				set the converted_number to the converted_number & "0"
			end try
		end repeat
		return the converted_number
	else
		return this_number
	end if
end number_to_string

on logEvent(e)
	tell application "Finder" to set myName to (name of file (path to me))
	do shell script "echo '" & (current date) & space & quoted form of (e as string) & "' >> ~/Library/Logs/" & myName & ".log"
end logEvent