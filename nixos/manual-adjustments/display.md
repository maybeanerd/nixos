# Ensure display can use 175hz refresh rate

Get the current values:

```bash
xrandr
```

Generate a new mode with 175hz refresh rate:

```bash
gtf 3440 1440 175
```
```bash
gtf 3840 2160 120
```
Copy the Modeline output from the previous command and create a new mode:

```bash
xrandr --newmode "3440x1440_175.00"  1347.89  3440 3752 4136 4832  1440 1441 1444 1594  -HSync +Vsync
```
```bash
xrandr --newmode "3840x2160_120.00"  1501.69  3840 4192 4624 5408  2160 2161 2164 2314  -HSync +Vsync
```

Add the new mode to your display (replace `DP-1` with your actual display identifier from the `xrandr` output):

```bash
xrandr --addmode DP-1 3440x1440_175.00
```
```bash
xrandr --addmode HDMI-A-1 3840x2160_120.00
```
Set the new mode as the active mode for your display:

```bash
xrandr --output DP-1 --mode 3440x1440_175.00
```
```bash
xrandr --output HDMI-A-1 --mode 3840x2160_120.00
```
