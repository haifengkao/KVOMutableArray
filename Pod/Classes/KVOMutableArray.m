#import "KVOMutableArray.h"


@implementation KVOMutableArray

- (instancetype)initWithMutableArray:(NSMutableArray*)array
{
    if((self = [super init]))
    {
        _arr = array;
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
    NSMutableArray* arr = [aDecoder decodeObjectForKey:@"arr"];
    return [self initWithMutableArray:arr];
}

- (void)encodeWithCoder:(NSCoder *)encoder;
{
    [encoder encodeObject:self.arr forKey:@"arr"];
}

- (BOOL)isEqualToArray:(KVOMutableArray*)array
{
    if (![array isKindOfClass:[KVOMutableArray class]]) {
        // I guess array is NSArray
        return NO;
    }
    
    return [self.arr isEqualToArray:array.arr];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained [])buffer count:(NSUInteger)len
{
    NSUInteger arrayIndex = (NSUInteger)state->state;
    NSUInteger arraySize = [self.arr count];
    NSUInteger bufferIndex = 0;
    
    while ((arrayIndex < arraySize) && (bufferIndex < len)) {
        buffer[bufferIndex] = (self.arr)[arrayIndex];
        arrayIndex++;
        bufferIndex++;
    }
    
    state->state = (unsigned long)arrayIndex;
    state->itemsPtr = buffer; // Assigning '__autoreleasing id *' to '__unsafe_unretained id*' changes retain/release properties of pointer
    //state->mutationsPtr = (unsigned long *)self;
    state->mutationsPtr = &state->extra[0]; //TODO: mutationPtr is disabled
    return bufferIndex;
}

- (AMBlockToken*)addObserverWithTask:(AMBlockTask)task
{    
    return [self addObserverForKeyPath:@"arr" task:task];
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
    return [self countOfArr];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [self objectInArrAtIndex:index];
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
    [self insertObject:obj inArrAtIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [self removeObjectFromArrAtIndex:index];
}

- (void)addObject:(id)obj
{
    [self insertObject:obj inArrAtIndex:[self.arr count]];
}

- (void)removeLastObject
{
    NSMutableArray* arr = [self mutableArrayValueForKey:@"arr"];
    [arr removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)obj {
    [self replaceObjectInArrAtIndex:index withObject:obj];
}


#pragma mark - immutable convenience functions
- (id)firstObject
{
    return self.arr.firstObject;
}

- (id)lastObject
{
    return self.arr.lastObject;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx
{
    return [self.arr objectAtIndexedSubscript:idx];
}

- (NSUInteger)indexOfObject:(id)object
{
    return [self.arr indexOfObject:object];
}

#pragma mark - mutable convenience functions
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

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx
{
    // the implementation of replaceObjectAtIndex uses setObject:atIndexedSubscript: of self.arr
    [self replaceObjectAtIndex:idx withObject:obj];
}

- (void)removeObject:(id)anObject
{    
    NSMutableArray* arr = [self mutableArrayValueForKey:@"arr"];
    [arr removeObject: anObject];
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
    id obj1 = [self objectAtIndex:idx1];
    id obj2 = [self objectAtIndex:idx2];
    
    if (!obj1 || !obj2) {
        return;
    }
    [self replaceObjectAtIndex:idx1 withObject:obj2];
    [self replaceObjectAtIndex:idx2 withObject:obj1];
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes
{
    [self insertArr:objects atIndexes:indexes];
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes
{
   [self removeArrAtIndexes:indexes];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
    [self replaceArrAtIndexes:indexes withArr:objects];
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

#pragma mark - NSMutableCopying
- (id)mutableCopyWithZone:(NSZone *)zone {
    KVOMutableArray* mutableSelf = [[KVOMutableArray allocWithZone:zone] initWithMutableArray:[self.arr mutableCopyWithZone:zone]];
    return mutableSelf;
}
@end

