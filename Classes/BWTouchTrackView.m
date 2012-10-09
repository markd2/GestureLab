#import "BWTouchTrackView.h"

typedef enum : NSInteger {
    kStateReadyToTrack,
    kStateTracking
} TrackingState;

static const CGFloat kPromptTextSize = 36.0;


@interface BWTouchTrackView () {
    TrackingState _state;
}

@end // extension


@implementation BWTouchTrackView

- (void) commonInit {
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
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


- (void) drawBackground: (CGRect) rect {
    [[UIColor whiteColor] set];
    UIRectFill (rect);
} // drawBackground


- (void) drawPromptTextInRect: (CGRect) rect {
    UIFont *font = [UIFont boldSystemFontOfSize: kPromptTextSize];
    NSString *prompt = @"Gesture Here";

    CGSize textSize = [prompt sizeWithFont: font
                              constrainedToSize: rect.size
                              lineBreakMode: UILineBreakModeWordWrap];

    CGRect textRect = CGRectMake (CGRectGetMidX(rect) - textSize.width / 2.0,
                                  CGRectGetMidY(rect) - textSize.height / 2.0,
                                  textSize.width, textSize.height);

    [[UIColor lightGrayColor] set];

    [prompt drawInRect: textRect
            withFont: font
            lineBreakMode: UILineBreakModeWordWrap
            alignment: UITextAlignmentCenter];

} // drawPromptTextInRect


- (void) drawFrame: (CGRect) rect {
    [[UIColor blackColor] set];
    UIRectFrame (rect);
} // drawFrame


- (void) drawRect: (CGRect) rect {

    CGRect bounds = self.bounds;

    [self drawBackground: bounds];
    [self drawPromptTextInRect: bounds];
    [self drawFrame: bounds];

} // drawRect

// --------------------------------------------------

- (void) touchesBegan: (NSSet *) touches  withEvent: (UIEvent *) event {
    NSLog (@"BEGAN");
} // touchesBegan


- (void) touchesMoved: (NSSet *) touches  withEvent: (UIEvent *) event {
    NSLog (@"MOVED");

} // touchesMoved


- (void) touchesEnded: (NSSet *) touches  withEvent: (UIEvent *) event {
    NSLog (@"ENDED");
} // touchesEnded


- (void) touchesCancelled: (NSSet *) touches  withEvent: (UIEvent *) event {
    NSLog (@"Cancelled");

} // touchesCancelled

@end // BWTouchView

