#import "BWTouchTrackView.h"

#import "NSObject+AddressValue.h"
#import "UIColor+AddressColor.h"

typedef enum : NSInteger {
    kStateReadyToTrack,
    kStateTracking
} TrackingState;

static const CGFloat kPromptTextSize = 36.0;
static const CGFloat kTrackLineWidth = 5.0;

// How long to wait before returning to ready-to-track state.
static const CGFloat kLastTouchTimeout = 2.0;

static UIColor *kTrackingBackgroundColor;


@interface BWTouchTrackView () {
    TrackingState _state;
    NSMutableSet *_touchesInFlight;    // keyed by touch address wrapped in NSValue
    NSMutableDictionary *_touchTracks; // keyed by touch address wrapped in NSValue
}

@end // extension



@interface BWTouchThing : NSObject
@property (nonatomic, strong) UITouch *touch;
@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, assign) UITouchPhase phase;
@property (nonatomic, assign) CGPoint locationInView;

+ (id) thingFromUITouch: (UITouch *) touch;

@end // BWTouchThing



@implementation BWTouchTrackView

- (UIColor *) trackingBackgroundColor {
    if (kTrackingBackgroundColor == nil) {
        kTrackingBackgroundColor = [UIColor colorWithRed: 0.919607843184834778188281772
                                            green: 0.976862745128818388273781738
                                            blue: 1.0
                                            alpha: 1.0];

    }

    return kTrackingBackgroundColor;

} // trackingBackgroundColor


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


- (void) setState: (TrackingState) state {
    if (_state != state) {
        _state = state;
        [self setNeedsDisplay];
    }
} // setState


// Triggered by performSelector/after delay
- (void) finishedTracking {
    NSLog (@"GRONK!");
    [self setState: kStateReadyToTrack];
} // finishedTracking


- (void) drawBackground: (CGRect) rect {
    if (_state == kStateReadyToTrack) {
        [[UIColor whiteColor] set];
    } else {
        [[self trackingBackgroundColor] set];
    }

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


- (void) drawTracks {
    // Keys are the nsvalue-wrapped UITouch, the value is a mutable array of Things.

    [_touchTracks enumerateKeysAndObjectsUsingBlock: ^(id key, id value, BOOL *stop) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            for (BWTouchThing *thing in value) {
                switch (thing.phase) {
                case UITouchPhaseBegan:
                    [path moveToPoint: thing.locationInView];
                    break;

                case UITouchPhaseStationary:
                case UITouchPhaseMoved:
                case UITouchPhaseEnded:
                case UITouchPhaseCancelled:
                    [path addLineToPoint: thing.locationInView];
                    break;
                }
            }

            UIColor *color = [UIColor bwColorWithAddress: key];
            if (![_touchesInFlight containsObject: key]) {
                color = [UIColor colorWithWhite: 0.95  alpha: 1.0];
            }
            [color set];

            path.lineWidth = kTrackLineWidth;
            path.lineJoinStyle = kCGLineJoinRound;
            path.lineCapStyle = kCGLineCapRound;
            [path stroke];
        }];

} // drawTracks


- (void) drawFrame: (CGRect) rect {
    [[UIColor blackColor] set];
    UIRectFrame (rect);
} // drawFrame


- (void) drawRect: (CGRect) rect {

    CGRect bounds = self.bounds;

    [self drawBackground: bounds];
    [self drawPromptTextInRect: bounds];

    [self drawTracks];
    [self drawFrame: bounds];

} // drawRect

// --------------------------------------------------

- (void) startTrackingTouch: (UITouch *) touch {
    NSValue *touchAddress = touch.bwAddressValue;

    [_touchesInFlight addObject: touch.bwAddressValue];

    // Add a tracking array if not already there.
    NSMutableArray *track = [_touchTracks objectForKey: touchAddress];
    
    if (track) {
        NSLog (@"RECYCLING?");
    } else {
        track = [NSMutableArray array];
        [_touchTracks setObject: track  forKey: touchAddress];
    }

} // startTrackingTouch


- (void) stopTrackingTouch: (UITouch *) touch {
    [_touchesInFlight removeObject: touch.bwAddressValue];

    if (_touchesInFlight.count == 0) {
        [self setNeedsDisplay];

        [self performSelector:@selector(finishedTracking)
              withObject: nil
              afterDelay: kLastTouchTimeout];
    }
} // stopTrackingTouch


- (void) trackTouch: (UITouch *) touch {
    NSValue *touchAddress = touch.bwAddressValue;
    NSMutableArray *track = [_touchTracks objectForKey: touchAddress];
    assert (track);

    BWTouchThing *thing = [BWTouchThing thingFromUITouch: touch];
    [track addObject: thing];

    [self setNeedsDisplay];

    // Have more touches come in since we saw the last touch sequence end?
    [NSObject cancelPreviousPerformRequestsWithTarget: self
              selector: @selector(finishedTracking)
              object: nil];

} // trackTouch


- (void) touchesBegan: (NSSet *) touches  withEvent: (UIEvent *) event {
    if (_state == kStateReadyToTrack) {
        [_touchesInFlight removeAllObjects];
        [_touchTracks removeAllObjects];

        [self setState: kStateTracking];
    }

    for (UITouch *touch in touches) {
        [self startTrackingTouch: touch];
        [self trackTouch: touch];
    }

} // touchesBegan


- (void) touchesMoved: (NSSet *) touches  withEvent: (UIEvent *) event {
    for (UITouch *touch in touches) {
        [self trackTouch: touch];
    }
} // touchesMoved


- (void) touchesEnded: (NSSet *) touches  withEvent: (UIEvent *) event {
    for (UITouch *touch in touches) {
        [self trackTouch: touch];
        [self stopTrackingTouch: touch];
    }

} // touchesEnded


- (void) touchesCancelled: (NSSet *) touches  withEvent: (UIEvent *) event {
    for (UITouch *touch in touches) {
        [self trackTouch: touch];
        [self stopTrackingTouch: touch];
    }
} // touchesCancelled

@end // BWTouchView


@implementation BWTouchThing

- (id) initWithTouch: (UITouch *) touch {
    if ((self = [super init])) {
        _touch = touch;
        _timestamp = touch.timestamp;
        _phase = touch.phase;
        _locationInView = [touch locationInView: touch.view];
    }

    return self;

} // initWithTouch


+ (id) thingFromUITouch: (UITouch *) touch {
    return [[self alloc] initWithTouch: touch];
} // thingFromUITouch


- (NSString *) description {
    static const char *phases[] = {
        "began", "moved", "stationary", "ended", "cancelled"
    };

    NSString *desc = 
        [NSString stringWithFormat: @"(%f (%s): %@)",
                  self.timestamp, phases[self.phase],
                  NSStringFromCGPoint(self.locationInView)];
    return desc;

} // description

@end // BWTouchThing
