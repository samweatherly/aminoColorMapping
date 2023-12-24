# First we open and read, line by line, the map/lookup file.
# We store it in an array, mapFile. We will use this array to determine the similarities of
# the aminos acids:
# * 	- 100% indentical 			- 1.00
# : 	- similar 					- 25.00
# . 	- less similar 				- 37.50
# " "	- (a space) no similarities	- 50.00 (default value)

mapFile = []
databaseFileName = "" # used to store user input of databse/map/lookup file name with extension
while databaseFileName.length < 1
	puts "Enter DATABASE/MAP file name with extension. Ensure the file exists in the local directory."
	databaseFileName = gets.chomp
	if !File.exist?(databaseFileName) || databaseFileName.length < 2
		databaseFileName = ""
		puts "File does not exist in local directory."
	end
end
f = File.open(databaseFileName, "r").each_with_index do |line, index|
	if index > 2
		line.gsub!("\t", "    ") # substitue all occurences of tabs for 4 spaces
		mapFile.push(line)
	end
end
f.close


# editMatchingAmino takes characterSearch and characterSearchIndex to find the corresponding 
# similarity symbol ("*", ":", ",", " "). Also take mapLineIndex to track where the loop was in
# the mapFile array
def editMatchingAmino(characterSearch, characterSearchIndex, mapFile, mapLineIndex)

	# Starts the loop the line after where the match was found with the chainIdentifier.
	# This will check each line for "%%%%%" to ensure it has not gone too far (this should never
	# happen but is just for added safety). It next checks for "|" to ensure it is not on an 
	# empty line. We want to be reading along the middle/second line of each data set. Multiple sets can exist in each
	# section.
	# Running total to compare to characterSearchIndex. This lets us know if we are reading the
	# correct line.
	numberOfElements = 0

	# Starts the line after the comparision was made (comparison made in section title only)
	mapFile[mapLineIndex + 1..-1].each_with_index do |editMapLine, editMapFileIndex|

		if editMapLine.include?("%%%%%")
			break
		elsif editMapLine.include?("|") && editMapLine.include?("_HUMAN")
			holdLineArr = editMapLine.split(" ") # temp var that isolates the meat (minus title)
			
			# numberOfElements is required to compare to characterSearchIndex. If the count of the
			# elements in the first line is less than characterSearchIndex we must go to the next
			# line while ensuring we preserve the value of our count.
			numberOfElements += holdLineArr[1].gsub("-", "").length()


			# ensures row is in range of characterSearchIndex
			if numberOfElements >= characterSearchIndex
				# This will give the index where the data starts; used to tell where to start
				# counting on the third row.
				dataIndexStart = editMapLine.index(holdLineArr[1])

				# This gives us the number of elements on all previous lines. We get this by
				# getting the element count at the end of the line minus all elements on the
				#current line
				dataElementCount = (numberOfElements - holdLineArr[1].gsub("-", "").length())
				mappedIndex = dataIndexStart # will store the total line index of the value we are searching
				holdLineArr[1].split("").each_with_index do |char, arrayIndex|
					if char.match?(/[A-Z]/)
					dataElementCount += 1
						if dataElementCount == characterSearchIndex
							mappedIndex += arrayIndex
							break
						end
					end
				end

				# This loop doesn't start at the first line of the mapFile, therefore we must
				# account for this when using the index from .each_with_index. Add the subarray
				# starting point (mapLineIndex + 1) to the .each_with_index index 
				# (editMapFileIndex) and then add 1 to get the next line ( to access similarity 
				# symbols).

				return mapFile[(mapLineIndex + 1) + (editMapFileIndex + 1)][mappedIndex]

			end # tests for correct line data character count
		end # tests for correct line type
	end # mapFile loop
end # editMatchingAmino function


# These variables will store the most recent search variables. If the current line is the same
# as the previous line, the output will be a copy of the last.
lastCharacterSearch = ""
lastCharacterSearchIndex = ""
lastSimilarityValue = ""

# inputFile - This is the large file. We will start looking for edits at line 17217 (where ATOM
# beings) and will continue through to line 76516 (the last TER).
# Note that the entire file is read and copied to our output file, amino_automation_output.pdb.
inputFileName = "" # used to store user input of input file with extension
while inputFileName.length < 1
	puts "Enter INPUT file name only (no extension). File extension will be set to '.pdb'. Ensure the file exists in the local directory."
	inputFileName = gets.chomp
	if !File.exist?(inputFileName + ".pdb") || inputFileName.length < 1
	inputFileName = ""
	puts "File does not exist in local directory."
end
end

outputFileName = "" # used to store user output
while outputFileName.length < 1
	puts "Enter OUTPUT file name only (no extension). The file will be '.pdb'."
	outputFileName = gets.chomp
end
puts "Processing..."

outputFile = File.open("#{outputFileName}.pdb", "w")
inputFile = File.open("#{inputFileName}.pdb", "r").each_with_index do |inputLine, index|

	if (inputLine[0..3] == "ATOM") # If the line starts with "ATOM" - Tested and works
		# We need to grab the character in the 5th column as well as the number in the 6th column.
		# This should be index 4 and 5 of an array split around spaces.
		characterSearch = inputLine.split(" ")[4]
		# To solve the problem of bad input; columns 5 and 6 sometimes aren't space separated.
		if (characterSearch.length() > 1)
			characterSearchIndex = characterSearch[1..-1]
			characterSearch = characterSearch[0]
		else
			characterSearchIndex = inputLine.split(" ")[5]
		end

		inputLine = inputLine[0..59] + " 50.00" + inputLine[66..-1]

		# Copy similary value (B value) from previous line if the characterSearch and 
		# charaterSearchIndex are identical.
		if characterSearch.length > 0 && characterSearch == lastCharacterSearch && characterSearchIndex == lastCharacterSearchIndex
			inputLineSimilarityIndex = inputLine.rindex("50.00")
			inputLine[inputLineSimilarityIndex..inputLineSimilarityIndex + 4] = lastSimilarityValue
			outputFile.puts(inputLine)
			next
		end


		# Now we search for characterSearch in the mapFile (database/lookup/map).
		# We do this by looping through the mapFile. If a line contains 5 percent symbols (%%%%%)
		# we split("%%%%%")[0] and further split(','). We check for a match. If no match, we move
		# on, but if so, we call our editMatchingAmino() function.
		mapFileIndex = 0
		mapFileLoop = true
		similarityCharacter = ""
		while mapFileIndex < (mapFile.length() - 1) && mapFileLoop
			if mapFile[mapFileIndex].include?("%%%%%")
				chainIdentifier = mapFile[mapFileIndex].split("%%%%%")[0] # this will grab eg. "f,m,X"
				 # split to array eg ['f','m','X']
				chainIdentifierArray = chainIdentifier.gsub(/s+/, "").split(",")
				 # Compares each to chainIdentifier. 
				 # If there is a match, calls editMatchingAmino()
				chainIdentifierArray.each do |letter|
					if letter == characterSearch
						similarityCharacter = editMatchingAmino(characterSearch, characterSearchIndex.to_i, mapFile, mapFileIndex)
						mapFileLoop = false
						break
					end
				end
			end
			mapFileIndex += 1
		end # while

		# To write, we want to modify the 2nd last column. There is no clean way of doing this
		# without altering the spacing between columns on each line. However, we know that every
		# value in this column is "50.00". If we find the last "50.00" in each row we should be
		# fine as the last column is consistently only a single letter, thus has no risk of being
		# "50.00".
		newSimilarityValue = "50.00"
		case similarityCharacter
		when "*" # 100% identical
			newSimilarityValue = "1.00 " # QUESTION FOR KEVIN - SPACING AROUND 1 cause less character than others
		when ":" # similar
			newSimilarityValue = "25.00"
		when "." # less similar
			newSimilarityValue = "37.50"
		when " " # no similarity
			newSimilarityValue = "50.00"
		else
			newSimilarityValue = "50.00"
		end

		# rindex returns the last occurence of a given substring. We want to find the index of
		# last occurrence of "50.00" as this is the value we wish to change to reflect the
		# similarity status. "*", ":", ".", " " will be changed to "1.00", "25.00", "37.50",
		# "50.00" respectively
		inputLineSimilarityIndex = inputLine.rindex("50.00")
		inputLine[inputLineSimilarityIndex..inputLineSimilarityIndex + 4] = newSimilarityValue
		outputFile.puts(inputLine)

		lastCharacterSearch = characterSearch
		lastCharacterSearchIndex = characterSearchIndex
		lastSimilarityValue = newSimilarityValue
	else
		outputFile.puts(inputLine)
	end
end

