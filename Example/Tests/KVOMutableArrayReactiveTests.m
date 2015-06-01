//
//  KVOMutableArrayReactiveTests.m
//  KVOMutableArray
//
//  Created by Lono on 2015/6/1.
//  Copyright (c) 2015年 Hai Feng Kao. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KVOMutableArray+ReactiveCocoaSupport.h>
#import <RACTuple.h>

@interface RACSignal(dummy)

@end
@implementation RACSignal(dummy)

- (void)dealloc
{
    
}

@end

@interface KVOMutableArrayReactiveTests : XCTestCase

@end

@implementation KVOMutableArrayReactiveTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testChangeSignal {
    // This is an example of a performance test case.
    
    __block __weak RACSignal* signalRef = nil;
    __block __weak KVOMutableArray* arrayRef = nil;
    
    __block BOOL objectAdded = NO;
    __block BOOL objectRemoved = NO;
    __block BOOL completionReceived = NO;
@autoreleasepool {
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithMutableArray:[@[@"hello"] mutableCopy]];
    arrayRef = array;
@autoreleasepool {
    RACSignal* signal = [array changeSignal];
    signalRef = signal;
    
    [signal subscribeNext:^(RACTuple* t) {
        NSArray *wholeArray = t.first;
        NSDictionary *change= t.second;
        
        NSLog(@"it changed: %@", [change objectForKey:NSKeyValueChangeKindKey]);
        NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
        
        NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
        NSArray* new = change[NSKeyValueChangeNewKey];
        NSArray* old = change[NSKeyValueChangeOldKey];
        if ([kind integerValue] == NSKeyValueChangeInsertion)  // Rows were added
        {
            objectAdded = YES;
            XCTAssertTrue([new[0] isEqualToString:@"world"], @"should get add event");
            XCTAssertNil(old, @"no old values");
        }
        
        else if ([kind integerValue] == NSKeyValueChangeRemoval)  // Rows were removed
        {
            objectRemoved = YES;
            XCTAssertTrue([old[0] isEqualToString:@"world"], @"should get add event");
            XCTAssertNil(new, @"no new values");
        }
    } completed:^{
        completionReceived = YES;
    }];
}
    XCTAssert(signalRef == nil, @"should deallocate signal");
    [array addObject:@"world"];
    [array removeLastObject];
}
    XCTAssert(arrayRef == nil, @"should deallocate array");
    XCTAssert(completionReceived == YES, @"should receive completion message");
    XCTAssert(objectRemoved == YES, @"should receive remove object notification");
    XCTAssert(objectAdded == YES, @"should receive add object notification");
}


@end
