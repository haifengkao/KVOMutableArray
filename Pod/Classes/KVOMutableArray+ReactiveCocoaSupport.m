//
//  KVOMutableArray+ReactiveCocoaSupport.m
//  Pods
//
//  Created by Lono on 2015/6/1.
//
//

#import "KVOMutableArray+ReactiveCocoaSupport.h"
#import <RACEXTKeyPathCoding.h>
#import <NSObject+RACPropertySubscribing.h>
#import "KVOMutableArrayObserver.h"

@interface KVOMutableArray (ReactiveCocoaSupportInternal)
- (KVOMutableArrayObserver*)observer;
@end

@implementation KVOMutableArray (ReactiveCocoaSupport)

- (RACSignal*)changeSignal
{
    
    KVOMutableArrayObserver* observer = [self observer];
    RACSignal* signal = [observer rac_valuesAndChangesForKeyPath:@keypath(observer, arr)
                                                     options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                                                    observer:observer];
    return signal;
}
@end
