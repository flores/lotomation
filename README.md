lotomation
==========

lo automates the crib

![lotomation desktop ui](http://lo.ladevops.org/lotomation.png)

# WAT

Just sharing the wins and fails while I play with automation.  There's a couple
components in this project: a webserver meant to run in the cloud and various
Linux devices (Raspberry Pi, Beagle Bone, old laptops and desktops, etc) running
programs from `bin` depending on the results from the webservice.

Much of this probably won't be useful to you unless (until?) I clean it up,
but to give you an idea of all the stuff it's doing, here's the config file 
under `etc/config.yaml.example`.  In other words, it's JANKY AS FUUUUUUU.

```
goals:
  fitbit:         # goals for punishment
    steps:
    very_active_miles:
punishments:
  21:             # hour pain starts, can have many punishments
    devices:      # array of devices
    state:        # power state, can be on or off
  23:
    devices:
    state:
location:
  doorcouch:      # some zone name you define
    min:          # lower threshold for zone, in rssi
    max:          # upper threshold for zone, in rssi
    devices:      # which devices to act on in zone
  middle:
    min:
    max:
    devices:
camera:
  snapurl:        # curlable url for ipcam
  syncpath:       # where to sync it to on the remote server ("live" feed)
  backup:         # local directory, writes to snapshot.<unixtime>.jpg
webserver:
  host:	          # where the webserver lives, accessed by scripts in bin/
  port:
  user:           # auth
  pass:           
auth:
  ninjablocks: '' # api token for ninja
  fitbit:         # get from api.fitbit.com
    consumer_key:
    consumer_secret:
    token:
    secret:
    user_id:
devices:
  fitbit: ''      # mac addresses of bluetooth le devices
  433MHz: ''      # radio controlled devices
stereo:
  names: [ 'turntable', 'some hostname' ] # friendly stereo input names
status:           # I am lazy and this should be in a DB
  dir:	          # just writes files for now, must be writeable
  verbose:        # set to true for noisy mode
  jamdir:         # where you keep your jams. leave off trailing /
```

We'll go into detail about the various things going on there below...

# Location aware lighting

[**Demo**](https://www.youtube.com/watch?v=c0dtQ4VUico)

I use a [FitBit](http://fitbit.com) as a locator.  It was not designed for
this, but as a LE Bluetooth device I can ping it from various devices 
(Raspberry-Pis, BeagleBones, anything I can connect a Bluetooth LE dongle to) 
and make a guess about where I am in the home.  Those devices run 
`bin/tracker-bt.rb` in a `while true; ...` because I am jank like that.

To use this feature you must first enter the MAC address of your FitBit (or any
Bluetooth device) under "Devices" in the config file...

```
devices:
  fitbit: 'SO:ME:MA:CA:ADD:RE:SS'    # mac addresses of bluetooth le devices
```

Then you must create zones based on the RSSI level of your tracker in different
parts of your home.  The RSSI/signal strength between the min and max values
declare you are in some zone.

```
location:
  doorcouch:    # some zone name you define
    min: -60    # lower threshold for zone, in rssi
    max: -85    # upper threshold for zone, in rssi
    devices: ['couch-light', 'headphone-amp']   # which devices to act on in zone
  middle:
    min:
    max:
    devices:

```

## Music and lights when I come home, doubles as an emergency jam button

Additionally, I also check to see if my location device (aka FitBit) is pingable
at all.  If it is, I get music automagically.  This works great to get tunes
as soon as I walk into my home.  Here is a [**demo**](https://www.youtube.com/watch?v=1hELb-8z134)

The way this works is another one of the microcomputers has a DAC and harddrive
connected.  

It runs `bin/come-home-play-a-jam.sh`, which also lets me trigger
music whenever I want, such as pushing [an emergency jam button]
(https://www.youtube.com/watch?v=mkUJn2-rYj0) or by pushing the "play a jam"
button on the remote:

![play a jam button](http://lo.ladevops.org/lotomation-jam-button.png)

# Wrappers to other people's home automation products

Today I use a [NinjaBlocks](https://github.com/ninjablocks) Kickstarter board 
(v0.1), which is a BeagleBoard with a nice API, and their libs for now.  Each
device gets a name, like "couch-light" or "headphone-amp" or whatever.

Instead of using crappy vendor apps to control lights, I just use a little
Sinatra app with Twitter Bootstrap icons for controls.  This is nice because it
also works well as a mobile remote on my phone.

![remote control](http://lo.ladevops.org/lotomation-mobile.png)

Soon I will be getting a WeMo and add multi-vendor support.  The remote should
also change to some Angular-ish clientside app.

# Stereo input control

I happen to like old vintage hi-fi equipment, and that stuff doesn't have
remote controls.  Now, I could have simply bought a modern preamp or receiver
or something, but instead I use a Raspberry-Pi to manipulate the input selection
of a A/V switcher.  It looks like this and is super ugly:

![Raspeberry-Pi A/V Switcher](https://pbs.twimg.com/media/BeY0lWTCQAARSLk.jpg)

And here is that [**demo**](https://www.youtube.com/watch?v=zUiWG0au5TE)

That Raspberry-Pi runs `bin/switch-stereo-input.rb`, which calls up to the 
webservice to figure out what input it should use.  This allows me to switch 
the input via simple `curl` or web-ui:

![stereo input selection](http://lo.ladevops.org/lotomation-stereo-input.png)

# Punishment when I do not get enough exercise

Sometimes I get lazy and don't exercise enough, but FitBit has a (unreliable)
API, and @whazzmaster's sweet [FitGem](https://github.com/whazzmaster/fitgem) 
makes it really easy to call it.  So, I simply trigger an event every minute
if I have not reached enough steps.

For example, I can make a crazy strobe light when I do not have enough exercise,
like this [**demo**](https://www.youtube.com/watch?v=OdBaccgz1V4)

The config file keeps punishments under it's own section.  This is mine at the
time of this commit:

```
punishments:
  21:
    devices: [ 'stereo' ]
    state: 'off'
  22:
    devices: [ 'ambient-light', 'farside-light', 'nearside-light' ]
    state: 'on'
  23:
    devices: [ 'farside-light', 'nearside-light' ]
    state: 'off'
```

Those punishments inherit from the previous time.  So in other words, this is
what happens IF I do not have enough FitBit steps for the day:
* At 9pm my stereo turns off
* At 10pm all my lights go on.  The stereo remains off.
* At 11pm all my lights except the ambinet light goes off.  The stereo remains off.

I get reminded via the web-ui like this:
![exercise punishments](http://lo.ladevops.org/lotomation-punishments.png)

The really rough bit is that `bin/punisher.rb` runs on a minute cron, so even if
I tried to circumvent any punishments, it would just go back into effect at the
next minute unless I rewired my stuff.  Instead it's simpler to just take a
walk :)


