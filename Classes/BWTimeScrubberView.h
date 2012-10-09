#import <UIKit/UIKit.h>

@protocol BWTimeScrubberDelegate;


@interface BWTimeScrubberView : UIView

@property (nonatomic, weak) id <BWTimeScrubberDelegate> delegate;

@end // BWTimeScrubberView


@protocol BWTimeScrubberDelegate <NSObject>

- (void) timeScrubber: (BWTimeScrubberView *) scrubbed
       scrubbedToTime: (NSTimeInterval) time;

@end // BWTimeScrubberDelegate
