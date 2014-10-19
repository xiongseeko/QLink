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
#import "AFNetworking.h"
#import "XMLDictionary.h"

@interface LoginViewController ()
{
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

-(void)initRequestActionLogin
{
    [SVProgressHUD showWithStatus:@"正在验证..."];
    
    NSString *sUrl = [NetworkUtil getActionLogin:_tfName.text andUPwd:_tfPassword.text andUKey:_tfKey.text];
    NSURL *url = [NSURL URLWithString:sUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __weak __typeof(self)weakSelf = self;
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSString *sConfig = [[NSString alloc] initWithData:responseObject encoding:[DataUtil getGB2312Code]];
        
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
        
        //处理配置信息
        configTempObj_ = [Config getTempConfig:configArr];
        
        weakSelf.pName = _tfName.text;
        weakSelf.pPwd = _tfPassword.text;
        weakSelf.pKey = _tfKey.text;
        weakSelf.pIsSelected = _btnRemeber.selected;
        weakSelf.pConfigTemp = configTempObj_;
        
        if (configTempObj_.isSetIp) {//需要配置ip
            [weakSelf initSetUpIp];
        } else
        {
            [weakSelf actionNULL];
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
#pragma mark Custom Methods

-(void)initSetUpIp
{
    [SVProgressHUD showWithStatus:@"正在配置ip..."];
    
    NSString *sUrl = [NetworkUtil getAction:ACTIONSETUPIP];
    NSURL *url = [NSURL URLWithString:sUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSString *strXML = [[NSString alloc] initWithData:responseObject encoding:[DataUtil getGB2312Code]];
        strXML = [strXML stringByReplacingOccurrencesOfString:@"\"GB2312\"" withString:@"\"utf-8\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0,40)];
        NSData *newData = [strXML dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSDictionary dictionaryWithXMLData:newData];
         
        if (!dict) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                             message:@"配置ip出错,请重试."
                                                            delegate:nil
                                                   cancelButtonTitle:@"关闭"
                                                   otherButtonTitles:nil, nil];
            [alert show];
            return;
        }
         
        //设置Ip Socket
        [self load_setIpSocket:dict];
    
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
