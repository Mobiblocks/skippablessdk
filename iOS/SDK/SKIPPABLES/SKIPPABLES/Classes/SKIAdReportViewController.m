//
//  SKIAdReportViewController.m
//  SKIPPABLES
//
//  Created by Daniel on 2/16/18.
//  Copyright © 2018 Mobiblocks. All rights reserved.
//

#import "SKIAdReportViewController.h"

#import "SKIConstants.h"

@interface SKIAdReportWindowManager : NSObject

+ (instancetype)manager;

- (NSString *)showViewController:(UIViewController *)viewController;
- (void)hideViewController:(NSString *)identifier;

@property(strong, nonatomic) NSMutableDictionary<NSString *, UIWindow *> *windows;

@end

@implementation SKIAdReportWindowManager

+ (instancetype)manager {
	static SKIAdReportWindowManager *manager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		manager = [[self alloc] init];
	});
	
	return manager;
}

- (instancetype)init
{
	self = [super init];
	if (self) {
		self.windows = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (NSString *)showViewController:(UIViewController *)viewController {
//	__weak typeof(self) wSelf = self;
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	window.windowLevel = UIWindowLevelNormal;
	window.rootViewController = [UIViewController new];
//	window.rootViewController = [SKIAdReportViewController navigatingViewControllerWidthCallback:^(BOOL canceled, NSString * _Nullable email, NSString * _Nullable message) {
//		if (canceled) {
//			wSelf.window.hidden = NO;
//			wSelf.window = nil;
//			return;
//		}
//
//		[[SKIAdEventTracker defaultTracker] sendReportWithDeviceData:wSelf.requestResponse.deviceInfo adId:wSelf.requestResponse.rawResponse[@"AdId"] adUnitId:wSelf.adUnitID email:email message:message];
//
//		SKIAsyncOnMain(^{
//			wSelf.window.hidden = NO;
//			wSelf.window = nil;
//			if ([wSelf.delegate respondsToSelector:@selector(skiAdView:didFailToReceiveAdWithError:)]) {
//				SKIAdRequestError *requestError = [SKIAdRequestError errorNoFillWithUserInfo:nil];
//				[wSelf.delegate skiAdView:wSelf didFailToReceiveAdWithError:requestError];
//			}
//		});
//	}];
	[window makeKeyAndVisible];
	[window.rootViewController presentViewController:viewController animated:YES completion:nil];

//	SKIAsyncOnMain(^{
//		[UIView transitionWithView:window
//						  duration:UINavigationControllerHideShowBarDuration
//						   options:UIViewAnimationOptionTransitionFlipFromBottom
//						animations:^{
//						}
//						completion:nil];
//	});
	
	NSString *uuid = [[NSUUID UUID] UUIDString];
	[self.windows setObject:window forKey:uuid];
	
	return uuid;
}

- (void)hideViewController:(NSString *)identifier {
	UIWindow *window = [self.windows objectForKey:identifier];
	[window.rootViewController dismissViewControllerAnimated:YES completion:^{
		window.hidden = YES;
		[self.windows removeObjectForKey:identifier];
	}];
}

@end

@interface SKIAdReportViewController () <UITextFieldDelegate, UITextViewDelegate>

@property (copy, nonatomic, nonnull) void (^callback)(BOOL canceled, NSString *email, NSString *message);
@property (strong, nonatomic) UITableViewCell *emailCell;
@property (strong, nonatomic) UITableViewCell *messageCell;

@property (strong, nonatomic) UITextField *emailTextField;
@property (strong, nonatomic) UITextView *messageTextView;

@property (strong, nonatomic) UIWindow *window;

@end

@implementation SKIAdReportViewController

+ (instancetype)viewController {
	return [[self alloc] initWithStyle:UITableViewStyleGrouped];
}

+ (UINavigationController *)navigatingViewControllerWidthCallback:(void (^_Nonnull)(BOOL canceled, NSString *email, NSString *message))callback {
	SKIAdReportViewController *reportController = [self viewController];
	reportController.callback = callback;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:reportController];
	navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
	
	return navigationController;
}

+ (void)showFromViewController:(UIViewController *)viewController callback:(void (^_Nonnull)(BOOL canceled, NSString *email, NSString *message))callback {
	if (viewController) {
		[viewController presentViewController:[self navigatingViewControllerWidthCallback:callback] animated:YES completion:nil];
		return;
	}
	
	__block NSString *idenitifer = [[SKIAdReportWindowManager manager] showViewController:[self navigatingViewControllerWidthCallback:^(BOOL canceled, NSString * _Nullable email, NSString * _Nullable message) {
		[[SKIAdReportWindowManager manager] hideViewController:idenitifer];
		callback(canceled, email, message);
	}]];
}

- (instancetype)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	
	if (self) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelItemSelectd:)];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendItemSelectd:)];
	}
	
	return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self) {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelItemSelectd:)];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleDone target:self action:@selector(sendItemSelectd:)];
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
	[self.view addGestureRecognizer:tapGesture];
    
	self.emailCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"emailCell"];
	self.emailCell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	self.emailTextField = [[UITextField alloc] initWithFrame:self.emailCell.contentView.bounds];
	self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
	self.emailTextField.returnKeyType = UIReturnKeyNext;
	self.emailTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.emailTextField.delegate = self;
	[self.emailCell.contentView addSubview:self.emailTextField];
	
	self.messageCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"messageCell"];
	self.messageCell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	self.messageTextView = [[UITextView alloc] initWithFrame:self.messageCell.contentView.bounds];
	self.messageTextView.keyboardType = UIKeyboardTypeDefault;
	self.messageTextView.returnKeyType = UIReturnKeyDefault;
	self.messageTextView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.messageTextView.editable = YES;
	self.messageTextView.delegate = self;
	self.messageTextView.font = [UIFont systemFontOfSize:17.f];
	[self.messageCell.contentView addSubview:self.messageTextView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
	return UIStatusBarAnimationFade;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return self.emailCell;
	}
	
	return self.messageCell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return @"Email (optional)";
	}
	
	return @"Message";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 44.f;
	}
	
	return 220.f;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.emailTextField) {
		[self.messageTextView becomeFirstResponder];
	}
	
	return NO;
}

- (void)textViewDidChange:(UITextView *)textView {
	self.navigationItem.rightBarButtonItem.enabled = textView.text.length > 2;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
	if (gesture.view == self.view) {
		[self.emailTextField resignFirstResponder];
		[self.messageTextView resignFirstResponder];
	}
}

- (void)cancelItemSelectd:(id)sender {
	self.callback(YES, nil, nil);
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendItemSelectd:(id)sender {
	self.callback(NO, self.emailTextField.text, self.messageTextView.text);
	[self dismissViewControllerAnimated:NO completion:nil];
}

@end
