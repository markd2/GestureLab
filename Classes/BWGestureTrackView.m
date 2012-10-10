#import "BWGestureTrackView.h"

#import "QuietLog.h"

#import "UIColor+AddressColor.h"

@interface BWGestureTrackView () {
    BOOL _recording;
    NSTimeInterval _startTimestamp;

    NSMutableArray *_recognizers;
    NSMutableSet *_recognizersInFlight;
    NSMutableDictionary *_recordedActions;
}

@end // extension

static const CGFloat kRecognizerHeight = 30.0;
static const CGFloat kLabelTextSize = 15.0; 

// How long to wait before returning to ready-to-track state.
static const CGFloat kLastTouchTimeout = 1.0;

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

        if (   state == UIGestureRecognizerStateEnded // a.k. recognized
            || state == UIGestureRecognizerStateFailed) {

            [_recognizersInFlight removeObject: object];

            if (_recognizersInFlight.count == 0) {
                [self performSelector: @selector(notifyDelegateAllDone)
                      withObject: nil
                      afterDelay: kLastTouchTimeout];
            }

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


- (void) recordState: (UIGestureRecognizerState) state
       forRecognizer: (UIGestureRecognizer *) recognizer {

    static const char *g_stateNames[] = {
        "possible",
        "began",
        "changed",
        "recognized / ended",
        "cancelled",
        "failed"
    };

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
                            lineBreakMode: UILineBreakModeWordWrap];
    
    CGRect textRect = CGRectMake (CGRectGetMidX(rect) - textSize.width / 2.0,
                                  CGRectGetMidY(rect) - textSize.height / 2.0,
                                  textSize.width, textSize.height);

    [[UIColor whiteColor] set];

    if ([text hasSuffix: @"GestureRecognizer"]) {
        text = [text substringToIndex: text.length - @"GestureRecognizer".length];
    }

    [text drawInRect: textRect
            withFont: font
            lineBreakMode: UILineBreakModeWordWrap
            alignment: UITextAlignmentCenter];

} // drawText


- (void) drawRecognizersInRect: (CGRect) rect {
    CGRect recognizerRect = CGRectMake (rect.origin.x, rect.origin.y,
                                        rect.size.width, kRecognizerHeight);

    for (UIGestureRecognizer *recognizer in _recognizers) {
        recognizerRect.origin.y += kRecognizerHeight;
        UIColor *color = [UIColor bwColorWithAddress: recognizer];
        [color set];
        UIRectFill (recognizerRect);

        [self drawText: [[recognizer class] description]
              inRect: recognizerRect];
    }

} // drawRecognizersInRect


- (void) drawRect: (CGRect) rect {
    CGRect bounds = self.bounds;

    [self drawBackground: bounds];
    [self drawRecognizersInRect: rect];
    [self drawFrame: bounds];

} // drawRect


@end // BWGestureTrackView

