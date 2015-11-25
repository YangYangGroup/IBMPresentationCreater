//
//  PreviewViewController.h
//  PresentationCreator
//
//  Created by songyang on 15/10/15.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "WXApiObject.h"

@interface PreviewViewController : UIViewController
{
    enum WXScene _scene;
}
@property (nonatomic, strong) NSString *showSummaryNameStr;//接收上一页传过来的summaryname就是title显示的名字
@property (nonatomic, strong) NSString *showTemplateIdStr;//接收上一页传过来的templateid
@property (nonatomic, strong) NSString *showSummaryIdStr;

@end
