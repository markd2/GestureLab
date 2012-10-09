#import "UIColor+AddressColor.h"

@implementation UIColor (BWAddressColor)

+ (UIColor *) bwColorWithAddress: (id) address {
    UIColor *color = [UIColor colorWithRed: (((int)address >> 0) & 0xFF) / 255.0
                              green: (((int)address >> 8) & 0xFF) / 255.0
                              blue: (((int)address >> 16) & 0xFF) / 255.0
                              alpha: 1.0];
    return color;
} // bwColorWithAddress

@end // BWAddressColor
