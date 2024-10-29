#!/bin/bash

iverilog -o ${2%.v} $2 $1
vvp ${2%.v}
