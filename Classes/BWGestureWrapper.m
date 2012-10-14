#import "BWGestureWrapper.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation BWGestureWrapper

- (id) initWithGestureRecognizer: (UIGestureRecognizer *) recognizer {
    _recognizer = recognizer;

    return self;

} // initWithGestureRecognizer


+ (id) wrapperWithGestureRecognizer: (UIGestureRecognizer *) recognizer {
    return [[self alloc] initWithGestureRecognizer: recognizer];
} // wrapperWithGestureRecognizer


- (void) forwardInvocation: (NSInvocation *) invocation {
    NSLog (@"forwarding %s", (char *)invocation.selector);
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

- (void) setState: (UIGestureRecognizerState) state {
    // not getting called.
    NSLog (@"STATE IS %d", state);
    [self.recognizer setState: state];

} // setState


- (void) reset {
    // not getting called.
    NSLog (@"RESET");
    [self.recognizer reset];
} // reset


- (void) touchesEnded: (NSSet *) touches
            withEvent: (UIEvent *) event {
    NSLog (@"ENDED");
    [self.recognizer touchesEnded: touches  withEvent:event];
} // touchesEnded

- (void) touchesCancelled: (NSSet *) touches
                withEvent: (UIEvent *) event {
    NSLog (@"CANCELLED");
    [self.recognizer touchesCancelled: touches  withEvent:event];
} // touchesCancelled


@end // BWGestureWrapper
