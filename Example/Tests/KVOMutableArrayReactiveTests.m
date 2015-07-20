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
    
    __block NSInteger i = 0;
    [signal subscribeNext:^(RACTuple* t) {
        NSArray *array = t.first;
        NSDictionary *change= t.second;
        
        
        NSLog(@"it changed: %@", [change objectForKey:NSKeyValueChangeKindKey]);
        NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
        if (i == 0) {
            // insert @"world"
            NSArray* expected = @[@"hello", @"world"];
            XCTAssertEqualObjects(array, expected, @"the unmodifed array");
            XCTAssert(indices.firstIndex == 1, @"world is inserted at index 1");
        } else if (i == 1) {
            // remove @"world"
            NSArray* expected = @[@"hello"];
            XCTAssertEqualObjects(array, expected, @"the unmodifed array");
            XCTAssert(indices.firstIndex == 1, @"world is removed at index 1");
        }
        ++i;
        
        
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
            XCTAssertTrue([old[0] isEqualToString:@"world"], @"should get remove event");
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
