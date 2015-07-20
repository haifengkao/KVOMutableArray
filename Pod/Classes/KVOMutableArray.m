#import "KVOMutableArray.h"
#import "KVOMutableArrayObserver.h"

@interface KVOMutableArray()
@property (nonatomic, strong) KVOMutableArrayObserver* observer;
@end

@implementation KVOMutableArray

- (NSMutableArray*)arr
{
    return self.observer.arr;
}

- (instancetype)initWithMutableArray:(NSMutableArray*)array
{
    if((self = [super init]))
    {
        _observer = [[KVOMutableArrayObserver alloc] initWithMutableArray:array];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithMutableArray:[[NSMutableArray alloc] init]];
}

- (instancetype)initWithObjects:(const id [])objects count:(NSUInteger)cnt;
{
    NSMutableArray* arr = [[NSMutableArray alloc] initWithObjects:objects count:cnt];
    return [self initWithMutableArray:arr];
}

- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    NSMutableArray* arr = [[NSMutableArray alloc]  initWithCapacity:numItems];
    return [self initWithMutableArray:arr];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSMutableArray* arr = [[NSMutableArray alloc] initWithCoder:aDecoder];
    //    KVOMutableArrayObserver* observer = [aDecoder decodeObjectForKey:@"observer"];
    return [self initWithMutableArray:arr];
}

- (void)encodeWithCoder:(NSCoder *)encoder;
{
    [self.observer.arr encodeWithCoder:encoder];
    //    [encoder encodeObject:self.observer forKey:@"observer"];
}

- (BOOL)isEqualToArray:(KVOMutableArray*)array
{
    if (![array isKindOfClass:[KVOMutableArray class]]) {
        // I guess array is NSArray
        return NO;
    }
    
    return [self.arr isEqualToArray:array.arr];
}

#pragma mark - NSArray subclassing methods
/*
  Any subclass of NSArray must override the primitive instance methods count and objectAtIndex:. 
  These methods must operate on the backing store that you provide for the elements of the collection.
  For this backing store you can use a static array, a standard NSArray object, or some other 
  data type or mechanism. You may also choose to override, partially or fully, any other NSArray method 
  for which you want to provide an alternative implementation.
 */
- (NSUInteger)count
{
    return [self.observer countOfArr];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [self.observer objectInArrAtIndex:index];
}

#pragma mark - NSArray subclassing methods, not on Apple's doc but required
- (id)firstObject
{
    return self.arr.firstObject;
}

- (id)lastObject
{
    return self.arr.lastObject;
}

#pragma mark - NSMutableArray subclassing methods

/*
 NSMutableArray defines five primitive methods:
 insertObject:atIndex:
 removeObjectAtIndex:
 addObject:
 removeLastObject
 replaceObjectAtIndex:withObject:
 */
- (void)insertObject:(id)obj atIndex:(NSUInteger)index {
    [self.observer insertObject:obj inArrAtIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self.observer removeObjectFromArrAtIndex:index];
}

- (void)addObject:(id)obj
{
    [self.observer insertObject:obj inArrAtIndex:[self.arr count]];
}

- (void)removeLastObject
{
    NSMutableArray* arr = [self.observer mutableArrayValueForKey:@"arr"];
    [arr removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)obj {
    [self.observer replaceObjectInArrAtIndex:index withObject:obj];
}

#pragma mark - not required immutable convenience functions
//- (id)objectAtIndexedSubscript:(NSUInteger)idx
//{
//    return [self.arr objectAtIndexedSubscript:idx];
//}
//
//- (NSUInteger)indexOfObject:(id)object
//{
//    return [self.arr indexOfObject:object];
//}

#pragma mark - mutable convenience functions
// we need to keep the following methods for perfomance reasons
// the default NSMutableArray implementation will send the insertion event one by one, which is inefficient

- (void)addObjectsFromArray:(NSArray*)array
{
    NSUInteger count = self.arr.count;
    NSRange range = {count, array.count};
    NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    if (indexSet.count > 0) {
        // don't send meaningless KVO event
        [self insertObjects:array atIndexes:indexSet];
    }
}

- (void)removeAllObjects
{
    NSRange range = {0, self.arr.count};
    NSIndexSet* indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    if (indexSet.count > 0) {
        // don't send meaningless KVO event
        [self removeObjectsAtIndexes:indexSet];
    }
    
//    don't use the following codes. each object removed will send
//    one KVO notification, which is very inefficient
//
//    arr returned is NSKeyValueNotifyingMutableArray
//    NSMutableArray* arr = [self mutableArrayValueForKey:@"arr"];
//    [arr removeAllObjects];
}


- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    [self.observer insertArr:objects atIndexes:indexes];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
   [self.observer removeArrAtIndexes:indexes];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
    [self.observer replaceArrAtIndexes:indexes withArr:objects];
}

#pragma mark - not required mutable convenience functions
// the abstract NSMutableArray can handle the following methods correctly

//- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
//{
//    // the implementation of replaceObjectAtIndex uses setObject:atIndexedSubscript: of self.arr
//    [self replaceObjectAtIndex:idx withObject:obj];
//}

//- (void)removeObject:(id)anObject
//{    
//    NSMutableArray* arr = [self.observer mutableArrayValueForKey:@"arr"];
//    [arr removeObject: anObject];
//}

//- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
//{
//    id obj1 = [self objectAtIndex:idx1];
//    id obj2 = [self objectAtIndex:idx2];
//    
//    if (!obj1 || !obj2) {
//        return;
//    }
//    [self replaceObjectAtIndex:idx1 withObject:obj2];
//    [self replaceObjectAtIndex:idx2 withObject:obj1];
//}

//- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
//{
//    NSUInteger arrayIndex = (NSUInteger)state->state;
//    NSUInteger arraySize = [self.arr count];
//    NSUInteger bufferIndex = 0;
//    
//    while ((arrayIndex < arraySize) && (bufferIndex < len)) {
//        buffer[bufferIndex] = (self.arr)[arrayIndex];
//        arrayIndex++;
//        bufferIndex++;
//    }
//    
//    state->state = (unsigned long)arrayIndex;
//    state->itemsPtr = buffer; // Assigning '__autoreleasing id *' to '__unsafe_unretained id*' changes retain/release properties of pointer
//    //state->mutationsPtr = (unsigned long *)self;
//    state->mutationsPtr = &state->extra[0]; //TODO: mutationPtr is disabled
//    return bufferIndex;
//}

#pragma mark - NSCopying
- (id)copyWithZone:(NSZone *)zone
{
    //  may return a NSArray, beware!!!
    return [self.arr copy];
}

#pragma mark - NSMutableCopying
- (id)mutableCopyWithZone:(NSZone *)zone {
    KVOMutableArray* mutableSelf = [[KVOMutableArray allocWithZone:zone] initWithMutableArray:[self.arr mutableCopyWithZone:zone]];
    return mutableSelf;
}

#pragma mark - KVO
- (AMBlockToken*)addObserverWithTask:(AMBlockTask)task
{    
    return [self.observer addObserverWithTask:task];
}

@end

