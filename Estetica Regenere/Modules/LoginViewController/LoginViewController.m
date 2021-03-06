//
//  LoginViewController.m
//  Estetica Regenere
//
//  Created by Adriano on 10/12/15.
//  Copyright (c) 2015 Adriano. All rights reserved.
//

#import "LoginViewController.h"
#import "BasicButtonView.h"
#import "LoadingView.h"
#import "LoginProvider.h"
#import "HomeViewController.h"
#import "LoginFormView.h"
#import "SignUpViewController.h"

@interface LoginViewController () <BasicButtonProtocol, LoginProviderDelegate, SignUpViewControllerDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet LoginFormView *loginFormView;
@property (weak, nonatomic) IBOutlet BasicButtonView *performLoginBasicButton;
@property (weak, nonatomic) IBOutlet LoadingView *loadingView;
@property (strong, nonatomic) id<LoginViewControllerCallback> delegate;

@end

@implementation LoginViewController

-(instancetype)initWithDelegate:(id<LoginViewControllerCallback>)delegate
{
    self = [super init];
    [self setDelegate:delegate];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self setupButtons];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark - private methods
- (void) setupNavigationBar
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void) setupButtons
{
    [self.performLoginBasicButton setType:BasicButtonTypeCallToAction];
    [self.performLoginBasicButton setTitle:@"Entrar no app"];
    [self.performLoginBasicButton setDelegate:self];
    
}

-(void) displayAlertWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (IBAction)signupButton:(id)sender {

    [self presentViewController:[SignUpViewController signUpViewControllerWithDelegate:self] animated:YES completion:nil];

}

#pragma mark - BasicButtonDelegate
-(void)buttonTapped:(id)button
{
    if (button == self.performLoginBasicButton) {
        [self.loadingView startLoading];
        [[LoginProvider new] performLoginWithEmail:[self.loginFormView getEmail] passord:[self.loginFormView getPassword] delegate:self];
    }
}

#pragma mark - LoginProviderDelegate
-(void)onLoginSuccessWithToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"user-token"];
    [self.loadingView stopLoading];
    [self.delegate dismissLoginViewController];

}

-(void)onLoginFailure
{
    [self displayAlertWithTitle:@"Erro no login" message:@"Verifique se o e-mail e a senha estão certos"];
}

-(void)onNetworkFailure
{
    [self displayAlertWithTitle:@"Erro na rede" message:@"Não possível se conectar à Internet"];
}

-(void)onResponseFailure
{
    [self displayAlertWithTitle:@"Erro na rede" message:@"Não foi possível efetuar login. Por favor tente mais tarde."];
}

#pragma mark - AlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.loadingView stopLoading];
}

#pragma mark - Sign Up Delegate
- (void)onSignUpSuccessWithEmail:(NSString *)email
                        password:(NSString *)password
{
    [[LoginProvider new] performLoginWithEmail:email
                                       passord:password
                                      delegate:self];
}
@end
