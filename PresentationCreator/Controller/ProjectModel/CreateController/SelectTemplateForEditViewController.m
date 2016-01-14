//
//  SelectTemplateForEditViewController.m
//  PresentationCreator
//
//  Created by Lin Lecui on 16/1/12.
//  Copyright © 2016年 songyang. All rights reserved.
//

#import "SelectTemplateForEditViewController.h"
#import "SelectTemplateCollectionViewCell.h"
#import "ShowTemplateDetailsViewController.h"
#import "TemplateModel.h"

@interface SelectTemplateForEditViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITextViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *templateArray;
@property (nonatomic) NSInteger selectTemplateIndex;


@end

@implementation SelectTemplateForEditViewController

-(void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title = @"Select Template";
    //    self.parentViewController.tabBarController.tabBar.hidden = YES;
    self.parentViewController.tabBarController.tabBar.hidden = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.templateArray = [DBDaoHelper queryAllTemplate];
    [self addCollectionView];
    [self addNavigation];
}

-(void)addNavigation{
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    backbtn.frame = CGRectMake(0, 0, 30, 30);
    [backbtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backbtn];
    self.navigationItem.leftBarButtonItem = backItem;
}

-(void)backClick{
     [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - CollectionView
-(void)addCollectionView
{
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:aView];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//横竖滚动样式
    //    flowLayout.footerReferenceSize = CGSizeMake(KScreenWidth-80, 400);//头部.尾部设置
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64+5, KScreenWidth-10, KScreenHeight-64-10) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1.0];
    
    //设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    //注册cell和ReusableView（相当于头部）
    [self.collectionView registerClass:[SelectTemplateCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ReusableView"];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.templateArray.count;
}
//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    SelectTemplateCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    
    TemplateModel *tm = [[TemplateModel alloc]init];
    tm = [self.templateArray objectAtIndex:indexPath.row];
    cell.imgView.image = [UIImage imageNamed:tm.templateThumbNail];
    cell.titleLable.text = tm.templateName;
    
    return cell;
}
#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake((KScreenWidth-10-5)/2, (KScreenHeight-64-5)/2);
}
//定义每个UICollectionView 的间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1,1, 1, 1);
}
//定义每个UICollectionView 纵向的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
//设置每个collectionview的行间距   每个cell的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    _selectTemplateIndex = indexPath.row;
    
    TemplateModel *tm = [[TemplateModel alloc]init];
    tm = [self.templateArray objectAtIndex:indexPath.row];
    
    ShowTemplateDetailsViewController *showVC =
                                    [[ShowTemplateDetailsViewController alloc]init];
    showVC.templateId = tm.templateId;
    showVC.showSummaryIdStr = self.showSummaryIdStr;
    
    [self.navigationController pushViewController:showVC animated:YES];
    
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
