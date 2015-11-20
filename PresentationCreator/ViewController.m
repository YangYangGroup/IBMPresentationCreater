//
//  ViewController.m
//  PresentationCreator
//
//  Created by songyang on 15/9/29.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "ViewController.h"
#import "ViewTableViewCell.h"
#import "ShowViewController.h"
#import "ProjectModel.h"
#import "DBDaoHelper.h"

@interface ViewController ()
@property (nonatomic, strong) UITableView *tabView;
@property (nonatomic, strong) UITextField *DBtextField;
@property (nonatomic, strong) NSMutableArray *mutableArray;
@end

@implementation ViewController
-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = NO;
    self.mutableArray = [DBDaoHelper selectTableArray];
    NSLog(@"%@",self.mutableArray);
    //tableview刷新
    [self.tabView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.DBtextField = [[UITextField alloc]init];
    self.mutableArray = [[NSMutableArray alloc]init];
    [self addNavigation];
    [self addTableView];
}
-(void)addNavigation
{
//    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];//设置navigationbar的颜色
//    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    
    
    self.navigationItem.title=@"Presentation Creator";
//    UIButton *rightbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    rightbtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
//    
//    rightbtn.frame = CGRectMake(0, 0, 20, 20);
//    [rightbtn addTarget:self action:@selector(setClick) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *SearchItem = [[UIBarButtonItem alloc]initWithCustomView:rightbtn];
//    [rightbtn setBackgroundImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
//    self.navigationItem.rightBarButtonItem = SearchItem;
}
-(void)addTableView
{
    UIView *aView = [[UIView alloc]init];
    [self.view addSubview:aView];
    _tabView = [[UITableView alloc] init];
    _tabView = [[UITableView alloc]initWithFrame:CGRectMake(0,64 , KScreenWidth, KScreenHeight-64-44) style:UITableViewStylePlain];
    _tabView.dataSource = self;
    _tabView.delegate = self;
    //    _tabView.scrollEnabled =NO; //设置tableview 不能滚动
    //隐藏系统的分割线
//    [_tabView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //    _tabView.separatorColor = [UIColor blackColor];
    [self.view addSubview:_tabView];
}
-(void)setClick
{
    
}
//设置列表有多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mutableArray.count;
}
//列表每行的高度
-  (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}
//列表每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"firstTable";
    ViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    //判断是否有隐藏的cell
    if (cell == nil)
    {
        cell = [[ViewTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    ProjectModel *model = [self.mutableArray objectAtIndex:indexPath.row];
    NSLog(@"%ld",(long)indexPath.row);
    cell.titleLabel.text = model.tableNameStr;
    return cell;
}
// UITableView的点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShowViewController *vc = [[ShowViewController alloc]init];
    ProjectModel *model =[self.mutableArray objectAtIndex:indexPath.row];
    NSLog(@"%@",model.tableNameStr);
    NSLog(@"%ld",model.tableId);
    NSString *str = [NSString stringWithFormat:@"%ld",model.tableId];
    NSInteger aaa = indexPath.row+1;
    NSString *summaryIdStr = [NSString stringWithFormat:@"%ld",(long)aaa];
    vc.showSummaryIdStr = summaryIdStr;
    vc.showSummaryNameStr = model.tableNameStr;
    vc.showTemplateIdStr = str;
    
    [self.navigationController pushViewController:vc animated:YES];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove";
}
//// delete function
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if(editingStyle == UITableViewCellEditingStyleDelete){
//        NSString *title = NSLocalizedString(@"Please confirm", nil);
//        NSString *message = NSLocalizedString(@"Do you want to delete?", nil);
//        NSString *cancelTitle = NSLocalizedString(@"Cancel", nil);
//        NSString *deleteTitle = NSLocalizedString(@"Delete", nil);
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//            
//        }];
//        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:deleteTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            ProjectModel *model = [_mutableArray objectAtIndex:indexPath.row];
            
            [DBDaoHelper deleteSummaryById:[NSString stringWithFormat:@"%ld",(long)model.tableId]];
            self.mutableArray = [DBDaoHelper selectTableArray];
            [self.tabView reloadData];
//        }];
//        [alertController addAction:cancelAction];
//        [alertController addAction:deleteAction];
//        [self presentViewController:alertController animated:YES completion:nil];
        
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
