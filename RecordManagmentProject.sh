#!/bin/bash
# Check if the record file argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <record_file>"
    exit 1
fi

record_file="$1"
# Check if the record file exists
if [ ! -f "$record_file" ]; then
    echo "Record file '$record_file' not found."
    read -p "Do you want to create a new record file? (y/n): " choice
    case "$choice" in
        [yY])
            touch "$record_file" || { echo "Failed to create record file"; exit 1; }
            echo "New record file '$record_file' created."
            ;;
        *)
            echo "Exiting."
            exit 1
            ;;
    esac
fi

# Function to write to log file
Write_To_LogFile() {
    local event="$1"
    local status="$2"
    local additional_info="$3"
    local datetime=$(date +"%Y/%m/%d %T")
    local log_file="script_log.txt"  # Define the log file path
    echo "$datetime $event $status $additional_info" | tee -a "$log_file"
}


# Function to handle errors
Handle_Error() {
    local event="$1"
    local status="$2"
    local additional_info="$3"
    echo "Error: $additional_info"
    Write_To_LogFile "$event" "$status" "$additional_info"
}

# Function to update record
Update_Record() {
    local record_name="$1"
    local amount="$2"
    local operation="$3"
    
    if grep -q "^$record_name" "$RecordFile"; then
        existing_amount=$(grep "^$record_name" "$RecordFile" | awk -F ',' '{print $2}')
        new_amount=$((existing_amount + amount))
        sed -i "s/^$record_name,.*/$record_name,$new_amount/" "$RecordFile"
        echo "Record $operation successfully"
        Write_To_LogFile "${operation}Record" "Success" "$record_name $amount"
    else
        Handle_Error "${operation}Record" "Failure" "Record not found"
    fi
}

# Function to add a record
Add_Record() {
    local record_name="$1"
    local amount="$2"
    
    if grep -q "^$record_name" "$RecordFile"; then
        Update_Record "$record_name" "$amount" "Add"
    else
        echo "$record_name,$amount" >> "$RecordFile"
        echo "Record added successfully"
        Write_To_LogFile "AddRecord" "Success" "$record_name $amount"
    fi
}

# Function to delete a record
Delete_Record() {
    local record_name="$1"
    local amount="$2"
    
    if grep -q "^$record_name" "$RecordFile"; then
        existing_amount=$(grep "^$record_name" "$RecordFile" | awk -F ',' '{print $2}')
        if [ "$amount" -le "$existing_amount" ]; then
            new_amount=$((existing_amount - amount))
            if [ "$new_amount" -eq 0 ]; then
                sed -i "/^$record_name,/d" "$RecordFile"
            else
                sed -i "s/^$record_name,.*/$record_name,$new_amount/" "$RecordFile"
            fi
            echo "Record deleted successfully"
            Write_To_LogFile "DeleteRecord" "Success" "$record_name $amount"
        else
            Handle_Error "DeleteRecord" "Failure" "Quantity exceeds existing amount"
        fi
    else
        Handle_Error "DeleteRecord" "Failure" "Record not found"
    fi
}

# Function to search for a record
Search_Record() {
    local search_string="$1"
    
    search_result=$(grep -i "$search_string" "$RecordFile")
    if [ -n "$search_result" ]; then
        sorted_result=$(echo "$search_result" | sort)
        echo "Search results:"
        echo "$sorted_result"
        Write_To_LogFile "SearchRecord" "Success" "$search_string"
    else
        Handle_Error "SearchRecord" "Failure" "No records found"
    fi
}

# Function to update the name of a record
Update_Record_Name() {
    local old_name="$1"
    local new_name="$2"
    
    if grep -q "^$old_name" "$RecordFile"; then
        sed -i "s/^$old_name/$new_name/" "$RecordFile"
        echo "Record name updated successfully"
        Write_To_LogFile "UpdateRecordName" "Success" "$old_name -> $new_name"
    else
        Handle_Error "UpdateRecordName" "Failure" "Record not found"
    fi
}

# Function to update the amount of a record
Update_Record_Amount() {
    local record_name="$1"
    local amount="$2"
    
    Update_Record "$record_name" "$amount" "UpdateAmount"
}

# Function to print the total amount of records
Print_Total_Amount() {
    total=0
    while IFS=',' read -r _ amount; do
        ((total += amount))
    done < "$RecordFile"
    if [ "$total" -gt 0 ]; then
        echo "Total Records: $total"
        Write_To_LogFile "PrintTotalRecords" "Success" "$total"
    else
        Handle_Error "PrintTotalRecords" "Failure" "No records found"
    fi
}

# Function to print records in sorted order
Print_Sorted_Record() {
    if [ -s "$RecordFile" ]; then
        sort -t ',' -k1 "$RecordFile" | while IFS=',' read -r name amount; do
            echo "$name $amount"
        done
        Write_To_LogFile "PrintSortedRecords" "Success" 
    else
        Handle_Error "PrintSortedRecords" "Failure" "No records found"
    fi
}

# Main function
main() {
    echo "Inside main function"  # Add this line
    while true; do
        # Display menu
        echo "Menu"
        echo "1. Add a Record"
        echo "2. Delete a Record"
        echo "3. Search for a Record"
        echo "4. Update Record Name"
        echo "5. Update Record Amount"
        echo "6. Print Total Amount of Records"
        echo "7. Print Records in Sorted Order"
        echo "8. Exit"
        read -p "Enter your choice: " choice

        case $choice in
            1)
                read -p "Enter Record Name: " record_name
                read -p "Enter Amount: " amount
                Add_Record "$record_name" "$amount"
                ;;
            2)
                read -p "Enter Record Name: " record_name
                read -p "Enter Amount: " amount
                Delete_Record "$record_name" "$amount"
                ;;
            3)
                read -p "Enter Search String: " search_string
                Search_Record "$search_string"
                ;;
            4)
                read -p "Enter Old Name: " old_name
                read -p "Enter New Name: " new_name
                Update_Record_Name "$old_name" "$new_name"
                ;;
            5)
                read -p "Enter Record Name: " record_name
                read -p "Enter Amount: " amount
                Update_Record_Amount "$record_name" "$amount"
                ;;
            6)
                Print_Total_Amount
                ;;
            7)
                Print_Sorted_Record
                ;;
            8)
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter a number between 1 and 8."
                ;;
        esac
    done
}
main


