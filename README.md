# KVOMutableArray
`KVOMutableArray` is a proxy object which supports key value observation of NSMutableArray. 

[![CI Status](http://img.shields.io/travis/haifengkao/KVOMutableArray.svg?style=flat)](https://travis-ci.org/haifengkao/KVOMutableArray)
[![Coverage Status](https://coveralls.io/repos/haifengkao/KVOMutableArray/badge.svg?branch=master&service=github)](https://coveralls.io/github/haifengkao/KVOMutableArray?branch=master)
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
KVOMutableArray* array = [KVOMutableArray new];
AMBlockToken* token = [array addObserverWithTask:^BOOL(id obj, NSDictionary *change) {
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
Alternatively, you can do
```objective-c
KVOMutableArray* array = [[KVOMutableArray alloc] initWithObjects:@(1), @(2), @(3), nil];
```

### Init from the exisiting NSArray
```objective-c
NSArray* someArray = @[@(1), @(2), @(3), @(4)];
KVOMutableArray* array = [[KVOMutableArray alloc] initWithArray:someArray];
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
KVOMutableArray* array = [[KVOMutableArray alloc] initWithArray:@[@"hello", @"world"]];
[array removeLastObject];
[array addObject:@"awesome!"];
[array removeObjectAtIndex:0];
NSString* awesome = array[0];
```
Or from the enclosing NSMutableArray
```objective-c
KVOMutableArray* array = [[KVOMutableArray alloc] initWithArray:@[@"hello", @"world"]];
[array.arr removeLastObject];
[array.arr addObject:@"awesome!"];
[array.arr removeObjectAtIndex:0];
NSString* awesome = array.arr[0];
```

## Gotchas
KVOMutableArray is now a subclass of NSMutableArray after 1.0 release.
This change makes two gotchas available:

First, the unarchived object is an NSMutableArray, not a KVOMutableArary. 
[No solution on StackOverflow so far](http://stackoverflow.com/questions/18874493/nsmutablearray-subclass-not-calling-subclasss-initwithcoder-when-unarchiving).

```objective-c
KVOMutableArray* array = [[KVOMutableArray alloc] initWithArray:@[@(1), @(2), @(3)]];
NSData* data = [NSKeyedArchiver archivedDataWithRootObject:array];

// not a KVOMutableArray
NSMutableArray* unarchived = [NSKeyedUnarchiver unarchiveObjectWithData:data];
```

Second, the object returns from `copy` is a NSArray. There is no immutable KVOMutableArray, the only reasonable choice is to return immutable NSArray object.
```objective-c
KVOMutableArray* array = [[KVOMutableArray alloc] init];

// not a KVOMutableArray
NSArray* copy = [array copy];
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
