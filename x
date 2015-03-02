= Apple Magic Mouse Speed =

I find the default speed too fast, especially when compared to the default speed of the Magic Trackpad under X.

I want to set it's speed separately from other mice / pointer input devices.
xinput seems to be the method.

So I list the devices:

```
$ xinput list  
⎡ Virtual core pointer                    	id=2	[master pointer  (3)]
⎜   ↳ Virtual core XTEST pointer              	id=4	[slave  pointer  (2)]
⎜   ↳ bcm5974                                 	id=12	[slave  pointer  (2)]
⎜   ↳ chrismcclimans’s Trackpad             	id=11	[slave  pointer  (2)]
⎜   ↳ ajp's mouse                             	id=14	[slave  pointer  (2)]
⎣ Virtual core keyboard                   	id=3	[master keyboard (2)]
    ↳ Virtual core XTEST keyboard             	id=5	[slave  keyboard (3)]
    ↳ Power Button                            	id=6	[slave  keyboard (3)]
    ↳ Video Bus                               	id=7	[slave  keyboard (3)]
    ↳ Power Button                            	id=8	[slave  keyboard (3)]
    ↳ Sleep Button                            	id=9	[slave  keyboard (3)]
    ↳ Apple Inc. Apple Internal Keyboard / Trackpad	id=10	[slave  keyboard (3)]
    ↳ iikeyboard                              	id=13	[slave  keyboard (3)]
```

I grab the acceleration for a device I like (my Magic Mouse trackpad)

```
$ xinput list-props 11 | grep Accel
	Device Accel Profile (272):	0
	Device Accel Constant Deceleration (273):	2.500000
	Device Accel Adaptive Deceleration (274):	1.000000
	Device Accel Velocity Scaling (275):	12.500000
```

Then I set those for my Magic Mouse (non-trackpad)

```
xinput --set-prop 14 'Device Accel Constant Deceleration' 2.5
xinput --set-prop 14 'Device Accel Velocity Scaling' 12.5
```

Things feel a lot better at this point... now to get them to persist.
This might be a good link for more info: http://blog.tkassembled.com/308/a-better-magic-trackpad-experience-in-linux/
