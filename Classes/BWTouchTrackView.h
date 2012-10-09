#import <UIKit/UIKit.h>


@protocol BWTouchTrackViewDelegate;

@interface BWTouchTrackView : UIView

@property (nonatomic, assign) NSTimeInterval startTimestamp;
@property (nonatomic, assign) NSTimeInterval endTimestamp;

@property (nonatomic, readonly) NSTimeInterval trackingDuration;

@property (nonatomic, weak) id <BWTouchTrackViewDelegate> delegate;

@end // BWTouchTackView


@protocol BWTouchTrackViewDelegate <NSObject>

- (void) touchTrackBeganTracking: (BWTouchTrackView *) touchTrack;
- (void) touchTrackEndedTracking: (BWTouchTrackView *) touchTrack;

@end // BWTouchTrackViewDelegate
