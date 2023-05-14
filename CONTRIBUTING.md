# Contribute

## Branch

This repository has 2 main branches:

- `dev`: default branch. The upcoming version, which your pull request should be made against.
- `stable`: the currently version on App Store.

## Commit and Pull Request

### Naming Conventions

1. **Pull Requests (PRs)**

   When naming your pull requests, you can use a format similar to: `[Tag/Functionality] // Brief Summary of the Pull Request`.

   For example：

   - If you're fixing a bug related to notifications and improving the stamina notification, you could name your pull request: `Notification // Fix customize stamina notification`.
   - If you are adding a new widget (add a new feature), name it `Feature // New lockscreen widget`.

   If there is only one commit in the pr, you can also use the commit name for the whole pr.

2. **Commits**

   When naming your commits, you can use a format similar to: `[tag]: Brief Summary of the Change`. For example, if you're adding a new feature to your project that allows showing expedition configurable using the gi style widget, you could name your commit: `feat: gi style widget show expedition configurable`.

   Avaliable tags are:

   - `feat`: new feature
   - `fix`: bug fix
   - `i18n`: internationalization and UI text improve
   - `docs`: documentation changes
   - `code`: code formatting changes that do not affect the actual execution of the code, such as adding blank lines, reformatting, etc.
   - `refactor`: code changes that do not include bug fixes or new features
   - `perf`: performance improvement changes
   - `test`: addition or correction of test code
   - `chore`: changes to the build process or auxiliary tools and libraries (such as documentation generation)
   - `repo`: Git and GitHub repository related
   - `other`: others

## Code Style and Conventions

This repository uses [SwiftLint](https://github.com/realm/SwiftLint) and [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) to enforce code style and conventions. Install them and xcode will automaticlly format your code and warn you violate the rules while building. Make sure the codes you added are free of warning before committing.

## File Struct

This project adopts a file structure with "feature" as its core. When you need to modify or add a feature, please work in the [Features](Features) folder. Basic rule is the codes of some feature do not rely on any other feature in that folder.

If you have a common feature, such as a common model, view, view modifier, etc., please add it in the [Common](Common) folder according to its category.

Regarding the API of miHoYo, we have placed it in the [HBMihoyoAPI](Packages/HBMihoyoAPI) package under the [Packages](Packages) folder.

## Develop

### Internationalization

We use i18n key in codes. If you want a string in UI, follow the steps below:

1. Create an english key in [Localizable.strings (English)](Internationalization/en.lproj/Localizable.strings) and fill its value. Imitate other key in the file to name your key.
2. Copy those new keys to other language as a placeholder.
3. Access the `LocalizedKey` in UI via key. For example: `Text("app.name")` or `"app.name".localized()`.

### UserDefaults

We use [SwiftyUserDefaults](https://github.com/sunshinejr/SwiftyUserDefaults) instead of directly use `UserDefaults`.

If you want to store something into `UserDefaults`:

1. Add your key in `extension DefaultsKeys` of [Common/UserDefaultKeys.swift](./Common Tools/UserDefaultKeys.swift).

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
