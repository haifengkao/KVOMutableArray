#import <Foundation/Foundation.h>
#import "NSObject+BlockObservation.h"

@interface KVOMutableArray<ObjectType> : NSMutableArray<NSFastEnumeration, NSMutableCopying, NSCoding, NSCopying>

- (NSMutableArray<ObjectType>*)arr;

- (instancetype)init;
- (instancetype)initWithMutableArray:(NSMutableArray<ObjectType>*)array NS_DESIGNATED_INITIALIZER;
- (BOOL)isEqualToArray:(KVOMutableArray<ObjectType>*)array;
- (AMBlockToken*)addObserverWithTask:(AMBlockTask)task;

// Warning!! [NSKeyedUnarchiver unarchiveObject] will return NSMutableArray
// see http://stackoverflow.com/questions/18874493/nsmutablearray-subclass-not-calling-subclasss-initwithcoder-when-unarchiving
- (void)encodeWithCoder:(NSCoder *)encoder;

// Warning!! [kvoMutableArray copy] may return NSArray
- (id)copyWithZone:(NSZone *)zone;
@end
