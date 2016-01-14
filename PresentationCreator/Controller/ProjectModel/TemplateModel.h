//
//  TemplateModel.h
//  PresentationCreator
//
//  Created by Lin Lecui on 16/1/11.
//  Copyright © 2016年 songyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemplateModel : NSObject
@property (nonatomic, strong) NSString *templateId;
@property (nonatomic, strong) NSString *templateName;
@property (nonatomic, strong) NSString *templateThumbNail;
@property (nonatomic, strong) NSString *updateFlag;
@property (nonatomic, strong) NSString *createdTS;

@end
