//
//  BWViewController.h
//  GestureLab
//
//  Created by Mark Dalrymple on 10/9/12.
//  Copyright (c) 2012 Mark Dalrymple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BWTimeScrubberView;
@class BWTouchTrackView;

@interface BWViewController : UIViewController

@property (nonatomic, weak) IBOutlet BWTimeScrubberView *timeScrubber;
@property (nonatomic, weak) IBOutlet BWTouchTrackView *touchTrackView;

@end // BWViewController
