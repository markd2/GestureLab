//
//  BWViewController.m
//  GestureLab
//
//  Created by Mark Dalrymple on 10/9/12.
//  Copyright (c) 2012 Mark Dalrymple. All rights reserved.
//

#import "BWViewController.h"

#import "BWGestureTrackView.h"
#import "BWLoggingTextView.h"
#import "BWTimeScrubberView.h"
#import "BWTouchTrackView.h"
#import "BWGestureWrapper.h"

#import "QuietLog.h"


@interface BWViewController () <BWTimeScrubberDelegate,
    BWTouchTrackViewDelegate, BWGestureTrackViewDelegate> {
    NSTimeInterval _recordingStart;
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
    self.gestureTrackView.delegate = self;
    self.timeScrubber.delegate = self;
    self.timeScrubber.totalDuration = 0.0;

    [self.loggingTextView addLine: @"Tap and drag in the gesture view to start recognizers.\n"
         includeTimestamp: NO];
    [self.loggingTextView addLine: @"Look here for NSLog / QuietLog / etc.\n"
         includeTimestamp: NO];

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

    __unused BWGestureWrapper *longPressWrapped =
        [BWGestureWrapper wrapperWithGestureRecognizer: longPress];
    __unused BWGestureWrapper *pinchyWrapped = 
        [BWGestureWrapper wrapperWithGestureRecognizer: pinchy];
    __unused BWGestureWrapper *twoTapWrapped =
        [BWGestureWrapper wrapperWithGestureRecognizer: twoTap];
    __unused BWGestureWrapper *pannyWrapped =
        [BWGestureWrapper wrapperWithGestureRecognizer: panny];
    
    //[self.touchTrackView addGestureRecognizer: longPress];
    // [self.touchTrackView addGestureRecognizer: twoTap];
    // [self.touchTrackView addGestureRecognizer: pinchy];
    [self.touchTrackView addGestureRecognizer: (id)longPressWrapped];
    [self.touchTrackView addGestureRecognizer: (id)twoTapWrapped];
    [self.touchTrackView addGestureRecognizer: (id)pinchyWrapped];
    [self.touchTrackView addGestureRecognizer: (id)pannyWrapped];

    [self.gestureTrackView removeAllRecognizers];
    // [self.gestureTrackView trackGestureRecognizer: longPress];
    // [self.gestureTrackView trackGestureRecognizer: twoTap];
    // [self.gestureTrackView trackGestureRecognizer: pinchy];
    [self.gestureTrackView trackGestureRecognizer: (id)longPressWrapped];
    [self.gestureTrackView trackGestureRecognizer: (id)twoTapWrapped];
    [self.gestureTrackView trackGestureRecognizer: (id)pinchyWrapped];
    [self.gestureTrackView trackGestureRecognizer: (id)pannyWrapped];

} // addSomeGestures


- (void) iPinchYou: (UIPinchGestureRecognizer *) pinchy {
    QuietLog (@"PEENCH");
} // iPinchYou


- (void) twoTap: (UITapGestureRecognizer *) tappy {
    QuietLog (@"TAPPY");
} // twoTap


- (void) longPress: (UILongPressGestureRecognizer *) pressy {
    QuietLog (@"PRESSY");
} // longPress


- (void) panny: (UIPanGestureRecognizer *) panny {
    QuietLog (@"PANNY");
} // panny


- (void) timeScrubber: (BWTimeScrubberView *) scrubbed
       scrubbedToTime: (NSTimeInterval) time {
    [self.touchTrackView drawUpToTimestamp: time];
    [self.loggingTextView displayToTimestamp: time];
} // scrubbedToTime


- (void) touchTrackBeganTracking: (BWTouchTrackView *) touchTrack {
    self.timeScrubber.mode = kModeReadonly;
    [self.loggingTextView clear];
    [self.gestureTrackView startRecording];

    _recordingStart = [NSDate timeIntervalSinceReferenceDate];
} // touchTrackBeganTracking


- (void) touchTrackEndedTracking: (BWTouchTrackView *) touchTrack {
    // TODO(markd): move to common "end recording" place.
    self.timeScrubber.mode = kModeScrubbable;

    self.timeScrubber.totalDuration = touchTrack.trackingDuration;
    self.timeScrubber.currentTime = touchTrack.trackingDuration;

    self.gestureTrackView.totalDuration = touchTrack.trackingDuration;
    self.gestureTrackView.currentTime = touchTrack.trackingDuration;

    [self.gestureTrackView stopRecording];

    QuietLog (@"END TRACKING %f", touchTrack.trackingDuration);

} // touchTrackEndedTracking


- (void) trackViewCompletedLastRecognizer: (BWGestureTrackView *) trackView {
    QuietLog (@"ALL DONE!");

    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval delta = now - _recordingStart;

    if (delta > self.timeScrubber.totalDuration) {
        self.timeScrubber.totalDuration = delta;
        self.gestureTrackView.totalDuration = delta;

        // TODO(markd): make the above setNeedsDisplay
        [self.timeScrubber setNeedsDisplay];
        [self.gestureTrackView setNeedsDisplay];
    }

} // trackViewCompletedLastRecognizer


@end // BWViewController
