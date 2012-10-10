#import <UIKit/UIKit.h>

// Watch a collection of gestures, and draw a temporal track of when they changed states.

@interface BWGestureTrackView : UIView

- (void) removeAllRecognizers;
- (void) trackGestureRecognizer: (UIGestureRecognizer *) gestureRecognizer;

@end // BWGestureTrackView
