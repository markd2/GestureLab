#import "QuietLog.h"

void QuietLog (NSString *format, ...) {
    va_list argList;

    va_start (argList, format);
    NSString *message = [[NSString alloc] initWithFormat: format
                                           arguments: argList];
    va_end  (argList);

    fprintf (stderr, "%s\n", [message UTF8String]);

} // QuietLog
