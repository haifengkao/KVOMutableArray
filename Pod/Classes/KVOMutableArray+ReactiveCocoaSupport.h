//
//  KVOMutableArray+ReactiveCocoaSupport.h
//  Pods
//
//  Created by Hai Feng Kao on 2015/6/1.
//
//

#import "KVOMutableArray.h"
#import "RACSignal.h"

@interface KVOMutableArray (ReactiveCocoaSupport)
- (RACSignal*)changeSignal;
@end
