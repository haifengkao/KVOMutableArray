//
//  KVOMutableArrayObserver.m
//  Pods
//
//  Created by Hai Feng Kao on 2015/7/20.
//
//

#import "KVOMutableArrayObserver.h"

@implementation KVOMutableArrayObserver

- (instancetype)init
{
    return [self initWithMutableArray:[NSMutableArray new]];
}

- (instancetype)initWithMutableArray:(NSMutableArray*)array
{
    if((self = [super init]))
    {
        _arr = array;
    }
    return self;
}


- (AMBlockToken*)addObserverWithTask:(AMBlockTask)task
{    
    return [self addObserverForKeyPath:@"arr" task:task];
}

#pragma mark - Getter Indexed Accessors
- (NSUInteger)countOfArr {
    return [self.arr count];
}

- (id)objectInArrAtIndex:(NSUInteger)index {
    if (index >= self.arr.count) {
        return nil;
    }
    return (self.arr)[index];
}

// Implementing this method is optional, but offers additional performance gains. This method corresponds to the NSArray method getObjects:range:.
- (void)getArr:(id __unsafe_unretained*)buffer range:(NSRange)inRange
{
    // Return the objects in the specified range in the provided buffer.
    [self.arr getObjects:buffer range:inRange];
}

#pragma mark - Mutable Indexed Accessors
- (void)replaceObjectInArrAtIndex:(NSUInteger)index withObject:(id)obj
{
    (self.arr)[index] = obj;
}

- (void)replaceArrAtIndexes:(NSIndexSet*)indexes withArr:(NSArray*)array
{
    [self.arr replaceObjectsAtIndexes:indexes withObjects:array];
}

- (void)removeObjectFromArrAtIndex:(NSUInteger)index
{
    [self.arr removeObjectAtIndex:index];
}

- (void)removeArrAtIndexes:(NSIndexSet *)indexes
{
    [self.arr removeObjectsAtIndexes:indexes];
}

- (void)insertObject:(id)obj inArrAtIndex:(NSUInteger)index
{
    [self.arr insertObject:obj atIndex:index];
}

- (void)insertArr:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self.arr insertObjects:array atIndexes:indexes];
}

@end
