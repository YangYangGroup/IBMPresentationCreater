//
//  EditPresentationNameViewController.m
//  PresentationCreator
//
//  Created by Lin Lecui on 15/11/25.
//  Copyright © 2015年 songyang. All rights reserved.
//  

#import "EditPresentationNameViewController.h"
#import "DBDaoHelper.h"
#import "ShowViewController.h"

@interface EditPresentationNameViewController ()
@property (nonatomic, strong) UITextField *txtField;
@end

@implementation EditPresentationNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1];
    [self addNavigation];
    
    [self loadDataToView];
}

-(void)loadDataToView{
    UIView *uView = [[UIView alloc]initWithFrame:CGRectMake(0,80,KScreenWidth,40)];
    uView.backgroundColor = [UIColor whiteColor];
    _txtField = [[UITextField alloc]init];
    _txtField.frame = CGRectMake(15, 0, KScreenWidth -30, 40);
    _txtField.text = _summaryName;
    _txtField.backgroundColor = [UIColor whiteColor];
    _txtField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_txtField becomeFirstResponder];
    [uView addSubview:_txtField];
    [self.view addSubview:uView];
}

-(void)addNavigation
{
    self.navigationItem.title = @"Edit Name";
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //    backbtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    backbtn.frame = CGRectMake(0, 0, 30, 30);
    backbtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [backbtn setBackgroundImage:[UIImage imageNamed:@"back@2x"] forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(doneEditName) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *SearchItem = [[UIBarButtonItem alloc]initWithCustomView:backbtn];
    self.navigationItem.leftBarButtonItem = SearchItem;
    
 
    
}
-(void)doneEditName{
     NSString *temp = [_txtField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (temp.length == 0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"Please type your presentation name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show ];
    }else{
        [DBDaoHelper updateSummaryNameById:_summaryId SummaryName:temp];
        [self.navigationController setTitle:_txtField.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
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
