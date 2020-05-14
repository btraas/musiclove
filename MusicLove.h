//
//  MusicLove.h
//  MusicLove
//
//  ©2019 Brayden Traas
//

#define kPrefsPlistPath @"/var/mobile/Library/Preferences/ca.btraas.musiclove.plist"

extern const int HEART_WIDTH = 14;
extern const int HEART_HEIGHT = 14;

#define kNoctisAppID 			CFSTR("com.laughingquoll.noctis")
#define kNoctisEnabledKey 		CFSTR("LQDDarkModeEnabled")

#define kSettingsChangedNotification		CFSTR("ca.btraas.musiclove.settings-changed")
#define kQuitMessagesNotification 			CFSTR("ca.btraas.musiclove.please-quit-messages")
#define kRelaunchMessagesNotification 		CFSTR("ca.btraas.musiclove.please-relaunch-messages")


// Private APIs

// @interface SpringBoard : UIApplication
// - (id)_accessibilityFrontMostApplication;
// @end
//
// @interface UIApplication (MusicLove)
// - (BOOL)isSuspended;
// - (void)terminateWithSuccess;
// @end
//
// @interface UIImage (MusicLove)
// + (UIImage *)imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
// @end
//
// // @interface UIColor (DM)
// // - (float)_luminance;
// // + (float)_luminanceWithRed:(float)arg1 green:(float)arg2 blue:(float)arg3;
// // @end
//
//
//
// @interface SBApplication : NSObject
// @end
//
// @interface SBApplicationController : NSObject
// + (id)sharedInstance;
// - (id)applicationWithBundleIdentifier:(id)arg1;
// - (void)applicationService:(id)arg1 suspendApplicationWithBundleIdentifier:(id)arg2;
// @end
//
// @interface NCNotificationRequest : NSObject
// @property (nonatomic, readonly, copy) NSString *sectionIdentifier;
// @property (nonatomic, readonly, copy) NSString *categoryIdentifier;
// @end
//
// @interface NCNotificationViewController : UIViewController
// - (id)initWithNotificationRequest:(NCNotificationRequest *)arg1;
// - (BOOL)dismissPresentedViewControllerAndClearNotification:(BOOL)arg1 animated:(BOOL)arg2;
// - (void)dismissViewControllerWithTransition:(int)arg1 completion:(id /* block */)arg2;
// @end
