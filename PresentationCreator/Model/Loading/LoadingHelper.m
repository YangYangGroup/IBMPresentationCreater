//
//  LoadingHelper.m
//  PresentationCreator
//
//  Created by songyang on 15/11/9.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "LoadingHelper.h"
#import "MBProgressHUD.h"
@implementation LoadingHelper

+(void)showLoadingWithView:(UIView *)aView
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:aView animated:YES];
    hud.labelText = @"Loading……";
    //    hud.color = [UIColor redColor];
    hud.labelFont = [UIFont systemFontOfSize:16.0f];
}

+(void)hiddonLoadingWithView:(UIView *)aView
{
    [MBProgressHUD hideAllHUDsForView:aView animated:YES];
}
@end
