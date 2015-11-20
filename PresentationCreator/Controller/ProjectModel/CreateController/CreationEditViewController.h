//
//  CreationEditViewController.h
//  PresentationCreator
//
//  Created by songyang on 15/10/12.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreationEditViewController : UIViewController
{
    BOOL isFullScreen;
}
@property (nonatomic, strong) NSString *detailsIdStr;//“details表”传过来的details_id
//@property (nonatomic, strong) NSString *summaryIdStr;//创建的ppt项目名称
//@property (nonatomic, strong) NSString *summaryNameStr;
@property (nonatomic) NSInteger selectTemplateIndex;
@end
