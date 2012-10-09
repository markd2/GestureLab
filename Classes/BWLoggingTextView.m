#import "BWLoggingTextView.h"

@interface BWLoggingTextView () {
    NSMutableString *_contents;
}
@end // extension


@implementation BWLoggingTextView


- (void) addLine: (NSString *) line {
    if (_contents == nil) _contents = [NSMutableString string];

    [_contents appendString: line];
    self.text = _contents;
} // addLine

@end // BWLoggingTextView
