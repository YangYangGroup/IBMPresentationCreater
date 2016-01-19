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
#import "TemplateModel.h"
#import "ShowTemplateDetailsViewController.h"

@interface SelectTemplateViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITextViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *templateArray;

@property (nonatomic, strong) NSMutableArray *detailsArray;//获取details表对象
@property (nonatomic, strong) NSString *maxSummaryIdStr;//取summary表中最大的主键值
@property (nonatomic, strong) NSString *summaryNameStr;
@property (nonatomic, strong) UIControl *titleViewControl;
@property (nonatomic, strong) UITextView *titleTextView;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic) NSInteger selectTemplateIndex;

@end

@implementation SelectTemplateViewController
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
   
//    if([self.checkFlag isEqualToString:@"new"]){
    [self addClick];
//    }
//    if ([self.checkFlag isEqualToString:@"edit"]) {
//        NSString *tmpTId = [NSString stringWithFormat:@"%ld",(long)self.selectTemplateIndex];
//        TemplateModel *tm = [[TemplateModel alloc]init];
//        tm = [self.templateArray objectAtIndex:indexPath.row];
//        
//        ShowTemplateDetailsViewController *showVC =
//        [[ShowTemplateDetailsViewController alloc]init];
//        showVC.templateId = tm.templateId;
//        [self.navigationController pushViewController:showVC animated:YES];
//
//    }
    
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
    self.navigationController.navigationBarHidden = NO;
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
        
        TemplateModel *tModel = [[TemplateModel alloc]init];
        tModel = [self.templateArray objectAtIndex:self.selectTemplateIndex];
        NSMutableArray *tdArray = [DBDaoHelper queryTemplateDetailsWithTemplateId:tModel.templateId];
        
        
        for (int i=0; i < tdArray.count; i++) {
            NSString *pageNumber = [NSString stringWithFormat:@"%ld",(long)i];
            TemplateDetailsModel *tdModel = [[TemplateDetailsModel alloc]init];
            tdModel = [tdArray objectAtIndex:i];
            
             [DBDaoHelper insertHtmlToDetailsSummaryIdWith:self.maxSummaryIdStr TemplateId:tModel.templateId TemplateDetailsId:tdModel.templateDetailsId HtmlCode:tdModel.templateHtml PageNumber:pageNumber];
        }
        
        ShowViewController *vc = [[ShowViewController alloc]init];
        
        vc.showSummaryIdStr = _maxSummaryIdStr;
        vc.showSummaryNameStr =  _summaryNameStr;
        vc.showTemplateIdStr = _maxSummaryIdStr;
        [self.navigationController pushViewController:vc animated:YES];
        
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
