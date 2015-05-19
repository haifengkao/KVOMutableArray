//
//  NSObject+BlockObservation.h
//  Version 1.0
//
//  Andy Matuschak
//  andy@andymatuschak.org
//  Public domain because I love you. Let me know how you use it.
//

#import <Foundation/Foundation.h>

@interface AMBlockToken :  NSObject
- (instancetype)initWithObject:(NSObject*)obj uuid:(NSString*)uuid NS_DESIGNATED_INITIALIZER;
- (void)removeObserver;
@end

typedef BOOL (^AMBlockTask)(id obj, NSDictionary *change); //return NO if observer wants to unsubscribe the event

@interface NSObject (AMBlockObservation)
- (AMBlockToken *)addObserverForKeyPath:(NSString *)keyPath task:(AMBlockTask)task;
- (AMBlockToken *)addObserverForKeyPath:(NSString *)keyPath onQueue:(NSOperationQueue *)queue task:(AMBlockTask)task;
@end


