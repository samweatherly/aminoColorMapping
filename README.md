Conditions:
  - No trailing spaces after the number count in the database/map document.
  - Only one space inbetween the data and the trailing number count.
  - The title for A WHOLE SECTION (not a line) of data must be preceded by comma separated Chain Identifiers.

To do:
  - Correct issue with grabbing characterSearch and characterSearchIndex when the index is greater than a 3 digit number.
  - Change hard coded start on 17217 to start where line[0..3] == "ATOM" (also for values after - 76514+)
  - Change starting values to all be 50.00 (different in other files)


This Ruby script first takes in the database/map file and stores it as an array. It uses this to determine if/when to change data in the modelling file.
The modelling file is read in and written to a new file, amino_automation_output.pdb. This all happens one line at a time.