//
//  BWViewController.m
//  GestureLab
//
//  Created by Mark Dalrymple on 10/9/12.
//  Copyright (c) 2012 Mark Dalrymple. All rights reserved.
//

#import "BWViewController.h"

#import "BIDCheckMarkGestureRecognizer.h"

#import "BWGestureTrackView.h"
#import "BWLoggingTextView.h"
#import "BWTimeScrubberView.h"
#import "BWTouchTrackView.h"
#import "BWGestureWrapper.h"

#import "QuietLog.h"

// How long to wait before returning to ready-to-track state.
static const CGFloat kLastTouchTimeout = 1.0;
static const CGFloat kMinScrubTime = 1.0;

@interface BWViewController () <BWTimeScrubberDelegate, 
                                    BWTouchTrackViewDelegate,
                                    BWGestureWrapperDelegate> {
    NSTimeInterval _recordingStart;
    NSTimeInterval _recordingMaybeEnded;
    BOOL _trackCompleted;
    BOOL _gesturesCompleted;
    NSMutableSet *_gesturesInFlight;
}

@end

@implementation BWViewController

- (void)viewDidLoad
{
    // I *LOVE* the mixture of tabs and spaces in the template -
    // nice attention to detail, Apple!

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.touchTrackView.delegate = self;
    self.timeScrubber.delegate = self;
    self.timeScrubber.totalDuration = 0.0;

    [self.loggingTextView addLine: @"Tap and drag in the gesture view to start recognizers.\n"
         includeTimestamp: NO];
    [self.loggingTextView addLine: @"Look here for NSLog / QuietLog / etc.\n"
         includeTimestamp: NO];

    _gesturesInFlight = [NSMutableSet set];

    [self addSomeGestures];
} // viewDidLoad


- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) direction {
    return UIInterfaceOrientationIsLandscape(direction);
} // shouldAutorotate



- (void) addSomeGestures {
    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                              action: @selector(longPress:)];

    UITapGestureRecognizer *twoTap =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                        action: @selector(twoTap:)];
    twoTap.numberOfTapsRequired = 2;
    twoTap.numberOfTouchesRequired = 2;

    UIPinchGestureRecognizer *pinchy =
        [[UIPinchGestureRecognizer alloc] initWithTarget: self
                                          action: @selector(iPinchYou:)];

    UIPanGestureRecognizer *panny =
        [[UIPanGestureRecognizer alloc] initWithTarget: self
                                        action: @selector(panny:)];
    
    BIDCheckMarkGestureRecognizer *checky =
        [[BIDCheckMarkGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(checky:)];

    __unused BWGestureWrapper *longPressWrapped =
        [BWGestureWrapper wrapperWithGestureRecognizer: longPress];
    __unused BWGestureWrapper *pinchyWrapped = 
        [BWGestureWrapper wrapperWithGestureRecognizer: pinchy];
    __unused BWGestureWrapper *twoTapWrapped =
        [BWGestureWrapper wrapperWithGestureRecognizer: twoTap];
    __unused BWGestureWrapper *pannyWrapped =
        [BWGestureWrapper wrapperWithGestureRecognizer: panny];
    __unused BWGestureWrapper *checkyWrapped =
        [BWGestureWrapper wrapperWithGestureRecognizer: checky];

    longPressWrapped.delegate = self;
    pinchyWrapped.delegate = self;
    twoTapWrapped.delegate = self;
    pannyWrapped.delegate = self;
    checkyWrapped.delegate = self;
    
    //[self.touchTrackView addGestureRecognizer: longPress];
    // [self.touchTrackView addGestureRecognizer: twoTap];
    // [self.touchTrackView addGestureRecognizer: pinchy];
    [self.touchTrackView addGestureRecognizer: (id)longPressWrapped];
    [self.touchTrackView addGestureRecognizer: (id)twoTapWrapped];
    [self.touchTrackView addGestureRecognizer: (id)pinchyWrapped];
    [self.touchTrackView addGestureRecognizer: (id)checkyWrapped];
    // [self.touchTrackView addGestureRecognizer: (id)pannyWrapped];

    [self.gestureTrackView removeAllRecognizers];
    // [self.gestureTrackView trackGestureRecognizer: longPress];
    // [self.gestureTrackView trackGestureRecognizer: twoTap];
    // [self.gestureTrackView trackGestureRecognizer: pinchy];
    [self.gestureTrackView trackGestureRecognizer: (id)longPressWrapped];
    [self.gestureTrackView trackGestureRecognizer: (id)twoTapWrapped];
    [self.gestureTrackView trackGestureRecognizer: (id)pinchyWrapped];
    // [self.gestureTrackView trackGestureRecognizer: (id)pannyWrapped];
    [self.gestureTrackView trackGestureRecognizer: (id)checkyWrapped];

} // addSomeGestures


- (void) iPinchYou: (UIPinchGestureRecognizer *) pinchy {
    QuietLog (@"PEENCH");
    [self.gestureTrackView recordActionForGestureRecognizer: pinchy];
} // iPinchYou


- (void) twoTap: (UITapGestureRecognizer *) tappy {
    QuietLog (@"TAPPY");
    [self.gestureTrackView recordActionForGestureRecognizer: tappy];
} // twoTap


- (void) longPress: (UILongPressGestureRecognizer *) pressy {
    QuietLog (@"PRESSY");
    [self.gestureTrackView recordActionForGestureRecognizer: pressy];
} // longPress


- (void) panny: (UIPanGestureRecognizer *) panny {
    QuietLog (@"PANNY");
    [self.gestureTrackView recordActionForGestureRecognizer: panny];
} // panny


- (void) checky: (BIDCheckMarkGestureRecognizer *) checky {
    QuietLog (@"CHECKY");
    [self.gestureTrackView recordActionForGestureRecognizer: checky];
} // panny


- (void) timeScrubber: (BWTimeScrubberView *) scrubbed
       scrubbedToTime: (NSTimeInterval) time {
    [self.touchTrackView drawUpToTimestamp: time];
    [self.loggingTextView displayToTimestamp: time];
} // scrubbedToTime


- (void) handleTrackingEnded {
    if (!_trackCompleted || !_gesturesCompleted) return;

    NSTimeInterval delta = _recordingMaybeEnded - _recordingStart;

    if (delta < kMinScrubTime) delta = kMinScrubTime;

    self.timeScrubber.mode = kModeScrubbable;

    self.timeScrubber.totalDuration = delta;
    self.timeScrubber.currentTime = delta;

    self.gestureTrackView.totalDuration = delta;
    self.gestureTrackView.currentTime = delta;

    [self.timeScrubber setNeedsDisplay];
    [self.gestureTrackView setNeedsDisplay];

} // handleTrackingEnded


- (void) touchTrackBeganTracking: (BWTouchTrackView *) touchTrack {
    self.timeScrubber.mode = kModeReadonly;
    [self.loggingTextView clear];
    [self.gestureTrackView startRecording];

    _recordingStart = [NSDate timeIntervalSinceReferenceDate];
    _trackCompleted = NO;
} // touchTrackBeganTracking


- (void) touchTrackEndedTracking: (BWTouchTrackView *) touchTrack {

    _trackCompleted = YES;

    NSTimeInterval possibleEnd = _recordingStart + touchTrack.trackingDuration;
    if (possibleEnd > _recordingMaybeEnded) _recordingMaybeEnded = possibleEnd;

    [self handleTrackingEnded];

} // touchTrackEndedTracking


- (void) assumeTrackingDone {
    _gesturesCompleted = YES;
    [self handleTrackingEnded];
} // assumeTrackingDone


- (void) wrapperStartedTracking: (BWGestureWrapper *) wrapper {
    [_gesturesInFlight addObject: wrapper];
    [NSObject cancelPreviousPerformRequestsWithTarget: self
              selector: @selector(assumeTrackingDone)
              object: nil];

} // wrapperStartedTracking


- (void) wrapperStoppedTracking: (BWGestureWrapper *) wrapper {
    [_gesturesInFlight removeObject: wrapper];

    if (_gesturesInFlight.count == 0) {
        _recordingMaybeEnded = [NSDate timeIntervalSinceReferenceDate];
        [self performSelector: @selector(assumeTrackingDone)
              withObject: nil
              afterDelay: kLastTouchTimeout];
    }

} // wrapperStoppedTracking


@end // BWViewController
