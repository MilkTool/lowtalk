#!/bin/bash

wget -O- get.pharo.org/70+vm | bash

exec ./pharo-ui Pharo.image st scripts/loadImage.st

