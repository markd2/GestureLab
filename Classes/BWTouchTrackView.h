#import <UIKit/UIKit.h>

static NSString *const BWTouchTrackView_TrackingBegan;
static NSString *const BWTouchTrackView_TrackingEnded;

@interface BWTouchTrackView : UIView

@property (nonatomic, assign) NSTimeInterval startTimestamp;
@property (nonatomic, assign) NSTimeInterval endTimestamp;

@property (nonatomic, readonly) NSTimeInterval trackingDuration;

@end // BWTouchTackView
