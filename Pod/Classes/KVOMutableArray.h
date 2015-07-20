#import <Foundation/Foundation.h>
#import "NSObject+BlockObservation.h"

@interface KVOMutableArray : NSMutableArray<NSFastEnumeration, NSMutableCopying, NSCoding, NSCopying>

- (NSMutableArray*)arr;

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
- (void)removeObject:(id)anObject;
- (void)removeAllObjects;
- (void)removeLastObject;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes;
- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects;
- (AMBlockToken*)addObserverWithTask:(AMBlockTask)task;

// #warning [NSKeyedUnarchiver unarchiveObject] will return NSMutableArray
// see http://stackoverflow.com/questions/18874493/nsmutablearray-subclass-not-calling-subclasss-initwithcoder-when-unarchiving
- (void)encodeWithCoder:(NSCoder *)encoder;

// #warning [kvoMutableArray copy] may return NSArray
- (id)copyWithZone:(NSZone *)zone;

#pragma mark - immutable fuctions
@property (readonly) NSUInteger count;
@property (nonatomic, readonly) id firstObject NS_AVAILABLE(10_6, 4_0);
@property (nonatomic, readonly) id lastObject;
@end
