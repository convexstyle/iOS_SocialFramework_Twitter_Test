### A small MVC sample application of Social Framework for Twitter

This is a small MVC sample application of Social Framework for Twitter.
This sample application is aiming at posting an image and a comment to Twitter.

There are a lot of sample codes about Social Framework on the Internet, but majority of them is checking the availability of Twitter each time a button is clicked or something like this. 
In my case, I wanted to change the visual status according to the availability so that users can recognize they can use Twitter.

As you see a below example, the idea is pretty simple. Twitter account identifier is saved in the model so that the visual assets are changed to whatever you want.

<pre>
ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [_accountStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
            if(granted) {
                
                // Get a saved ACAccount
                **ACAccount *account = [_accountStore accountWithIdentifier:[_model getTwitterAccountIdentifier]];**
                
                // Parameters
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setObject:@"Test Message #test" forKey:@"status"];
                NSString *imagePath = [[NSString alloc] initWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"Sample@2x.png"];
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

</pre>

