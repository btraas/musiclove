#include "MLVRootListController.h"
#include <spawn.h>
#include <signal.h>

@implementation MLVRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}


// functions

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
