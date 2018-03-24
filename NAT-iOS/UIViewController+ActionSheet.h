//
//  UIViewController+ActionSheet.h
//  NAT-iOS
//
//  Created by simpzan on 24/03/2018.
//  Copyright © 2018 simpzan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ActionSheet)

typedef void (^ActionSheetCallback)(int index);
- (void)select:(NSArray *)actions title:(NSString *)title :(ActionSheetCallback)callback;

@end
