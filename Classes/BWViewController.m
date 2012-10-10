//
//  BWViewController.m
//  GestureLab
//
//  Created by Mark Dalrymple on 10/9/12.
//  Copyright (c) 2012 Mark Dalrymple. All rights reserved.
//

#import "BWViewController.h"

#import "BWLoggingTextView.h"
#import "BWTimeScrubberView.h"
#import "BWTouchTrackView.h"

@interface BWViewController () <BWTimeScrubberDelegate, BWTouchTrackViewDelegate>

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
} // viewDidLoad


- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) direction {
    return UIInterfaceOrientationIsLandscape(direction);
} // shouldAutorotate


- (void) timeScrubber: (BWTimeScrubberView *) scrubbed
       scrubbedToTime: (NSTimeInterval) time {
    [self.touchTrackView drawUpToTimestamp: time];
    [self.loggingTextView displayToTimestamp: time];
} // scrubbedToTime


- (void) touchTrackBeganTracking: (BWTouchTrackView *) touchTrack {
    self.timeScrubber.mode = kModeReadonly;
    [self.loggingTextView clear];
} // touchTrackBeganTracking


- (void) touchTrackEndedTracking: (BWTouchTrackView *) touchTrack {
    self.timeScrubber.mode = kModeScrubbable;
    self.timeScrubber.totalDuration = touchTrack.trackingDuration;
    self.timeScrubber.currentTime = touchTrack.trackingDuration;
} // touchTrackEndedTracking



@end // BWViewController

