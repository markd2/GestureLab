#import "BWTimeScrubberView.h"

static const CGFloat kTriangleBaseWidth = 30.0;

@implementation BWTimeScrubberView


- (void) setCurrentTime: (NSTimeInterval) currentTime {
    _currentTime = MIN (currentTime, self.totalDuration);
    [self setNeedsDisplay];
} // setCurrentTime


- (void) setMode: (BWTimeScrubberMode) mode {
    if (_mode != mode) {
        _mode = mode;
        [self setNeedsDisplay];
    }
} // setMode


- (void) drawPlayheadInRect: (CGRect) rect {
    CGFloat percentage = self.currentTime / self.totalDuration;
    CGFloat playheadPosition = rect.origin.x + rect.size.width * percentage;
    
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    [triangle moveToPoint: CGPointMake(playheadPosition - (kTriangleBaseWidth / 2.0),
                                       0.0)];
    [triangle addLineToPoint: CGPointMake (playheadPosition + (kTriangleBaseWidth / 2.0),
                                           0.0)];
    [triangle addLineToPoint: CGPointMake (playheadPosition, rect.size.height)];
    [triangle closePath];

    [[UIColor blackColor] set];
    [triangle fill];

} // drawPlayheadInRect


- (void) drawRect: (CGRect) rect {
    CGRect bounds = self.bounds;


    if (self.mode == kModeReadonly) {
        [[UIColor lightGrayColor] set];
    } else if (self.mode == kModeScrubbable) {
        [[UIColor whiteColor] set];
    }
    UIRectFill(bounds);

    if (self.mode == kModeScrubbable) {
        [self drawPlayheadInRect: bounds];
    }

    [[UIColor blackColor] set];
    UIRectFrame(bounds);
} // drawRect


// --------------------------------------------------

- (void) scrubToTouch: (UITouch *) touch {
    CGPoint location = [touch locationInView: touch.view];
    CGRect bounds = self.bounds;

    CGFloat relativePosition = location.x - bounds.origin.x;
    CGFloat percentageAcross = relativePosition / bounds.size.width;

    NSTimeInterval scrubbedTime = self.totalDuration * percentageAcross;

    [self setCurrentTime: scrubbedTime];
    [self.delegate timeScrubber: self  scrubbedToTime: scrubbedTime];

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
