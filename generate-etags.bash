#!/usr/bin/env bash
find . -name *.c -o -name *.h  -o -name *.lisp -o -name *.ros | xargs etags
