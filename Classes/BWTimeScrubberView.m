#import "BWTimeScrubberView.h"


@implementation BWTimeScrubberView

- (void) drawRect: (CGRect) rect {
    CGRect bounds = self.bounds;

    UIColor *color = [UIColor colorWithRed: (((int)self >> 0) & 0xFF) / 255.0
                              green: (((int)self >> 8) & 0xFF) / 255.0
                              blue: (((int)self >> 16) & 0xFF) / 255.0
                              alpha: 1.0];
    [color set];
    UIRectFill(bounds);

    [[UIColor blackColor] set];
    UIRectFrame(bounds);
} // drawRect


// --------------------------------------------------

- (void) scrubToTouch: (UITouch *) touch {
    CGPoint location = [touch locationInView: touch.view];
    CGRect bounds = self.bounds;

    CGFloat relativePosition = location.x - bounds.origin.x;
    CGFloat percentageAcross = relativePosition / bounds.size.width;

    [self.delegate timeScrubber: self  scrubbedToTime: percentageAcross];

} // scrubToTouch


- (void) touchesBegan: (NSSet *) touches  withEvent: (UIEvent *) event {
    UITouch *touch = [touches anyObject];
    [self scrubToTouch: touch];
    
} // touchesBegan


- (void) touchesMoved: (NSSet *) touches  withEvent: (UIEvent *) event {
    UITouch *touch = [touches anyObject];
    [self scrubToTouch: touch];

} // touchesMoved


- (void) touchesEnded: (NSSet *) touches  withEvent: (UIEvent *) event {
} // touchesEnded


- (void) touchesCancelled: (NSSet *) touches  withEvent: (UIEvent *) event {
} // touchesCancelled


@end // BWTimeScrubberView
