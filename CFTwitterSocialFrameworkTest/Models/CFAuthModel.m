//
//  CFAuthModel.m
//  CFTwitterSocialFrameworkTest
//
//  Created by convexstyle on 28/08/13.
//  Copyright (c) 2013 convexstyle. All rights reserved.
//

#import "CFAuthModel.h"

@implementation CFAuthModel


#pragma mark - Life Circle
+ (CFAuthModel*)getInstance
{
    static CFAuthModel* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });
    return instance;
}


#pragma mark - Set/Get Twitter Data
- (void)setTwitterAccountIdentifier:(NSString *)aIdentifier
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:aIdentifier forKey:CFTwitterIdentifierKey];
    [userDefaults synchronize];
    
    // Send Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:CFTwitterIdentifierSaved object:self userInfo:nil];
}

- (void)clearTwitterAccountIdentifier
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:nil forKey:CFTwitterIdentifierKey];
    [userDefaults synchronize];
    
    // Send Notification
    [[NSNotificationCenter defaultCenter] postNotificationName:CFTwitterIdentifierCleared object:self userInfo:nil];
}

- (NSString*)getTwitterAccountIdentifier
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:CFTwitterIdentifierKey];
}


@end
