#import <UIKit/UIKit.h>

// Text view that hijacks standard out and redirects it to a text view.

@interface BWLoggingTextView : UITextView

- (void) addLine: (NSString *) line;

- (void) displayToTimestamp: (NSTimeInterval) timestamp;  // From 0 .. whenver

- (void) clear;

@end // BWLoggingTextView
