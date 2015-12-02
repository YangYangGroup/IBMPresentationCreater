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
#import "ShowViewController.h"

@interface SelectTemplateViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITextViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) NSMutableArray *detailsArray;//获取details表对象
@property (nonatomic, strong) NSString *maxSummaryIdStr;//取summary表中最大的主键值
@property (nonatomic, strong) NSString *summaryNameStr;
@property (nonatomic, strong) UIControl *titleViewControl;
@property (nonatomic, strong) UITextView *titleTextView;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic) NSInteger selectTemplateIndex;

@end

@implementation SelectTemplateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Select A Template";
    [self addCollectionView];
    self.imageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"IMG_1"],[UIImage imageNamed:@"IMG_6"],nil];
    
    self.titleArray = [NSArray arrayWithObjects:@"First Template",@"Second Template", nil];
}
#pragma mark - CollectionView
-(void)addCollectionView
{
    UIView *aView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:aView];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//横竖滚动样式
    //    flowLayout.footerReferenceSize = CGSizeMake(KScreenWidth-80, 400);//头部.尾部设置
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64+5, KScreenWidth-10, KScreenHeight-64-10-50) collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
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
    
    return CGSizeMake((KScreenWidth-10-5)/2, (KScreenHeight-64-10-5)/2);
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
//    SelectTemplateCollectionViewCell * cell = (SelectTemplateCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    CreationEditViewController *creationVC = [[CreationEditViewController alloc]init];
//    
//    creationVC.selectTemplateIndex = indexPath.item;
//    [self.navigationController pushViewController:creationVC animated:YES];
    _selectTemplateIndex = indexPath.row;
    [self addClick];
    
}


#pragma show ppt name function
//这个是判断没有输入的时候按钮为不可用状态
-(void)textViewDidChange:(UITextView *)textView{
    if (_titleTextView.text.length > 0) {
        _okButton.enabled = YES;
    }else{
        _okButton.enabled = NO;
    }
}
-(void)addClick
{
    self.navigationController.navigationBarHidden =YES;//隐藏系统自带导航栏按钮
    _titleViewControl = [[UIControl alloc]initWithFrame:CGRectMake(0, 20, KScreenWidth, KScreenHeight+5)];
    _titleViewControl.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
    
    UILabel *titleLabel = [[UILabel alloc]init];
    titleLabel.frame = CGRectMake(20, 20, KScreenWidth, 30);
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = @"Presentation name:";
    [_titleViewControl addSubview:titleLabel];
    
    _titleTextView = [[UITextView alloc]init];
    _titleTextView.frame = CGRectMake(20, 50, KScreenWidth-40, KScreenHeight*0.25);
    _titleTextView.delegate = self;
    _titleTextView.layer.borderColor = [UIColor blackColor].CGColor;
    _titleTextView.layer.borderWidth = 1;
    _titleTextView.layer.cornerRadius = 6;
    _titleTextView.layer.masksToBounds = YES;
    _titleTextView.backgroundColor = [UIColor whiteColor];
    [_titleTextView becomeFirstResponder];
    [_titleViewControl addSubview:_titleTextView];
    
    
    //back按钮
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(60 , 30 + KScreenHeight*0.25 + 40, 60, 40);
    [backBtn setTitle:@"Back" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    backBtn.backgroundColor = [UIColor grayColor];
    backBtn.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [backBtn.layer setMasksToBounds:YES];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    //    [backBtn.layer setBorderWidth:1.0];
    [backBtn.layer setCornerRadius:7.0];
    backBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [backBtn addTarget:self action:@selector(backShowViewClick) forControlEvents:UIControlEventTouchUpInside];
    [_titleViewControl addSubview:backBtn];
    
    // 点击OK按钮，保存到summary表中，并返回最大的主键。
    _okButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _okButton.frame = CGRectMake(KScreenWidth-60-60 , 30 + KScreenHeight*0.25 + 40, 60, 40);
    [_okButton setTitle:@"Save" forState:UIControlStateNormal];
    [_okButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    _okButton.backgroundColor = [UIColor grayColor];
    _okButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [_okButton.layer setMasksToBounds:YES];
    [_okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    //    [_okButton.layer setBorderWidth:1.0];
    [_okButton.layer setCornerRadius:7.0];
    _okButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_okButton addTarget:self action:@selector(saveSummaryTile) forControlEvents:UIControlEventTouchUpInside];
    _okButton.enabled = NO;
    [_titleViewControl addSubview:_okButton];
    
    [self.view addSubview:_titleViewControl];
    [self.view bringSubviewToFront:_titleViewControl];
}
-(void)backShowViewClick
{
    [_titleViewControl removeFromSuperview];
    _titleViewControl = nil;
}
-(void)saveSummaryTile{
    
    NSString *temp = [_titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //看剩下的字符串的长度是否为零
    if ([temp length]!=0) {
        self.summaryNameStr = _titleTextView.text;
        self.navigationItem.title=self.summaryNameStr;
        self.maxSummaryIdStr = [DBDaoHelper insertSummaryWithName:_titleTextView.text];
        [_titleViewControl removeFromSuperview];
        _titleViewControl = nil;
        self.navigationController.navigationBarHidden =NO;
        
        if (self.selectTemplateIndex == 0) {
            
            //像details表添加2条数据 首页 尾页
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"1" HtmlCode:template_1 PageNumber:@"1"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"2" HtmlCode:template_2 PageNumber:@"2"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"3" HtmlCode:template_3 PageNumber:@"3"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"4" HtmlCode:template_4 PageNumber:@"4"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"5" HtmlCode:template_5 PageNumber:@"5"];
        }else if (self.selectTemplateIndex == 1){
            //像details表添加2条数据 首页 尾页
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"1" HtmlCode:template_1 PageNumber:@"1"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"6" HtmlCode:template_6 PageNumber:@"2"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"7" HtmlCode:template_7 PageNumber:@"3"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"8" HtmlCode:template_8 PageNumber:@"4"];
            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"9" HtmlCode:template_9 PageNumber:@"5"];
            //            [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"5" HtmlCode:template_5 PageNumber:@"6"];
            //        [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"5" HtmlCode:template_5 PageNumber:@"7"];
        }
        
        
        ShowViewController *vc = [[ShowViewController alloc]init];
        
        vc.showSummaryIdStr = _maxSummaryIdStr;
        vc.showSummaryNameStr =  _summaryNameStr;
        vc.showTemplateIdStr = _maxSummaryIdStr;
        [self.navigationController pushViewController:vc animated:YES];
        
        //    //像details表添加2条数据 首页 尾页
        //    [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"1" HtmlCode:template_1 PageNumber:@"1"];
        //    [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:@"5" HtmlCode:template_5 PageNumber:@"2"];
        //查询details表
        self.detailsArray = [DBDaoHelper selectDetailsDataBySummaryId:self.maxSummaryIdStr];
        [self.collectionView reloadData];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:@"Please type your presentation name." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alertView show ];
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
