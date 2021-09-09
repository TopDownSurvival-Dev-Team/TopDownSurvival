# Make sure version has been passed
if [ $# -eq 0 ]
then
    echo "Please provide a version number for client beta"
    exit 1
fi

# MacOS Release
butler push exports/MacOS.zip mysterycoder456/top-down-survival:macos-beta --userversion $1

# Windows Release
butler push exports/Windows.zip mysterycoder456/top-down-survival:windows-beta --userversion $1

# Linux Release
butler push exports/Linux.zip mysterycoder456/top-down-survival:linux-beta --userversion $1

