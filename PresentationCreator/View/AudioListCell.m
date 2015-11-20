//
//  AudioListCell.m
//  UITableViewProject
//
//  Created by Lin Lecui on 15/11/19.
//  Copyright © 2015年 Lin Lecui. All rights reserved.
//

#import "AudioListCell.h"

@implementation AudioListCell
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _checkBox = [[UIImageView alloc]initWithFrame:CGRectMake(5 , 10, 24, 24)];
        _checkBox.image  = [UIImage imageNamed:@"checkbox_unchecked.png"];
        [self.contentView addSubview:_checkBox];
        
        _nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(35, 10, [UIScreen mainScreen].bounds.size.width - 35, 24)];
        _nameLabel.text = @"";
        
        [self.contentView addSubview:_nameLabel];
    }
    return self;
}



@end
