#include "MLVRootListController.h"
#include <spawn.h>
#include <signal.h>
#include <CommonCrypto/CommonDigest.h>

#include "../common.m"
#include "../preftools.xm"
#include "UIKit/UIKit.h"
// #include "MyAdditions.h"



@implementation MLVRootListController

// - (void) viewDidLoad {
// 	[((UIViewController*)super) viewDidLoad];
// 	if(shouldAutoOpenRestore()) {
// 		restorePurchaseAlert(self);
// 	}
// }

- (NSArray *)specifiers {
	if (!_specifiers) {

		NSString* plistName = proEnabled() ? @"Pro" : @"Root";
		_specifiers = [[self loadSpecifiersFromPlistName:plistName target:self] retain];

		if(shouldAutoOpenRestore()) {
			NSLog(@"shouldAutoOpenRestore!!");
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				restorePurchaseAlert(self);

					// [vc presentViewController:alertController2 animated:YES completion:nil];
			});
		} else {
			NSLog(@"should NOT AutoOpenRestore!!");
		}

	}

	return _specifiers;
}

// - (void)reloadSpecifiers {
// 	_specifiers = nil;
// 	NSString* plistName = proEnabled() ? @"Pro" : @"Root";
// 	_specifiers = [[self loadSpecifiersFromPlistName:plistName target:self] retain];
// }


void restorePurchaseAlert(MLVRootListController* vc) {

	setPref(@"auto-open-restore", @"NO");


  UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Load Purchase"
                                                                                  message: @"Please enter your PayPal email"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"email";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
				[textField setKeyboardType:UIKeyboardTypeEmailAddress];
				[textField setReturnKeyType:UIReturnKeySend];


        // textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
		[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
		}]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * field = textfields[0];
        NSLog(@"inputAlert result: %@",field.text);
				// NSLog(@"md5: %@", [field.text md5]);

				NSString *restoreResponseTitle;
				NSString *restoreResponseMessage;

				if(field.text && verifyProEmail(field.text)) {
					NSLog(@"Success");
					restoreResponseTitle = @"Success!";
					restoreResponseMessage = @"MusicLove Pro is now enabled (may require a respring)";
					setPref(@"paypal-email", field.text);
					_proEnabled = true;
					[vc reloadSpecifiers];
					// vc.specifiers = nil; // force a refresh of specifiers
				} else {
					NSLog(@"Failed");
					restoreResponseTitle = @"Failed!";
					restoreResponseMessage = @"Could not find your purchase in our records. Please purchase or contact btraas@gmail.com";
					setPref(@"paypal-email", @"");
				}
				NSLog(@"pp-email was set.");

				UIAlertController * alertController2 = [UIAlertController alertControllerWithTitle: restoreResponseTitle
																																												message: restoreResponseMessage
																																										preferredStyle:UIAlertControllerStyleAlert];

				// NSLog(@"alert controller 2 was set.");


				[alertController2 addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {


				}]];
				NSLog(@"alert controller 2 added action.");

				// [alertController show];
				// [alertController release];

				[((UIViewController*)vc) presentViewController:alertController2 animated:YES completion:nil];
				// dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				// 		[vc presentViewController:alertController2 animated:YES completion:nil];
				// });
				// NSLog(@"dispatched");



    }]];
    // [alertController show];
    // [alertController release];
    [((UIViewController*)vc) presentViewController:alertController animated:YES completion:nil];
}

// functions

- (void)registerPro {
	// void inputAlert(UIAlertController* vc, NSString* title, NSString* message, NSString* placeholder) {


	UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Purchase or Restore"
                                                                                  message: @"Tap Restore if you've already purchased MusicLove"
                                                                              preferredStyle:UIAlertControllerStyleAlert];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Restore purchase" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			restorePurchaseAlert(self);
    }]];
		[alertController addAction:[UIAlertAction actionWithTitle:@"Purchase (PayPal)" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			setPref(@"auto-open-restore", @"YES");
			NSURL *url = [NSURL URLWithString:@"https://jailbreak.btraas.ca/musiclove-pro.php"];
	    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }]];

		[alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

    }]];
    // [alertController show];
    // [alertController release];
    [((UIViewController *)self) presentViewController:alertController animated:YES completion:nil];


	// inputAlert((UIViewController *)self, @"Register", @"Please enter paypal email", @"Email");
}

- (void)openPayPal {
    NSURL *url = [NSURL URLWithString:@"https://www.paypal.me/braydentraas/1"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    //[[UIApplication sharedApplication] openURL:url];
}

- (void)respring {
	pid_t pid;
	int status;
	const char *argv[] = {"killall", "SpringBoard", NULL};
	posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)argv, NULL);
	waitpid(pid, &status, WEXITED);
}

@end
