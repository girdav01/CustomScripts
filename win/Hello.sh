#/bin/bash
# Hello.sh
echo "Welcome to your first Bash Custom script"
OUTPUT=$(hostname)
echo $OUTPUT
echo "****************"
# Display current running processes
echo "Display processes"
OUTPUT=$(ps)
echo $OUTPUT
echo "script end"