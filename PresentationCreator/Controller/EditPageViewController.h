//
//  EditPageViewController.h
//  PresentationCreator
//
//  Created by Lin Lecui on 15/12/7.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditPageViewController : UIViewController
{
    BOOL isFullScreen;
}
@property (nonatomic, strong) NSString *detailsIdStr;//“details表”传过来的details_id
@property (nonatomic, strong) NSString *showTemplateIdStr;//接收上一页传过来的templateid
@property (nonatomic, strong) NSString *showSummaryNameStr;//接收上一页传过来的summaryname就是title显示的名字
@property (nonatomic, strong) NSString *showSummaryIdStr;

@end
