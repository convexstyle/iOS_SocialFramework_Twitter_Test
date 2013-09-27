//
//  CFAuthModel.h
//  CFTwitterSocialFrameworkTest
//
//  Created by convexstyle on 28/08/13.
//  Copyright (c) 2013 convexstyle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CFAuthModel : NSObject
+(CFAuthModel*)getInstance;
- (void)setTwitterAccountIdentifier:(NSString*)aIdentifier;
- (void)clearTwitterAccountIdentifier;
- (NSString*)getTwitterAccountIdentifier;
@end
