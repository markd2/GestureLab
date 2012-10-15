#import "BWGestureTrackView.h"

#import "QuietLog.h"

#import "NSObject+AddressValue.h"
#import "UIColor+AddressColor.h"


static const CGFloat kRecognizerHeight = 30.0;
static const CGFloat kLabelWidth = 200;
static const CGFloat kLabelTextSize = 15.0; 
static const CGFloat kActionChevronSize = 6.0;

// Synthetic states for the recognizer tracking
enum {
    kActionTriggered = UIGestureRecognizerStateFailed + 2000
};


// http://www.colorpicker.com
static CGFloat g_trackBackgrounds[][3] = {
    { 222.0, 238.0, 255.0 }, // light blue
    { 235.0, 255.0, 222.0 }, // light green
    { 255.0, 222.0, 251.0 }, // light pink
    { 250.0, 246.0, 182.0 }, // yellowish
    { 222.0, 222.0, 255.0 }, // blueish
    { 255.0, 222.0, 222.0 }, // redorangish
};


static const char *g_stateNames[] = {
    "possible",
    "began",
    "changed",
    "recognized / ended",
    "cancelled",
    "failed"
};

static const char *g_stateInitials[] = {
    "P",
    "B",
    "C",
    "R",
    "X",
    "F"
};


// How long to wait before returning to ready-to-track state.
static const CGFloat kLastTouchTimeout = 1.0;


@interface BWGestureTrackView () {
    BOOL _recording;
    NSTimeInterval _startTimestamp;

    NSMutableArray *_recognizers;
    NSMutableDictionary *_recordedActions;
}

@end // extension

@interface BWGestureThing : NSObject
@property (nonatomic, strong) UIGestureRecognizer *recognizer;
@property (nonatomic, assign) UIGestureRecognizerState state;
@property (nonatomic, assign) NSTimeInterval timestamp;  // absolute time

+ (id) thingFromGesture: (UIGestureRecognizer *) gesture
                  state: (int) state;

@end // BWGestureThing


@implementation BWGestureTrackView


- (void) commonInit {
    _recognizers = [NSMutableArray array];
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
            // The reset to possible state isn't being done in a KVOable manner,
            // so assume it returns to possible when reaching a terminal state.
            [self recordState: UIGestureRecognizerStatePossible
                  forRecognizer: object];
        }

    } else {
        [super observeValueForKeyPath: keyPath
               ofObject: object
               change: change
               context: context];
    }
} // observeValueForKeyPath


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

} // recordState


- (void) startRecording {
    [_recordedActions removeAllObjects];

    _recording = YES;
    _startTimestamp = [NSDate timeIntervalSinceReferenceDate];

    for (UIGestureRecognizer *recognizer in _recognizers) {
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

    [[UIColor blackColor] set];

    if ([text hasSuffix: @"GestureRecognizer"]) {
        text = [text substringToIndex: text.length - @"GestureRecognizer".length];
    }

    [text drawInRect: textRect
            withFont: font
            lineBreakMode: UILineBreakModeTailTruncation
            alignment: UITextAlignmentCenter];

} // drawText


- (void) drawRecognizer: (UIGestureRecognizer *) recognizer
                 inRect: (CGRect) rect {
    NSValue *key = recognizer.bwAddressValue;

    NSArray *track = [_recordedActions objectForKey: key];
    if (track == nil) return; // nothing recorded for this recognizer yet.

    CGFloat pointsPerSecond = rect.size.width / self.totalDuration;

    // Render all the various states
    for (BWGestureThing *thing in track) {
        if (thing.state == kActionTriggered) continue;

        NSTimeInterval adjustedTimestamp = thing.timestamp - _startTimestamp;
        CGFloat xPosition = rect.origin.x + adjustedTimestamp * pointsPerSecond;

        CGRect labelRect = CGRectMake (xPosition - kLabelTextSize, rect.origin.y,
                                       kLabelTextSize * 2, rect.size.height);
        NSString *initial = [NSString stringWithFormat: @"%s",
                                      g_stateInitials[thing.state]];
        [self drawText: initial  inRect: labelRect];

        [[UIColor redColor] set];
        UIRectFrame (labelRect);
    }

    // Draw the action triggers
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];

    [[UIColor grayColor] set];
    for (BWGestureThing *thing in track) {
        if (thing.state != kActionTriggered) continue;

        [bezierPath removeAllPoints];

        NSTimeInterval adjustedTimestamp = thing.timestamp - _startTimestamp;
        CGFloat xPosition = rect.origin.x + adjustedTimestamp * pointsPerSecond;
        CGFloat yBottom = rect.origin.y + rect.size.height;

        // Make a little chevron thing
        [bezierPath moveToPoint: CGPointMake (xPosition - kActionChevronSize / 2.0,
                                              yBottom)];
        [bezierPath addLineToPoint: CGPointMake (xPosition, 
                                                 yBottom - kActionChevronSize)];
        [bezierPath addLineToPoint: CGPointMake (xPosition + kActionChevronSize / 2.0,
                                                 yBottom)];
        [bezierPath stroke];
    }
    
} // drawRecognizer


- (UIColor *) colorForIndex: (NSUInteger) index {
    // TODO(markd): try not to be stupily expensive.
    if (index >= sizeof(g_trackBackgrounds) / sizeof(*g_trackBackgrounds)) {
        assert (!"oops, out of range");
    }
    UIColor *color = [UIColor colorWithRed: g_trackBackgrounds[index][0] / 255.0
                              green: g_trackBackgrounds[index][1] / 255.0
                              blue: g_trackBackgrounds[index][0] / 255.0
                              alpha: 1.0];
    return color;

} // colorForIndex


- (void) drawRecognizersInRect: (CGRect) rect {
    CGRect recognizerRect = CGRectMake (rect.origin.x, rect.origin.y,
                                        rect.size.width, kRecognizerHeight);

    for (UIGestureRecognizer *recognizer in _recognizers) {
        NSUInteger index = [_recognizers indexOfObject: recognizer];
        UIColor *color = [self colorForIndex: index];
        [color set];
        UIRectFill (recognizerRect);

        CGRect labelRect = recognizerRect;
        labelRect.size.width = kLabelWidth;
        [self drawText: [[recognizer class] description]
              inRect: labelRect];

        CGRect contentsRect = recognizerRect;
        contentsRect.size.width -= kLabelWidth;
        contentsRect.origin.x += kLabelWidth;
        [self drawRecognizer: recognizer  inRect: contentsRect];

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


- (void) recordActionForGestureRecognizer: (UIGestureRecognizer *) gestureRecognizer {
    [self recordState: kActionTriggered
          forRecognizer: gestureRecognizer];
} // recordActionForGestureRecognizer


@end // BWGestureTrackView


@implementation BWGestureThing

- (id) initWithGesture: (UIGestureRecognizer *) recognizer
                 state: (int) state {

    if ((self = [super init])) {
        _recognizer = recognizer;
        _state = state;
        _timestamp = [NSDate timeIntervalSinceReferenceDate];
    }

    return self;

} // initWithGesture


+ (id) thingFromGesture: (UIGestureRecognizer *) recognizer
                  state: (int) state {
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
