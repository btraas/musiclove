/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.


*/

// #define Debugger
// #define DEBUG 0

#import "sqlite3.h"
#include <objc/runtime.h>
#import "UIKit/UIKit.h"
#include "MusicLove.h"

#define resourceBundle @"/Library/Application Support/ca.btraas.musiclove.bundle"


#include "common.m" // functions like nlog() and getProperty()
#include "preftools.xm"
#include "musictools.xm" // DB functions like getArtistPID()
// #include "tweakui.h"
#include "tweakui.m" // functions like updateMusicLoveUI()

// iTunes_Control/iTunes/MediaLibrary.sqlitedb -> item_stats.liked_state
//  (2 = liked, 3 = disliked)
// item_pid is id


static NSObject* controller;

NSMutableDictionary *cellMap;



// void findSongCellTitle(UIView* songCell) {
// 	UIScrollView* collectionView = ((UIScrollView *)closest(songCell, @"UICollectionView"));
//vi
// 	// UIViewControllerWrapperView is iPad, _UIParallaxDimmingView is iPhone
// 	if(songCell && (collectionView == NULL || isClass([[collectionView superview] superview], @"UIViewControllerWrapperView") || isClass([[collectionView superview] superview], @"_UIParallaxDimmingView"))) {
// 		return getTitle(songCell);
// 		// VerticalScrollStackScrollView is for the artist only. "getArtistName() will get the album name instead..."
// 	} else if(isClass([[collectionView superview] superview], @"MusicApplication.VerticalScrollStackScrollView") || isClass([[collectionView superview] superview], @"_TtC5MusicP33_5364BCBBBF924B0F2B3BC61F02267B0216SplitDisplayView")) {
// 		return getTitle(songCell);
// 	}
// 	return nil;
// }


%hook MusicSongsViewController


	%new
	-(NSMutableDictionary*)getCellMap {
		return cellMap;
	}


	- (void)viewWillAppear:(BOOL)fp8 {
	    %orig;
			NSLog(@"MusicSongsViewController:: viewWillAppear");
	}


-(id)collectionView:(UICollectionView*)cv cellForItemAtIndexPath:(NSIndexPath*)indexPath {
	NSLog(@"MusicSongsViewController:: cellForItemAtIndexPath");
	MusicSongCell* cell = (MusicSongCell*)%orig(cv, indexPath);

	if(!cellMap) {
		NSInteger numberOfItems = [cv numberOfItemsInSection:indexPath.section];
		cellMap = [[NSMutableDictionary alloc]initWithCapacity:numberOfItems]; // interesting, it seems this will expand automatically if needed
	}

	[cellMap setObject:cell forKey:[NSNumber numberWithInt:indexPath.row]];

	updateMusicLoveUI((UIView*) cell);

	return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"DoubleTap: didSelectItem!");

		// clear caches
		[likeDict removeAllObjects];
		[ratingDict removeAllObjects];

		// updateMusicLoveUI(cell);
		NSLog(@"DoubleTap: checking if we should play the song!!");

		// do original action
		if(playSong || !doubleTapLikeEnabled()) {
			NSLog(@"DoubleTap: playSong = YES!");

			// @try {
			 	%orig;
			// }
			// @catch(NSException *exception) {
			// 	NSLog(@"%@", exception.reason);
			// }
			playSong = NO;
			return;
		}

		songCellTapped(self, collectionView, cellMap, indexPath);

	}

  %new
	- (void)tapTimerFired:(NSTimer *)aTimer{
    //timer fired, there was a single tap on indexPath.row = tappedRow
		NSLog(@"DoubleTap: Timer fired!");

    if(tapTimer != nil){
        tapCount = 0;
        tappedRow = -1;

				[tapTimer invalidate];
        tapTimer = nil;
    }
		if(cv && tapPath && cv != nil && tapPath != nil) {
			playSong = YES; // force the next artificial tap to run as originally intended by Apple.

			NSLog(@"DoubleTap: cv & tapPath not nil!");
			@try {
				NSLog(@"DoubleTap: Calling self collectionView:%@ didSelectItemAtIndexPath:%@", cv, tapPath);
				[self collectionView:cv didSelectItemAtIndexPath:tapPath];
			}
			@catch(NSException *exception) {
				NSLog(@"DoubleTap: Exception!");
			}


		}
	}


%end


%hook CompositeCollectionViewController

	%new
	-(NSMutableDictionary*)getCellMap {
		return cellMap;
	}

	// - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//
	// 	NSLog(@"CompositeCollectionViewController:: cellForRowAtIndexPath: %d", (int)indexPath.row);
	// 	return %orig;
	//
	// }


	// NSMutableDictionary *cellMap;


	/**
		hook the header creation load (for getting the artist on album VCs)

	 */
  -(UICollectionReusableView *)collectionView:(UICollectionView*)cv viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

		UICollectionReusableView* _orig = %orig(cv, kind, indexPath);


		if(controller != self && kind != nil && [kind isEqualToString:@"UICollectionElementKindGlobalHeader"] && _orig != nil) {

			for (UIView *subview in _orig.subviews){
				if(subview != nil && [NSStringFromClass([subview class]) isEqualToString:@"MusicApplication.ContainerDetailHeaderLockupView"])
					// NSLog(@" Lockup: %@", NSStringFromClass([subview class]));
					for(UIView *lockupSubview in subview.subviews) {
						NSString* lsClass =  NSStringFromClass([lockupSubview class]);
						// NSLog(@"  -> Lockup subview: %@", lsClass);
						if(lsClass != nil && [lsClass isEqualToString:@"UIButton"]) {
							UILabel* titleLabel = ((UIButton *)lockupSubview).titleLabel;
							if(titleLabel != nil && [titleLabel isKindOfClass:[UILabel class]]) {
								NSString* text = titleLabel.text;

								NSLog(@"");
								NSLog(@"Setting album artist: %@", text);
								//albumArtist = text; // hacky but it just might work... As long as there is no new straight "UIButton" added to this view.

								if([text isKindOfClass:[NSString class]]) {
									albumArtistPID = getArtistPID(titleLabel.text);
									NSLog(@"Album artist PID: %lld", albumArtistPID);
									// albumArtist = text;
									controller = self;
									// [heartViews removeAllObjects];
									// [heartKeys removeAllObjects];

									// [cv reloadData];
								}

							}
						}
					}

			}
		}
		return _orig;
	}


  // Actually returns a (swift) MusicApplication.SongCell
	-(id)collectionView:(UICollectionView*)cv cellForItemAtIndexPath:(NSIndexPath*)indexPath {

		NSLog(@"CompositeCollectionViewController:: cellForItemAtIndexPath");

		MusicSongCell* cell = (MusicSongCell*)%orig(cv, indexPath);

		if(!cellMap) {
			NSInteger numberOfItems = [cv numberOfItemsInSection:indexPath.section];
			cellMap = [[NSMutableDictionary alloc]initWithCapacity:numberOfItems]; // interesting, it seems this will expand automatically if needed
		}

		[cellMap setObject:cell forKey:[NSNumber numberWithInt:indexPath.row]];

		// dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		// 	updateMusicLoveUI(self);
		// });

		updateMusicLoveUI((UIView*) cell);

		return cell;

	}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"DoubleTap: didSelectItem!");

		// clear caches
		[likeDict removeAllObjects];
		[ratingDict removeAllObjects];

		// updateMusicLoveUI(cell);
		NSLog(@"DoubleTap: checking if we should play the song!!");

		// do original action
		if(playSong || !doubleTapLikeEnabled()) {
			NSLog(@"DoubleTap: playSong = YES!");

			// @try {
			 	%orig;
			// }
			// @catch(NSException *exception) {
			// 	NSLog(@"%@", exception.reason);
			// }
			playSong = NO;
			return;
		}

		songCellTapped(self, collectionView, cellMap, indexPath);

	}

  %new
	- (void)tapTimerFired:(NSTimer *)aTimer{
    //timer fired, there was a single tap on indexPath.row = tappedRow
		NSLog(@"DoubleTap: Timer fired!");

    if(tapTimer != nil){
        tapCount = 0;
        tappedRow = -1;

				[tapTimer invalidate];
        tapTimer = nil;
    }
		if(cv && tapPath && cv != nil && tapPath != nil) {
			playSong = YES; // force the next artificial tap to run as originally intended by Apple.

			NSLog(@"DoubleTap: cv & tapPath not nil!");
			@try {
				NSLog(@"DoubleTap: Calling self collectionView:%@ didSelectItemAtIndexPath:%@", cv, tapPath);
				[self collectionView:cv didSelectItemAtIndexPath:tapPath];
			}
			@catch(NSException *exception) {
				NSLog(@"DoubleTap: Exception!");
			}


		}
	}


%end




// this is for the Artist view controller. Works kinda like the album view controller.
%hook MusicPageHeaderContentView

-(void)layoutSubviews {
  %orig;
  vcArtist = [self title];
}

%end

%hook MusicContainerDetailHeaderLockupView

-(void)layoutSubviews {
	%orig;

	//vcAlbum = getProperty(self, @"titleText");
	//NSLog(@"MusicContainerDetailHeaderLockupView properties:");
	//logProperties(self);
	//NSLog(@"MusicContainerDetailHeaderLockupView subviews:");
	//logSubviews(self);

	UIButton* artistTitleButton;

	if(IDIOM == IPAD) {
		artistTitleButton = (UIButton*)findWithOrigin(self, @"UIButton", -66,35);
	} else {
		artistTitleButton = (UIButton*)findWithOrigin(self, @"UIButton", 107.5, 13.5);
	}

	if(artistTitleButton != nil) {
		vcArtist = [artistTitleButton valueForKey:@"currentTitle"];
		NSLog(@"MusicContainerDetailHeaderLockupView loaded artist: %@", vcArtist);
		// vcArtist = getProperty(artistTitleButton, @"currentTitle");
		// NSLog(@"MusicContainerDetailHeaderLockupView UIButton properties:");
		// logProperties(artistTitleButton);
	}


}


%end


// works...
%hook MusicArtworkComponentImageView

-(id)initWithFrame:(CGRect)frame {
  // NSLog(@"Artwork::initWithFrame");
  id _orig = %orig;
  // logProperties(_orig);
  // logSubviews(_orig);
  return _orig;
}

%end

// Begin Playlist love status
// if [self artistName] is null, it's a playlist made by the UI_USER_INTERFACE_IDIOM
// if [self artistName] == "Apple Music", it's a playlist by Apple Music
// else it's an album

%hook MusicAlbumCell

-(void)layoutSubviews {
	%orig;
	// NSString* title = [self title];
	// NSString* artist = getProperty(self, @"artistName");
	// // logProperties(self);
	// NSLog(@"MusicAlbumCell title: %@ artist: %@", title, artist);
}

%end

%hook MusicCompositeCollectionView
-(void)init {
	%orig;
}

-(void)layoutSubviews {
	NSLog(@"MusicApplication.CompositeCollectionView:: layoutSubviews");
	%orig;
}

// - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//
// 	NSLog(@"cellForRowAtIndexPath: %d", (int)indexPath.row);
// 	return %orig;
//
//     // CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kIdentifier forIndexPath: indexPath];
// 		//
//     // // Do anything else here you would like.
//     // // [cell someCustomMethod];
// 		//
//     // return cell;
// }

%end

%hook UICollectionView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSLog(@"UICollectionView:: cellForRowAtIndexPath: %d", (int)indexPath.row);
	return %orig;

    // CustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kIdentifier forIndexPath: indexPath];
		//
    // // Do anything else here you would like.
    // // [cell someCustomMethod];
		//
    // return cell;
}
%end




%hook MusicSongCell

// %property (nonatomic, assign) int currentLikeState;

-(id)init {
	NSLog(@"MusicSongCell:: init!");
	return %orig;
}

-(void)loadView {
	NSLog(@"MusicSongCell:: loadView!");
	%orig;
}

-(void)viewDidLoad {
	NSLog(@"MusicSongCell:: viewDidLoad!");
	%orig;
	// self.isPopular = false;
}

-(void)viewWillAppear:(BOOL)animated {
	NSLog(@"MusicSongCell:: viewWillAppear");
	%orig;
}

-(void)prepareForReuse {
	// NSLog(@"MusicSongCell:: prepareForReuse");
	%orig;
}

-(void)layoutIfNeeded {
	NSLog(@"MusicSongCell:: layoutIfNeeded");
	%orig;
}

-(void)draw:(CGRect)rect {
	NSLog(@"MusicSongCell:: draw");
	%orig;
}

-(void)layoutSubviews {
	// NSLog(@"MusicSongCell:: layoutSubviews!");
	// NSLog(@"MusicSongCell:: layoutSubviews! %@",[NSThread callStackSymbols]);

	%orig;
	// updateMusicLoveUI(self);


	NSString* title = getTitle(self);

	if(!viewHasTag(self, title)) {
		setViewTag(self, title);  // before delay
		// dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5), dispatch_get_main_queue(), ^{
			updateMusicLoveUI(self);

		// });
  	// updateMusicLoveUI(self);
  }


	// Delay execution of my block for 1 second.
	// dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
	// 	updateMusicLoveUI(self);
	// });


	// NSTimeInterval timeSinceLastUpdate =
	//dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		// updateMusicLoveUI(self);
	//});
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture {
		%orig(gesture);

		updateMusicLoveUI(self);
}


%end
//
// %hook _TtCVV5Music4Text7Drawing4View
// // %hook MusicTextDrawingView
//
// -(void)viewDidLoad {
// 	NSLog(@"MusicTextDrawingView:: viewDidLoad!");
// 	%orig;
// }
//
//
// - (void)viewDidLoad:(BOOL)animated {
// 	%orig;
//
// 	UIView* view = (UIView*)self;
// 	NSLog(@"MusicTextDrawingView::viewDidLoad");
// 	if(view.frame.origin.x == 0 && view.frame.origin.y == -10.5) {
// 		NSLog(@"MusicTextDrawingView::removing from superview!");
// 		[view removeFromSuperview];
// 	} else {
// 		NSLog(@"MusicTextDrawingView::not removing from superview!");
//
// 	}
// }
//
// %end

// %hook MusicStar
// -(id) init {
// 	return nil;
// }
// %end

%hook MusicNowPlayingCollectionViewSecondaryBackground
-(void)init {
	NSLog(@"");
	NSLog(@"MNPCVSB: init");
	NSLog(@"");
}
-(void)layoutSubviews {
	secondaryBackground = recursiveBackgroundColor(self);
	NSLog(@"");
	if(secondaryBackground == nil) {
		NSLog(@"MNPCVSB: got background: nil");
	} else {
		NSString *colorString = [CIColor colorWithCGColor:secondaryBackground.CGColor].stringRepresentation;
		NSLog(@"MNPCVSB: got background: %@", colorString);
	}

	NSLog(@"");
}
%end

// HSCloudClient is "HomeService" which syncs itunes cloud / apple music properties.
static HSCloudClient* cloudClient;
%hook HSCloudClient
- (HSCloudClient*)init {
	cloudClient = %orig;
	return cloudClient;
}
- (void)setItemProperties:(id)arg1 forSagaID:(unsigned long long)arg2 {
	NSLog(@"");
	NSLog(@" setItem properties for:%lld, %@ ", arg2, NSStringFromClass([arg1 class]));
	NSLog(@" cloudClient: %@", cloudClient);
	NSLog(@"");
	%orig(arg1, arg2);

}
%end

%hook MIPMediaItem
	-(id) init {
		NSLog(@" >> MIPMediaItem::init!");
		return %orig;
	}
%end

%hook UIButton
	-(void)layoutSubviews {
		%orig;
		NSArray *array = [self.allTargets allObjects]; // theNSSet is replaced with your NSSet id
		NSLog(@"allTargets: %@",array);

		// NSLog(@"_targetActions %@",self._targetActions);
	}
%end

%hook UICollectionViewDataSource
-(id)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {
	NSLog(@"UICollectionViewDataSource:: cellForRowAtIndexPath:");
	return %orig;
}
%end

%hook UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"UICollectionViewDelegate:: willDisplayCell");
	%orig;
}
%end

%hook UICollectionView
-(id)init {
	NSLog(@"UICollectionView:: init");
	return %orig;
}
-(void)layoutSubviews {
	// NSLog(@"UICollectionView:: layoutSubviews");
	%orig;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"UICollectionView:: willDisplayCell1");
	%orig;
}
-(void)willDisplayCell:(UICollectionViewCell *)cell cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"UICollectionView:: willDisplayCell2");
	%orig;
}
-(id)cellForItemAtIndexPath:(NSIndexPath*)indexPath {
	NSLog(@"Main.xm[576] UICollectionView:: cellForRowAtIndexPath:");
	return %orig;
}
%end

// MPModelSong -> data
%hook UIViewController
- (void)viewWillAppear:(BOOL)fp8 {
    %orig;

		NSLog(@"%@:: viewWillAppear (dbg)", NSStringFromClass([self class]));
		logProperties(self);

//        if([NSStringFromClass([self class]) isEqualToString:@"MusicApplication.AlbumDetailSongsViewController"]) {
//            NSLog(@"MusicApplication.AlbumDetailSongsViewController!");
//            if(![self view]) {
//                NSLog(@"View is null!");
//            } else {
//                NSLog(@"Found view: %@", NSStringFromClass([[self view] class]));
//            }
//            UIView* header = find([self view], @"MusicApplication.ContainerDetailHeaderLockupView");
//            if(!header) {
//                NSLog(@"Failed to find MusicApplication.ContainerDetailHeaderLockupView in this view!");
//            }
//
////            NSLog(@"Header views: ");
////            logSubviews(header);
//
//            UIButton* btn = (UIButton *)find(header, @"UIButton");
//            if(!btn) {
//                NSLog(@"Failed to find UIButton in this HeaderLockupView!");
//            }
//
//            vcArtist = [btn currentTitle];
//            NSLog(@"MusicApplication.AlbumDetailSongsViewController found artist: %@", vcArtist);
//        } else {
//            UIView* header = find([self view], @"MusicApplication.ContainerDetailHeaderLockupView");
//            if(!header) {
//                NSLog(@"Failed to find MusicApplication.ContainerDetailHeaderLockupView in this view!");
//            } else {
//                UIButton* btn = (UIButton *)find(header, @"UIButton");
//                if(!btn) {
//                    NSLog(@"Failed to find UIButton in this HeaderLockupView!");
//                } else {
//                    vcArtist = [btn currentTitle];
//                    NSLog(@"MusicApplication.AlbumDetailSongsViewController found artist: %@", vcArtist);
//                }
//            }
//
//            //            NSLog(@"Header views: ");
//            //            logSubviews(header);
//
//
//        }

		if(!likeDictInit) {
        likeDict = [NSMutableDictionary new];
        likeDictInit = YES;
    }
		if(!ratingDictInit) {
        ratingDict = [NSMutableDictionary new];
        ratingDictInit = YES;
    }

		// clear caches
		[likeDict removeAllObjects];
    [ratingDict removeAllObjects];
    // [dictX setValue:@YES forKey:@"TEST"];
    // NSLog(dictX[@"TEST"]);
}
%end

%hook MusicTintColorObservingView
-(void)viewWillAppear:(BOOL)animated {
	NSLog(@"MusicTintColorObservingView:: viewWillAppear");
	%orig;
	return;
}
%end

%hook BrowseCollectionViewController
-(void)viewDidLoad {
	%orig;
	NSLog(@"BrowseCollectionViewController:: viewDidLoad");
}
%end

%ctor {
	// MusicTextDrawingView = objc_getClass("_TtCVV5Music4Text7Drawing4View"),

		// MusicApplication.ContainerDetailHeaderLockupView.titleText (on album) = Album name
		// MusicApplication.ContainerDetailHeaderLockupView --> UIButton.currentTitle (on album) = Artist name



	  // MusicApplication.AlbumCell is also for playlists...
	// don't have a space after %init(
    %init(MusicAlbumCell = objc_getClass("MusicApplication.AlbumCell"),
			MusicSongCell	 = objc_getClass("MusicApplication.SongCell"),
			MusicNowPlayingCollectionViewSecondaryBackground = objc_getClass("MusicApplication.NowPlayingCollectionViewSecondaryBackground"),
			MusicArtworkComponentImageView = objc_getClass("MusicApplication.ArtworkComponentImageView"),
          	MusicPageHeaderContentView = objc_getClass("MusicApplication.PageHeaderContentView"),
			MusicContainerDetailHeaderLockupView = objc_getClass("MusicApplication.ContainerDetailHeaderLockupView"),
			MusicSongsViewController = objc_getClass("MusicApplication.SongsViewController"),
			MusicTintColorObservingView = objc_getClass("MusicApplication.TintColorObservingView"),
			BrowseCollectionViewController = objc_getClass("_TtGC5Music30BrowseCollectionViewController"),
          	CompositeCollectionViewController = objc_getClass("MusicApplication.CompositeCollectionViewController")
	);
}
