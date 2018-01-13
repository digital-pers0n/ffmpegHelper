tell application "iTerm"
    activate
        tell front window
            tell current session
                write text "\"%script%\""
            end tell
        end tell
end tell