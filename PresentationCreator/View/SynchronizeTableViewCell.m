//
//  SynchronizeTableViewCell.m
//  PresentationCreator
//
//  Created by Lin Lecui on 16/1/14.
//  Copyright © 2016年 songyang. All rights reserved.
//

#import "SynchronizeTableViewCell.h"

@implementation SynchronizeTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(-1, 0, KScreenWidth + 1, 74)];
        bgView.layer.borderColor = [UIColor colorWithRed:180/255.0f green:180/255.0f blue:180/255.0f alpha:1.0].CGColor;
        bgView.layer.borderWidth = 0.5;
        UIFont *font = [UIFont fontWithName:@"Arial" size:15.0f];
    
        UIImage *image = [UIImage imageNamed:@"Synchronize-1.png"];
        UIImageView *imgView = [[UIImageView alloc]init];
        imgView.frame = CGRectMake(5, 5, 64, 64);
        imgView.image = image;
        [bgView addSubview:imgView];
        
        UILabel *synchronizeLabel = [[UILabel alloc]initWithFrame:CGRectMake(75, 10, 170, 50)];
        synchronizeLabel.text = @"Synchronize Template";
        synchronizeLabel.font = font;
        [bgView addSubview:synchronizeLabel];
        
        self.updateAvailableLabel = [[UILabel alloc]initWithFrame:CGRectMake(KScreenWidth-50 -10, 20, 50, 30)];
        self.updateAvailableLabel.backgroundColor = [UIColor redColor];
        self.updateAvailableLabel.text = @"new";
        self.updateAvailableLabel.textColor = [UIColor whiteColor];
        self.updateAvailableLabel.textAlignment = NSTextAlignmentCenter;
        self.updateAvailableLabel.layer.cornerRadius = 5;
//        self.updateAvailableLabel.layer.borderWidth = 1;
        self.updateAvailableLabel.layer.masksToBounds = YES;
        [bgView addSubview:self.updateAvailableLabel];
        
        [self addSubview:bgView];
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
