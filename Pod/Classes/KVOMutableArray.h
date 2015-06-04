#import <Foundation/Foundation.h>
#import "NSObject+BlockObservation.h"

@interface KVOMutableArray : NSObject<NSFastEnumeration, NSMutableCopying>
@property (nonatomic, strong) NSMutableArray* arr;

- (instancetype)init;
- (instancetype)initWithMutableArray:(NSMutableArray*)array NS_DESIGNATED_INITIALIZER;
- (BOOL)isEqualToArray:(KVOMutableArray*)array;
- (void)addObject:(id)obj;
- (void)addObjectsFromArray:(NSArray*)array;
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)idx;
- (NSUInteger)indexOfObject:(id)object;
- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx;
- (void)insertObject:(id)obj atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)obj;
- (void)insertObject:(id)obj inArrAtIndex:(NSUInteger)index;
- (void)removeObject:(id)anObject;
- (void)removeAllObjects;
- (void)removeLastObject;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects;
- (AMBlockToken*)addObserverWithTask:(AMBlockTask)task;

@property (readonly) NSUInteger count;
@end
