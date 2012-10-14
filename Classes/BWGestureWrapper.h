#import <UIKit/UIKit.h>

// Not a perfect cover, since anything that's doing [self blah] will be using itself
// and bypassing our cover, so this is mainly for catching things being sent to the
// recognizer from outside the class.

@class UIGestureRecognizer;

@protocol BWGestureWrapperDelegate;


@interface BWGestureWrapper : NSProxy

@property (nonatomic, readonly) UIGestureRecognizer *recognizer;
@property (nonatomic, weak) id <BWGestureWrapperDelegate> delegate;

+ (id) wrapperWithGestureRecognizer: (UIGestureRecognizer *) recognizer;

@end // BWGestureWrapper


@protocol BWGestureWrapperDelegate <NSObject>

- (void) wrapperStartedTracking: (BWGestureWrapper *) wrapper;
- (void) wrapperStoppedTracking: (BWGestureWrapper *) wrapper;

@end // BWGestureWrapperDelegate

