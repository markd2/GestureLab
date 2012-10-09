#import "NSObject+AddressValue.h"


@implementation NSObject (BWAddressValue)

- (NSValue *) bwAddressValue {
    NSValue *value = [NSValue value: &self
                              withObjCType: @encode(void *)];
    return value;
} // bwAddressValue

@end // BWAddressValue
