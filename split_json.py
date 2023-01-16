from ast import Continue
import json
from glob import glob

# Set the number of lines per file
lines_per_file = 2000000
files = glob('./data/*.json')

for file in files:
    # Open the input file
    with open(file, 'r') as input_file:
        print(file)
        # Read the input file line by line
        lines = input_file.readlines()
        print(len(lines))
        # Initialize the output file number
        output_file_number = 1
        # Initialize a list to store the lines for the current output file
        current_output_lines = []
        if len(lines) > lines_per_file:
            # Iterate over the lines in the input file
            for i, line in enumerate(lines):
                # Add the current line to the list of lines for the current output file
                current_output_lines.append(line)
                # If the current line is the last one or we have reached the maximum number of lines per file
                if (i+1 == len(lines)) or (i+1) % lines_per_file == 0:
                    # Open the output file
                    fname = f'{file.split(".")[0]}_part{output_file_number}.json'
                    print(fname)
                    with open(fname, 'w') as output_file:
                        # Write the lines for the current output file to the file
                        output_file.write("".join(current_output_lines))
                    # Increase the output file number
                    output_file_number += 1
                    # Reset the list of lines for the current output file
                    current_output_lines = []
