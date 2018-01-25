
# First we open and read, line by line, the map/lookup file.
# We store it in an array, mapFile. We will use this array to determine the similarities of
# the aminos acids:
# * 	- 100% indentical 			- 1.00
# : 	- similar 					- 25.00
# . 	- less similar 				- 37.50
# " "	- (a space) no similarities	- 50.00 (default value)

mapFile = []
# myTest = File.open("testTabsToSpaces", "w")
f = File.open("Splicing_protein_alignment_database", "r").each_with_index do |line, index|
	if index > 2
		line.gsub!("\t", "    ") # substitue all occurences of tabs for 4 spaces
		# myTest.puts(line) # Test to see if tabs to spaces change worked. Appears to be correct.
		mapFile.push(line)
	end
	# myTest.puts(line)
end
f.close
# myTest.close
# puts mapFile



# editMatchingAmino takes characterSearch and characterSearchIndex to find the corresponding 
# similarity symbol ("*", ":", ",", " "). Also take mapLineIndex to track where the loop was in
# the mapFile array
def editMatchingAmino(characterSearch, characterSearchIndex, mapLineIndex)
	# Starts the loop the line after where the match was found with the chainIdentifier
	# This will check each line for "%%%%%" to ensure it has not gone too far. It next checks
	# for "|" to ensure it is not on an empty line. lineCount check to make sure the line is
	# not the first occurrence of "|", but the second.
	lineCount = 1
	mapFile[mapLineIndex + 1..-1].each do |editMapLine|
		if editMapLine.include?("%%%%%")
			break
		elsif lineCount == 0 && editMapLine.include?("|")
			lineCount = 1
			holdLineArr = editMapline.split(" ") # temp var that isolates the meat (minus title)

		elsif lineCount == 1 && editMapLine.include?("|") # skips first "|" line
			lineCount == 0
		end
	end

end


# inputFile - This is the large file. We will start looking for edits at line 17217 (where ATOM
# beings) and will continue through to line 76516 (the last TER).
# Note that the entire file is read and copied to our output file, amino_automation_output.pdb.

outputFile = File.open("amino_automation_output.pdb", "w")
inputFile = File.open("5o9z.pdb", "r").each_with_index do |inputLine, index|

	# Lines before 17217 (216 because index) are copied without modification. 
	# Tested < 17216 and copies to the line before "ATOM" starts.
	# Tested > 76514 and copies to the "TER" after the last "ATOM"
	if index < 17216 || index > 76514
		outputFile.puts(inputLine)
	elsif (inputLine[0]..[3] == "ATOM") # If the line starts with "ATOM"
		# We need to grab the character in the 5th column as wel as the number in the 6th column.
		# This should be index 4 and 5 of an array split around spaces.
		characterSearch = inputLine.split(" ")[4]
		characterSearchIndex = inputLine.split(" ")[5]

		# Now we search for characterSearch in the mapFile.
		# We do this by looping through the mapFile. If a line contains 5 percent symbols (%%%%%)
		# we split("%%%%%")[0] and further split(','). We check for a match. If no match, we move
		# on, but if so, we call our editMatchingAmino() method.
		mapFile.each_with_index do |mapLine, mapLineIndex|
			if mapLine.include?("%%%%%")
				chainIdentifier = mapLine.split("%%%%%")[0] # this will grab eg. "f,m,X"
				chainIdentifierArray = chainIdentifier.split(",") # split to array eg ['f','m','X']
				 # Compares each to chainIdentifier. 
				 # If there is a match, calls editMatchingAmino()
				chainIdentifierArray.each do |letter|
					if letter == characterSearch
						# puts "#{characterSearch}, #{characterSearchIndex}, #{index}"
						editMatchingAmino(characterSearch, characterSearchIndex, mapLineIndex)
					end
				end
			end
		end


		# To write, we want to modify the 2nd last column. There is no clean way of doing this
		# without altering the spacing between columns on each line. However, we know that every
		# value in this column is "50.00". If we find the last "50.00" in each row we should be
		# fine as the last column is consistently only a single letter, thus has no risk of being
		# "50.00".
	end
	
end

