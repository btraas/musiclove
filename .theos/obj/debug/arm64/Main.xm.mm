#line 1 "Main.xm"









#define NLOG false
#define DEBUG 0

#import "MediaRemote.h"
#import "sqlite3.h"
#import <objc/runtime.h>
#import "UIKit/UIKit.h"


#define bundle @"/Library/Application Support/ca.btraas.musiclove.bundle"


#include "Songs.xm"


#include "common.xm"
#include "musictools.xm"






static NSObject* controller;









NSString* getTitle(NSObject* _orig) {
	return getProperty(_orig, @"title");
}
NSString* getArtistName(NSObject* _orig) {
	return getProperty(_orig, @"artistName");
}

void drawLike(UICollectionViewCell* _orig, NSString* title, BOOL likeState) {


	NSString *imageString = [[NSBundle bundleWithPath:bundle] pathForResource:@"heart" ofType:@"png"];



	if(imageString == nil) {
		NSLog(@" image is nil");
		return;
	}
	UIImage *heartImage = [UIImage imageWithContentsOfFile:imageString];
	if(heartImage == nil) {
		NSLog(@" heartImage is nil");

		return;
	}


	heartImage = [heartImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	if(heartImage == nil) {
		NSLog(@" heartImage is nil");
		return;
	}






	if(likeState == NO) {
		NSLog(@"Clearing heart %@ (likeState=NO)", getTitle(_orig));

		for(UIView* subview in _orig.subviews) {
			if([NSStringFromClass([subview class]) isEqualToString:@"UIImageView"]) {
				NSLog(@"subview origin.x: %f", subview.frame.origin.x);

				if(subview.frame.origin.x <= 15 && subview != nil) {

						NSLog(@"     -> origin < 15. Removing now! (this is a previously added heart)");
						if(subview != nil) {
							[subview removeFromSuperview];
						}

				}
			}
		}
	} else {
		NSLog(@"Adding heart %@ (likeState=YES)", getTitle(_orig));



		CGRect frame = CGRectMake( (IDIOM == IPAD ? 0 : 3.5), 17.5, 14, 14);
















		UIImageView *newView = [[UIImageView alloc] initWithFrame:frame];




		if(newView != nil) {

			[newView setTintColor:[UIColor redColor]];
			[newView setImage:heartImage];

			if(_orig != nil && _orig.contentView != nil && _orig.contentView.window != nil) {
				NSLog(@"adding heart");

				[_orig.contentView addSubview:newView];
				[_orig.contentView bringSubviewToFront:newView];

			}

		}
	}

}


void drawSongLike(UIView* _orig, NSString* title, BOOL likeState) {


	NSString *imageString = [[NSBundle bundleWithPath:bundle] pathForResource:@"heart" ofType:@"png"];



	if(imageString == nil) {
		NSLog(@" image is nil");
		return;
	}
	UIImage *heartImage = [UIImage imageWithContentsOfFile:imageString];
	if(heartImage == nil) {
		NSLog(@" heartImage is nil");

		return;
	}


	heartImage = [heartImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	if(heartImage == nil) {
		NSLog(@" heartImage is nil");
		return;
	}


	if(likeState == NO) {


		for(UIView* subview in _orig.subviews) {
			if([NSStringFromClass([subview class]) isEqualToString:@"UIImageView"]) {
				NSLog(@"subview origin.x: %f", subview.frame.origin.x);

				if(subview.frame.origin.x <= 15 && subview != nil) {

						NSLog(@"     -> origin < 15. Removing now! (this is a previously added heart)");
						if(subview) {
							[subview removeFromSuperview];
						}

				}
			}
		}
	} else {


    int paddingLeft = 0;

    CGRect newFrame = [_orig convertRect:_orig.bounds toView:nil];
    if(newFrame.origin.x == 0) {

    }













		CGRect frame = CGRectMake(paddingLeft, 17.5, 14, 14);

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




#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class MusicTintColorObservingView; @class MusicSongCell; @class CompositeCollectionViewController; @class MusicArtworkComponentImageView; @class SongsViewController;
static UICollectionReusableView * (*_logos_orig$_ungrouped$CompositeCollectionViewController$collectionView$viewForSupplementaryElementOfKind$atIndexPath$)(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL, UICollectionView*, NSString *, NSIndexPath *); static UICollectionReusableView * _logos_method$_ungrouped$CompositeCollectionViewController$collectionView$viewForSupplementaryElementOfKind$atIndexPath$(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL, UICollectionView*, NSString *, NSIndexPath *); static UICollectionViewCell * (*_logos_orig$_ungrouped$CompositeCollectionViewController$collectionView$cellForItemAtIndexPath$)(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL, id, NSIndexPath *); static UICollectionViewCell * _logos_method$_ungrouped$CompositeCollectionViewController$collectionView$cellForItemAtIndexPath$(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL, id, NSIndexPath *); static id (*_logos_orig$_ungrouped$SongsViewController$init)(_LOGOS_SELF_TYPE_INIT id, SEL) _LOGOS_RETURN_RETAINED; static id _logos_method$_ungrouped$SongsViewController$init(_LOGOS_SELF_TYPE_INIT id, SEL) _LOGOS_RETURN_RETAINED; static id (*_logos_orig$_ungrouped$MusicTintColorObservingView$init)(_LOGOS_SELF_TYPE_INIT id, SEL) _LOGOS_RETURN_RETAINED; static id _logos_method$_ungrouped$MusicTintColorObservingView$init(_LOGOS_SELF_TYPE_INIT id, SEL) _LOGOS_RETURN_RETAINED; static id (*_logos_orig$_ungrouped$MusicSongCell$init)(_LOGOS_SELF_TYPE_INIT id, SEL) _LOGOS_RETURN_RETAINED; static id _logos_method$_ungrouped$MusicSongCell$init(_LOGOS_SELF_TYPE_INIT id, SEL) _LOGOS_RETURN_RETAINED; static UIColor * (*_logos_orig$_ungrouped$MusicSongCell$backgroundColor)(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL); static UIColor * _logos_method$_ungrouped$MusicSongCell$backgroundColor(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$MusicSongCell$setBackgroundColor$)(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL, UIColor *); static void _logos_method$_ungrouped$MusicSongCell$setBackgroundColor$(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL, UIColor *); static id (*_logos_orig$_ungrouped$MusicArtworkComponentImageView$initWithFrame$)(_LOGOS_SELF_TYPE_INIT id, SEL, CGRect) _LOGOS_RETURN_RETAINED; static id _logos_method$_ungrouped$MusicArtworkComponentImageView$initWithFrame$(_LOGOS_SELF_TYPE_INIT id, SEL, CGRect) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$_ungrouped$MusicArtworkComponentImageView$layoutSubviews)(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$MusicArtworkComponentImageView$layoutSubviews(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL);

#line 231 "Main.xm"






  static UICollectionReusableView * _logos_method$_ungrouped$CompositeCollectionViewController$collectionView$viewForSupplementaryElementOfKind$atIndexPath$(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UICollectionView* cv, NSString * kind, NSIndexPath * indexPath) {

		UICollectionReusableView* _orig = _logos_orig$_ungrouped$CompositeCollectionViewController$collectionView$viewForSupplementaryElementOfKind$atIndexPath$(self, _cmd, cv, kind, indexPath);


		if(controller != self && kind != nil && [kind isEqualToString:@"UICollectionElementKindGlobalHeader"] && _orig != nil) {

			for (UIView *subview in _orig.subviews){
				if(subview != nil && [NSStringFromClass([subview class]) isEqualToString:@"Music.ContainerDetailHeaderLockupView"])

					for(UIView *lockupSubview in subview.subviews) {
						NSString* lsClass =  NSStringFromClass([lockupSubview class]);

						if(lsClass != nil && [lsClass isEqualToString:@"UIButton"]) {
							UILabel* titleLabel = ((UIButton *)lockupSubview).titleLabel;
							if(titleLabel != nil && [titleLabel isKindOfClass:[UILabel class]]) {
								NSString* text = titleLabel.text;

								NSLog(@"");
								NSLog(@"Setting album artist: %@", text);


								if([text isKindOfClass:[NSString class]]) {
									albumArtistPID = getArtistPID(titleLabel.text);
									NSLog(@"Album artist PID: %lld", albumArtistPID);

									controller = self;




								}

							}
						}
					}

			}
		}
		return _orig;
	}





	static UICollectionViewCell * _logos_method$_ungrouped$CompositeCollectionViewController$collectionView$cellForItemAtIndexPath$(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id cv, NSIndexPath * indexPath) {

		UICollectionViewCell* _orig = _logos_orig$_ungrouped$CompositeCollectionViewController$collectionView$cellForItemAtIndexPath$(self, _cmd, cv, indexPath);
		if(_orig == nil) {
			return _orig;
		}


		if([NSStringFromClass([_orig class]) isEqualToString:@"Music.SongCell"]) {
			 NSLog(@"");
			 NSLog(@"Got SongCell");

			 __block int isLiked = 0;
			 NSString* title = getTitle(_orig);
			 NSString* artist = getArtistName(_orig);
			 int likeState = findLikedState(title, artist);

			 NSLog(@"Cell = %@/%@, state=%d",title,artist,likeState);





			 for(UIView* subview in _orig.contentView.subviews) {
				 NSLog(@"Checking subview:  %@ at origin.x: %f", NSStringFromClass([subview class]), subview.frame.origin.x );

				 if([NSStringFromClass([subview class]) isEqualToString:@"UIImageView"]) {
					 NSLog(@"Removing subview: %@  %@", title, NSStringFromClass([subview class] ));

					 	[subview removeFromSuperview];






















				 }
			 }




















						if(likeState != 2) {


							 if(title == getTitle(_orig))
							 		drawLike(_orig, title,  NO);

						} else {
							isLiked = 1;



							if(title == getTitle(_orig))
								drawLike(_orig, title, YES);

						}





						NSLog(@"%@: is liked? %@", title, isLiked > 0 ? @"TRUE" : @"FALSE");

            showHideStar(_orig.contentView, likeState);


















































		}

		return _orig;

}



static id _logos_method$_ungrouped$SongsViewController$init(_LOGOS_SELF_TYPE_INIT id __unused self, SEL __unused _cmd) _LOGOS_RETURN_RETAINED {
  NSLog(@"SongsViewController::init");
  return _logos_orig$_ungrouped$SongsViewController$init(self, _cmd);
}


static id _logos_method$_ungrouped$MusicTintColorObservingView$init(_LOGOS_SELF_TYPE_INIT id __unused self, SEL __unused _cmd) _LOGOS_RETURN_RETAINED {
  NSLog(@"MusicTintColorObservingView::init");
  return _logos_orig$_ungrouped$MusicTintColorObservingView$init(self, _cmd);
}




static id _logos_method$_ungrouped$MusicSongCell$init(_LOGOS_SELF_TYPE_INIT id __unused self, SEL __unused _cmd) _LOGOS_RETURN_RETAINED {

  return _logos_orig$_ungrouped$MusicSongCell$init(self, _cmd);
}
static UIColor * _logos_method$_ungrouped$MusicSongCell$backgroundColor(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {

  return _logos_orig$_ungrouped$MusicSongCell$backgroundColor(self, _cmd);
}

static void _logos_method$_ungrouped$MusicSongCell$setBackgroundColor$(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UIColor * color) {




    return _logos_orig$_ungrouped$MusicSongCell$setBackgroundColor$(self, _cmd, color);
}




static id _logos_method$_ungrouped$MusicArtworkComponentImageView$initWithFrame$(_LOGOS_SELF_TYPE_INIT id __unused self, SEL __unused _cmd, CGRect frame) _LOGOS_RETURN_RETAINED {
  NSLog(@"Artwork::initWithFrame");
  id _orig = _logos_orig$_ungrouped$MusicArtworkComponentImageView$initWithFrame$(self, _cmd, frame);


  return _orig;
}

static void _logos_method$_ungrouped$MusicArtworkComponentImageView$layoutSubviews(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
  _logos_orig$_ungrouped$MusicArtworkComponentImageView$layoutSubviews(self, _cmd);





  if([self superview] ) {

    NSString* superviewClass = NSStringFromClass([[ ((UIView*)self) superview] class]);
    UIViewController* vc = (UIViewController *)[[((UIView*)self).superview viewWithTag:10] nextResponder];
    NSString* vcClass = NSStringFromClass(vc);
    NSLog(@"VC class: %@", vcClass);
    if(![superviewClass isEqualToString:@"UITableViewCellContentView"]) {
      NSLog(@"Not a UITableViewCellContentView!");
      return;
    }






    UIView* songCell = closest(self, @"Music.SongCell");
    if(songCell) {


      NSString* title = getTitle(songCell);
      NSString* artist = getArtistName(songCell);
      int likeState = findLikedState(title, artist);

      UIScrollView* collectionView = ((UIScrollView *)closest(self, @"UICollectionView"));




      NSLog(@"%@ likeState: %d", title, likeState);



      if(isClass([[collectionView superview] superview], @"UIViewControllerWrapperView") || isClass([[collectionView superview] superview], @"_UIParallaxDimmingView")) {
        if(songCell && title == getTitle(songCell)) {
          drawSongLike([self superview], title, (likeState == 2 ? YES : NO));
          showHideStar([self superview], likeState);
        }
      } else {
        NSLog(@" superview superview (%@) is not a UIViewControllerWrapperView!!: ", classNameOf([[collectionView superview] superview]));
      }
    }
  }
}










static __attribute__((constructor)) void _logosLocalCtor_3a0cc2aa(int __unused argc, char __unused **argv, char __unused **envp) {




    {Class _logos_class$_ungrouped$CompositeCollectionViewController = objc_getClass("Music.CompositeCollectionViewController"); MSHookMessageEx(_logos_class$_ungrouped$CompositeCollectionViewController, @selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:), (IMP)&_logos_method$_ungrouped$CompositeCollectionViewController$collectionView$viewForSupplementaryElementOfKind$atIndexPath$, (IMP*)&_logos_orig$_ungrouped$CompositeCollectionViewController$collectionView$viewForSupplementaryElementOfKind$atIndexPath$);MSHookMessageEx(_logos_class$_ungrouped$CompositeCollectionViewController, @selector(collectionView:cellForItemAtIndexPath:), (IMP)&_logos_method$_ungrouped$CompositeCollectionViewController$collectionView$cellForItemAtIndexPath$, (IMP*)&_logos_orig$_ungrouped$CompositeCollectionViewController$collectionView$cellForItemAtIndexPath$);Class _logos_class$_ungrouped$SongsViewController = objc_getClass("Music.SongsViewController"); MSHookMessageEx(_logos_class$_ungrouped$SongsViewController, @selector(init), (IMP)&_logos_method$_ungrouped$SongsViewController$init, (IMP*)&_logos_orig$_ungrouped$SongsViewController$init);Class _logos_class$_ungrouped$MusicTintColorObservingView = objc_getClass("Music.MusicTintColorObservingView"); MSHookMessageEx(_logos_class$_ungrouped$MusicTintColorObservingView, @selector(init), (IMP)&_logos_method$_ungrouped$MusicTintColorObservingView$init, (IMP*)&_logos_orig$_ungrouped$MusicTintColorObservingView$init);Class _logos_class$_ungrouped$MusicSongCell = NSClassFromString(@"Music.SongCell"); MSHookMessageEx(_logos_class$_ungrouped$MusicSongCell, @selector(init), (IMP)&_logos_method$_ungrouped$MusicSongCell$init, (IMP*)&_logos_orig$_ungrouped$MusicSongCell$init);MSHookMessageEx(_logos_class$_ungrouped$MusicSongCell, @selector(backgroundColor), (IMP)&_logos_method$_ungrouped$MusicSongCell$backgroundColor, (IMP*)&_logos_orig$_ungrouped$MusicSongCell$backgroundColor);MSHookMessageEx(_logos_class$_ungrouped$MusicSongCell, @selector(setBackgroundColor:), (IMP)&_logos_method$_ungrouped$MusicSongCell$setBackgroundColor$, (IMP*)&_logos_orig$_ungrouped$MusicSongCell$setBackgroundColor$);Class _logos_class$_ungrouped$MusicArtworkComponentImageView = objc_getClass("Music.ArtworkComponentImageView"); MSHookMessageEx(_logos_class$_ungrouped$MusicArtworkComponentImageView, @selector(initWithFrame:), (IMP)&_logos_method$_ungrouped$MusicArtworkComponentImageView$initWithFrame$, (IMP*)&_logos_orig$_ungrouped$MusicArtworkComponentImageView$initWithFrame$);MSHookMessageEx(_logos_class$_ungrouped$MusicArtworkComponentImageView, @selector(layoutSubviews), (IMP)&_logos_method$_ungrouped$MusicArtworkComponentImageView$layoutSubviews, (IMP*)&_logos_orig$_ungrouped$MusicArtworkComponentImageView$layoutSubviews);}
}
