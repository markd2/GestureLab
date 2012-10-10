#import "BWTouchTrackView.h"

#import "NSObject+AddressValue.h"
#import "UIColor+AddressColor.h"

#import "QuietLog.h"

typedef enum : NSInteger {
    kStateReadyToTrack,
    kStateTracking,
    kStateScrolledDrawback
} TrackingState;

static const BOOL kLogTouchActivity = YES;  // Sometimes can be too chatty.

static const CGFloat kPromptTextSize = 36.0;
static const CGFloat kTrackLineWidth = 5.0;

// How long to wait before returning to ready-to-track state.
static const CGFloat kLastTouchTimeout = 1.0;

static UIColor *kTrackingBackgroundColor;


@interface BWTouchTrackView () {
    TrackingState _state;
    NSMutableSet *_touchesInFlight;    // keyed by touch address wrapped in NSValue
    NSMutableDictionary *_touchTracks; // keyed by touch address wrapped in NSValue
    NSTimeInterval _drawTimestamp;
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


- (void) drawUpToTimestamp: (NSTimeInterval) timestamp {
    _drawTimestamp = timestamp;
    [self setState: kStateScrolledDrawback];
    [self setNeedsDisplay];
} // drawUpToTimestamp


- (void) setState: (TrackingState) state {
    if (_state != state) {
        _state = state;
        [self setNeedsDisplay];
    }
} // setState


// Triggered by performSelector/after delay
- (void) finishedTracking {
    [self setState: kStateReadyToTrack];
    [self.delegate touchTrackEndedTracking: self];
} // finishedTracking


- (NSTimeInterval) trackingDuration {
    return self.endTimestamp - self.startTimestamp;
} // trackingDuration


- (void) drawBackground: (CGRect) rect {
    if (_state == kStateReadyToTrack || _state == kStateScrolledDrawback) {
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


- (void) drawTracksUntilTime: (NSTimeInterval) timestamp {
    NSTimeInterval adjustedTimestamp = self.startTimestamp + timestamp;

    [_touchTracks enumerateKeysAndObjectsUsingBlock: ^(id key, id value, BOOL *stop) {
            UIBezierPath *path = [UIBezierPath bezierPath];
            path.lineWidth = kTrackLineWidth;
            path.lineJoinStyle = kCGLineJoinRound;
            path.lineCapStyle = kCGLineCapRound;

            for (BWTouchThing *thing in value) {
                if (thing.timestamp > adjustedTimestamp) break;

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
            [color set];

            [path stroke];
        }];

} // drawTracksUntilTime


- (void) drawActiveTracks {
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

} // drawActiveTracks


- (void) drawFrame: (CGRect) rect {
    [[UIColor blackColor] set];
    UIRectFrame (rect);
} // drawFrame


- (void) drawRect: (CGRect) rect {

    CGRect bounds = self.bounds;

    [self drawBackground: bounds];

    [self drawPromptTextInRect: bounds];

    if (_state == kStateReadyToTrack || _state == kStateTracking) {
        [self drawActiveTracks];
    } else {
        [self drawTracksUntilTime: _drawTimestamp];
    }
    [self drawFrame: bounds];

} // drawRect

// --------------------------------------------------

- (void) startTrackingTouch: (UITouch *) touch {

    if (_state == kStateReadyToTrack || _state == kStateScrolledDrawback) {
        [_touchesInFlight removeAllObjects];
        [_touchTracks removeAllObjects];

        [self setState: kStateTracking];

        self.startTimestamp = touch.timestamp;
        self.endTimestamp = touch.timestamp;

        [self.delegate touchTrackBeganTracking: self];
    }

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

    if (touch.phase == UITouchPhaseCancelled) {
        // We got the cancelled prior/instead-of the began, which confuses our drawing.
        // So add a synthetic began
        BWTouchThing *thing = [BWTouchThing thingFromUITouch: touch];

        thing.phase = UITouchPhaseBegan;
        [track addObject: thing];
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
    self.endTimestamp = touch.timestamp;

    NSValue *touchAddress = touch.bwAddressValue;
    NSMutableArray *track = [_touchTracks objectForKey: touchAddress];
    if (!track) {
        // The recognizer has canceled this touch (probably) before we saw the
        // 'began'
        [self startTrackingTouch: touch];
        track = [_touchTracks objectForKey: touchAddress];
    }
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
    for (UITouch *touch in touches) {
        [self startTrackingTouch: touch];
        [self trackTouch: touch];
    }
    if (kLogTouchActivity) QuietLog (@"began");
} // touchesBegan


- (void) touchesMoved: (NSSet *) touches  withEvent: (UIEvent *) event {
    for (UITouch *touch in touches) {
        [self trackTouch: touch];
    }
    if (kLogTouchActivity) QuietLog (@"moved");
} // touchesMoved


- (void) touchesEnded: (NSSet *) touches  withEvent: (UIEvent *) event {
    for (UITouch *touch in touches) {
        [self trackTouch: touch];
        [self stopTrackingTouch: touch];
    }
    if (kLogTouchActivity) QuietLog (@"ended");
} // touchesEnded


- (void) touchesCancelled: (NSSet *) touches  withEvent: (UIEvent *) event {
    for (UITouch *touch in touches) {
        // Log them all without worrying about the track going away.
        [self trackTouch: touch];
    }

    if (kLogTouchActivity) QuietLog (@"cancelled");

    for (UITouch *touch in touches) {
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
