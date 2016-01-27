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
#import "AFNetworking.h"
#import "SBJson.h"
#import "TemplateModel.h"
#import "DBDaoHelper.h"

@interface SettingsViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *settingsTableView;
@property (nonatomic, strong) NSString *availableFlag;
@property (nonatomic, strong) NSMutableArray *returnTemplateArr;
@property (nonatomic, strong) NSMutableArray *nextPostArr;
@property (nonatomic, assign) int isFirstTime;


@end

@implementation SettingsViewController
-(void)viewWillAppear:(BOOL)animated{
    self.isFirstTime = [DBDaoHelper checkTemplateDataIsNull];
    [self.settingsTableView reloadData];
    [self firstSynchronizationTemplate];
    
    
    
//    [self SecondSynchronizationTemplate];
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
-(void)firstSynchronizationTemplate
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    _nextPostArr = [[NSMutableArray alloc]init];
    NSMutableArray *postArr = [[NSMutableArray alloc]init];
   
    
    if(self.isFirstTime == 0){
        NSMutableDictionary *dictNoData = [[NSMutableDictionary alloc]init];
        [dictNoData setObject:@"" forKey:@"templateId"];
        [dictNoData setObject:@"" forKey:@"updateFlag"];
        [postArr addObject:dictNoData];
    }else{
         NSMutableDictionary *dictAllTemplateIdAndFlag = [[NSMutableDictionary alloc]init];
        _returnTemplateArr = [DBDaoHelper selectTemplateIdAndUpdateFlag];
        
        for (TemplateModel *tm in _returnTemplateArr) {
            [dictAllTemplateIdAndFlag setObject:tm.templateId forKey:@"templateId"];
            [dictAllTemplateIdAndFlag setObject:tm.updateFlag forKey:@"updateFlag"];
        }
        [postArr addObject:dictAllTemplateIdAndFlag];
    }
   
    NSLog(@"%@",[postArr JSONRepresentation]);
    //你的接口地址
    NSString *url=@"http://9.115.24.148/PPT/service/templateCheck";
    //发送请求
    [manager POST:url parameters:postArr success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *resultJsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        
        NSDictionary *resultJsonDic = [resultJsonArray objectAtIndex:0];
        NSLog(@"return flag:%@",resultJsonDic);
         NSMutableArray *arr = [resultJsonDic objectForKey:@"templateList"];
        NSLog(@"return flag:%ld",(long)arr.count);
        if ([[resultJsonDic objectForKey:@"flag"]isEqualToString:@"1"]) {
            self.availableFlag = @"T";
            
        }else{
            self.availableFlag = @"F";
        }
      //  [self SecondSynchronizationTemplate];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
}
-(BOOL)SecondSynchronizationTemplate
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //申明返回的结果是json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //申明请求的数据是json类型
    manager.requestSerializer=[AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//    NSMutableArray *postArr = [[NSMutableArray alloc]init];
//    NSMutableDictionary *dic2 = [[NSMutableDictionary alloc]init];
//    
//    [dic2 setObject:@"8196f261-66f7-4742-a690-fa70bb2d8a8b" forKey:@"templateId"];
//    [postArr addObject:dic2];
//    NSLog(@"%@",[postArr JSONRepresentation]);
    
    //你的接口地址
    NSString *url=@"http://9.115.24.148/PPT/service/templateUpdate";
    [manager POST:url parameters:_nextPostArr success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *resultJsonArray = [NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"%@",resultJsonArray);
        NSDictionary *resultJsonDic = [resultJsonArray objectAtIndex:0];
        NSLog(@"JSON: %@", resultJsonDic);
        NSMutableArray *arr = [resultJsonDic objectForKey:@"templateList"];
        NSLog(@"template list length:%ld",(long)arr.count);
        for (int i = 0; i < arr.count; i++)
        {
            NSMutableDictionary *dic = [arr objectAtIndex:i];
            NSLog(@"%@",dic);
            //图片路径
            NSLog(@"%@",[dic objectForKey:@"icon"]);
            
            
            [LoadingHelper hiddonLoadingWithView:self.view];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];

    return YES;
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
            cell.updateAvailableLabel.hidden = YES;
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
        
//        [NSThread sleepForTimeInterval:3.0];
        
        if ([self.availableFlag isEqualToString:@"T"]) {
            [LoadingHelper showLoadingWithView:self.view];
            if([self SecondSynchronizationTemplate]){
                
            }
           
        }
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
