//
//  KVOMutableArrayTests.m
//  KVOMutableArrayTests
//
//  Created by Hai Feng Kao on 05/19/2015.
//  Copyright (c) 2014 Hai Feng Kao. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <KVOMutableArray.h>

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


- (void)setUpClass {
    // Run at start of all tests in the class
}

- (void)tearDownClass {
    // Run at end of all tests in the class
    self.array = nil;
    self.token = nil;
}

- (void)setUp {
    // Run before each test method
    receiveReplacement = receiveAdd = receiveDelete = NO;
}

- (void)tearDown {
    // Run after each test method
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
    array[0] = @"world";
    
    XCTAssertEqual(array[0], @"world");
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
@end
