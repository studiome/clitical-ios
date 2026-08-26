# App icon — vector source

`AppIcon-{Light,Dark,Tinted}.svg` are the masters for
`clitical/Assets.xcassets/AppIcon.appiconset/`. Edit the SVG, never the PNG.

Design constants (1024 x 1024 canvas):

| | value | note |
|---|---|---|
| background | `#2D6A7B` | same as `AccentColor.colorset` (light) |
| limb | `#FFFFFF` (dark: `#DCE6E9`) | 6.07:1 against the background |
| artery | `#0E8F8A` , stroke 42 / 32 | 3.95:1 against the limb |
| lesion marker | `#B32620` , r 40 | `riskHigh` in `PredictedRiskView.swift`; 6.53:1 |

The limb bleeds off the top edge so it reads as a leg rather than a sock.
`AppIcon-AltA-Light.svg` keeps the original closed top instead.

Re-export at 1024 x 1024:

    qlmanage -t -s 1024 -o . AppIcon-Light.svg

The light PNG must be flattened to RGB (no alpha); dark and tinted keep
transparency so the system supplies the background.
