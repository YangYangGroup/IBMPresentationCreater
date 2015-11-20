//
//  ProjectModel.h
//  PresentationCreator
//
//  Created by songyang on 15/10/11.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectModel : NSObject
@property(nonatomic,assign) NSInteger pageId;
@property(nonatomic,assign) NSInteger tableId;
@property(nonatomic,assign) NSInteger templateId;
@property(nonatomic,strong) NSString *tableNameStr;
@property(nonatomic,strong) NSString *tableHtmlStr;
@property(nonatomic,strong) NSString *tempaleIdStr;
@property(nonatomic,strong) NSString *tempaleHtmlStr;

@end
