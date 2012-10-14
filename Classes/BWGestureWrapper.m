#import "BWGestureWrapper.h"

// TODO(markd): see why the pinch gesture recognizer is not cooperating.

#import <UIKit/UIGestureRecognizerSubclass.h>

#import "QuietLog.h"

@interface BWGestureWrapper () {
    NSMutableSet *_touchesInFlight;
}

@end // BWGestureWrapper


@implementation BWGestureWrapper

- (id) initWithGestureRecognizer: (UIGestureRecognizer *) recognizer {
    _recognizer = recognizer;
    _touchesInFlight = [NSMutableSet set];

    return self;

} // initWithGestureRecognizer


+ (id) wrapperWithGestureRecognizer: (UIGestureRecognizer *) recognizer {
    return [[self alloc] initWithGestureRecognizer: recognizer];
} // wrapperWithGestureRecognizer


- (Class) class {
    return self.recognizer.class;
} // class


- (void) forwardInvocation: (NSInvocation *) invocation {
    if ([self.recognizer respondsToSelector: invocation.selector]) {
        [invocation invokeWithTarget: self.recognizer];
    } else {
        [super forwardInvocation: invocation];
    }

} // forwardInvocation


- (NSMethodSignature *) methodSignatureForSelector: (SEL) sel {
    return [self.recognizer methodSignatureForSelector: sel];
} // methodSignatureForSelector


// --------------------------------------------------
// Spies


- (void) trackTouches: (NSSet *) touches {
    if (_touchesInFlight.count == 0) {
        // Moving from not-tracking to tracking.
        [self.delegate wrapperStartedTracking: self];
    }

    [_touchesInFlight unionSet: touches];

} // trackTouches


- (void) untrackTouches: (NSSet *) touches {
    [_touchesInFlight minusSet: touches];
    if (_touchesInFlight.count == 0) {
        QuietLog (@"-= DONE?!? =-");
        [self.delegate wrapperStoppedTracking: self];
    }
} // untrackTouches.  Wow, that's a terrible name.


- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
    QuietLog (@"BEGAN");
    [self trackTouches: touches];
    [self.recognizer touchesBegan: touches  withEvent:event];
} // touchesBegan


- (void) touchesEnded: (NSSet *) touches
            withEvent: (UIEvent *) event {
    QuietLog (@"ENDED");
    [self untrackTouches: touches];
    [self.recognizer touchesEnded: touches  withEvent:event];
} // touchesEnded

- (void) touchesCancelled: (NSSet *) touches
                withEvent: (UIEvent *) event {
    QuietLog (@"CANCELLED");
    [self untrackTouches: touches];
    [self.recognizer touchesCancelled: touches  withEvent:event];
} // touchesCancelled


@end // BWGestureWrapper
