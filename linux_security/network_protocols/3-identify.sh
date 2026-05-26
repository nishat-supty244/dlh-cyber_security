
#!/bin/bash
if command -v lynis >/dev/null 2>&1; then
    sudo lynis audit system --quick
else
    echo "Lynis is not installed."
    exit 1
fi
