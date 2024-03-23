Record Management System
Overview

This bash script provides functionalities to manage records in a file. It allows users to add, delete, search, update, and print records.
Usage

To use the script, follow these steps:

    Ensure you have Bash installed on your system.
    Save the script to a file, e.g., record_management.sh.
    Make the script executable: chmod +x record_management.sh.
    Run the script with the record file name as an argument: ./record_management.sh <record_file>.

Example

bash
./record_management.sh record.txt

Features

    Add a Record: Add a new record to the file.
    Delete a Record: Remove a record from the file.
    Search for a Record: Find records containing a specific string.
    Update Record Name: Modify the name of an existing record.
    Update Record Amount: Update the amount of an existing record.
    Print Total Amount of Records: Display the total amount of all records.
    Print Records in Sorted Order: Print all records sorted alphabetically.

Function Definitions

    Write_To_LogFile: Function to write events to a log file.
    Handle_Error: Function to handle errors and log them.
    Update_Record: Function to update the amount of a record.
    Add_Record: Function to add a new record.
    Delete_Record: Function to delete a record.
    Search_Record: Function to search for records containing a specific string.
    Update_Record_Name: Function to update the name of a record.
    Update_Record_Amount: Function to update the amount of a record.
    Print_Total_Amount: Function to print the total amount of records.
    Print_Sorted_Record: Function to print records in sorted order.
    Main: The main function to execute the script.

Notes

    Ensure the record file is provided as an argument when running the script.
    If the record file doesn't exist, the script prompts whether to create a new one.

Contributors

    Areej Amash
