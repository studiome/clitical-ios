# CLiTICAL for iOS

*日本語版: [README.ja.md](README.ja.md)*

An iOS app that predicts post-operative risks of revascularisation for chronic
limb-threatening ischaemia (CLTI) from patient data.

It implements the prediction models by Miyata et al., built on the JCLIMB registry of the
Japanese Society for Vascular Surgery (JSVS), and is a native SwiftUI rewrite of the
Flutter/Android version of CLiTICAL.

> **Disclaimer**
> This app is intended to support the clinical judgement of healthcare professionals. The
> values it calculates are estimates from statistical models and do not determine diagnosis
> or treatment. The final decision remains the responsibility of the attending physician.

## Features

- **Patient data entry** — six sections: basic information, social history, clinical
  information, arterial lesion sites, other vascular lesions, and comorbidities
- **Risk prediction** — five indices calculated from the entered data
- **References** — the source papers opened in an `SFSafariViewController`
- **Settings** — Japanese/English switching applied instantly in-app, terms of service,
  and app information
- **Accessibility** — VoiceOver support, Dynamic Type, and risk levels never conveyed by
  colour alone

## Predicted indices

| Index | Description |
| --- | --- |
| 30-day death or major amputation | Risk of death and/or major amputation within 30 days |
| 30-day MALE | Major adverse limb events within 30 days |
| 2-year OS | Two-year overall survival, with a low/medium/high risk classification |
| 2-year AFS | Two-year amputation-free survival |
| GNRI | Geriatric Nutritional Risk Index, with a four-level classification |

GNRI is calculated as `14.89 × Alb + 41.7 × min(weight / (22 × height²), 1.0)` and
classified as no risk (≥98), low (92–98), moderate (82–92), or major (<82).
The 30-day risks use logistic regression; 2-year OS/AFS use Cox proportional hazards models
(baseline survival 0.922 for OS and 0.876 for AFS).

At least one arterial lesion site must be selected — AI (aortoiliac), FP (femoropopliteal),
or BK (below the knee) — and the most proximal selected site determines the lesion
classification.

## Requirements

- iOS 15.0 or later (iPhone only)
- Xcode 15 or later / Swift 5.9
- No third-party dependencies (the only networking is opening reference and terms links)

## Project layout

```
clitical-ios/
├── clitical/                     # App target (SwiftUI)
│   ├── CliticalApp.swift         # Entry point
│   ├── MainTabView.swift         # Tabs, references, settings and about
│   ├── ContentView.swift         # Patient data form
│   ├── PredictedRiskView.swift   # Results screen
│   ├── ChoiceListView.swift      # ToggleRow / SegmentedRow / MenuChoiceRow
│   ├── AgeFormView.swift, …      # Numeric fields (age, height, weight, Alb)
│   ├── Labels.swift              # Domain enums → localization keys
│   ├── LocalizationManager.swift # In-app language switching
│   ├── QuestionError.swift       # Input error definitions
│   └── CLPatientData/            # Local Swift package (domain logic)
│       ├── Sources/CLPatientData/
│       │   ├── PatientData.swift # Patient data model (value type)
│       │   ├── PatientRisk.swift # Risk calculation and classification
│       │   └── Questions.swift   # Predictors and regression coefficients
│       └── Tests/CLPatientDataTests/
├── cliticalUITests/              # XCUITest
├── ja.lproj / en.lproj           # Localizable.strings
└── clitical-ios.xcodeproj
```

## Architecture

- **Domain logic kept separate** — risk calculation lives in `CLPatientData`, a local Swift
  package independent of the UI, so it is testable without SwiftUI. The regression
  coefficients are collected in `Questions.swift` as one `enum` case per predictor.
- **Patient data as a value type** — `PatientData` is a `struct` passed to the forms through
  `@State` / `@Binding`, and is never persisted.
- **In-app language switching** — `LocalizationManager` swaps the class of `Bundle.main` so
  that the selected `.lproj` wins, letting `Text("key")` re-resolve without a restart. Only
  navigation titles, which UIKit caches, are resolved explicitly via
  `localization.string(forKey:)`.
- **HIG-conformant UI** — settings-like items are grouped in a single Settings tab rather
  than holding tabs of their own, and choices use inline `Picker` / `Toggle` controls
  instead of pushed screens.

## Build and run

Open `clitical-ios.xcodeproj` in Xcode and run the `clitical-ios` scheme.

From the command line:

```bash
xcodebuild -project clitical-ios.xcodeproj -scheme clitical-ios -destination 'platform=iOS Simulator,name=iPhone 16' build
```

## Tests

Development follows red/green TDD. The domain unit tests are written with
[Swift Testing](https://developer.apple.com/documentation/testing).

Package tests only:

```bash
swift test --package-path clitical/CLPatientData
```

All tests including the UI tests:

```bash
xcodebuild -project clitical-ios.xcodeproj -scheme clitical-ios -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Localization

Japanese (default) and English are supported. Strings live in
`ja.lproj/Localizable.strings` and `en.lproj/Localizable.strings`, and the key sets are kept
identical between the two. The selected language is stored in `UserDefaults` under
`app_language`; on first launch the app follows the device language.

## Versioning

`MARKETING_VERSION` (display version) and `CURRENT_PROJECT_VERSION` (build number) are
managed in the Xcode project's build settings. The display version is shown under
Settings > About.

## References

1. Miyata T. et al, *Risk prediction model for early outcomes of revascularization for
   chronic limb-threatening ischaemia.* Br J Surg. 2022 Oct 14;109(11):1123.
   <https://doi.org/10.1093/bjs/znab036>
2. Miyata T. et al, *Prediction Models for Two Year Overall Survival and Amputation Free
   Survival After Revascularisation for Chronic Limb Threatening Ischaemia.*
   Eur J Vasc Endovasc Surg. 2022 Jun 7;S1078-5884(22)00340-9.
   <https://doi.org/10.1016/j.ejvs.2022.05.038>

## Privacy

Patient data is processed on this device only and is never sent or stored elsewhere. The
only thing the app saves is the selected language.

## License

Released under the [MIT License](LICENSE).

The regression coefficients and classification thresholds come from the papers listed under
References; the MIT License applies to the software implementation only.

## Credits

- Published by: Japanese Society for Vascular Surgery / JCLIMB Committee (2022)
- Developed by: Kazuhiro Miyahara
- Terms of service: <https://studiome.github.io/clti_risk/>
