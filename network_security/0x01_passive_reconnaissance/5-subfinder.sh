#!/bin/bash
subfinder -d $1 -silent | xargs -I {} sh -c 'echo -n "{},"; dig +short @8.8.8.8 {} | tail -n1' > $1.txt
