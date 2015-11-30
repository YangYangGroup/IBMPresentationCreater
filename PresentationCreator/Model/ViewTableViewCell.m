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
        UIFont *font = [UIFont fontWithName:@"Arial" size:13.0f];
        UIFont *fontName = [UIFont fontWithName:@"Arial" size:16.0f];
        
        _imgView = [[UIImageView alloc]init];
        _imgView.frame = CGRectMake(10, 5, 50, 70);
        [self addSubview:_imgView];
        
        _nameLabel = [[UILabel alloc]init];
        _nameLabel.frame = CGRectMake(75, 5, KScreenWidth-100-15-20, 30);
        _nameLabel.font = fontName;
        _nameLabel.lineBreakMode = UILineBreakModeWordWrap;
        _nameLabel.numberOfLines = 0;
        [self addSubview:_nameLabel];
        
        _statusLabel = [[UILabel alloc]init];
        _statusLabel.frame = CGRectMake(75, 35, KScreenWidth-100-15-20, 20);
        
        _statusLabel.font = font;
        [self addSubview:_statusLabel];
        
        _dateLabel = [[UILabel alloc]init];
        _dateLabel.frame = CGRectMake(75, 55, KScreenWidth-100-15-20, 20);
        _dateLabel.font = font;
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
