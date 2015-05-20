# KVOMutableArray
A NSMutableArray which can be key value observed (KVO)

[![CI Status](http://img.shields.io/travis/Hai Feng Kao/KVOMutableArray.svg?style=flat)](https://travis-ci.org/Hai Feng Kao/KVOMutableArray)
[![Version](https://img.shields.io/cocoapods/v/KVOMutableArray.svg?style=flat)](http://cocoapods.org/pods/KVOMutableArray)
[![License](https://img.shields.io/cocoapods/l/KVOMutableArray.svg?style=flat)](http://cocoapods.org/pods/KVOMutableArray)
[![Platform](https://img.shields.io/cocoapods/p/KVOMutableArray.svg?style=flat)](http://cocoapods.org/pods/KVOMutableArray)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## What is it?

`KVOMutableArray` is a proxy object which supports key value observation of NSMutableArray. 

The [idea behind this project](http://stackoverflow.com/questions/24088953/kvo-notifications-for-a-modification-of-an-nsarray-backed-by-a-nsmutablearray).

## So what can I do with it?

### Receive KVO notificaiton
```objective-c
AMBlockToken* token = [kvoMutableArray addObserverWithTask:^BOOL(id obj, NSDictionary *change) {
        NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
        NSNumber *kind = change[NSKeyValueChangeKindKey];
        NSArray* new = change[NSKeyValueChangeNewKey];
        NSArray* old = change[NSKeyValueChangeOldKey];
        
        if ([kind integerValue] == NSKeyValueChangeInsertion)
        {
            NSLog(@"objects added: %@", [new objectsAtIndexes:indexes]);
        } else if ([kind integerValue] == NSKeyValueChangeRemoval)
        {
            NSLog(@"objects removed: %@", [old objectsAtIndexes:indexes]indices);
        }

        return YES;
    }];
```

## Installation

KVOMutableArray is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

``` ruby
pod "KVOMutableArray"
```

 If you don't have CocoaPods installed or integrated into your project, you can learn how to do so [here](http://cocoapods.org).

# Example

`Example.xcworkspace` in the `Example` directory serves as an example implementation of `MSDynamicsDrawerViewController`. It uses Cocoapods to link with the `MSDynamicsDrawerViewController` source files in the root directory as a development pod. As such, use the example `xcworkspace` and not the `xcproj`.

# Usage

## Pane View Controller

# Requirements

Requires iOS 7.0, and ARC.

# Contributing

Forks, patches and other feedback are welcome.
## License

KVOMutableArray is available under the MIT license. See the LICENSE file for more info.
