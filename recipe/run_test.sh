#!/bin/bash
# Run a modern mode test

gmt begin -Vd
gmt figure modern_figure pdf
gmt pscoast -Vd -R0/5/0/5 -JM5i -P -W0.25p
gmt end
