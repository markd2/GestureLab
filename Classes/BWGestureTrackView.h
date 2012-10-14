#import <UIKit/UIKit.h>

// Watch a collection of gestures, and draw a temporal track of when they changed states.

@interface BWGestureTrackView : UIView

@property (nonatomic, assign) NSTimeInterval totalDuration;
@property (nonatomic, assign) NSTimeInterval currentTime; // clamped to totalDuration

- (void) removeAllRecognizers;
- (void) trackGestureRecognizer: (UIGestureRecognizer *) gestureRecognizer;

- (void) startRecording;
- (void) stopRecording;

@end // BWGestureTrackView
