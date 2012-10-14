// BIDCheckMarkRecogizer - recognize a checkmark.
// Code from "Beginning iOS 5 Development" by Dave Mark, Jeff LaMarche, and Jack Nutting.

#import <UIKit/UIKit.h>

@interface BIDCheckMarkGestureRecognizer : UIGestureRecognizer

@property (assign, nonatomic) CGPoint lastPreviousPoint;
@property (assign, nonatomic) CGPoint lastCurrentPoint;
@property (assign, nonatomic) CGFloat lineLengthSoFar;

@end
