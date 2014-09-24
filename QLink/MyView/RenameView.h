//
//  RenameView.h
//  QLink
//
//  Created by SANSAN on 14-9-23.
//  Copyright (c) 2014年 SANSAN. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RenameViewDelegate <NSObject>

-(void)handleCanclePressed;
-(void)handleConfirmPressed:(NSString *)deviceId
                 andNewName:(NSString *)newName
                    andType:(NSString *)pType;

@end

@interface RenameView : UIView<UITextFieldDelegate>

@property(nonatomic,strong) IBOutlet UITextField *tfContent;
@property(nonatomic,assign) id<RenameViewDelegate>delegate;

@property(nonatomic,strong) NSString *pDeviceId;
@property(nonatomic,strong) NSString *pType;

-(IBAction)btnCanclePressed;
-(IBAction)btnConfirm;

@end
