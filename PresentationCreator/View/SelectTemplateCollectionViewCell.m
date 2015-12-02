//
//  SelectTemplateCollectionViewCell.m
//  PresentationCreator
//
//  Created by songyang on 15/10/21.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "SelectTemplateCollectionViewCell.h"

@implementation SelectTemplateCollectionViewCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 0, (KScreenWidth-10-5)/2, (KScreenHeight-64-20)/2-20)];
        self.imgView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.imgView];
        
        self.titleLable = [[UILabel alloc]initWithFrame:CGRectMake(10, (KScreenHeight-64-20)/2-20, (KScreenWidth-10-5)/2, 20)];
        self.titleLable.font = [UIFont systemFontOfSize:14];
        self.titleLable.textAlignment = NSTextAlignmentCenter;
        self.titleLable.textColor = [UIColor blackColor];
//        self.titleLable.backgroundColor = [UIColor redColor];
        [self addSubview:self.titleLable];
    }
    return self;
}
@end
