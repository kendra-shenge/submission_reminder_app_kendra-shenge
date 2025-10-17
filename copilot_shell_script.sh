#!/bin/bash

# Define main directory pattern and important file paths
main_dir="submission_remainder_*/"
startup_script="startup.sh"
env_file="./submission_remainder_*/config/config.env"
continue_checking="y"
chosen_assignment=""  # Will hold the user's input for assignment name

run_analysis() {
    # Accepts the assignment name as an argument
    current_assignment="$1"

    if [ ! -d $main_dir ]; then
        sleep 0.9
        echo "Required directory not found. Please run create_environment.sh first."
        echo " "
        exit 1
    else
        # Update ASSIGNMENT value in the config.env file with user input
        sed -i "s/ASSIGNMENT=\".*\"/ASSIGNMENT=\"$chosen_assignment\"/" $env_file

        echo "Analyzing assignment: '$current_assignment'"

        # Move into the assignment directory and run the startup script
        cd $main_dir
        if [ ! -f $startup_script ]; then
            echo "Error: $startup_script not found."
            exit 1
        else
            ./$startup_script
            cd ..
        fi
    fi
}

# Repeat the analysis process while user chooses to continue
while [[ "$continue_checking" == "y" || "$continue_checking" == "Y" ]]; do
    echo " "
    echo "Which assignment would you like to review?"
    echo "Example options:
Shell Navigation
Shell Basics
Git"

    # Capture user input into chosen_assignment
    read -p "Enter the assignment name: " chosen_assignment

    # Call the function to run analysis
    run_analysis "$chosen_assignment"

    echo " "
    read -p "Do you want to analyze another assignment (y/n): " continue_checking
done

echo -e "Exiting"

