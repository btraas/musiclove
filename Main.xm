/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.


*/

// #define Debugger
#define NLOG false
// #define DEBUG 0

#import "sqlite3.h"
#import <objc/runtime.h>
#import "UIKit/UIKit.h"
#include "MusicLove.h"

#define resourceBundle @"/Library/Application Support/ca.btraas.musiclove.bundle"


#include "common.xm" // functions like nlog() and getProperty()
#include "preftools.xm"
#include "musictools.xm" // DB functions like getArtistPID()

// iTunes_Control/iTunes/MediaLibrary.sqlitedb -> item_stats.liked_state
//  (2 = liked, 3 = disliked)
// item_pid is id


static NSObject* controller;




NSString* getTitle(NSObject* _orig) {
	return getProperty(_orig, @"title");
}
NSString* getArtistName(NSObject* _orig) {
	return getProperty(_orig, @"artistName");
}




%hook CompositeCollectionViewController

	/**
		hook the header creation load (for getting the artist on album VCs)

	 */
  -(UICollectionReusableView *)collectionView:(UICollectionView*)cv viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {

		UICollectionReusableView* _orig = %orig(cv, kind, indexPath);


		if(controller != self && kind != nil && [kind isEqualToString:@"UICollectionElementKindGlobalHeader"] && _orig != nil) {

			for (UIView *subview in _orig.subviews){
				if(subview != nil && [NSStringFromClass([subview class]) isEqualToString:@"Music.ContainerDetailHeaderLockupView"])
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

%end


// this is for the Artist view controller. Works kinda like the album view controller.
NSString* vcArtist = @"";
%hook MusicPageHeaderContentView

-(void)layoutSubviews {
  %orig;
  vcArtist = [self title];
}

%end


%hook MusicArtworkComponentImageView

-(id)initWithFrame:(CGRect)frame {
  NSLog(@"Artwork::initWithFrame");
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

%hook MusicSongCell

-(void)layoutSubviews {
	%orig;
	NSLog(@"MusicSongCell:: layoutSubviews!");
	UIView* songCell = self;

	UIScrollView* collectionView = ((UIScrollView *)closest(self, @"UICollectionView"));
	// artist -> all songs superview = Music.VerticalScrollStackScrollView
	// all songs superview = UIViewControllerWrapperView
	//logViewInfo([collectionView superview]);

	//if not changed

	// UIViewControllerWrapperView is iPad, _UIParallaxDimmingView is iPhone
	if(songCell && (collectionView == NULL || isClass([[collectionView superview] superview], @"UIViewControllerWrapperView") || isClass([[collectionView superview] superview], @"_UIParallaxDimmingView"))) {


		// hideStar([self superview]); // until we know


		NSString* title = getTitle(songCell);
		NSString* artist = getArtistName(songCell);
		int likeState = findLikedState(title, artist, nil);
		NSLog(@"");
		logProperties(songCell);
		NSLog(@"%@ (MSC) likeState (from artist): %d", title, likeState);


		NSString* newTitle = getTitle(songCell);
		if([newTitle isEqualToString:title]) {

			drawLike(self, title, (likeState == 2 ? YES : NO), -1, -1, YES);
			showHideStar(find(self, @"UITableViewCellContentView"), likeState);

		} else {
			NSLog(@"%@ likeState (from artist): title changed! (from %@ to %@)", title, title, newTitle);

		}

		// VerticalScrollStackScrollView is for the artist only. "getArtistName() will get the album name instead..."
	} else if(isClass([[collectionView superview] superview], @"Music.VerticalScrollStackScrollView") || isClass([[collectionView superview] superview], @"_TtC5MusicP33_5364BCBBBF924B0F2B3BC61F02267B0216SplitDisplayView")) {
		NSString* title = getTitle(songCell);
		NSString* album = getArtistName(songCell); // maybe apple music has a bug? artistName literally stores the album name in the artist view controller...
		int likeState = findLikedState(title, vcArtist, nil);
		NSLog(@"");
		NSLog(@"%@/%@ likeState (from album): %d", title, album, likeState);

		if([title isEqualToString: getTitle(songCell)]) {
			drawLike(self, title, (likeState == 2 ? YES : NO), 3, 7, NO);

			showHideStar(find(self, @"UITableViewCellContentView"), likeState);
		}else {
			NSLog(@"Title has changed!! Skipping setting draw/star");
		}
	} else {
		NSLog(@"(%@) superview (%@) superview (%@) superview (%@) is not a UIViewControllerWrapperView!!: ",
				classNameOf(collectionView),
				classNameOf([collectionView superview]),
				classNameOf([[collectionView superview] superview]),
				classNameOf([[[collectionView superview] superview] superview]));

	}
}

%end

// %hook MusicStar
// -(id) init {
// 	return nil;
// }
// %end

%ctor {
	  // Music.AlbumCell is also for playlists...
    %init(MusicAlbumCell = objc_getClass("Music.AlbumCell"),
					MusicSongCell	 = objc_getClass("Music.SongCell"),
					MusicArtworkComponentImageView = objc_getClass("Music.ArtworkComponentImageView"),
          MusicPageHeaderContentView = objc_getClass("Music.PageHeaderContentView"),
          CompositeCollectionViewController = objc_getClass("Music.CompositeCollectionViewController"));
}
