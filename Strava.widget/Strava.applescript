-- Strava API documentation: http://strava.github.io/api/

-- Set a few global variables because I'm lazy, please don't touch.
global scriptStart, scriptEnd, myID, unit
property enableLogging : false -- options: true | false

-- I use the below commands to test. Please don't touch.
-- my test({"7217285", "545a5f91ea156a7a415f8ea985c277a2808f5caf", "KM", "4000", "12/12/16"})
--my test({"38964", "5533ca8895cf012f007f319c073de983f39f7f13", "KM", "4000", "12/31/16"})

on run (arguments)
	-- grab arguments from input
	set myID to item 1 of arguments
	set token to item 2 of arguments
	set unit to item 3 of arguments
	set yDistGoal to item 4 of arguments
	try
		set deadline to item 5 of arguments
	on error
		set {year:y} to (current date)
		set deadline to date ("12/31/" & y) as string
	end try
	
	set scriptStart to "curl -G https://www.strava.com/api/v3/athlete"
	set scriptEnd to " -H 'Authorization: Bearer " & token & "'"
	set wNumber to (do shell script "date '+%V'") as number
	set dNumber to (do shell script "date '+%u'") as number
	
	
	-------------------------------------------------------
	---------------MAIN CALCULATIONS----------------
	-------------------------------------------------------
	
	try
		-- Distance ridden this week, from Strava
		set wDistance to getwDistance()
		
		-- Distance ridden this year, from Strava
		set yDistance to getyDistance()
		
		-- How many weeks are remaining until the deadline?
		set wRemaining to ((date deadline) - (current date)) div days / 7
		
		-- Distance I need to ride weekly to meet my yearly goal
		set wDistGoal to (yDistGoal - yDistance) / wRemaining
		
		-- Percentage of weekly progress I have completed
		set wProgress to makePercent(wDistance / wDistGoal)
		
		-- Percentage of weekly progress I should have completed
		set wGoal to makePercent((dNumber * wDistGoal / 7) / wDistGoal)
		
		-- Percentage of yearly progress I have completed
		set yProgress to makePercent(yDistance / yDistGoal)
		
		-- Percentage of yearly progress I should have completed
		set yGoal to makePercent((wNumber * (yDistGoal / 52)) / yDistGoal)
		
		if unit is "M" then
			set wDistance to toMiles(wDistance)
			set yDistance to toMiles(yDistance)
		end if
		
		logEvent("My yearly goal (yDistGoal): " & yDistGoal & space & unit & return & Â
			"Distance I rode this year so far (yDistance): " & yDistance & space & unit & return & Â
			"Distance I rode this week so far (wDistance): " & wDistance & space & unit & return & Â
			"Percentage of weekly progress I have completed (wProgress): " & wProgress & return & Â
			"Percentage of weekly progress I should have completed (wGoal): " & wGoal & return & Â
			"Percentage of yearly progress I have completed (yProgress): " & yProgress & return & Â
			"Percentage of yearly progress I should have completed (yGoal): " & yGoal Â
			as string)
		
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
---------------SUBROUTINES GALORE---------------
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
		set wDistance to (formatNumber(aDistance) / 1000) + wDistance
	end repeat
	set AppleScript's text item delimiters to ""
	if wDistance contains "." then
		set wDistance to round_truncate(wDistance, 1)
	end if
	return wDistance
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
		set yDistance to yDistance as meters as kilometers as integer
		if yDistance contains "." then
			set yDistance to round_truncate(yDistance, 1)
		end if
		return comma_delimit(yDistance)
	on error e
		logEvent(e)
		return 0
	end try
end getyDistance

on makePercent(thisNumber)
	set output to round_truncate(thisNumber * 100, 0)
	if output is less than 0 then set output to 100
	return output & "%" as string
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
	repeat decimal_places times
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

on comma_delimit(this_number)
	set this_number to this_number as string
	if this_number contains "E" then set this_number to number_to_text(this_number)
	set the num_length to the length of this_number
	set the this_number to (the reverse of every character of this_number) as string
	set the new_num to ""
	repeat with i from 1 to the num_length
		if i is the num_length or (i mod 3) is not 0 then
			set the new_num to (character i of this_number & the new_num) as string
		else
			set the new_num to ("," & character i of this_number & the new_num) as string
		end if
	end repeat
	return the new_num
end comma_delimit

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

on formatNumber(n)
	if n contains "." then
		set AppleScript's text item delimiters to "."
		set y to text item 1 of n
		set AppleScript's text item delimiters to ""
		return y as number
	end if
end formatNumber

on logEvent(e)
	if enableLogging is true then
		set e to e as string
		tell application "Finder" to set myName to (name of file (path to me))
		do shell script "echo '" & "***LOG START***" & return & (current date) & return & e & return & "***LOG END***" & "' >> ~/Library/Logs/" & quoted form of myName & ".log"
	else
		return
	end if
end logEvent