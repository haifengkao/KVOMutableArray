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


@implementation KVOMutableArray (ReactiveCocoaSupport)

- (RACSignal*)changeSignal
{
    RACSignal* signal = [self rac_valuesAndChangesForKeyPath:@keypath(self, arr)
                                                     options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                                                    observer:self];
    return signal;
}
@end
