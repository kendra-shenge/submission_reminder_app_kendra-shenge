#!/usr/bin/bash

# Prompt the user for their name and create a main directory named submission_reminder_{userName}
read -p "Enter your name: " user_name

# Define the main directory using the user's name
main_folder="submission_reminder_${user_name}"
mkdir -p "$main_folder"

# Create necessary subfolders inside the main directory
mkdir -p "$main_folder/app"
mkdir -p "$main_folder/modules"
mkdir -p "$main_folder/assets"
mkdir -p "$main_folder/config"

# Assign paths for easier reference
app_dir="$main_folder/app"
module_dir="$main_folder/modules"
asset_dir="$main_folder/assets"
config_dir="$main_folder/config"

# Generate the environment configuration file with predefined variables
cat > "$config_dir/config.env" << 'EOF'
# Environment settings
ASSIGNMENT="Shell Navigation"
DAYS_REMAINING=2
EOF

# Create the main reminder script inside the app folder
cat > "$app_dir/reminder.sh" << 'EOF'
#!/bin/bash

# Load configuration values and helper functions
source ./config/config.env
source ./modules/functions.sh

# Define path to the student submissions list
submissions_list="$(dirname "$0")/../assets/submissions.txt"

# Display assignment info and run the check function
echo "Assignment: $ASSIGNMENT"
echo "Days remaining to submit: $DAYS_REMAINING days"
echo "--------------------------------------------"

check_submissions $submissions_list
EOF

# Create the functions script used for checking submission statuses
cat > "$module_dir/functions.sh" << 'EOF'
#!/bin/bash

# Function to parse the submissions file and notify for pending submissions
function check_submissions {
    local file_path=$1
    echo "Reviewing submission records in $file_path"

    # Skip header and read each line of the file
    while IFS=, read -r student assignment status; do
        # Clean up leading/trailing spaces
        student=$(echo "$student" | xargs)
        assignment=$(echo "$assignment" | xargs)
        status=$(echo "$status" | xargs)

        # Check if the assignment matches and status is 'not submitted'
        if [[ "$assignment" == "$ASSIGNMENT" && "$status" == "not submitted" ]]; then
            echo "Reminder: $student has not submitted the $ASSIGNMENT assignment!"
        fi
    done < <(tail -n +2 "$file_path") # Omit the header row
}
EOF

# Create the sample submissions data file
cat > "$asset_dir/submissions.txt" << 'EOF'
student, assignment, submission status
Chinemerem, Shell Navigation, not submitted
Chiagoziem, Git, submitted
Divine, Shell Navigation, not submitted
Anissa, Shell Basics, submitted
Mwiti, Git, submitted
Musando, Git, not submitted
Yvonne, Shell Navigation, not submitted
Antoinne, shell Basics, submitted
Stephen, Shell Navigation, not submitted
Michael, Git, not submitted
Richard, Shell Basics, submitted
EOF

# Create a launcher script to run the application
cat > "$main_folder/startup.sh" << 'EOF'
#!/bin/bash

# Get the directory where this script is located
base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define path to the main reminder script
reminder_script="$base_dir/app/reminder.sh"

# Validate that the config file exists before running
if [ ! -f "$base_dir/config/config.env" ]; then
    echo "Error: config.env is missing. Make sure you're inside $base_dir"
    exit 1
fi

# Run the reminder application
bash "$reminder_script"
EOF

# Make all shell scripts executable
chmod +x "$app_dir"/*
chmod +x "$module_dir"/*
cd "$main_folder"
chmod +x startup.sh
cd ..

# Final message to the user
echo "Success! The reminder environment has been set up."
echo "To launch the application, run:"
echo "cd $main_folder && ./startup.sh"

