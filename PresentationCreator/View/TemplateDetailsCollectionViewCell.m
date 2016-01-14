//
//  TemplateDetailsCollectionViewCell.m
//  PresentationCreator
//
//  Created by Lin Lecui on 16/1/11.
//  Copyright © 2016年 songyang. All rights reserved.
//

#import "TemplateDetailsCollectionViewCell.h"
#import "Global.h"

@implementation TemplateDetailsCollectionViewCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth/2-10, (KScreenHeight-64-20)/2)];

        self.maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth/2-10, (KScreenHeight-64-20)/2)];
        self.maskView.backgroundColor = [UIColor colorWithRed:100/255.0f green:100/255.0f blue:100/255.0f alpha:0.0];

        [self addSubview:self.webView];
        [self addSubview:self.maskView];
        
    }
    return self;
}
@end
