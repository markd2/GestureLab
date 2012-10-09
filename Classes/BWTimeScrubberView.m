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


@end // BWTimeScrubberView
