# Make sure version has been passed
if [ $# -eq 0 ]
then
    echo "Please provide a version number for server beta"
    exit 1
fi

# MacOS Release
butler push exports/MacOS.dmg mysterycoder456/top-down-survival:macos-server-beta --userversion $1

# Windows Release
butler push exports/Windows.zip mysterycoder456/top-down-survival:windows-server-beta --userversion $1

# Linux Release
butler push exports/Linux.zip mysterycoder456/top-down-survival:linux-server-beta --userversion $1

