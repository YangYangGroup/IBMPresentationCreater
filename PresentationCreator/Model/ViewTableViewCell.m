//
//  ViewTableViewCell.m
//  PresentationCreator
//
//  Created by songyang on 15/9/29.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "ViewTableViewCell.h"

@implementation ViewTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _imgView = [[UIImageView alloc]init];
        _imgView.frame = CGRectMake(15, 5, 100, 140);
        [self addSubview:_imgView];
        
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.frame = CGRectMake(100 + 15 +5, 2, KScreenWidth-100-15-20, 100);
        [self addSubview:_nameLabel];
        
        _statusLabel = [[UILabel alloc]init];
        _statusLabel.frame = CGRectMake(100 + 15 +5, 100, KScreenWidth-100-15-20, 40);
        [self addSubview:_statusLabel];
        
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
