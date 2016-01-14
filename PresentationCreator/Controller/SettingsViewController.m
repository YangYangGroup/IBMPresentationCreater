//
//  SettingsViewController.m
//  PresentationCreator
//
//  Created by Lin Lecui on 16/1/14.
//  Copyright © 2016年 songyang. All rights reserved.
//

#import "SettingsViewController.h"
#import "SynchronizeTableViewCell.h"
#import "LoadingHelper.h"

@interface SettingsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *settingsTableView;
@property (nonatomic, strong) NSString *availableFlag;
@end

@implementation SettingsViewController
-(void)viewWillAppear:(BOOL)animated{
    self.availableFlag = @"F";
    [self.settingsTableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   
    [self addNavigation];
    [self initUITableView];
}

-(void)addNavigation
{
    self.navigationItem.title=@"Settings";
}

#pragma init UITableView
-(void)initUITableView{
    self.settingsTableView = nil;
    self.settingsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64)];
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;
    self.settingsTableView.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1.0];
//    self.settingsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.settingsTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.settingsTableView];
}

//设置列表有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger row;
    if (section == 0) {
        row = 1;
    }else{
        row = 3;
    }
    
    return row;
}
// height for row
-  (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat f;
    if (indexPath.section ==0) {
        f = 74;
    }else{
        f = 50;
    }
    return f;
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
//列表每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        SynchronizeTableViewCell *cell = [[SynchronizeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        if ([self.availableFlag isEqualToString:@"T"]) {
            cell.updateAvailableLabel.hidden = YES;
            cell.updateAvailableLabel.alpha = 0.8;
        }else{
            cell.updateAvailableLabel.hidden = NO;
        }
        return cell;
    }
    NSString *identifier = @"firstTable";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //判断是否有隐藏的cell
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    //    ProjectModel *model = [self.mutableArray objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"moments"];
    cell.textLabel.text = @"Building...";
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        SynchronizeTableViewCell *cell = [self.settingsTableView cellForRowAtIndexPath:indexPath];
        cell.updateAvailableLabel.hidden = YES;
        [LoadingHelper showLoadingWithView:self.view];
//        [NSThread sleepForTimeInterval:3.0];
        [LoadingHelper hiddonLoadingWithView:self.view];
    }
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
