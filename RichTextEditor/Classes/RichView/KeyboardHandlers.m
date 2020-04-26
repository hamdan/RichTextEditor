//
//  KeyboardHandlers.m
//  RichTextEditor
//
//  Created by hamdan hashmi on 24/04/2020.
//  Copyright © 2020 Hamdan. All rights reserved.
//

#import "KeyboardHandlers.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <WebKit/WebKit.h>

@implementation KeyboardHandlers

#pragma mark - Convenience replacement for keyboardDisplayRequiresUserAction in WKWebview
+ (void)allowDisplayingKeyboardWithoutUserAction {
    Class class = NSClassFromString(@"WKContentView");
    NSOperatingSystemVersion iOS_11_3_0 = (NSOperatingSystemVersion){11, 3, 0};
    NSOperatingSystemVersion iOS_12_2_0 = (NSOperatingSystemVersion){12, 2, 0};
    NSOperatingSystemVersion iOS_13_0_0 = (NSOperatingSystemVersion){13, 0, 0};
    if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_13_0_0]) {
        SEL selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:activityStateChanges:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
        ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
        });
        method_setImplementation(method, override);
    }
   else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_12_2_0]) {
        SEL selector = sel_getUid("_elementDidFocus:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
        ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
        });
        method_setImplementation(method, override);
    }
    else if ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion: iOS_11_3_0]) {
        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:changingActivityState:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, BOOL arg3, id arg4) {
            ((void (*)(id, SEL, void*, BOOL, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3, arg4);
        });
        method_setImplementation(method, override);
    } else {
        SEL selector = sel_getUid("_startAssistingNode:userIsInteracting:blurPreviousNode:userObject:");
        Method method = class_getInstanceMethod(class, selector);
        IMP original = method_getImplementation(method);
        IMP override = imp_implementationWithBlock(^void(id me, void* arg0, BOOL arg1, BOOL arg2, id arg3) {
            ((void (*)(id, SEL, void*, BOOL, BOOL, id))original)(me, selector, arg0, TRUE, arg2, arg3);
        });
        method_setImplementation(method, override);
    }
}

@end
