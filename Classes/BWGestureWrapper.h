#import <UIKit/UIKit.h>

// Not a perfect cover, since anything that's doing [self blah] will be using itself
// and bypassing our cover, so this is mainly for catching things being sent to the
// recognizer from outside the class.

@class UIGestureRecognizer;

@interface BWGestureWrapper : NSProxy

@property (nonatomic, readonly) UIGestureRecognizer *recognizer;

+ (id) wrapperWithGestureRecognizer: (UIGestureRecognizer *) recognizer;

@end // BWGestureWrapper
