#import <Foundation/Foundation.h>
#import "NSObject+BlockObservation.h"

@interface KvoMutableArray : NSObject<NSFastEnumeration, NSMutableCopying>
@property (nonatomic, strong) NSMutableArray* arr;

- (instancetype)init;
- (instancetype)initWithMutableArray:(NSMutableArray*)array NS_DESIGNATED_INITIALIZER;
- (BOOL)isEqualToArray:(KvoMutableArray*)array;
- (void) addObject:(id)obj;
- (void)addObjectsFromArray:(NSArray*)array;
- (id)objectAtIndex:(NSUInteger)index;
- (void)insertObject:(id)obj atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)obj;
- (void)insertObject:(id)obj inArrAtIndex:(NSUInteger)index;
- (void)removeObject:(id)anObject;
- (void)removeAllObjects;
- (void)removeLastObject;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;
- (AMBlockToken*)addObserverWithTask:(AMBlockTask)task;

@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger count;
@property (NS_NONATOMIC_IOSONLY, readonly) NSUInteger countOfArr;
#pragma mark - immutable functions
- (NSUInteger)indexOfObject:(id)object;
@end
