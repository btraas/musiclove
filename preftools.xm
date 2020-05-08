#include "MusicLove.h"
#define APPLE_MUSIC_TINT_COLOR_STRING @"#ff2d55"



BOOL darkEnabled() {
	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
  return settings[@"support-dark-tweak"] ? [settings[@"support-dark-tweak"] boolValue] : NO;
}


BOOL shouldAutoOpenRestore() {
	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
	NSString* autoOpenRestoreValue = settings[@"auto-open-restore"];
	NSLog(@"autoOpenRestoreValue: %@", autoOpenRestoreValue);
	return settings[@"auto-open-restore"] ? [settings[@"auto-open-restore"] isEqualToString:@"YES"] : NO;
}

BOOL verifyProEmail(NSString* email) {
	NSString* str = [NSString stringWithFormat:@"musiclove-%@", email];
	// NSLog(@"sha1: %@", sha1(str));

	NSString *uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

	NSString* url = [NSString stringWithFormat:@"http://jailbreak.btraas.ca/musiclove-pro-check.php?email=%@&a=%@&uuid=%@", email, sha1(str), uniqueIdentifier];
	// NSLog(@"url: %@", url);
	NSString* response = getDataFrom(url);
	// NSLog(@"response: %@", response);

	if(response == nil || [response isEqualToString:@""]) {
		alert(@"MusicLove Pro verification failed", @"Are you connected to the internet? Please respring and try again.");
	}
	NSString *expected = sha1([NSString stringWithFormat:@"btraas-musiclove-%@-true", email]);
	return expected && response && [expected isEqualToString:response];
}


BOOL _proEnabled = NO;
BOOL _proLoaded  = NO;
BOOL proEnabled() {
	// NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
  // return settings[@"pro-enabled"] ? [settings[@"pro-enabled"] boolValue] : NO;
	if(_proLoaded) {
		//NSLog(@" -Pro status already loaded. returning %@", (_proEnabled ? @"YES" : @"NO"));
		return _proEnabled;
	}

	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
  NSString* ppEmail = settings[@"paypal-email"] ? [settings[@"paypal-email"] stringValue] : nil;
	if(ppEmail == nil) {
		NSLog(@" -ppEmail is nil! Returning NO");

		_proLoaded = YES;
		_proEnabled = NO;
		return NO;
	}
	// NSString* str = [NSString stringWithFormat:@"musiclove-%@", ppEmail];
	// NSLog(@"sha1: %@", sha1(str));
	// NSString* url = [NSString stringWithFormat:@"http://jailbreak.btraas.ca/musiclove-pro-check.php?email=%@&a=%@", ppEmail, sha1(str)];
	// NSLog(@"url: %@", url);
	// NSString* response = getDataFrom(url);
	// NSLog(@"response: %@", response);
	//
	// NSString *expected = sha1([NSString stringWithFormat:@"btraas-musiclove-%@-true", ppEmail]);


	NSString *restoreResponseTitle;
	if(verifyProEmail(ppEmail)) {
		NSLog(@"Success!");
		restoreResponseTitle = @"Success!";
		_proLoaded = YES;
		_proEnabled = YES;
		return YES;
	} else {
		NSLog(@"Fail!");
		restoreResponseTitle = @"Failed!";
		_proLoaded = YES;
		_proEnabled = NO;
		return NO;
	}

}
BOOL dislikeEnabled() {
	if(!proEnabled()) {
		return NO; // this feature requires proEnabled()
	}
	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
  return settings[@"show-song-dislike"] ? [settings[@"show-song-dislike"] boolValue] : YES;
}


BOOL doubleTapLikeEnabled() {
	if(!proEnabled()) {
		return NO; // this feature requires proEnabled()
	}
	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
  return settings[@"double-tap-like"] ? [settings[@"double-tap-like"] boolValue] : YES;
}

BOOL ratingEnabled() {
	if(!proEnabled()) {
		return NO;
	}
	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
  return settings[@"show-rating"] ? [settings[@"show-rating"] boolValue] : NO;
}

NSString* getLikeColor() {
	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
	NSString* likeColor = [settings objectForKey:@"like-color"]; // assuming that the key has a value saved like #FFFFFF:0.75423
	if(likeColor && proEnabled()) return likeColor;
	return APPLE_MUSIC_TINT_COLOR_STRING; // else
}
NSString* getDislikeColor() {
	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
	NSString* dislikeColor = [settings objectForKey:@"dislike-color"]; // assuming that the key has a value saved like #FFFFFF:0.75423
	if(dislikeColor && proEnabled()) return dislikeColor;
	return @"#909090"; // else
}



BOOL heartEnabled() {
	if(ratingEnabled()) {
		return NO;
	}
	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
  return settings[@"show-song-heart"] ? [settings[@"show-song-heart"] boolValue] : YES;
}

BOOL starEnabled() {
	if(ratingEnabled()) {
		return NO;
	}
	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
  BOOL enabled =  settings[@"show-song-popularity"] ? [settings[@"show-song-popularity"] boolValue] : YES;
  return enabled;
}
