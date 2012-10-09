//
//  BWAppDelegate.h
//  GestureLab
//
//  Created by Mark Dalrymple on 10/9/12.
//  Copyright (c) 2012 Mark Dalrymple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BWViewController;

@interface BWAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) BWViewController *viewController;

@end
