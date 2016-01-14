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
        UIFont *font = [UIFont fontWithName:@"Arial" size:12.0f];
        UIFont *fontName = [UIFont fontWithName:@"Arial" size:18.0f];
        
        _imgView = [[UIImageView alloc]init];
        _imgView.frame = CGRectMake(10, 5, 50, 70);
        [self addSubview:_imgView];
        
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.frame = CGRectMake(73, 5, KScreenWidth-80, 50);
        _nameLabel.font = fontName;
        _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
        
//        _nameLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        _nameLabel.numberOfLines = 0;
        [self addSubview:_nameLabel];
        
        _statusLabel = [[UILabel alloc]init];
        _statusLabel.frame = CGRectMake(75, 53, KScreenWidth-100-15-20, 20);
        _statusLabel.font = font;
        _statusLabel.textColor = [UIColor grayColor];
        [self addSubview:_statusLabel];
        
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.frame = CGRectMake(KScreenWidth - (KScreenWidth-100-15-20) + 65, 53, KScreenWidth-100-15-20, 20);
        _dateLabel.font = font;
        _dateLabel.textColor = [UIColor grayColor];
        [self addSubview:_dateLabel];
        
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
