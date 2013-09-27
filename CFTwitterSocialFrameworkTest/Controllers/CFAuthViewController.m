//
//  CFAuthViewController.m
//  CFTwitterSocialFrameworkTest
//
//  Created by convexstyle on 28/08/13.
//  Copyright (c) 2013 convexstyle. All rights reserved.
//

#import "CFAuthViewController.h"

@interface CFAuthViewController ()

@end

@implementation CFAuthViewController {
    // Variables
    CFAuthModel *_model;
    ACAccountStore *_accountStore;
    NSArray *_twitterAccounts;
    
    // Views
    UIButton *_authButton;
    UIButton *_uploadButton;
    UIButton *_deleteButton;
}


#pragma mark - Life Circle
- (id)init
{
    self = [super init];
    if(self) {
        // Initialize
        self.title = @"Twitter SocialFramework Test";
        
        // Variables
        _accountStore = [[ACAccountStore alloc] init];
        _model        = [CFAuthModel getInstance];
    }
    return self;
}

- (void)dealloc
{
    // Remove Observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - View Circle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add Observers
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(twitterDataHandler:) name:CFTwitterIdentifierSaved object:_model];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(twitterDataHandler:) name:CFTwitterIdentifierCleared object:_model];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountStoreHandler:) name:ACAccountStoreDidChangeNotification object:nil];
}

- (void)loadView
{
    // Variables
    CGRect viewRect = [UIScreen mainScreen].bounds;
    
    //--- Views ---//
    UIView *mainView = [[UIView alloc] initWithFrame:viewRect];
    self.view        = mainView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Variables
    CGRect viewRect = self.view.bounds;
    CGFloat padding = 15.0f;
    
    //--- Views ---//
    // Authorize Button
    _authButton         = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _authButton.enabled = NO;
    _authButton.frame   = CGRectMake(padding, padding, viewRect.size.width - padding * 2, 40);
    [_authButton setTitle:@"Choose your Twitter Account" forState:UIControlStateNormal];
    [_authButton addTarget:self action:@selector(authorizeHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_authButton];
    
    // Upload Button
    _uploadButton         = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _uploadButton.enabled = NO;
    _uploadButton.frame   = CGRectMake(_authButton.frame.origin.x,
                                       _authButton.frame.origin.y + _authButton.frame.size.height + padding,
                                       _authButton.frame.size.width,
                                       _authButton.frame.size.height);
    [_uploadButton setTitle:@"Upload a Photo to Twitter" forState:UIControlStateNormal];
    [_uploadButton addTarget:self action:@selector(uploadHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_uploadButton];
    
    // Delete Button
    _deleteButton         = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _deleteButton.enabled = NO;
    _deleteButton.frame   = CGRectMake(_uploadButton.frame.origin.x,
                                       _uploadButton.frame.origin.y + _uploadButton.frame.size.height + padding,
                                       _uploadButton.frame.size.width,
                                       _uploadButton.frame.size.height);
    [_deleteButton setTitle:@"Delete your Twitter Account" forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(deleteHandler:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:_deleteButton];
    
    // (1) Simply, check whether authorisation is required or not
    [self updateButtonState];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Remove Observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Custom Button State
- (void)updateButtonState
{
    NSString *identifier       = [_model getTwitterAccountIdentifier];
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [_accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(granted) {
                NSLog(@"identifier >>> %@", identifier);
                if(identifier) {
                    _uploadButton.enabled = YES;
                    _authButton.enabled   = NO;
                    _deleteButton.enabled = YES;
                } else {
                    _authButton.enabled   = YES;
                    _uploadButton.enabled = NO;
                    _deleteButton.enabled = NO;
                }
            } else {
                _authButton.enabled   = YES;
                _uploadButton.enabled = NO;
                _deleteButton.enabled = NO;
            }
        });
        
    }];
}


#pragma mark - NSNotification Observer Methods
- (void)twitterDataHandler:(NSNotification*)aNotification
{
    NSString *notificationName = aNotification.name;
    if(notificationName && [notificationName isEqualToString:CFTwitterIdentifierSaved]) {
        
        // Update Button State
        [self updateButtonState];
        
    } else if(notificationName && [notificationName isEqualToString:CFTwitterIdentifierCleared]) {
    
        // Update Button State
        [self updateButtonState];
        
    }
}

- (void)accountStoreHandler:(NSNotification*)aNotification
{
    NSString *notificationName = aNotification.name;
    if([notificationName isEqualToString:ACAccountStoreDidChangeNotification]) {
        // Check the privacy status again
        [self updateButtonState];
    }
}


#pragma mark - UIButton Methods
- (void)authorizeHandler:(id)aSender
{
    if([aSender isKindOfClass:[UIButton class]]) {
        
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
            ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
            [_accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(granted) {
                        
                        _twitterAccounts = [_accountStore accountsWithAccountType:twitterType];
                        
                        if(_twitterAccounts.count > 1) {
                            
                            UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
                            actionSheet.tag            = CFAuthAccountActionSheet;
                            actionSheet.delegate       = self;
                            actionSheet.title          = @"Please choose your preferred Twitter Account for Pop Camera.";
                            
                            // Loop All ACAccounts
                            NSEnumerator *enumerator = [_twitterAccounts objectEnumerator];
                            ACAccount *account = nil;
                            while (account = [enumerator nextObject]) {
                                [actionSheet addButtonWithTitle:account.username];
                            }
                            [actionSheet addButtonWithTitle:@"Cancel"];
                            [actionSheet setCancelButtonIndex:_twitterAccounts.count];
                            [actionSheet showInView:self.view];
                            
                        } else if(_twitterAccounts.count == 1) {
                            // Save the identifier of Twitter account for a later use
                            ACAccount *twitterAccount = [_twitterAccounts lastObject];
                            [_model setTwitterAccountIdentifier:twitterAccount.identifier];
                        }
                        
                    } else {
                        if(error) {
                            
                            // Probably, this code block would not be triggered in Social Framwork with Twitter, but this error handling was define just in case.
                            if([error.domain isEqualToString:@"com.apple.accounts"]) {
                                switch (error.code) {
                                    case 6: {
                                        UIAlertViewQuick(@"Error", @"Any Twitter account was found in your iPhone.", @"OK");
                                        break;
                                    }
                                    case 7: {
                                        UIAlertViewQuick(@"Error", @"Permission to access your Twitter account was denied.", @"OK");
                                        break;
                                    }
                                    default:
                                        break;
                                }
                            } else {
                                UIAlertViewQuick(@"Error", @"A unknown error occurred.", @"OK");
                            }
                            
                        } else {
                            // App has requested to a user's Twitter account, but he/she has manually changed the privacy setting to Off.
                            UIAlertViewQuick(@"Error", @"Please allow My App to access your Twitter account in Settings > Privacy > Twitter.", @"OK");
                        }
                        _authButton.enabled = YES;
                        
                    }
                });
                
            }];
            
        } else {// There is no Twitter account registered in a user's iPhone
        
            UIAlertViewQuick(@"Error", @"You haven't registered any Twitter account yet. Please add it in Settings > Twitter.", @"OK");
            
        }
        
    }
}

// https://dev.twitter.com/docs/api/1.1/post/statuses/update_with_media
- (void)uploadHandler:(id)aSender
{
    if([aSender isKindOfClass:[UIButton class]]) {
        
        _uploadButton.enabled = NO;
        
        ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [_accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted) {
                
                // Get a saved ACAccount
                ACAccount *account = [_accountStore accountWithIdentifier:[_model getTwitterAccountIdentifier]];
                
                // Parameters
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setObject:@"Test Message #test" forKey:@"status"];
                NSString *imagePath = [[NSString alloc] initWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Sample.png"];
                UIImage *image      = [[UIImage alloc] initWithContentsOfFile:imagePath];
                
                NSURL *requestURL  = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update_with_media.json"];
                SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:requestURL parameters:params];
                [request addMultipartData:UIImagePNGRepresentation(image) withName:@"media" type:@"image/png" filename:@"sample.png"];
                request.account    = account;
                [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        _uploadButton.enabled = YES;
                        
                        if(error) {
                            // see CFNextworkErrors.h in more details
                            if([error.domain isEqualToString:NSURLErrorDomain]) {
                                switch (error.code) {
                                    case kCFURLErrorNotConnectedToInternet: {
                                        UIAlertViewQuick(@"Error", @"You might be offline. Please check your Internet connection.", @"OK");
                                        break;
                                    }
                                    case kCFURLErrorTimedOut: {
                                        UIAlertViewQuick(@"Error", @"Your Internet connection might be unstable. Please check your Internet connection.", @"OK");
                                        break;
                                    }
                                    case kCFURLErrorCannotConnectToHost: {
                                        UIAlertViewQuick(@"Error", @"Twitter might be unstable. Please try it later.", @"OK");
                                        break;
                                    }
                                    default: {
                                        UIAlertViewQuick(@"Error", @"Uploading a photo was failed.", @"OK");
                                        break;
                                    }
                                }
                            } else {
                                UIAlertViewQuick(@"Error", @"A unknown error occurred.", @"OK");
                            }
                            
                        } else {
                            NSError *jsonError = nil;
                            id jsonData        = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&jsonError];
                            if(jsonError) {
                                UIAlertViewQuick(@"Error", @"Uploading your photo was failed.", @"OK");
                            } else {
                                NSLog(@"jsonData >>> %@", jsonData);
                            }
                        
                        }
                    });
                }];
                
            } else {
            
            }
        }];
        
    }
}

- (void)deleteHandler:(id)aSender
{
    if([aSender isKindOfClass:[UIButton class]]) {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
        actionSheet.tag            = CFAuthRemoveAccountActionSheet;
        actionSheet.delegate       = self;
        actionSheet.title          = @"Remove your Twitter data ?";
        [actionSheet addButtonWithTitle:@"Yes"];
        [actionSheet addButtonWithTitle:@"No"];
        [actionSheet setDestructiveButtonIndex:0];
        [actionSheet setCancelButtonIndex:1];
        [actionSheet showInView:self.view];
    }
}


#pragma mark - UIActionSheetDelegate Methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (actionSheet.tag) {
        case CFAuthAccountActionSheet: {

            if(buttonIndex < _twitterAccounts.count) {
                ACAccount *account = [_twitterAccounts objectAtIndex:buttonIndex];
                [_model setTwitterAccountIdentifier:account.identifier];
            }
            break;
        }
        case CFAuthRemoveAccountActionSheet: {
            
            if(_model) {
                [_model clearTwitterAccountIdentifier];
            }
            
            break;
        }
        default:
            break;
    }
}


#pragma mark - Rotation Methods
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - Memory Related Methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
