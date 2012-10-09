#import <UIKit/UIKit.h>

typedef enum : NSInteger {
    kModeReadonly,
    kModeScrubbable
} BWTimeScrubberMode;


@protocol BWTimeScrubberDelegate;


@interface BWTimeScrubberView : UIView

@property (nonatomic, assign) NSTimeInterval totalDuration;
@property (nonatomic, assign) NSTimeInterval currentTime; // clamped to totalDuration
@property (nonatomic, assign) BWTimeScrubberMode mode;

@property (nonatomic, weak) id <BWTimeScrubberDelegate> delegate;

@end // BWTimeScrubberView


@protocol BWTimeScrubberDelegate <NSObject>

- (void) timeScrubber: (BWTimeScrubberView *) scrubbed
       scrubbedToTime: (NSTimeInterval) time;

@end // BWTimeScrubberDelegate
