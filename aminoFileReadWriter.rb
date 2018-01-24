
# First we open and read, line by line, the map/lookup file.
# We store it in an array, mapFile. We will use this array to determine the similarities of
# the aminos acids:
# * 	- 100% indentical 			- 1.00
# : 	- similar 					- 25.00
# . 	- less similar 				- 40.00
# " "	- (a space) no similarities	- 50.00 (default value)

mapFile = []
# myTest = File.open("amino_automation_output.pdb", "w")
f = File.open("Splicing_protein_alignment_database", "r").each_with_index do |line, index|
	if index > 2
		mapFile.push(line)
	end
	# myTest.puts(line)
end
f.close
# puts mapFile


# inputFile - This is the large file. We will start looking for edits at line 17217 (where ATOM
# beings) and will continue through to line 76516 (the last TER).
# Note that the entire file is read and copied to our output file, amino_automation_output.pdb.

outputFile = File.open("amino_automation_output.pdb", "w")
inputFile = File.open("5o9z.pdb", "r").each_with_index do |line, index|

	# Lines before 17217 (216 because index) are copied without modification. 
	# Tested < 17216 and copies to the line before "ATOM" starts.
	# Tested > 76514 and copies to the "TER" after the last "ATOM"
	if index < 17216 || index > 76514
		outputFile.puts(line)
	elsif outputFile.puts(line[0]..[3] == "ATOM") # If the line starts with "ATOM"
		# We need to grab the character in the 5th column as wel as the number in the 6th column.
		# This should be index 4 and 5 of an array split around spaces.
		characterSearch = line.split(" ")[4]
		characterSearchIndex = line.split(" ")[5]

		# Now we search for characterSearch in the mapFile.
		# We do this by looping through the mapFile. If a line contains 5 percent symbols (%%%%%)
		# we split("%%%%%")[0] and further split(','). We check for a match. If no match, we move
		# on, but if so, we 


		# To write we want to modify the 2nd last column. There is no clean way of doing this
		# without altering the spacing between columns on each line. However, we know that every
		# value in this column is "50.00". If we find the last "50.00" in each row we should be
		# fine as the last column is consistently only a single letter, thus has no risk of being
		# "50.00".
	end
	
end

