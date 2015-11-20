//
//  EditNowViewController.h
//  PresentationCreator
//
//  Created by songyang on 15/10/19.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditNowViewController : UIViewController
{
    BOOL isFullScreen;
}
@property (nonatomic, strong) NSString *editNowDetailsIdStr;
@property (nonatomic, strong) NSString *editNowSummaryNameStr;
@property (nonatomic, strong) NSString *editNowHtmlCodeStr;
@property (nonatomic, strong) NSString *editNowSummaryIdStr;
@property (nonatomic, strong) NSString *editNowAudioIdStr;
@end
