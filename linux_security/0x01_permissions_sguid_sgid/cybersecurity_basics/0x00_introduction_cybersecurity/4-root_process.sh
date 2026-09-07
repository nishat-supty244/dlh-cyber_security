#!/bin/bash
ps aux | grep "^$1 " | grep -vE "\s0\s+0"
