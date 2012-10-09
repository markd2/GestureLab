//
//  BWViewController.m
//  GestureLab
//
//  Created by Mark Dalrymple on 10/9/12.
//  Copyright (c) 2012 Mark Dalrymple. All rights reserved.
//

#import "BWViewController.h"

#import "BWTimeScrubberView.h"

@interface BWViewController () <BWTimeScrubberDelegate>

@end

@implementation BWViewController

- (void)viewDidLoad
{
    // I *LOVE* the mixture of tabs and spaces in the template -
    // nice attention to detail, Apple!

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.timeScrubber.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) direction {
    return UIInterfaceOrientationIsLandscape(direction);
} // shouldAutorotate


- (void) timeScrubber: (BWTimeScrubberView *) scrubbed
       scrubbedToTime: (NSTimeInterval) time {
    NSLog (@"LEET SCRUBZORZ %f", time);
} // scrubbedToTime


@end // BWViewController

