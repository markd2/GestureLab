#import "BWGestureTrackView.h"

#import "QuietLog.h"

#import "UIColor+AddressColor.h"

@interface BWGestureTrackView () {
    NSMutableArray *_recognizers;
    BOOL _recording;
}

@end // extension

static const CGFloat kRecognizerHeight = 30.0;
static const CGFloat kLabelTextSize = 15.0; 

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


static const char *g_stateNames[] = {
    "possible",
    "began",
    "changed",
    "recognized / ended",
    "cancelled",
    "failed"
};


- (void) observeValueForKeyPath: (NSString *) keyPath
                       ofObject: (id) object 
                         change: (NSDictionary *) change 
                        context: (void *) context {

    if (context == (__bridge void *)self
        && [keyPath isEqualToString: @"state"]) {
        NSNumber *state = change[@"new"];
        QuietLog (@"Observed - %@'s state is %s", 
                  [object class],
                  g_stateNames[state.integerValue]);

    } else {
        [super observeValueForKeyPath: keyPath
               ofObject: object
               change: change
               context: context];
    }
} // observeValueForKeyPath




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

