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

        [self addSubview:self.webView];
    }
    return self;
}
@end
