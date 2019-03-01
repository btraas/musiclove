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


#define bundle @"/Library/Application Support/ca.btraas.musiclove.bundle"


#include "common.xm" // functions like nlog() and getProperty()
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


void drawLike(UIView* _orig, NSString* title, BOOL likeState, int paddingLeft, double paddingTop) {


	// NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Resource" ofType:@"bundle"];
	NSString *imageString = [[NSBundle bundleWithPath:bundle] pathForResource:@"heart" ofType:@"png"];
	// NSLog(@" found image: %@",  imageString);
	// UIImage *heartImage = [UIImage imageNamed:@"heart.png" inBundle:[NSBundle bundleWithPath:bundle]];

	if(imageString == nil) {
		NSLog(@" image is nil");
		return;
	}
	UIImage *heartImage = [UIImage imageWithContentsOfFile:imageString];
	if(heartImage == nil) {
		NSLog(@" heartImage is nil");

		return;
	}

	// UIImage *heartImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/heart@2x.png", bundle]];
	heartImage = [heartImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	if(heartImage == nil) {
		NSLog(@" heartImage is nil");
		return;
	}


	if(likeState == NO) {
		// NSLog(@"Clearing heart %@ (likeState=NO)", getTitle(_orig));
    // clear existing heart
		for(UIView* subview in _orig.subviews) {
			if([NSStringFromClass([subview class]) isEqualToString:@"UIImageView"]) {
				NSLog(@"subview origin.x: %f", subview.frame.origin.x);

				if(subview.frame.origin.x <= 15 && subview != nil) {
					// dispatch_async(dispatch_get_main_queue(), ^(void){
						NSLog(@"     -> origin < 15. Removing now! (this is a previously added heart)");
						if(subview) {
							[subview removeFromSuperview];
						}
					// });
				}
			}
		}
	} else {
		// NSLog(@"Adding heart %@ (likeState=YES)", getTitle(_orig));


    int _paddingLeft = 0;


    CGRect newFrame = [_orig convertRect:_orig.bounds toView:nil];
    if(newFrame.origin.x == 0) {
      _paddingLeft = 4;
    }

    if(paddingLeft < 0) {
      paddingLeft = _paddingLeft;
    }

		if(paddingTop < 0) {
			paddingTop = 17.5;
		}

		CGRect frame = CGRectMake(paddingLeft, paddingTop, 14, 14);

		UIImageView *newView = [[UIImageView alloc] initWithFrame:frame];

		if(newView != nil) {
			[newView setTintColor:[UIColor redColor]];
			[newView setImage:heartImage];

			if(_orig &&  _orig.window != nil) {
				NSLog(@"adding heart");

				[_orig addSubview:newView];
				[_orig bringSubviewToFront:newView];

			}

		}
	}

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

 /*
  hook cell creation

 */
	-(UICollectionViewCell *)collectionView:(id)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
		// NSLog(@"cellForItemAtIndexPath");
		UICollectionViewCell* _orig = %orig(cv, indexPath);
		if(_orig == nil) {
			return _orig;
		}


		if([NSStringFromClass([_orig class]) isEqualToString:@"Music.SongCell"]) {
			 NSLog(@"");
			 NSLog(@"Got SongCell");

			 __block int isLiked = 0;
			 NSString* title = getTitle(_orig);
			 NSString* artist = getArtistName(_orig);
			 int likeState = findLikedState(title, artist, nil);

			 NSLog(@"Cell = %@/%@, state=%d",title,artist,likeState);


			 // NSLog(@"Got SongCell");

			 // clear out old hearts
			 for(UIView* subview in _orig.contentView.subviews) {
				 NSLog(@"Checking subview:  %@ at origin.x: %f", NSStringFromClass([subview class]), subview.frame.origin.x );

				 if([NSStringFromClass([subview class]) isEqualToString:@"UIImageView"]) {
					 NSLog(@"Removing subview: %@  %@", title, NSStringFromClass([subview class] ));
				 	 [subview removeFromSuperview];
				 }
			 }



				if(likeState != 2) {
					 // [titles setObject:[NSNumber numberWithBool:NO] forKey:title];

					 if(title == getTitle(_orig))
					 		drawLike(_orig, title,  NO, -1, -1);

				} else {
					isLiked = 1;

				  // [titles setObject:[NSNumber numberWithBool:YES] forKey:title];
					// // dispatch_sync(dispatch_get_main_queue(), ^(void){
					if(title == getTitle(_orig))
						drawLike(_orig, title, YES, -1, -1);
					// });
				}
					// dispatch_async(dispatch_get_main_queue(), ^(void){


				NSLog(@"%@: is liked? %@", title, isLiked > 0 ? @"TRUE" : @"FALSE");

        showHideStar(_orig.contentView, likeState);


		}

		return _orig;

}
%end


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

-(void)layoutSubviews {
  %orig;
  // NSLog(@"");
  // logViewInfo(self);

  // if a music tableview cell

  if([self superview] ) {

    NSString* superviewClass = NSStringFromClass([[ ((UIView*)self) superview] class]);
    UIViewController* vc = (UIViewController *)[[((UIView*)self).superview viewWithTag:10] nextResponder];
    NSString* vcClass = NSStringFromClass(vc);
    NSLog(@"VC class: %@", vcClass);
    if(![superviewClass isEqualToString:@"UITableViewCellContentView"]) {
      NSLog(@"Not a UITableViewCellContentView!");
      return;
    }
    // logViewInfo([self superview]);

    // canScrollX



    UIView* songCell = closest(self, @"Music.SongCell");
    if(songCell) {
      // logViewInfo(songCell);
      // logProperties(songCell);


      UIScrollView* collectionView = ((UIScrollView *)closest(self, @"UICollectionView"));
      // artist -> all songs superview = Music.VerticalScrollStackScrollView
      // all songs superview = UIViewControllerWrapperView
      //logViewInfo([collectionView superview]);

      //if not changed

      // UIViewControllerWrapperView is iPad, _UIParallaxDimmingView is iPhone
      if(songCell && (collectionView == NULL || isClass([[collectionView superview] superview], @"UIViewControllerWrapperView") || isClass([[collectionView superview] superview], @"_UIParallaxDimmingView"))) {
        NSString* title = getTitle(songCell);
        NSString* artist = getArtistName(songCell);
        int likeState = findLikedState(title, artist, nil);
        NSLog(@"%@ likeState (from artist): %d", title, likeState);

        if(title == getTitle(songCell)) {
          drawLike([self superview], title, (likeState == 2 ? YES : NO), -1, -1);
          showHideStar([self superview], likeState);
        }

        // VerticalScrollStackScrollView is for the artist only. "getArtistName() will get the album name instead..."
      } else if(isClass([[collectionView superview] superview], @"Music.VerticalScrollStackScrollView")) {
        NSString* title = getTitle(songCell);
        NSString* album = getArtistName(songCell); // maybe apple music has a bug? artistName literally stores the album name in the artist view controller...
        int likeState = findLikedState(title, vcArtist, nil);
        logProperties(songCell);
        NSLog(@"%@/%@ likeState (from album): %d", title, album, likeState);

        if(title == getTitle(songCell)) {
          drawLike([self superview], title, (likeState == 2 ? YES : NO), 3, 7);

          showHideStar([self superview], likeState);
        }
      } else {
        NSLog(@"(%@) superview (%@) superview (%@) is not a UIViewControllerWrapperView!!: ", classNameOf(collectionView), classNameOf([collectionView superview]), classNameOf([[collectionView superview] superview]));

      }
    }
  }
}

%end

//
// %hook a
// - (id)init {
//   return %orig;
// }
// %end

%ctor {
    %init(MusicArtworkComponentImageView = objc_getClass("Music.ArtworkComponentImageView"),
          MusicPageHeaderContentView = objc_getClass("Music.PageHeaderContentView"),
          CompositeCollectionViewController = objc_getClass("Music.CompositeCollectionViewController"));
}
