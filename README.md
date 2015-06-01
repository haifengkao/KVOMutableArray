# KVOMutableArray
`KVOMutableArray` is a proxy object which supports key value observation of NSMutableArray. 

[![CI Status](http://img.shields.io/travis/Hai Feng Kao/KVOMutableArray.svg?style=flat)](https://travis-ci.org/Hai Feng Kao/KVOMutableArray)
[![Version](https://img.shields.io/cocoapods/v/KVOMutableArray.svg?style=flat)](http://cocoapods.org/pods/KVOMutableArray)
[![License](https://img.shields.io/cocoapods/l/KVOMutableArray.svg?style=flat)](http://cocoapods.org/pods/KVOMutableArray)
[![Platform](https://img.shields.io/cocoapods/p/KVOMutableArray.svg?style=flat)](http://cocoapods.org/pods/KVOMutableArray)

## Installation

KVOMutableArray is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

``` ruby
pod "KVOMutableArray"
```

KVOMutableArray supports monitoring with ReactiveCocoa signals. To enable this feature, add the following line instead:
``` ruby
pod "KVOMutableArray/ReactiveCocoaSupport"
```

 If you don't have CocoaPods installed or integrated into your project, you can learn how to do so [here](http://cocoapods.org).

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## So what can I do with it?

#### Receive KVO notificaiton, YEAH!
```objective-c
AMBlockToken* token = [kvoMutableArray addObserverWithTask:^BOOL(id obj, NSDictionary *change) {
        NSIndexSet *indexes = change[NSKeyValueChangeIndexesKey];
        NSNumber *kind = change[NSKeyValueChangeKindKey];
        NSArray* new = change[NSKeyValueChangeNewKey];
        NSArray* old = change[NSKeyValueChangeOldKey];
        
        if ([kind integerValue] == NSKeyValueChangeInsertion)
        {
            NSLog(@"objects %@ added at indexes: %@", new, indexes);
        } else if ([kind integerValue] == NSKeyValueChangeRemoval)
        {
            NSLog(@"objects %@ removed from indexes: %@", old, indexes);
        }

        return YES;
    }];
```

## Usage

### Init array
```objective-c
KVOMutableArray* array = [KVOMutableArray new];
[array addObject:@"hello"];
[array addObject:@"world"];
```

### Init from the exisiting NSArray
```objective-c
NSMutableArray* someArray = [@[@(1), @(2), @(3), @(4)] mutableCopy];
KVOMutableArray* array = [[KVOMutableArray alloc] initWithMutableArray:someArray];
```

### Register KVO events
```objective-c
AMBlockToken* token = [array addObserverWithTask:^BOOL(id obj, NSDictionary *change) {
    // handle the event here
}];
```
Alternatively, you can use ReactiveCocoa signals.
```objective-c
RACSignal* signal = [array changeSignal];
[signal subscribeNext:^(RACTuple* t) {
    NSArray *obj = t.first;
    NSDictionary *change= t.second;
    // handle the event here
        
}];
```
### Stop receiving KVO events
```objective-c
[token removeObserver];
```

### Retrieve the enclosing NSMutableArray object
```objective-c
NSMutableArray* theMutableArray = array.arr;
```

### Add, Remove, Access the objects

Manipulating the objects from KVOMutableArray
```objective-c
KVOMutableArray* array = [[KVOMutableArray alloc] initWithMutableArray:[@[@"hello", @"world"] mutableCopy]];
[array removeLastObject];
[array addObject:@"awesome!"];
[array removeObjectAtIndex:0];
NSString* awesome = array[0];
```
Or from the enclosing NSMutableArray
```objective-c
KVOMutableArray* array = [[KVOMutableArray alloc] initWithMutableArray:[@[@"hello", @"world"] mutableCopy]];
[array.arr removeLastObject];
[array.arr addObject:@"awesome!"];
[array.arr removeObjectAtIndex:0];
NSString* awesome = array.arr[0];
```

## Requirements

Requires iOS 7.0, and ARC.

## How it works

Because NSMutableArray cannot be directly key value observed, we monitor the change events from a property of KVOMutableArray.
For more details, check [the stackoverflow discussion](http://stackoverflow.com/questions/24088953/kvo-notifications-for-a-modification-of-an-nsarray-backed-by-a-nsmutablearray).


## Contributing

Forks, patches and other feedback are welcome.

## License

KVOMutableArray is available under the MIT license. See the LICENSE file for more info.
