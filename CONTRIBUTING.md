# Contribute

## Branch

This repository has 2 main branches:

- `main`: the currently version on App Store
- `dev`: the upcoming version, which your pull request should be made against

## Code Style and Conventions

This repository uses [SwiftLint](https://github.com/realm/SwiftLint) and [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) to enforce code style and conventions.

Before committing:
- run `make lint` and `make format` in the terminal to automatically correct and format the code.
- make sure the codes you added are free of warning.

## File Struct

This project adopts a file structure with "feature" as its core. When you need to modify or add a feature, please work in the [Features](Features) folder. 

If you have a common feature, such as a common struct, extension, etc., please add it in the [Common Tools](Common Tools) folder according to its category. 

Regarding the API of miHoYo, we have placed it in the [HBMihoyoAPI](Packages/HBMihoyoAPI)" package under the [Packages](Packages) folder.

## Develop

### UserDefaults

We use [SwiftyUserDefaults](https://github.com/sunshinejr/SwiftyUserDefaults) instead of directly use `UserDefaults`. 

If you want to store something into `UserDefaults`: 

1. Add your key in `extension DefaultsKeys` of [Common Tools/UserDefaultKeys.swift](./Common Tools/UserDefaultKeys.swift). 

   Example: 

   ```swift
   extension DefaultsKeys {
       var example: DefaultsKey<String> { 
         .init("example", defaultValue: "Hello World!") 
       }
   }
   ```

2. Get and set the value by `Defaults[\.yourKey]`. 

   Example: 

   ```swift
   // Set value
   Defaults[\.example] = "Hello HSRPizza"
   // Get value
   Defaults[\.example]
   ```

### SF Symbol

We use [SFSafeSymbols](https://github.com/SFSafeSymbols/SFSafeSymbols) instead of directly access `systemImage`. 

If you want to use SF Symbol, just replace all `systemImage` with `systemSymbol` and access the symbol using dot notation. For example: 

```swift
// Image
Image(systemSymbol: .exclamationmarkCircle)
// Label
Label("account.new", systemSymbol: .plusCircle)
```

### Internationalization

We use i18n key in codes. If you want an string in UI, follow the steps below: 

1. Create an i18n key in [Localizable.strings (English)](./Internationalization/en.lproj/Localizable.strings) and fill its value. Imitate other key in the file to name your key. 
2. Access the text in UI via key. For example: `Text("app.name")`