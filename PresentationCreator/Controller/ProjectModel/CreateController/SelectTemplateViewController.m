//
//  SelectTemplateViewController.m
//  PresentationCreator
//
//  Created by songyang on 15/10/21.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import "SelectTemplateViewController.h"
#import "SelectTemplateCollectionViewCell.h"
#import "CreationEditViewController.h"

@interface SelectTemplateViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *titleArray;
@end

@implementation SelectTemplateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Select A Template";
    [self addCollectionView];
//    self.imageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"IMG_1"],[UIImage imageNamed:@"IMG_2"],[UIImage imageNamed:@"IMG_3"],[UIImage imageNamed:@"IMG_4"],[UIImage imageNamed:@"IMG_5"],[UIImage imageNamed:@"IMG_6"],[UIImage imageNamed:@"IMG_7"],[UIImage imageNamed:@"IMG_8"],[UIImage imageNamed:@"IMG_9"],[UIImage imageNamed:@"IMG_10"],nil];
//    
//    self.titleArray = [NSArray arrayWithObjects:@"ppt1",@"ppt2",@"ppt3",@"ppt4",@"ppt5",@"ppt6",@"ppt7",@"ppt8",@"ppt9",@"ppt10", nil];
    self.imageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"IMG_1"],[UIImage imageNamed:@"IMG_6"],nil];
    
    self.titleArray = [NSArray arrayWithObjects:@"First Template",@"Second Template", nil];
}
#pragma mark - CollectionView
-(void)addCollectionView
{
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:aView];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
//    flowLayout.footerReferenceSize = CGSizeMake(KScreenWidth, KScreenHeight-64);//头部.尾部设置
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 84, KScreenWidth, KScreenHeight-64-40-44) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    
    //设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    //注册cell和ReusableView（相当于头部）
    [self.collectionView registerClass:[SelectTemplateCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
//    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ReusableView"];
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.imageArray.count;
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
    cell.imgView.image = [self.imageArray objectAtIndex:indexPath.item];
    cell.titleLable.text = [self.titleArray objectAtIndex:indexPath.item];
    
    return cell;
}
#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(KScreenWidth, KScreenHeight-64-40-44);
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
#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    SelectTemplateCollectionViewCell * cell = (SelectTemplateCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    CreationEditViewController *creationVC = [[CreationEditViewController alloc]init];
    
    creationVC.selectTemplateIndex = indexPath.item;
    [self.navigationController pushViewController:creationVC animated:YES];
    
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
