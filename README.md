# Coast: Night Dark

A second track beside **Coast** by **Dogeish** (v0.2), the T-180 circuit: **Coast Night**. It is the
same circuit with the big stadium floodlights off at night, so it is dark and lit by the lamps set
into the road. The original Coast stays exactly as its author shipped it, and both show in the track
list.

**No model is changed or copied.** The change is two lines of CSP config, shown whole in
[`diff/ext_config.diff`](diff/ext_config.diff).

## What is on and what is off at night on Coast Night

The lighting config of Coast is small. It names four glowing materials and one set of cast lights:

| what | in the config | Coast Night |
|---|---|:-:|
| Stadium floodlights, the light they cast | `LIGHT_SERIES` on `Stadiumlight`, range 350 m | **off** |
| Stadium floodlights, the glow of the heads | `ksEmissive` on `Stadiumlight`, strength 25 | **off** |
| Lamps set into the road (the dots) | `ksEmissive` on `Tracklight`, strength 10 | on, unchanged |
| Finish-line lights | `ksEmissive` on `Finishlight`, strength 10 | on, unchanged |
| Yacht windows | `ksEmissive` on `Yachtwindow`, strength 1 | on, unchanged |

The same two lines are changed in the configs of the **Gold** and **Fuji** skins, which each carry
their own copy of the stadium lights. The **BigCoast** skin adds short lights on the road lamps and
the finish line; those stay.

## Why a second track and not a second layout

CSP gives every layout of a track the same lights config (checked for the Thunderhead night preset:
a config inside a layout folder is ignored). Coast also ships as a single-layout track, and turning
it into a two-layout one would move its own files around. So Coast Night is a folder of its own,
`coast_night`, beside `coast`.

It costs almost no disk: every file in it is a hard link to the same file in Coast, except the three
lighting configs and the small name files. If hard links are not possible on your drive the
installer copies instead (about 180 MB).

## Install

You need Coast v0.2 installed. Double-click `INSTALL.bat`. It finds Coast in your Steam libraries,
checks its three lighting files are the ones this was made for, and builds `coast_night` beside it.
In Content Manager press F5, pick **Coast Night** and set the time to night.

`UNINSTALL.bat` removes `coast_night`. Coast itself is never changed.

Coast Night is a different track to the game, so lap times and online sessions on it are separate
from Coast.

## Rebuilding it

`tools/apply.py ORIGINAL.ini OUT.ini` makes the dark file from the original and refuses if
the original is not the shape it expects. The originals are not kept in this repository.
