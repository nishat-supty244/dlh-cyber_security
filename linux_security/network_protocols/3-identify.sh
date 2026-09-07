#!/bin/bash
command -v lynis >/dev/null 2>&1 && sudo lynis audit system --quick
