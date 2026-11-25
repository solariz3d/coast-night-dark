# Coast: Night Dark

A night-lighting change for **Coast** by **Dogeish** (v0.2), the T-180 circuit. At night the big
stadium floodlights are off, so the circuit is dark and lit by the lamps set into the road.

**No model is changed.** It is two lines of CSP config. The whole change is in
[`diff/ext_config.diff`](diff/ext_config.diff).

## What is on and what is off at night

The lighting config of Coast is small. It names four glowing materials and one set of cast lights:

| what | in the config | Night Dark |
|---|---|:-:|
| Stadium floodlights, the light they cast | `LIGHT_SERIES` on `Stadiumlight`, range 350 m | **off** |
| Stadium floodlights, the glow of the heads | `ksEmissive` on `Stadiumlight`, strength 25 | **off** |
| Lamps set into the road (the dots) | `ksEmissive` on `Tracklight`, strength 10 | on, unchanged |
| Finish-line lights | `ksEmissive` on `Finishlight`, strength 10 | on, unchanged |
| Yacht windows | `ksEmissive` on `Yachtwindow`, strength 1 | on, unchanged |

The same two lines are changed in the configs of the **Gold** and **Fuji** skins, which each carry
their own copy of the stadium lights. The **BigCoast** skin adds short lights on the road lamps and the finish line; those stay.

## Install

Double-click `INSTALL.bat`. It finds Coast in your Steam libraries, checks the three files are the
ones this was made for, keeps a backup of each beside it, and copies the dark ones in.
`UNINSTALL.bat` puts the originals back.

Daytime is unaffected: these lights only come on at night.

## Rebuilding it

`tools/apply.py ORIGINAL.ini OUT.ini` makes the dark file from the original and refuses if
the original is not the shape it expects. The originals are not kept in this repository.
