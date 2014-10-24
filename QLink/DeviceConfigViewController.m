//
//  DeviceConfigViewController.m
//  QLink
//
//  Created by 尤日华 on 14-10-3.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "DeviceConfigViewController.h"
#import "SVProgressHUD.h"
#import "MyURLConnection.h"
#import "NetworkUtil.h"
#import "XMLDictionary.h"
#import "DataUtil.h"
#import "ILBarButtonItem.h"
#import "MainViewController.h"
#import "AFHTTPRequestOperation.h"

@interface DeviceConfigViewController ()
{
    NSArray *deviceArr_;
    NSDictionary *iconDic_;
    
    NSString *typeTag_;
    NSString *tabName_;
    
    UIButton *btnIconSel_;
}

@end

@implementation DeviceConfigViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    typeTag_ = @"_producttype";
    tabName_ = @"kfsetup";
    
    [self initNavigation];
    
    [self initControl];
    
    [self initData];

    [self initRequest:[NetworkUtil getAction:ACTIONSETUP]];
}

//设置导航
-(void)initNavigation
{
    ILBarButtonItem *back =
    [ILBarButtonItem barItemWithImage:[UIImage imageNamed:@"首页_返回.png"]
                        selectedImage:[UIImage imageNamed:@"首页_返回.png"]
                               target:self
                               action:@selector(btnBackPressed)];
    
    self.navigationItem.leftBarButtonItem = back;
    
    UIButton *btnTitle = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTitle.frame = CGRectMake(0, 0, 100, 20);
    [btnTitle setTitle:@"您拥有的设备" forState:UIControlStateNormal];
    btnTitle.titleEdgeInsets = UIEdgeInsetsMake(-5, 0, 0, 0);
    btnTitle.backgroundColor = [UIColor clearColor];
    
    [btnTitle setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.navigationItem.titleView = btnTitle;
}

-(void)initControl
{
    _tbDevice.delegate = self;
    _tbDevice.dataSource = self;
    if ([_tbDevice respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tbDevice setSeparatorInset:UIEdgeInsetsZero];
    }
}

-(void)initData
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"DeviceConfigIconPlist" ofType:@"plist"];
    iconDic_ = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
}

-(void)initRequest:(NSString *)sUrl
{
    [SVProgressHUD showWithStatus:@"加载中..." maskType:SVProgressHUDMaskTypeBlack];
    
    NSURL *url = [NSURL URLWithString:sUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [SVProgressHUD dismiss];
         
         NSString *sResult = [[NSString alloc] initWithData:responseObject encoding:[DataUtil getGB2312Code]];
         
         if (![DataUtil checkNullOrEmpty:sResult]) {
             if ([sResult isEqualToString:@"ok"]) {
                 ActionNullClass *actionNullClass = [[ActionNullClass alloc] init];
                 actionNullClass.delegate = self;
                 [actionNullClass initRequestActionNULL];
                 
             } else {
                 sResult = [sResult stringByReplacingOccurrencesOfString:@"\"GB2312\"" withString:@"\"utf-8\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,40)];
                 NSData *newData = [sResult dataUsingEncoding:NSUTF8StringEncoding];
                 
                 NSDictionary *dict = [NSDictionary dictionaryWithXMLData:newData];
                 
                 if (!dict) {
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                     message:@"配置出错,请重试."
                                                                    delegate:nil
                                                           cancelButtonTitle:@"关闭"
                                                           otherButtonTitles:nil, nil];
                     [alert show];
                     
                     return;
                 }
                 NSDictionary *info = [dict objectForKey:@"info"];
                 deviceArr_ = [DataUtil changeDicToArray:[info objectForKey:tabName_]];
                 
                 [_tbDevice reloadData];
             }
         } else {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"配置出错,请重试."
                                                            delegate:nil
                                                   cancelButtonTitle:@"关闭"
                                                   otherButtonTitles:nil, nil];
             [alert show];
             
             return;
         }
         
     }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"连接失败\n请确认网络是否连接." delegate:nil
                                                   cancelButtonTitle:@"关闭"
                                                   otherButtonTitles:nil, nil];
         [alertView show];
         
         [SVProgressHUD dismiss];
     }];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:operation];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [deviceArr_ count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"CELL";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSDictionary *setDic = [deviceArr_ objectAtIndex:indexPath.row];
    
    NSString *imgName = @"";
    NSString *imgNameSel = @"";
    if ([tabName_ isEqualToString:@"kfsdevice"]) {
        NSString *type = [setDic objectForKey:@"_type"];
        //处理‘点动’和‘翻转’的图标
        if ([type isEqualToString:@"light_1"] || [type isEqualToString:@"light_check"]) {
            type = @"light";
        }
        imgName = [NSString stringWithFormat:@"%@.png",type];
        imgNameSel = [NSString stringWithFormat:@"%@_select.png",type];
    }else{
        imgName = [NSString stringWithFormat:@"%@.png",[iconDic_ objectForKey:[setDic objectForKey:typeTag_]]];
        imgNameSel = [NSString stringWithFormat:@"%@02.png",[iconDic_ objectForKey:[setDic objectForKey:typeTag_]]];
    }
    
    UIButton *btnIcon = [UIButton buttonWithType:UIButtonTypeCustom];
    btnIcon.frame = CGRectMake(15, 15, 62, 62);
    [btnIcon setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [btnIcon setImage:[UIImage imageNamed:imgNameSel] forState:UIControlStateSelected];
    btnIcon.tag = 100 + indexPath.row;
    [cell.contentView addSubview:btnIcon];
    
    UILabel *lTitle = [[UILabel alloc] init];
    lTitle.frame = CGRectMake(90, 15, 218, 62);
    lTitle.textColor = [UIColor whiteColor];
    lTitle.backgroundColor = [UIColor clearColor];
    lTitle.font = [UIFont systemFontOfSize:14.0];
    lTitle.text = [setDic objectForKey:@"_name"];
    [cell.contentView addSubview:lTitle];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 92;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //设置图标选中
    btnIconSel_.selected = NO;
    UIButton *btnIcon = (UIButton *)[tableView viewWithTag:(100+indexPath.row)];
    btnIcon.selected = YES;
    btnIconSel_ = btnIcon;
    
    //设置请求类型
    typeTag_ = @"_type";
    tabName_ = @"kfsdevice";
    
    //请求
    NSDictionary *setDic = [deviceArr_ objectAtIndex:indexPath.row];
    NSString *sUrl = [setDic objectForKey:@"_url"];
    [self initRequest:sUrl];
}

#pragma mark -
#pragma mark ActionNullClassDelegate

-(void)failOper
{
    NSString *curVersion = [SQLiteUtil getCurVersionNo];
    if (![DataUtil checkNullOrEmpty:curVersion]) {
        //读取本地配置
        [SQLiteUtil setDefaultLayerIdAndRoomId];
        
        MainViewController *mainVC = [[MainViewController alloc] init];
        [self.navigationController pushViewController:mainVC animated:YES];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"配置失败,请重试." delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void)successOper
{
    [SVProgressHUD dismissWithSuccess:@"配置完成."];
    [SQLiteUtil setDefaultLayerIdAndRoomId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDeviceTab" object:nil];
    
    self.zkOperType = ZkOperDevice;
    [self load_typeSocket:SocketTypeWriteZk andOrderObj:nil];
}

#pragma mark -
#pragma mark Custom Methods

-(void)btnBackPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
