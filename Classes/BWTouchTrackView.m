#import "BWTouchTrackView.h"

#import "NSObject+AddressValue.h"

typedef enum : NSInteger {
    kStateReadyToTrack,
    kStateTracking
} TrackingState;

static const CGFloat kPromptTextSize = 36.0;


@interface BWTouchTrackView () {
    TrackingState _state;
    NSMutableSet *_touchesInFlight;    // keyed by touch address wrapped in NSValue
    NSMutableDictionary *_touchTracks; // keyed by touch address wrapped in NSValue
}

@end // extension


@implementation BWTouchTrackView

- (void) commonInit {
    self.userInteractionEnabled = YES;
    self.multipleTouchEnabled = YES;
    _state = kStateReadyToTrack;

    _touchesInFlight = [NSMutableSet set];
    _touchTracks = [NSMutableDictionary dictionary];
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
    if (_state == kStateReadyToTrack) {
        [_touchesInFlight removeAllObjects];
        [_touchTracks removeAllObjects];

        _state = kStateTracking;
    }

    for (UITouch *touch in touches) {
        [_touchesInFlight addObject: touch.bwAddressValue];
        NSLog (@"IN FLIGHT %@", _touchesInFlight);
    }

} // touchesBegan


- (void) touchesMoved: (NSSet *) touches  withEvent: (UIEvent *) event {

} // touchesMoved


- (void) touchesEnded: (NSSet *) touches  withEvent: (UIEvent *) event {
    for (UITouch *touch in touches) {
        [_touchesInFlight removeObject: touch.bwAddressValue];
        NSLog (@"IN FLIGHT %@", _touchesInFlight);
    }

} // touchesEnded


- (void) touchesCancelled: (NSSet *) touches  withEvent: (UIEvent *) event {
    for (UITouch *touch in touches) {
        [_touchesInFlight removeObject: touch.bwAddressValue];
        NSLog (@"IN FLIGHT %@", _touchesInFlight);
    }

} // touchesCancelled

@end // BWTouchView


