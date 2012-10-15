#import "BWTimeScrubberView.h"

static const CGFloat kTriangleBaseWidth = 30.0;
static const CGFloat kTimeLabelTextSize = 12.0;

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
    [triangle addLineToPoint: CGPointMake (playheadPosition, rect.size.height / 2.0)];
    [triangle closePath];

    [[UIColor blackColor] set];
    [triangle fill];

} // drawPlayheadInRect


- (void) addTimeLabel: (CGFloat) time
               inRect: (CGRect) rect {
    NSString *label = [NSString stringWithFormat: @"%ds", (int)time];

    UIFont *font = [UIFont systemFontOfSize: kTimeLabelTextSize];

    CGSize textSize = [label sizeWithFont: font];
    CGFloat pointsPerSecond = rect.size.width / self.totalDuration;

    CGRect textRect = CGRectMake (time * pointsPerSecond - textSize.width,
                                  0.0,
                                  textSize.width, textSize.height);
    [label drawInRect: textRect
           withFont: font];
    
} // addTimeLabel


- (void) drawTimelineInRect: (CGRect) rect {
    CGFloat currentTime;
    CGFloat pointsPerSecond = rect.size.width / self.totalDuration;
    UIBezierPath *path = [UIBezierPath bezierPath];

    [[UIColor lightGrayColor] set];

    // draw little stubblies at 1/10th seconds
    currentTime = 0.1;
    [path removeAllPoints];
    while (currentTime < self.totalDuration) {
        [path moveToPoint: CGPointMake (currentTime * pointsPerSecond,
                                        rect.size.height / 1.25)];
        [path addLineToPoint: CGPointMake (currentTime * pointsPerSecond, 
                                           rect.size.height)];
        currentTime += 0.1;
    }
    [path stroke];

    // draw half-length ones at half seconds
    currentTime = 0.5;
    [path removeAllPoints];
    while (currentTime < self.totalDuration) {
        [path moveToPoint: CGPointMake (currentTime * pointsPerSecond,
                                        rect.size.height / 2.0)];
        [path addLineToPoint: CGPointMake (currentTime * pointsPerSecond, 
                                           rect.size.height)];
        currentTime += 1.0;
    }
    [path stroke];

    // Draw full-length ones at full seconds
    currentTime = 1.0;
    [[UIColor grayColor] set];
    [path removeAllPoints];
    while (currentTime <= self.totalDuration) {
        [path moveToPoint: CGPointMake (currentTime * pointsPerSecond, 0.0)];
        [path addLineToPoint: CGPointMake (currentTime * pointsPerSecond, 
                                           rect.size.height)];
        [self addTimeLabel: currentTime  inRect: rect];
        currentTime += 1.0;
    }
    [path stroke];

} // drawTimelineInRect


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
        [self drawTimelineInRect: bounds];
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
