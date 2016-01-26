//
//  SummaryModel.h
//  PresentationCreator
//
//  Created by Lin Lecui on 15/11/23.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryModel : NSObject
@property (nonatomic, strong) NSString *summaryId;
@property (nonatomic, strong) NSString *summaryName;
@property (nonatomic, strong) NSString *contentHtml;
@property (nonatomic, strong) NSString *product_url;
@property (nonatomic, strong) NSString *dateTime;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *icon;
@end
