#import "BWGestureTrackView.h"

#import "QuietLog.h"

@interface BWGestureTrackView () {
    NSMutableArray *_recognizers;
}

@end // extension

@implementation BWGestureTrackView


- (void) commonInit {
    _recognizers = [NSMutableArray array];
} // commonInit


- (id) initWithFrame: (CGRect) frame {
    if ((self = [super initWithFrame: frame])) {
        [self commonInit];
    }

    return self;

} // initWithFrame


- (id) initWithCoder: (NSCoder *) decoder {
    if ((self = [super initWithCoder: decoder])) {
        [self commonInit];
    }

    return self;

} // initWithCoder


- (void) addGestureRecognizer: (UIGestureRecognizer *) gestureRecognizer {
    [_recognizers addObject: gestureRecognizer];
    [self setNeedsDisplay];

} // addGestureRecognizer


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


@end // BWGestureTrackView

