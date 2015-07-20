//
//  KVOMutableArrayObserver.h
//  Pods
//
//  Created by Lono on 2015/7/20.
//
//

#import <Foundation/Foundation.h>
#import "NSObject+BlockObservation.h"

@interface KVOMutableArrayObserver : NSObject
@property (nonatomic, strong) NSMutableArray* arr;

- (instancetype)initWithMutableArray:(NSMutableArray*)array NS_DESIGNATED_INITIALIZER;
- (AMBlockToken*)addObserverWithTask:(AMBlockTask)task;


#pragma mark - Getter Indexed Accessors
- (NSUInteger)countOfArr;
- (id)objectInArrAtIndex:(NSUInteger)index;
- (void)getArr:(id __unsafe_unretained*)buffer range:(NSRange)inRange;

#pragma mark - Mutable Indexed Accessors
- (void)replaceObjectInArrAtIndex:(NSUInteger)index withObject:(id)obj;
- (void)replaceArrAtIndexes:(NSIndexSet*)indexes withArr:(NSArray*)array;
- (void)removeObjectFromArrAtIndex:(NSUInteger)index;
- (void)removeArrAtIndexes:(NSIndexSet *)indexes;
- (void)insertObject:(id)obj inArrAtIndex:(NSUInteger)index;
- (void)insertArr:(NSArray *)array atIndexes:(NSIndexSet *)indexes;
@end
