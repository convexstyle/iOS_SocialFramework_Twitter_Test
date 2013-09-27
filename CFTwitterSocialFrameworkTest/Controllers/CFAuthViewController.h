//
//  CFAuthViewController.h
//  CFTwitterSocialFrameworkTest
//
//  Created by convexstyle on 28/08/13.
//  Copyright (c) 2013 convexstyle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

// Category
#import "UIAlertView+CFQuick.h"

// Models
#import "CFAuthModel.h"

typedef enum {
    CFAuthAccountActionSheet,
    CFAuthRemoveAccountActionSheet
} CFAuthActionSheetType;

@interface CFAuthViewController : UIViewController <UIActionSheetDelegate>

@end
