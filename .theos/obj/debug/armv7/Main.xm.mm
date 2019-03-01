#line 1 "Main.xm"









#define NLOG false


#import "sqlite3.h"
#import <objc/runtime.h>
#import "UIKit/UIKit.h"


#define bundle @"/Library/Application Support/ca.btraas.musiclove.bundle"


#include "common.xm" 
#include "musictools.xm" 






static NSObject* controller;




NSString* getTitle(NSObject* _orig) {
	return getProperty(_orig, @"title");
}
NSString* getArtistName(NSObject* _orig) {
	return getProperty(_orig, @"artistName");
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

@class MusicAlbumCell; @class MusicPageHeaderContentView; @class MusicArtworkComponentImageView; @class CompositeCollectionViewController; 
static UICollectionReusableView * (*_logos_orig$_ungrouped$CompositeCollectionViewController$collectionView$viewForSupplementaryElementOfKind$atIndexPath$)(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL, UICollectionView*, NSString *, NSIndexPath *); static UICollectionReusableView * _logos_method$_ungrouped$CompositeCollectionViewController$collectionView$viewForSupplementaryElementOfKind$atIndexPath$(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL, UICollectionView*, NSString *, NSIndexPath *); static UICollectionViewCell * (*_logos_orig$_ungrouped$CompositeCollectionViewController$collectionView$cellForItemAtIndexPath$)(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL, id, NSIndexPath *); static UICollectionViewCell * _logos_method$_ungrouped$CompositeCollectionViewController$collectionView$cellForItemAtIndexPath$(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL, id, NSIndexPath *); static void (*_logos_orig$_ungrouped$MusicPageHeaderContentView$layoutSubviews)(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$MusicPageHeaderContentView$layoutSubviews(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL); static id (*_logos_orig$_ungrouped$MusicArtworkComponentImageView$initWithFrame$)(_LOGOS_SELF_TYPE_INIT id, SEL, CGRect) _LOGOS_RETURN_RETAINED; static id _logos_method$_ungrouped$MusicArtworkComponentImageView$initWithFrame$(_LOGOS_SELF_TYPE_INIT id, SEL, CGRect) _LOGOS_RETURN_RETAINED; static void (*_logos_orig$_ungrouped$MusicArtworkComponentImageView$layoutSubviews)(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$MusicArtworkComponentImageView$layoutSubviews(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL); static void (*_logos_orig$_ungrouped$MusicAlbumCell$layoutSubviews)(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL); static void _logos_method$_ungrouped$MusicAlbumCell$layoutSubviews(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL); 

#line 45 "Main.xm"


	



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
			 int likeState = findLikedState(title, artist, nil);

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
					 		drawLike(_orig, title,  NO, -1, -1);

				} else {
					isLiked = 1;

				  
					
					if(title == getTitle(_orig))
						drawLike(_orig, title, YES, -1, -1);
					
				}
					


				NSLog(@"%@: is liked? %@", title, isLiked > 0 ? @"TRUE" : @"FALSE");

        showHideStar(_orig.contentView, likeState);


		}

		return _orig;

}




NSString* vcArtist = @"";


static void _logos_method$_ungrouped$MusicPageHeaderContentView$layoutSubviews(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
  _logos_orig$_ungrouped$MusicPageHeaderContentView$layoutSubviews(self, _cmd);
  vcArtist = [self title];
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
      
      


      UIScrollView* collectionView = ((UIScrollView *)closest(self, @"UICollectionView"));
      
      
      

      

      
      if(songCell && (collectionView == NULL || isClass([[collectionView superview] superview], @"UIViewControllerWrapperView") || isClass([[collectionView superview] superview], @"_UIParallaxDimmingView"))) {
        NSString* title = getTitle(songCell);
        NSString* artist = getArtistName(songCell);
        int likeState = findLikedState(title, artist, nil);
        NSLog(@"%@ likeState (from artist): %d", title, likeState);

        if(title == getTitle(songCell)) {
          drawLike([self superview], title, (likeState == 2 ? YES : NO), -1, -1);
          showHideStar([self superview], likeState);
        }

        
      } else if(isClass([[collectionView superview] superview], @"Music.VerticalScrollStackScrollView")) {
        NSString* title = getTitle(songCell);
        NSString* album = getArtistName(songCell); 
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










static void _logos_method$_ungrouped$MusicAlbumCell$layoutSubviews(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
	_logos_orig$_ungrouped$MusicAlbumCell$layoutSubviews(self, _cmd);
	NSString* title = [self title];
	NSString* artist = getProperty(self, @"artistName");
	
	NSLog(@"MusicAlbumCell title: %@ artist: %@", title, artist);
}



static __attribute__((constructor)) void _logosLocalCtor_60b1dd2a(int __unused argc, char __unused **argv, char __unused **envp) {
	  



    {Class _logos_class$_ungrouped$CompositeCollectionViewController = objc_getClass("Music.CompositeCollectionViewController"); MSHookMessageEx(_logos_class$_ungrouped$CompositeCollectionViewController, @selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:), (IMP)&_logos_method$_ungrouped$CompositeCollectionViewController$collectionView$viewForSupplementaryElementOfKind$atIndexPath$, (IMP*)&_logos_orig$_ungrouped$CompositeCollectionViewController$collectionView$viewForSupplementaryElementOfKind$atIndexPath$);MSHookMessageEx(_logos_class$_ungrouped$CompositeCollectionViewController, @selector(collectionView:cellForItemAtIndexPath:), (IMP)&_logos_method$_ungrouped$CompositeCollectionViewController$collectionView$cellForItemAtIndexPath$, (IMP*)&_logos_orig$_ungrouped$CompositeCollectionViewController$collectionView$cellForItemAtIndexPath$);Class _logos_class$_ungrouped$MusicPageHeaderContentView = objc_getClass("Music.PageHeaderContentView"); MSHookMessageEx(_logos_class$_ungrouped$MusicPageHeaderContentView, @selector(layoutSubviews), (IMP)&_logos_method$_ungrouped$MusicPageHeaderContentView$layoutSubviews, (IMP*)&_logos_orig$_ungrouped$MusicPageHeaderContentView$layoutSubviews);Class _logos_class$_ungrouped$MusicArtworkComponentImageView = objc_getClass("Music.ArtworkComponentImageView"); MSHookMessageEx(_logos_class$_ungrouped$MusicArtworkComponentImageView, @selector(initWithFrame:), (IMP)&_logos_method$_ungrouped$MusicArtworkComponentImageView$initWithFrame$, (IMP*)&_logos_orig$_ungrouped$MusicArtworkComponentImageView$initWithFrame$);MSHookMessageEx(_logos_class$_ungrouped$MusicArtworkComponentImageView, @selector(layoutSubviews), (IMP)&_logos_method$_ungrouped$MusicArtworkComponentImageView$layoutSubviews, (IMP*)&_logos_orig$_ungrouped$MusicArtworkComponentImageView$layoutSubviews);Class _logos_class$_ungrouped$MusicAlbumCell = objc_getClass("Music.AlbumCell"); MSHookMessageEx(_logos_class$_ungrouped$MusicAlbumCell, @selector(layoutSubviews), (IMP)&_logos_method$_ungrouped$MusicAlbumCell$layoutSubviews, (IMP*)&_logos_orig$_ungrouped$MusicAlbumCell$layoutSubviews);}
}
