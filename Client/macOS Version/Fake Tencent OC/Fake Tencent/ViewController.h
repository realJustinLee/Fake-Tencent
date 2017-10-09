//
//  ViewController.h
//  Fake Tencent
//
//  Created by 李欣 on 2017/9/19.
//  Copyright © 2017年 李欣. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSTextField *usernameText;
@property (weak) IBOutlet NSSecureTextField *passwordText;
@property (weak) IBOutlet NSButton *rememberUserCheck;
@property (weak) IBOutlet NSButton *autoLoginCheck;
@property (weak) IBOutlet NSButton *registerButton;
@property (weak) IBOutlet NSButton *loginButton;
@property (weak) IBOutlet NSButton *helpWelcomeBoard;


@end

