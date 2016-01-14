//
//  SynchroViewController.m
//  PresentationCreator
//
//  Created by Lin Lecui on 16/1/13.
//  Copyright © 2016年 songyang. All rights reserved.
//

#import "SynchroViewController.h"

@interface SynchroViewController ()

@end

@implementation SynchroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addNavigation];
}
-(void)addNavigation
{
    self.navigationItem.title=@"Settings";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
