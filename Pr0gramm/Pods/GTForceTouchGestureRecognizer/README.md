# GTForceTouchGestureRecognizer

[![CI Status](http://img.shields.io/travis/neobeppe/GTForceTouchGestureRecognizer.svg?style=flat)](https://travis-ci.org/neobeppe/GTForceTouchGestureRecognizer)
[![Coverage Status](https://coveralls.io/repos/github/neobeppe/GTForceTouchGestureRecognizer/badge.svg?branch=swift4)](https://coveralls.io/github/neobeppe/GTForceTouchGestureRecognizer?branch=swift4)
[![Version](https://img.shields.io/cocoapods/v/GTForceTouchGestureRecognizer.svg?style=flat)](http://cocoapods.org/pods/GTForceTouchGestureRecognizer)
[![License](https://img.shields.io/cocoapods/l/GTForceTouchGestureRecognizer.svg?style=flat)](http://cocoapods.org/pods/GTForceTouchGestureRecognizer)
[![Platform](https://img.shields.io/cocoapods/p/GTForceTouchGestureRecognizer.svg?style=flat)](http://cocoapods.org/pods/GTForceTouchGestureRecognizer)

## Requirements

iOS 10 is required.

## Installation

#### CocoaPods

GTForceTouchGestureRecognizer is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "GTForceTouchGestureRecognizer"
```

#### Swift Package Manager

You can use [The Swift Package Manager](https://swift.org/package-manager) to install `GTForceTouchGestureRecognizer` by adding the proper description to your `Package.swift` file:

```swift
import PackageDescription

let package = Package(
    name: "YOUR_PROJECT_NAME",
    targets: [],
    dependencies: [
        .Package(url: "https://github.com/neobeppe/GTForceTouchGestureRecognizer.git"),
    ]
)
```

Note that the [Swift Package Manager](https://swift.org/package-manager) is still in early design and development, for more information checkout its [GitHub Page](https://github.com/apple/swift-package-manager)

#### Manually

To use this library in your project manually you may:

1.  for Projects, just drag GTForceTouchGestureRecognizer.swift to the project tree
2.  for Workspaces, include the whole GTForceTouchGestureRecognizer.xcodeproj

## Usage

You can simply instantiate an GTForceTouchGestureRecognizer and add it to a view.

```swift
let forceTouchGestureRecognizer = GTForceTouchGestureRecognizer(target: self, action: #selector(someFunction:))
view.addGestureRecognizer(forceTouchGestureRecognizer)
```

Optionally you can specify:
*   force percentage `threshold`, which is 0.75 by default
*   `vibrateOnDeepPress` to enable/disable deep press vibration (default is `true`)
*   `hardTriggerMinTime` minimum time after force touch has began

## License

GTForceTouchGestureRecognizer is available under the MIT license. See the LICENSE file for more info.
