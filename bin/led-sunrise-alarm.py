#!/usr/bin/python

# makes a LPD8806 LED strip mimic a sunrise as an alarm clock
# uses the https://github.com/adammhaile/RPi-LPD8806 project for led helpers

import sys
sys.path.insert(0, './vendor/led-strip/RPi-LPD8806')
from bootstrap import *

# setup colors to loop through for fade
# colors use cls.cc standards
colors = [
  (255.0,65.0,54.0),  # red
  (255.0,133.0,27.0), # orange
  (255.0,220.0,0.0),  # yellow
  (255.0,254.0,254.0)
]

brightness = 0.2
brightness_per_step = 0.99 / len(colors)

for step in range(len(colors)):

  r, g, b = colors[step]
  brightness_max_this_step = brightness_per_step * ( step + 1 )

  if brightness >= 0.9: # hard brightness limit on led strip
    led.fill(Color(r, g, b, 0.99))
    led.update()
  else:
    while brightness < brightness_max_this_step:
      led.fill(Color(r, g, b, brightness))
      led.update()
      sleep(1)
      brightness += 0.01

  sleep(5)

sleep(1800)
led.all_off()
