#import <UIKit/UIKit.h>

@class UIGestureRecognizer;

@interface BWGestureWrapper : NSProxy

@property (nonatomic, readonly) UIGestureRecognizer *recognizer;

+ (id) wrapperWithGestureRecognizer: (UIGestureRecognizer *) recognizer;

@end // BWGestureWrapper
