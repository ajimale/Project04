Created by Abdikarim Jimale:

This program reads data from a CSV file. It works by calling the function (read-all-csv-files filenames), which itself uses (read-csv-file filename). To run the program, use the command racket functional_data_processing.rkt los_angeles_data.csv. You don’t need to specify the full file path; the function already includes the path, so you only need to provide the CSV file name (e.g., file_name.csv).

The program reads each line of the file and saves it in a list. I've encountered issues with data correlation; I wasn't sure how to test it correctly, and I also faced some code issues. I’ve commented out parts of the code related to data correlation, so test runs work fine.

I created some test functions within the main function.

Problems:

1- I had difficulty finding the correct mathematical equations for some functions.

2- I used my own testing methods, but they worked inconsistently. Some functions passed the test, while others did not.

3- I did some change base of the feedback I get it from students: 
from path way which I can take it from the argument input. 
Normalize-data and anaylze-time.