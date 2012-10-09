#import "BWLoggingTextView.h"

@interface BWLoggingTextView () {
    NSMutableString *_contents;
    int _oldStandardOut;
    int _oldStandardError;

    int _standardOutPipe[2];

    CFSocketRef _socketRef;
}
@end // extension

enum { kReadSide, kWriteSide };  // The two side to every pipe()

@implementation BWLoggingTextView


static void ReceiveMessage (CFSocketRef socket, CFSocketCallBackType type,
                            CFDataRef address, const void *data, void *info) {
    NSString *string = [[NSString alloc] initWithData: (__bridge NSData *) data
                                         encoding: NSUTF8StringEncoding];
    BWLoggingTextView *self = (__bridge BWLoggingTextView *) info;

    [self addLine: string];

} // ReceiveMessage


- (void) startMonitoringSocket: (int) fd {
    CFSocketContext context = { 0, (__bridge void *)(self), NULL, NULL, NULL };
    _socketRef = CFSocketCreateWithNative (kCFAllocatorDefault,
                                           fd,
                                           kCFSocketDataCallBack,
                                           ReceiveMessage,
                                           &context);
    if (_socketRef == NULL) {
        NSLog (@"couldn't make cfsocket");
        goto bailout;
    }
    
    CFRunLoopSourceRef rls = 
        CFSocketCreateRunLoopSource(kCFAllocatorDefault, _socketRef, 0);

    if (rls == NULL) {
        NSLog (@"couldn't create run loop source");
        goto bailout;
    }
    
    CFRunLoopAddSource (CFRunLoopGetCurrent(), rls, kCFRunLoopDefaultMode);
    CFRelease (rls);

bailout: 
    return;

} // startMonitoringSocket


- (void) hijackStandardOut {
    int result;
    result = pipe (_standardOutPipe);
    if (result == -1) {
        NSLog (@"could not make a pipe for standard out");
        return;
    }

    // save off the existing fd's for eventual reconnecting.
    _oldStandardOut = dup (fileno(stdout));
    _oldStandardError = dup (fileno(stderr));
    setbuf (stdout, NULL);  // Turn off buffering
    setbuf (stderr, NULL);  // Turn off buffering

    dup2 (_standardOutPipe[kWriteSide], fileno(stdout));
    dup2 (_standardOutPipe[kWriteSide], fileno(stderr));

    // Add the read side to the runloop.
    [self startMonitoringSocket: _standardOutPipe[kReadSide]];

} // hijackStandardOut


- (id) initWithFrame: (CGRect) frame {
    if ((self = [super initWithFrame: frame])) {
        [self hijackStandardOut];
    }
    
    return self;

} // initWithFrame


- (id) initWithCoder: (NSCoder *) decoder {
    if ((self = [super initWithCoder: decoder])) {
        [self hijackStandardOut];
    }
    
    return self;

} // initWithCoder


- (void) addLine: (NSString *) line {
    if (_contents == nil) _contents = [NSMutableString string];

    [_contents appendString: line];
    self.text = _contents;
} // addLine

@end // BWLoggingTextView
