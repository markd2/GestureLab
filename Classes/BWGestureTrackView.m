#import "BWGestureTrackView.h"

#import "QuietLog.h"

#import "NSObject+AddressValue.h"
#import "UIColor+AddressColor.h"


static const CGFloat kRecognizerHeight = 30.0;
static const CGFloat kLabelWidth = 200;
static const CGFloat kLabelTextSize = 15.0; 

// How long to wait before returning to ready-to-track state.
static const CGFloat kLastTouchTimeout = 1.0;


@interface BWGestureTrackView () {
    BOOL _recording;
    NSTimeInterval _startTimestamp;

    NSMutableArray *_recognizers;
    NSMutableSet *_recognizersInFlight;
    NSMutableDictionary *_recordedActions;
}

@end // extension

@interface BWGestureThing : NSObject
@property (nonatomic, strong) UIGestureRecognizer *recognizer;
@property (nonatomic, assign) UIGestureRecognizerState state;
@property (nonatomic, assign) NSTimeInterval timestamp;  // absolute time

+ (id) thingFromGesture: (UIGestureRecognizer *) gesture
                  state: (UIGestureRecognizerState) state;

@end // BWGestureThing


@implementation BWGestureTrackView


- (void) commonInit {
    _recognizers = [NSMutableArray array];
    _recognizersInFlight = [NSMutableSet set];
    _recordedActions = [NSMutableDictionary dictionary];
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


- (void) setCurrentTime: (NSTimeInterval) currentTime {
    _currentTime = MIN (currentTime, self.totalDuration);
    [self setNeedsDisplay];
} // setCurrentTime


- (void) removeAllRecognizers {
    [_recognizers removeAllObjects];
} // removeAllRecognizers


- (void) trackGestureRecognizer: (UIGestureRecognizer *) gestureRecognizer {
    [_recognizers addObject: gestureRecognizer];
    [self startWatchingRecognizer: gestureRecognizer];
    [self setNeedsDisplay];

} // trackGestureRecognizer


- (void) startWatchingRecognizer: (UIGestureRecognizer *) recognizer {
    [recognizer addObserver: self
                forKeyPath: @"state"
                options: NSKeyValueObservingOptionNew
                context: (__bridge void *) self];
    
} // startWatching


- (void) stopWatchingRecognizer: (UIGestureRecognizer *) recognizer {
    [recognizer removeObserver: self
                forKeyPath: @"state"
                context: (__bridge void *) self];

} // stopWatchingRecognizer


- (void) notifyDelegateAllDone {
    [self.delegate trackViewCompletedLastRecognizer: self];
    QuietLog (@"HOOVER %@", _recordedActions);
} // notifyDelegateAllDone


- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object 
                         change: (NSDictionary *) change 
                        context: (void *) context {

    if (context == (__bridge void *)self
        && [keyPath isEqualToString: @"state"]) {

        NSNumber *stateNumber = change[@"new"];
        UIGestureRecognizerState state = stateNumber.integerValue;

        [self recordState: state  forRecognizer: object];

        if (   state == UIGestureRecognizerStateEnded // a.k.a. recognized
            || state == UIGestureRecognizerStateFailed
            || state == UIGestureRecognizerStateCancelled) {

            [_recognizersInFlight removeObject: object];

            if (_recognizersInFlight.count == 0) {
                [self performSelector: @selector(notifyDelegateAllDone)
                      withObject: nil
                      afterDelay: kLastTouchTimeout];
            }

            // The reset to possible state isn't being done in a KVOable manner,
            // so assume it returns to possible when reaching a terminal state.
            [self recordState: UIGestureRecognizerStatePossible
                  forRecognizer: object];


        } else {
            // It's possible for a recognizer to go from done to back alive
            // during a logical gesture event recording session, so add in-flights
            // back in.
            [_recognizersInFlight addObject: object];
            [NSObject cancelPreviousPerformRequestsWithTarget: self
                      selector: @selector(notifyDelegateAllDone)
                      object: nil];
        }

    } else {
        [super observeValueForKeyPath: keyPath
               ofObject: object
               change: change
               context: context];
    }
} // observeValueForKeyPath


static const char *g_stateNames[] = {
    "possible",
    "began",
    "changed",
    "recognized / ended",
    "cancelled",
    "failed"
};

- (void) recordState: (UIGestureRecognizerState) state
       forRecognizer: (UIGestureRecognizer *) recognizer {

    NSValue *key = recognizer.bwAddressValue;
    NSMutableArray *track = [_recordedActions objectForKey: key];

    if (track == nil) {
        track = [NSMutableArray array];
        [_recordedActions setObject: track  forKey: key];
    }
    
    BWGestureThing *thing = [BWGestureThing thingFromGesture: recognizer
                                            state: state];
    [track addObject: thing];

    QuietLog (@"%@ -> %s", [recognizer class], g_stateNames[state]);

} // recordState


- (void) startRecording {
    [_recognizersInFlight removeAllObjects];
    [_recordedActions removeAllObjects];

    _recording = YES;
    _startTimestamp = [NSDate timeIntervalSinceReferenceDate];

    for (UIGestureRecognizer *recognizer in _recognizers) {
        [_recognizersInFlight addObject: recognizer];
        [self recordState: UIGestureRecognizerStatePossible
              forRecognizer: recognizer];
    }

} // startRecording


- (void) stopRecording {
    _recording = YES;
} // stopRecording


// --------------------------------------------------

- (void) drawBackground: (CGRect) rect {
    [[UIColor whiteColor] set];
    UIRectFill (rect);
} // drawBackground


- (void) drawFrame: (CGRect) rect {
    [[UIColor blackColor] set];
    UIRectFrame (rect);
} // drawFrame


- (void) drawText: (NSString *) text
           inRect: (CGRect) rect {
    UIFont *font = [UIFont boldSystemFontOfSize: kLabelTextSize];

    CGSize textSize = [text sizeWithFont: font
                            constrainedToSize: rect.size
                            lineBreakMode: UILineBreakModeTailTruncation];
    
    CGRect textRect = CGRectMake (CGRectGetMidX(rect) - textSize.width / 2.0,
                                  CGRectGetMidY(rect) - textSize.height / 2.0,
                                  textSize.width, textSize.height);

    [[UIColor whiteColor] set];

    if ([text hasSuffix: @"GestureRecognizer"]) {
        text = [text substringToIndex: text.length - @"GestureRecognizer".length];
    }

    [text drawInRect: textRect
            withFont: font
            lineBreakMode: UILineBreakModeTailTruncation
            alignment: UITextAlignmentCenter];

} // drawText


- (void) drawRecognizersInRect: (CGRect) rect {
    CGRect recognizerRect = CGRectMake (rect.origin.x, rect.origin.y,
                                        rect.size.width, kRecognizerHeight);

    for (UIGestureRecognizer *recognizer in _recognizers) {
        UIColor *color = [UIColor bwColorWithAddress: recognizer];
        [color set];
        UIRectFill (recognizerRect);

        CGRect labelRect = recognizerRect;
        labelRect.size.width = kLabelWidth;
        [self drawText: [[recognizer class] description]
              inRect: labelRect];

        recognizerRect.origin.y += kRecognizerHeight;
    }

    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(rect.origin.x + kLabelWidth, rect.origin.y)];
    [bezierPath addLineToPoint: CGPointMake(rect.origin.x + kLabelWidth,
                                            kRecognizerHeight * _recognizers.count)];
    [[UIColor blackColor] set];
    [bezierPath stroke];

} // drawRecognizersInRect


- (void) drawRect: (CGRect) rect {
    CGRect bounds = self.bounds;

    [self drawBackground: bounds];
    [self drawRecognizersInRect: rect];
    [self drawFrame: bounds];

} // drawRect


@end // BWGestureTrackView


@implementation BWGestureThing

- (id) initWithGesture: (UIGestureRecognizer *) recognizer
                 state: (UIGestureRecognizerState) state {

    if ((self = [super init])) {
        _recognizer = recognizer;
        _state = state;
        _timestamp = [NSDate timeIntervalSinceReferenceDate];
    }

    return self;

} // initWithGesture


+ (id) thingFromGesture: (UIGestureRecognizer *) recognizer
                  state: (UIGestureRecognizerState) state {
    return [[self alloc] initWithGesture: recognizer
                         state: state];
} // thingFromGesture


- (NSString *) description {
    NSString *description =
        [NSString stringWithFormat: @"(%f %@ -> %s)",
                  self.timestamp, self.recognizer, g_stateNames[self.state]];
    return description;

} // description

@end // BWGestureThing
