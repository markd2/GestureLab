#import "BWTouchTrackView.h"

static const CGFloat kPromptTextSize = 36.0;


@implementation BWTouchTrackView



- (void) drawBackground: (CGRect) rect {
    [[UIColor whiteColor] set];
    UIRectFill (rect);
} // drawBackground


- (void) drawPromptTextInRect: (CGRect) rect {
    UIFont *font = [UIFont boldSystemFontOfSize: kPromptTextSize];
    NSString *prompt = @"Gesture Here";

    CGSize textSize = [prompt sizeWithFont: font
                              constrainedToSize: rect.size
                              lineBreakMode: UILineBreakModeWordWrap];

    CGRect textRect = CGRectMake (CGRectGetMidX(rect) - textSize.width / 2.0,
                                  CGRectGetMidY(rect) - textSize.height / 2.0,
                                  textSize.width, textSize.height);

    [[UIColor lightGrayColor] set];

    [prompt drawInRect: textRect
            withFont: font
            lineBreakMode: UILineBreakModeWordWrap
            alignment: UITextAlignmentCenter];

} // drawPromptTextInRect


- (void) drawFrame: (CGRect) rect {
    [[UIColor blackColor] set];
    UIRectFrame (rect);
} // drawFrame


- (void) drawRect: (CGRect) rect {

    CGRect bounds = self.bounds;

    [self drawBackground: bounds];
    [self drawPromptTextInRect: bounds];
    [self drawFrame: bounds];

} // drawRect

@end // BWTouchView

