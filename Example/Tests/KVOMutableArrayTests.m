//
//  KVOMutableArrayTests.m
//  KVOMutableArrayTests
//
//  Created by Hai Feng Kao on 05/19/2015.
//  Copyright (c) 2014 Hai Feng Kao. All rights reserved.
//

#import <XCTest/XCTest.h>
@import KVOMutableArray;

@interface KvoMutableArrayTest : XCTestCase
{
    BOOL receiveDelete;
    BOOL receiveAdd;
    BOOL receiveReplacement;
}

@property (nonatomic, strong) id token;
@property (nonatomic, strong) KVOMutableArray* array;
@property (nonatomic, strong) XCTestExpectation *expectation;
@end
@interface Dummy : NSObject
@property (nonatomic, copy) NSString* currentTask;
@end
@implementation Dummy

@synthesize currentTask;

@end
@implementation KvoMutableArrayTest

- (void)setUp {
    // Run before each test method
    receiveReplacement = receiveAdd = receiveDelete = NO;
}

- (void)tearDown {
    // Run after each test method
}

- (void)testInitWithCapacity
{
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithCapacity:3];
    XCTAssert(array, @"capacity init works");
    XCTAssert(array.count == 0, @"the initial size is 0");
}

- (void)testGenerics
{
    KVOMutableArray<NSNumber*>* array = [[KVOMutableArray alloc] initWithObjects:@(1), @(2), @(3), nil];
    KVOMutableArray<NSNumber*>* array2 = [[KVOMutableArray alloc] initWithObjects:@(1), @(2), @(3), nil];

    XCTAssertTrue([array isEqualToArray:array2]);
    XCTAssertEqual(((NSNumber*)array[0]).integerValue, 1);
    XCTAssertEqual(((NSNumber*)array[1]).integerValue, 2);

}

- (void)testGetObjects
{
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithObjects:@(1), @(2), @(3), nil];
    
    NSRange range = NSMakeRange(1, 2);
    __unsafe_unretained id *objects = (__unsafe_unretained id *) malloc(sizeof(void *) * range.length);
    
    [array getObjects:objects range:range];
    
    XCTAssertEqual(((NSNumber*)objects[0]).integerValue, 2);
    XCTAssertEqual(((NSNumber*)objects[1]).integerValue, 3);
    
    free(objects);
}

- (void)testFastEnumeration
{
    BOOL executed = NO;
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithObjects:@(1), @(2), @(3), nil];
    NSInteger i = 1;
    for (NSNumber* num in array){
        XCTAssertEqual(i, num.integerValue);
        ++i;
        executed = YES;
    }
    
    XCTAssert(executed, @"should run the loop");
}

- (void)testContainsObject
{
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithObjects:@(1), @(2), @(3), nil];
    XCTAssert([array containsObject:@(1)], @"");
}

- (void)testArchiving
{
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithMutableArray:[@[@(1), @(2), @(3)] mutableCopy]];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:array];
    NSMutableArray* unarchived = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssert([unarchived isKindOfClass:[NSMutableArray class]], @"it won't be KVOMutableArray, beware!!!");
    
    XCTAssert([array.arr isEqualToArray:unarchived], @"");
}

- (void)testInitWithObjects
{
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithObjects:@(1), @(2), @(3), nil];
    XCTAssert([array[0] isEqual:@(1)], @"");
    XCTAssert([array[1] isEqual:@(2)], @"");
    XCTAssert([array[2] isEqual:@(3)], @"");
    XCTAssert(array.count == 3, @"");
    XCTAssert([array isKindOfClass:[KVOMutableArray class]], @"");
}

- (void)testInitWithArray
{
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithArray:@[@(1), @(2), @(3)] copyItems:NO];
    XCTAssert([array[0] isEqual:@(1)], @"");
    XCTAssert([array[1] isEqual:@(2)], @"");
    XCTAssert([array[2] isEqual:@(3)], @"");
    XCTAssert(array.count == 3, @"");
    XCTAssert([array isKindOfClass:[KVOMutableArray class]], @"");
}

- (void)testMutableCopy
{
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithArray:@[@(1), @(2), @(3)]];
    KVOMutableArray* mutableCopy = [array mutableCopy];
    
    XCTAssert([array isEqualToArray:mutableCopy], @"");
}

- (void)testCopy
{
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithArray:@[@(1), @(2), @(3)]];
    NSArray* copy = [array copy];
    
    XCTAssert([array.arr isEqualToArray:copy], @"");
}

- (void)testObjectKvo
{
    Dummy* dummy = [[Dummy alloc] init];
    
    self.token = [dummy addObserverForKeyPath:@"currentTask"
                                         task:^BOOL (id obj, NSDictionary *change) { //TODO: refactor, very dirty
        NSString* val = [change objectForKey:NSKeyValueChangeNewKey];
        NSLog(@"%@", val);
        return NO;
    }];
    dummy.currentTask = nil;
    dummy.currentTask = @"hello";
    
}

- (void)testIndexAccess
{

    KVOMutableArray* array = [[KVOMutableArray alloc] init];
    [array addObject:@"hello"];
    
    XCTAssertEqual(array[0], @"hello");
}

- (void)testIndexAccessWrite
{

    KVOMutableArray* array = [[KVOMutableArray alloc] init];
    [array addObject:@"hello"];
    [array addObject:@"123"];
    array[0] = @"world";
    
    XCTAssertEqual(array[0], @"world");
    XCTAssertEqual(array[1], @"123");
}


- (void)testKvo
{
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithMutableArray:[@[@"hello"] mutableCopy]];
    self.token = [array addObserverWithTask:^BOOL(id obj, NSDictionary* change){
        NSLog(@"it changed: %@", [change objectForKey:NSKeyValueChangeKindKey]);
        NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
        if (indices == nil)
            return YES; // Nothing to do
        
        
        // Build index paths from index sets
        NSUInteger indexCount = [indices count];
        NSUInteger buffer[indexCount];
        [indices getIndexes:buffer maxCount:indexCount inIndexRange:nil];
        
        NSMutableArray *indexPathArray = [NSMutableArray array];
        for (int i = 0; i < indexCount; i++) {
            NSUInteger indexPathIndices[2];
            indexPathIndices[0] = 0;
            indexPathIndices[1] = buffer[i];
            NSIndexPath *newPath = [NSIndexPath indexPathWithIndexes:indexPathIndices length:2];
            [indexPathArray addObject:newPath];
        }
        NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
        NSArray* new = change[NSKeyValueChangeNewKey];
        NSArray* old = change[NSKeyValueChangeOldKey];
        if ([kind integerValue] == NSKeyValueChangeInsertion)  // Rows were added{
        {
            receiveAdd = YES;
            XCTAssertTrue([new[0] isEqualToString:@"world"], @"should get add event");
            XCTAssertNil(old, @"no old values");
        }
        
        else if ([kind integerValue] == NSKeyValueChangeRemoval)  // Rows were removed
        {
            receiveDelete = YES;
            XCTAssertTrue([old[0] isEqualToString:@"world"], @"should get add event");
            XCTAssertNil(new, @"no new values");
        }
        return YES;
    }];
    [array addObject:@"world"];
    [array removeLastObject];
    
    XCTAssertTrue(receiveAdd);
    XCTAssertTrue(receiveDelete);
}

- (void)testKvoWithReplace
{
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithMutableArray:[@[@"hello"] mutableCopy]];
    self.token = [array addObserverWithTask:^BOOL(id obj, NSDictionary* change){
        NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
        
        XCTAssert(indices.firstIndex == 0, @"the first object is being replaced");
        NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
        NSLog(@"it changed: %@", kind);
        
        XCTAssertEqualObjects(kind, @(NSKeyValueChangeReplacement), @"should be replacement");
        receiveReplacement = YES;
        return YES;
    }];
    array[0] = @"world";
    
    XCTAssertTrue(receiveReplacement);
}

- (void)testKvoWithMultipleReplace
{
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithMutableArray:[@[@"hello", @"world"] mutableCopy]];
    self.token = [array addObserverWithTask:^BOOL(id obj, NSDictionary* change){
        NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
        
        XCTAssert(indices.firstIndex == 0, @"");
        XCTAssert(indices.lastIndex == 1, @"");
        
        NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
        NSLog(@"it changed: %@", kind);
        
        XCTAssertEqualObjects(kind, @(NSKeyValueChangeReplacement), @"should be replacement");
        receiveReplacement = YES;
        return YES;
    }];
    
    NSMutableIndexSet* indexes = [NSMutableIndexSet new];
    [indexes addIndex:0];
    [indexes addIndex:1];
    
    [array replaceObjectsAtIndexes:indexes withObjects:@[@"awesome", @"replace"]];
    
    XCTAssertTrue(receiveReplacement);
    XCTAssertEqualObjects(array[0], @"awesome");
    XCTAssertEqualObjects(array[1], @"replace");
}

- (void)testKvoRemoveAllObjectsFromEmptyArray
{
    KVOMutableArray* array = [[KVOMutableArray alloc] init];
    
    self.token = [array addObserverWithTask:^BOOL(id obj, NSDictionary* change){
        XCTAssertTrue(NO, @"should not trigger KVO");
    }];
    [array removeAllObjects];
}

- (void)testKvoAddObjectsFromEmptyArray
{
    KVOMutableArray* array = [[KVOMutableArray alloc] init];
    
    self.token = [array addObserverWithTask:^BOOL(id obj, NSDictionary* change){
        XCTAssertTrue(NO, @"should not trigger KVO");
    }];
    [array addObjectsFromArray:@[]];
}

- (void)testKvoAddObjectsFromArray
{
    KVOMutableArray* array = [[KVOMutableArray alloc] init];
    [array addObject:@"hello"];
    
    self.token = [array addObserverWithTask:^BOOL(id obj, NSDictionary* change){
        NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
        
        XCTAssertTrue(indices.count == 2, @"should receive all objects at once");
        
        // Build index paths from index sets
        NSUInteger indexCount = [indices count];
        NSUInteger buffer[indexCount];
        [indices getIndexes:buffer maxCount:indexCount inIndexRange:nil];
        
        NSMutableArray *indexPathArray = [NSMutableArray array];
        for (int i = 0; i < indexCount; i++) {
            NSUInteger indexPathIndices[2];
            indexPathIndices[0] = 0;
            indexPathIndices[1] = buffer[i];
            NSIndexPath *newPath = [NSIndexPath indexPathWithIndexes:indexPathIndices length:2];
            [indexPathArray addObject:newPath];
        }
        NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
        NSArray* new = change[NSKeyValueChangeNewKey];
        NSArray* old = change[NSKeyValueChangeOldKey];
        if ([kind integerValue] == NSKeyValueChangeInsertion)  // Rows were added{
        {
            receiveAdd = YES;
            XCTAssertTrue([new[0] isEqualToString:@"world"], @"should get add event");
            XCTAssertNil(old, @"no old values");
        }
        else if ([kind integerValue] == NSKeyValueChangeRemoval)  // Rows were removed
        {
            XCTAssertTrue(NO, @"should not run to here");
        }
        return YES;
    }];
    
    [array addObjectsFromArray:@[@"world", @"123"]];
}

- (void)testKVOExchangeSameObject
{
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithObjects:@"hello", @"world", @"123", nil];
    self.token = [array addObserverWithTask:^BOOL(id obj, NSDictionary* change){
        
        NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
        NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
        NSArray* new = change[NSKeyValueChangeNewKey];
        NSArray* old = change[NSKeyValueChangeOldKey];
        
        XCTAssertEqual(kind.integerValue, NSKeyValueChangeReplacement, @"");
        XCTAssertTrue(indices.count == 1, @"");
        XCTAssertTrue(indices.firstIndex == 1, @"");
        XCTAssertEqualObjects(new, @[@"world"], @"");
        XCTAssertEqualObjects(old, @[@"world"], @"");
        
        return YES;
    }];
    [array exchangeObjectAtIndex:1 withObjectAtIndex:1];
}

- (void)testKVOExchangeObject
{
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithObjects:@"hello", @"world", @"123", nil];
    __block NSInteger i = 0;
    self.token = [array addObserverWithTask:^BOOL(id obj, NSDictionary* change){
        
        NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
        NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
        NSArray* new = change[NSKeyValueChangeNewKey];
        NSArray* old = change[NSKeyValueChangeOldKey];
        
        XCTAssertEqual(kind.integerValue, NSKeyValueChangeReplacement, @"");
        if (i == 0) {
            // replace first index
            XCTAssertTrue(indices.count == 1, @"");
            XCTAssertTrue(indices.firstIndex == 1, @"");
            XCTAssertEqualObjects(new, @[@"123"], @"");
            XCTAssertEqualObjects(old, @[@"world"], @"");
        } else if (i == 1) {
            // replace second index
            XCTAssertTrue(indices.count == 1, @"");
            XCTAssertTrue(indices.firstIndex == 2, @"");
            XCTAssertEqualObjects(new, @[@"world"], @"");
            XCTAssertEqualObjects(old, @[@"123"], @"");
        }
        
        ++i;
        
        return YES;
    }];
    [array exchangeObjectAtIndex:1 withObjectAtIndex:2];
}

- (void)testKvoRemoveObject
{
    KVOMutableArray* array = [[KVOMutableArray alloc] initWithObjects:@"hello", @"world", @"123", nil];
    
    self.token = [array addObserverWithTask:^BOOL(id obj, NSDictionary* change){
        
        XCTAssertFalse(receiveDelete, @"the removal event should run exactly once");
        
        NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
        
        XCTAssertTrue(indices.count == 1, @"");
        XCTAssertTrue(indices.firstIndex == 1, @"");
        
        NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
        NSArray* new = change[NSKeyValueChangeNewKey];
        NSArray* old = change[NSKeyValueChangeOldKey];
        if ([kind integerValue] == NSKeyValueChangeInsertion)  // Rows were added{
        {
            XCTAssertTrue(NO, @"should not run here");
        }
        else if ([kind integerValue] == NSKeyValueChangeRemoval)  // Rows were removed
        {
            receiveDelete = YES;
            XCTAssertTrue([old[0] isEqualToString:@"world"], @"should get remove event");
            XCTAssertNil(new, @"no new values");
        } else {
            XCTAssert(NO, @"something goes wrong");
        }
        return YES;
    }];
    [array removeObject:@"world"];
}

- (void)testKvoRemoveAllObjects
{
    KVOMutableArray* array = [[KVOMutableArray alloc] init];
    
    [array addObject:@"hello"];
    [array addObject:@"world"];
    [array addObject:@"123"];
    
    self.token = [array addObserverWithTask:^BOOL(id obj, NSDictionary* change){
        NSIndexSet *indices = [change objectForKey:NSKeyValueChangeIndexesKey];
        
        XCTAssertTrue(indices.count == 3, @"should receive all objects at once");
        
        // Build index paths from index sets
        NSUInteger indexCount = [indices count];
        NSUInteger buffer[indexCount];
        [indices getIndexes:buffer maxCount:indexCount inIndexRange:nil];
        
        NSMutableArray *indexPathArray = [NSMutableArray array];
        for (int i = 0; i < indexCount; i++) {
            NSUInteger indexPathIndices[2];
            indexPathIndices[0] = 0;
            indexPathIndices[1] = buffer[i];
            NSIndexPath *newPath = [NSIndexPath indexPathWithIndexes:indexPathIndices length:2];
            [indexPathArray addObject:newPath];
        }
        NSNumber *kind = [change objectForKey:NSKeyValueChangeKindKey];
        NSArray* new = change[NSKeyValueChangeNewKey];
        NSArray* old = change[NSKeyValueChangeOldKey];
        if ([kind integerValue] == NSKeyValueChangeInsertion)  // Rows were added{
        {
            XCTAssertTrue(NO, @"should not run here");
        }
        else if ([kind integerValue] == NSKeyValueChangeRemoval)  // Rows were removed
        {
            receiveDelete = YES;
            XCTAssertTrue([old[0] isEqualToString:@"hello"], @"should get remove event");
            XCTAssertNil(new, @"no new values");
        }
        return YES;
    }];
    [array removeAllObjects];
}

/**
 *  disable self.token should stop all KVO notificaitons
 */
- (void)testKvoDisable
{
    self.expectation = [self expectationWithDescription:@"KvoE"];
    
    KVOMutableArray* array = [[KVOMutableArray alloc] init];
    self.array = array;
    
    self.token = [array addObserverWithTask:^BOOL(id obj, NSDictionary* change){
        NSCAssert(NO, @"should not be called");
        return NO;
    }];
    
    [self performSelectorInBackground:@selector(KvoDisableHelper) withObject:nil];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
    
}

- (void)KvoDisableHelper
{
    [self.token removeObserver];
    [self.array addObject:@"world"];
    [self.array removeLastObject];
    
    [self.expectation fulfill];
}

- (void)testLastObject
{
    KVOMutableArray* array = [[KVOMutableArray alloc] init];
    
    XCTAssertTrue(array.lastObject == nil, @"should be nil");
    [array insertObject:@"hi" atIndex:0];
    
    XCTAssertEqualObjects(array.lastObject, @"hi", @"should be the same");
    
    [array insertObject:@"hi2" atIndex:0];
    XCTAssertEqualObjects(array.lastObject, @"hi", @"should be the same");
}

- (void)testFistObject
{
    KVOMutableArray* array = [[KVOMutableArray alloc] init];
    
    XCTAssertTrue(array.firstObject == nil, @"should be nil");
    [array insertObject:@"hi" atIndex:0];
    
    XCTAssertEqualObjects(array.firstObject, @"hi", @"should be the same");
    
    [array insertObject:@"hi2" atIndex:0];
    XCTAssertEqualObjects(array.firstObject, @"hi2", @"should be the same");
}
@end
