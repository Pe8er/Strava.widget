-- Strava API documentation: http://strava.github.io/api/

-- Set a few global variables because I'm lazy, please don't touch.
global scriptStart, scriptEnd, myID, unit
property enableLogging : false -- options: true | false

-- I use the below commands to test. Please don't touch.
--my test({"7217285", "545a5f91ea156a7a415f8ea985c277a2808f5caf", "KM", "4000", "12/12/16"})
Ñ my test({"38964", "5533ca8895cf012f007f319c073de983f39f7f13", "KM", "4000", "12/31/16"})

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
			set yDistance to toMiles(yDistance)
			set wDistance to toMiles(wDistance)
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
			commaDelimit(roundThis(wDistance, 1)) & space & unit & "~" & Â
			wProgress & "~" & Â
			wGoal & "~" & Â
			commaDelimit(roundThis(yDistance, 1)) & space & unit & "~" & Â
			yProgress & "~" & Â
			yGoal Â
				as string
		
	on error e
		logEvent(e)
		return "NA"
	end try
end test


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
		set wDistance to (aDistance as meters as kilometers as number) + wDistance
	end repeat
	set AppleScript's text item delimiters to ""
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
		set yDistance to yDistance as meters as kilometers as number
		return yDistance
	on error e
		logEvent(e)
		return 0
	end try
end getyDistance

on roundThis(n, numDecimals)
	set x to 10 ^ numDecimals
	number_to_string((((n * x) + 0.5) div 1) / x) as number
end roundThis

on makePercent(thisNumber)
	set output to roundThis(thisNumber * 100, 1)
	if output is less than 0 then set output to 100
	return output & "%" as string
end makePercent

on commaDelimit(aNumber)
	set aNumber to aNumber as string
	if aNumber contains "E" then set aNumber to number_to_string(aNumber)
	if aNumber contains "." then
		set AppleScript's text item delimiters to "."
		set workingNumber to text item 1 of aNumber
		set suffixNumber to text item 2 of aNumber
		set AppleScript's text item delimiters to ""
	else
		set workingNumber to aNumber
		set suffixNumber to ""
	end if
	
	set the num_length to the length of workingNumber
	set the workingNumber to (the reverse of every character of workingNumber) as string
	set the newNumber to ""
	repeat with i from 1 to the num_length
		if i is the num_length or (i mod 3) is not 0 then
			set the newNumber to (character i of workingNumber & the newNumber) as string
		else
			set the newNumber to ("," & character i of workingNumber & the newNumber) as string
		end if
	end repeat
	if aNumber contains "." then
		set newNumber to newNumber & "." & suffixNumber
	end if
	return newNumber
end commaDelimit

on toMiles(n)
	set n to n as kilometers as miles as number
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
	if enableLogging is true then
		set e to e as string
		tell application "Finder" to set myName to (name of file (path to me))
		do shell script "echo '" & "***LOG START***" & return & (current date) & return & e & return & "***LOG END***" & "' >> ~/Library/Logs/" & quoted form of myName & ".log"
	else
		return
	end if
end logEvent