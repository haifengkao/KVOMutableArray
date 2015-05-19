//
//  NSObject+BlockObservation.h
//  Version 1.0
//
//  Andy Matuschak
//  andy@andymatuschak.org
//  Public domain because I love you. Let me know how you use it.
//

#import "NSObject+BlockObservation.h"
#import <dispatch/dispatch.h>
#import <objc/runtime.h>

static NSInteger AMObserverTrampolineContext;

@interface AMBlockToken()
@property (nonatomic, strong) NSObject* obj;
@property (nonatomic, copy) NSString* uuid;
@end



@interface AMObserverTrampoline : NSObject
{
    NSObject* __weak observee;
    NSString *keyPath;
    AMBlockTask task;
    NSOperationQueue *queue;
    AMBlockToken* __weak token;
    dispatch_once_t cancellationPredicate;
}

- (AMObserverTrampoline *)initObservingObject:(NSObject*)obj keyPath:(NSString *)newKeyPath onQueue:(NSOperationQueue *)newQueue task:(AMBlockTask)newTask token:(AMBlockToken *)token NS_DESIGNATED_INITIALIZER;
- (void)cancelObservation;
@end

@implementation AMObserverTrampoline
- (AMObserverTrampoline *)initObservingObject:(NSObject*)obj keyPath:(NSString *)newKeyPath onQueue:(NSOperationQueue *)newQueue task:(AMBlockTask)newTask token:(AMBlockToken *)theToken
{
    if (!(self = [super init])) return nil;
    task = [newTask copy];
    keyPath = [newKeyPath copy];
    queue = newQueue;
    observee = obj;
    cancellationPredicate = 0;
    token = theToken;
    
    [observee addObserver:self
               forKeyPath:keyPath
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                  context:&AMObserverTrampolineContext];
    
    return self;
}

- (void)observeValueForKeyPath:(NSString *)aKeyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &AMObserverTrampolineContext)
    {
        if (queue)
        {
            AMBlockTask queueTask = [task copy];
            [queue addOperationWithBlock:^{ 
                if(!queueTask(object, change))
                {
                    //TODO: release the observer
                    //[observee removeObserverWithBlockToken:token];           
                }
            }];
        }
        else
        {
            if (!task(object, change)) {
                //cancel this oberservation
                [token removeObserver];          
            }
        }
        //self may become invalid here
    }
}

- (void)cancelObservation
{
    if (observee) {
        dispatch_once(&cancellationPredicate, ^{
            [self->observee removeObserver:self forKeyPath:self->keyPath context:&AMObserverTrampolineContext];
            //observee = nil;
        });
    }
}

- (void)dealloc
{
    [self cancelObservation];  
}

@end

static const NSString * const AMObserverMapKey = @"org.andymatuschak.observerMap";
static dispatch_queue_t AMObserverMutationQueue = NULL;

static dispatch_queue_t AMObserverMutationQueueCreatingIfNecessary()
{
    static dispatch_once_t queueCreationPredicate = 0;
    dispatch_once(&queueCreationPredicate, ^{
        AMObserverMutationQueue = dispatch_queue_create("org.andymatuschak.observerMutationQueue", 0);
    });
    return AMObserverMutationQueue;
}

@implementation NSObject (AMBlockObservation)

- (AMBlockToken *)addObserverForKeyPath:(NSString *)keyPath task:(AMBlockTask)task
{
    return [self addObserverForKeyPath:keyPath onQueue:nil task:task];
}

- (AMBlockToken *)addObserverForKeyPath:(NSString *)keyPath onQueue:(NSOperationQueue *)queue task:(AMBlockTask)task
{
    AMBlockToken *token = [[AMBlockToken alloc] initWithObject:self uuid:[[NSProcessInfo processInfo] globallyUniqueString]];
    
    dispatch_sync(AMObserverMutationQueueCreatingIfNecessary(), ^{
        NSMutableDictionary *dict = objc_getAssociatedObject(self, (__bridge void*)AMObserverMapKey);
        
        if (!dict)
        {
            dict = [NSMutableDictionary new];
            objc_setAssociatedObject(self, (__bridge void*)AMObserverMapKey, dict, OBJC_ASSOCIATION_RETAIN);
        }
        
        AMObserverTrampoline *trampoline = [[AMObserverTrampoline alloc] initObservingObject:self
                                                                                     keyPath:keyPath 
                                                                                     onQueue:queue
                                                                                        task:task
                                                                                       token:token];
        dict[token.uuid] = trampoline;
    });
    
    return token;
}

- (void)removeObserverWithUUID:(NSString*)uuid
{
    dispatch_sync(AMObserverMutationQueueCreatingIfNecessary(), ^{
        NSMutableDictionary *observationDictionary = objc_getAssociatedObject(self, (__bridge void*)AMObserverMapKey);
        AMObserverTrampoline *trampoline = observationDictionary[uuid];
        
        if (!trampoline)
        {
            NSLog(@"[NSObject(AMBlockObservation) removeObserverWithBlockToken]: Ignoring attempt to remove non-existent observer on %@ for token %@.", self, uuid);
            return;
        }
        
        [trampoline cancelObservation];
        [observationDictionary removeObjectForKey:uuid];
        
        // Due to a bug in the obj-c runtime, this dictionary does not get cleaned up on release when running without GC.
        if ([observationDictionary count] == 0)
        {
            objc_setAssociatedObject(self, (__bridge void*)AMObserverMapKey, nil, OBJC_ASSOCIATION_RETAIN);
        }
    });
}


@end

@implementation AMBlockToken
- (instancetype)initWithObject:(NSObject*)obj uuid:(NSString*)uuid
{
    if (self = [super init]) {
        _obj = obj;
        _uuid = uuid;
    }
    return self;
}

- (void)removeObserver
{
    if (self.uuid) {
        [_obj removeObserverWithUUID:_uuid];
        self.uuid = nil;
        self.obj = nil;
    }
    
}

- (void)dealloc
{
    [self removeObserver];
}
@end

