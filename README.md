# Doggo

One iPhone app for a Halo One collar and a PetSafe Guardian GPS 2.0 collar: see both dogs on a map,
send tone/vibrate/static manually, and later add ESP32 Bluetooth beacons that warn the dog near no-go spots.

## Status

- iPhone app skeleton with demo dogs, map, manual commands and static safety limits.
- Fences modeled on the PetSafe app: circular safe zones you draw on a map, a pet card per dog
  ("Backyard • 5 min ago", GPS quality, battery and charging), and a tone or vibrate cue when a dog
  walks out of a fence. Fence cues never use static.
- Halo and Guardian connections are placeholders (neither company has a public API).
- ESP32 beacons: not started.

## Build

Requires Xcode 15+ and [XcodeGen](https://github.com/yonaskolb/XcodeGen):

```sh
brew install xcodegen
xcodegen
open Doggo.xcodeproj
```

## Layout

- `Doggo/Services/CollarProvider.swift`: the interface each collar brand implements.
- `Doggo/Services/SafetyPolicy.swift`: static is off by default, capped, and rate limited.
- `Doggo/Services/MockCollarProvider.swift`: demo dogs used until real collars are connected.
- `Doggo/Models/Fence.swift` and `Doggo/Views/FencesView.swift`: fences and the fence editor.
