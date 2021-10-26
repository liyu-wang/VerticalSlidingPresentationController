# VerticalSlidingPresentationController

## Overview

VerticalSlidingPresentationController is a custom view controller presentation library which is designed to animate the presented view controller from bottom of the screen. When the presented view controller is showing on the screen, it has two anchor points, one at the lower part of the screen and the other at the upper part, You could scroll the content view of the presented view controller directly to update the origin of the presented view controller so that it can slide between the two anchor points or be dismissed.

## Preview

![](Screenshots/screen-recording.gif)

## Requirements

- [x] Xcode 11 or higher.
- [x] Swift 5.1 or higher.
- [x] iOS 11 or higher.

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. To integrate into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'VerticalSlidingPresentationController', '~> 0.2.0'
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "liyu-wang/VerticalSlidingPresentationController" ~> 0.2.0
```

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding it as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/liyu-wang/VerticalSlidingPresentationController.git", .upToNextMajor(from: "0.2.0"))
]
```