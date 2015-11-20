//
//  FilesModel.h
//  PresentationCreator
//
//  Created by songyang on 15/11/4.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilesModel : NSObject

@property(nonatomic,strong) NSString *fileIdStr;
@property(nonatomic,strong) NSString *fileDetailsIdStr;
@property(nonatomic,strong) NSString *filesummaryIdStr;
@property(nonatomic,strong) NSString *filetypeStr;
@property(nonatomic,strong) NSString *filePathStr;
@property(nonatomic,strong) NSString *isChecked;
@end
