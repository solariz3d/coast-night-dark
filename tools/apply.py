"""Makes the dark-night config from the author's original, changing bytes only where stated.
   python tools/apply.py ORIGINAL.ini OUT.ini
1. the Stadiumlight glow (ksEmissive ..., 25) is set to 0 at night;
2. the one LIGHT_SERIES (cast from Stadiumlight, range 350) gets ACTIVE = 0.
Tracklight (the dots on the road), Finishlight and Yachtwindow are left exactly as shipped."""
import sys
src, dst = sys.argv[1], sys.argv[2]
b = open(src, 'rb').read()
nl = b'\r\n' if b'\r\n' in b else b'\n'
old_glow = b'VALUE_0 = 1, 0.95, 0.8, 25'
assert b.count(old_glow) == 1, 'stadium glow line not found exactly once'
b = b.replace(old_glow, b'VALUE_0 = 1, 0.95, 0.8, 0')
head = b'[LIGHT_SERIES_...]'
assert b.count(head) == 1, 'expected exactly one LIGHT_SERIES'
i = b.index(head)
assert b'MATERIALS = Stadiumlight' in b[i:i + 120], 'the one LIGHT_SERIES is not the stadium one'
b = b.replace(head, head + nl + b'ACTIVE = 0 ; coast-night-dark: the stadium floods cast no light', 1)
open(dst, 'wb').write(b)
