#!/bin/bash
/Applications/love.app/Contents/MacOS/love . 2>&1 &
PID=$!
sleep 2
kill $PID 2>/dev/null
