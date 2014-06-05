#!/usr/bin/env python

import sys
import time
import requests
import subprocess
import re

# get PyGlow from https://github.com/benleb/PyGlow
sys.path.append('vendor/PyGlow')

from pyglow import PyGlow

pyglow = PyGlow()
pyglow.all(0)

def throbcolorout(maxcolor, intensity, delay):
  i = 1
  while i <= maxcolor:
    pyglow.color(i, intensity)
    time.sleep(delay)
    i += 1
  time.sleep(delay)

def throbcolorin(maxcolor, intensity, delay):
  i = maxcolor
  while i >= 1:
    pyglow.color(i, intensity)
    time.sleep(delay)
    i -= 1
  time.sleep(delay)

def throboffout(maxcolor, intensity, delay):
  i = 1
  while i <= maxcolor:
    pyglow.color(i, 0)
    time.sleep(delay)
    i += 1
  time.sleep(delay)

def throboffin(maxcolor, intensity, delay):
  i = maxcolor
  while i > 0:
    pyglow.color(i, 0)
    time.sleep(delay)
    i -= 1
  time.sleep(delay)

def outandin(maxcolor, intensity, delay):
  throbcolorout(maxcolor, intensity, delay)
  throboffin(maxcolor, intensity, delay)
  
def outandout(maxcolor, intensity, delay):
  throbcolorout(maxcolor, intensity, delay)
  throboffout(maxcolor, intensity, delay)

def inandout(maxcolor, intensity, delay):
  throbcolorin(maxcolor, intensity, delay)
  throboffout(maxcolor, intensity, delay)

def inandin(maxcolor, intensity, delay):
  throbcolorin(maxcolor, intensity, delay)
  throboffin(maxcolor, intensity, delay)

city = sys.argv[1]
state = sys.argv[2]

city1 = sys.argv[3]
state1 = sys.argv[4]

with open('etc/wunderground.key', 'r') as f:
  wundergroundkey = f.read().rstrip()

try:
  while True:  
    response = requests.get('http://api.wunderground.com/api/%s/conditions/q/%s/%s.json' % (wundergroundkey, state, city))
  
    weather = response.json()
    temp = weather['current_observation']['temp_f']
    wind = float(weather['current_observation']['wind_gust_mph'])
    
    # standardize to piglow
    if wind == 0: wind = 1
    temp_to_brightness = int(temp / 100 * 254)
    if temp_to_brightness > 254: temp_to_brightness = 254
    temp_to_color = int(round(temp / 100 * 6))
    if temp_to_color > 6: temp_to_color = 6
    wind_to_wait = 3 / wind
    wind_to_speed = int(wind * 40)
  
    print(city)  
    print('temp %f' % temp)
    print('wind %f' % wind)
    print('led brightness %f' % temp_to_brightness)
    print('temp to color %f' % temp_to_color)
    print(wind_to_speed)
    
    response = requests.get('http://api.wunderground.com/api/%s/conditions/q/%s/%s.json' % (wundergroundkey, state1, city1))
  
    weather = response.json()
    temp = weather['current_observation']['temp_f']
    wind = float(weather['current_observation']['wind_gust_mph'])
    
    # standardize to piglow
    if wind == 0: wind = 1
    temp_to_brightness1 = int(temp / 100 * 254)
    if temp_to_brightness1 > 254: temp_to_brightness1 = 254
    temp_to_color1 = int(round(temp / 100 * 6))
    if temp_to_color1 > 6: temp_to_color1 = 6
    wind_to_wait1 = 3 / wind
    wind_to_speed = int(wind * 40)
    
    print(city1)
    print('temp %f' % temp)
    print('wind %f' % wind)
    
    for x in range(100):
      for i in range(1):
        outandin(temp_to_color, temp_to_brightness, wind_to_wait)
        outandout(temp_to_color, temp_to_brightness, wind_to_wait)
    
      for i in range(1):
        inandout(temp_to_color1, temp_to_brightness1, wind_to_wait1)
        inandin(temp_to_color1, temp_to_brightness1, wind_to_wait1)
      print('loop %s' % x)

    # traffic
    for i in range(3):
      pyglow.pulse_arm((i+1),75,200)
    
    print('loop complete, calling for more data')

except KeyboardInterrupt:
  # turn off all leds
  pyglow.all(0)
      
