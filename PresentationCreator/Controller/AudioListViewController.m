//
//  AudioListViewController.m
//  PresentationCreator
//
//  Created by Lin Lecui on 15/12/1.
//  Copyright © 2015年 songyang. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "AudioListViewController.h"
#import "AudioListCell.h"
#import "DBDaoHelper.h"
#import "Global.h"

@interface AudioListViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSMutableArray *audioArray;
@property (nonatomic, strong) UITableView *audioTableView;
@property (nonatomic, strong) NSString *selectedAudioName;
@property (nonatomic, strong) NSString *audioPath;
@property (nonatomic, strong) NSString *audioId;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;//音频播放器，用于播放录音文件
@end

@implementation AudioListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addNavigation];
    _audioArray = [[NSMutableArray alloc]init];
    _audioArray = [DBDaoHelper queryAllAudioFiles];
    
    NSLog(@"_aud path:%@",_audName);
    if([_audName length]>0){
        for (int i=0; i<_audioArray.count; i++) {
            FilesModel *fm = [[FilesModel alloc]init];
            fm = [_audioArray objectAtIndex:i];
            if ([_audName isEqualToString:fm.filePathStr]) {
                fm.isChecked = @"1";
                [_audioArray replaceObjectAtIndex:i withObject:fm];
            }
        }
    }
    [self loadAudioTableView];
}
-(void)addNavigation
{
    self.navigationItem.title=@"Select audio";
    UIButton *backbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    backbtn.frame = CGRectMake(0, 0, 30, 30);
    [backbtn setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backbtn addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:backbtn];
    self.navigationItem.leftBarButtonItem = backItem;
}

-(void)backClick{
    // 发送通知
    NSLog(@"audio id: %@",_audioId);
    
    if(_audioId.length != 0){
        [DBDaoHelper updateDetailByFileId:_audioId DetailsId:_detailsId];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectedAudioName" object:_selectedAudioName];
        
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)loadAudioTableView{
    _audioTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    _audioTableView.dataSource = self;
    _audioTableView.delegate = self;
    _audioTableView.backgroundColor = [UIColor  colorWithRed:237.0f/255.0f green:237.0f/255.0f blue:237.0f/255.0f alpha:0.7];
    [self.view addSubview:_audioTableView];
}
#pragma audio list table view

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _audioArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identitify = @"id";
    AudioListCell *cell = [tableView dequeueReusableCellWithIdentifier:identitify];
    if(cell == nil){
        cell = [[AudioListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identitify];
    }
    cell.backgroundColor = [UIColor  colorWithRed:187.0f/255.0f green:187.0f/255.0f blue:187.0f/255.0f alpha:0.5];
    
    FilesModel *fileModel = [FilesModel new];
    fileModel = [_audioArray objectAtIndex:indexPath.row];
    
    NSString *audioNm = [[NSString alloc]initWithString:fileModel.filePathStr];
    NSRange range = [audioNm rangeOfString:@"Documents/"];
    audioNm = [audioNm substringFromIndex:NSMaxRange(range)];
    cell.nameLabel.text = audioNm;
    if([fileModel.isChecked isEqualToString:@"1"]){
        cell.checkBox.image = [UIImage imageNamed:@"checkbox_checked.png"];
        _audioPath = fileModel.filePathStr;
    }else{
        cell.checkBox.image = [UIImage imageNamed:@"checkbox_unchecked.png"];
    }
    return  cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FilesModel *fm = [[FilesModel alloc]init];
    fm = [_audioArray objectAtIndex:indexPath.row];
    
    NSURL *url = [NSURL fileURLWithPath:fm.filePathStr];
    NSError *error = nil;
    _audioPlayer = nil;
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    _audioPlayer.volume = 1.0;
    [_audioPlayer play];
    
    
    for (int i = 0 ; i<_audioArray.count; i++) {
        FilesModel *fModel = [FilesModel new];
        fModel = [_audioArray objectAtIndex:i];
        fModel.isChecked = @"0";
        if (i == indexPath.row) {
            fModel.isChecked = @"1";
            _selectedAudioName = fModel.filePathStr;
            _audioId = [[NSString alloc]init];
            _audioId = fModel.fileIdStr;
        }
        
        [_audioArray replaceObjectAtIndex:i  withObject:fModel];
        fModel = nil;
    }
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    NSLog(@"audio name:%@",_selectedAudioName);
    [_audioTableView reloadData];
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
