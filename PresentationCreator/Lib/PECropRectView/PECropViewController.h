//
//  PECropViewController.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PECropViewController : UIViewController

@property (nonatomic) id delegate;
@property (nonatomic) UIImage *image;

@end

@protocol PECropViewControllerDelegate <NSObject>

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(NSString *)imageFullName;
- (void)cropViewControllerDidCancel:(PECropViewController *)controller;

@end
