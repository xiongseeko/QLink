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

@interface DeviceConfigViewController ()
{
    NSArray *deviceArr_;
    NSMutableData *responseData_;
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
    [SVProgressHUD showWithStatus:@"加载中..."];
    
    NSURL *url = [NSURL URLWithString:sUrl];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    MyURLConnection *connection = [[MyURLConnection alloc]
                                   initWithRequest:request
                                   delegate:self];
    connection.sTag = ACTIONSETUP;
    
    if (connection) {
        responseData_ = [NSMutableData new];
    }
}

#pragma mark -
#pragma mark NSURLConnection 回调方法
- (void)connection:(MyURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData_ appendData:data];
}
-(void) connection:(MyURLConnection *)connection didFailWithError: (NSError *)error
{
    NSLog(@"====fail");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                    message:@"请求出错,请稍后重试."
                                                   delegate:nil
                                          cancelButtonTitle:@"关闭"
                                          otherButtonTitles:nil, nil];
    [alert show];
    
    [SVProgressHUD dismiss];
}
- (void)connectionDidFinishLoading: (MyURLConnection*)connection
{
    [SVProgressHUD dismiss];
    
    if ([connection.sTag isEqualToString:ACTIONSETUP]) {
        NSString *sResult = [[NSString alloc] initWithData:responseData_ encoding:NSUTF8StringEncoding];
        if (![DataUtil checkNullOrEmpty:sResult]) {
            if ([sResult isEqualToString:@"ok"]) {
                NSLog(@"==ok==");
                
                ZKClass *zkClass = [[ZKClass alloc] init];
                zkClass.delegate = self;
                [zkClass initZhongKong];
                
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:@"添加设备出错,请重试."
                                                               delegate:nil
                                                      cancelButtonTitle:@"关闭"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                
                return;
            }
        } else {
            NSDictionary *dict = [NSDictionary dictionaryWithXMLData:responseData_];
            if (!dict) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:@"解析出错,请重试."
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
    }
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
#pragma mark ZKClassDelegate

-(void)successZKOper
{
    ActionNullClass *actionNullClass = [[ActionNullClass alloc] init];
    actionNullClass.delegate = self;
    [actionNullClass initRequestActionNULL];
}

#pragma mark -
#pragma mark ActionNullClassDelegate

-(void)failOper
{
    MainViewController *mainVC = [[MainViewController alloc] init];
    [self.navigationController pushViewController:mainVC animated:NO];
}

-(void)successOper
{
    
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
