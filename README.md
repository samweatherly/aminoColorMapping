This Ruby script first takes in the database/map file and stores it as an array. It uses this to determine if/when to change data in the modelling file.
The modelling file is read in and written to a new file, amino_automation_output.pdb (or whatever you choose to name it). This all happens one line at a time.\
Run aminoFileReadWriter.rb and enter the database (Splicing_protein_alignment_database), then the input file name (5o9z.pdb) followed by your desired name of the output file.
