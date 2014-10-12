//
//  LoginViewController.m
//  QLink
//
//  Created by 尤日华 on 14-9-17.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "DataUtil.h"
#import "NetworkUtil.h"
#import "SVProgressHUD.h"
#import "MyURLConnection.h"
#import "ASIHTTPRequest.h"

@interface LoginViewController ()
{
    NSMutableData *responseData_;
    Config *configTempObj_;//临时变量，存储Action=login请求对象
}
@end

@implementation LoginViewController

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
    
    [self initControlSet];
}

#pragma mark -
#pragma mark Custom Methods

-(void)initControlSet
{
    //设置输入框代理
    _tfKey.delegate = self;
    _tfName.delegate = self;
    _tfPassword.delegate = self;
    _tfPassword.secureTextEntry = YES;
    [_tfKey setValue:[NSNumber numberWithInt:10] forKey:PADDINGLEFT];
    [_tfName setValue:[NSNumber numberWithInt:10] forKey:PADDINGLEFT];
    [_tfPassword setValue:[NSNumber numberWithInt:10] forKey:PADDINGLEFT];
    
    //设置文本框值
    Member *member = [Member getMember];
    if (member && member.isRemeber) {
        _tfKey.text = member.uKey;
        _tfName.text = member.uName;
        _tfPassword.text = member.uPwd;
        _btnRemeber.selected = member.isRemeber;
    }
    
    //注册键盘出现与隐藏时候的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboadWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

//action=login
-(void)initRequestActionLogin
{
    [SVProgressHUD showWithStatus:@"正在验证..."];
    
    NSString *sUrl = [NetworkUtil getActionLogin:_tfName.text andUPwd:_tfPassword.text andUKey:_tfKey.text];
    
    NSURL *url = [NSURL URLWithString:sUrl];

    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:50];
    MyURLConnection *connection = [[MyURLConnection alloc]
                                   initWithRequest:request
                                   delegate:self];
    connection.sTag = LOGIN;

    if (connection) {
        responseData_ = [NSMutableData new];
    }
}

#pragma mark -
#pragma mark IBAction Methods

-(IBAction)btnLogin
{
    //判断登录是否为空
    if ([DataUtil checkNullOrEmpty:_tfName.text] || [DataUtil checkNullOrEmpty:_tfPassword.text] || [DataUtil checkNullOrEmpty:_tfKey.text]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:@"请输入完整的信息"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        
        [alert show];
        
        return;
    }
    
    [self initRequestActionLogin];
}

-(IBAction)btnRemeberPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
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
    
    [connection cancel];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:@"连接失败\n请确认网络是否连接." delegate:nil
                                              cancelButtonTitle:@"关闭"
                                              otherButtonTitles:nil, nil];
    [alertView show];
    
    [SVProgressHUD dismiss];
}
- (void)connectionDidFinishLoading: (MyURLConnection*)connection
{
    [SVProgressHUD dismiss];
    
    NSString *sConfig = [[NSString alloc] initWithData:responseData_ encoding:NSUTF8StringEncoding];
    
    NSArray *configArr = [sConfig componentsSeparatedByString:@"|"];
    if ([configArr count] < 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                        message:@"您输入的信息有误,请联系厂家"
                                                       delegate:nil
                                              cancelButtonTitle:@"关闭"
                                              otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    Member *curMember = [Member getMember];
    
    //处理配置信息
    configTempObj_ = [Config getTempConfig:configArr];
    NSString *curVersion = [SQLiteUtil getCurVersionNo];
    
    //重新解析配置文件
    if ((curMember && ![curMember.uKey isEqualToString:_tfKey.text])) {//更换用户
        //清除本地配置数据
        [SQLiteUtil clearData];
    }
    
    //设置登录信息
    [Member setUdMember:_tfName.text
                andUPwd:_tfPassword.text
                andUKey:_tfKey.text
           andIsRemeber:_btnRemeber.selected];
    
    if ((curMember && ![curMember.uKey isEqualToString:_tfKey.text]) || ![configTempObj_.configVersion isEqualToString:curVersion])//更换用户或者版本号不同则重新请求配置文件
    {
        ActionNullClass *actionNullClass = [[ActionNullClass alloc] init];
        actionNullClass.delegate = self;
        [actionNullClass initRequestActionNULL];
        
    }else{//读取本地数据配置
        NSLog(@"读取本地");
        
        [SQLiteUtil setDefaultLayerIdAndRoomId];
        
        MainViewController *mainVC = [[MainViewController alloc] init];
        [self.navigationController pushViewController:mainVC animated:YES];
    }
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.background = [UIImage imageNamed:@"登录页_输入框02.png"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.background = [UIImage imageNamed:@"登录页_输入框01.png"];
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
                                                            message:@"解析失败,请重试." delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [alertView show];
    }
}

-(void)successOper
{
    //解析存储成功，覆盖本地配置数据
    [Config setConfigObj:configTempObj_];
    
    [SVProgressHUD dismissWithSuccess:@"解析完成."];
    
    [SQLiteUtil setDefaultLayerIdAndRoomId];
    
    MainViewController *mainVC = [[MainViewController alloc] init];
    [self.navigationController pushViewController:mainVC animated:YES];
}

#pragma mark -
#pragma mark 通知注册

//键盘出现时候调用的事件
-(void) keyboadWillShow:(NSNotification *)note{
    [UIView animateWithDuration:0.2 animations:^(void){
        self.view.frame = CGRectMake(0, -60, 320, self.view.frame.size.height);
    }];
}

//键盘消失时候调用的事件
-(void)keyboardWillHide:(NSNotification *)note{
    [UIView animateWithDuration:0.2 animations:^(void){
        self.view.frame = CGRectMake(0, 0, 320, self.view.frame.size.height);
    }];
}

#pragma mark -

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_tfKey resignFirstResponder];
    [_tfName resignFirstResponder];
    [_tfPassword resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
