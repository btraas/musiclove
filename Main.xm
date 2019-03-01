/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.


*/

// #define Debugger
#define NLOG false
#define DEBUG 0

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
// static NSMutableDictionary *titles = [[NSMutableDictionary alloc] init];
// static NSMutableArray *heartViews = [[NSMutableArray alloc] init];
//
// static NSMutableDictionary *heartKeys = [[NSMutableDictionary alloc] init];





NSString* getTitle(NSObject* _orig) {
	return getProperty(_orig, @"title");
}
NSString* getArtistName(NSObject* _orig) {
	return getProperty(_orig, @"artistName");
}

void drawLike(UICollectionViewCell* _orig, NSString* title, BOOL likeState) {

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




	// dispatch_sync(dispatch_get_main_queue(), ^(void){

	if(likeState == NO) {
		NSLog(@"Clearing heart %@ (likeState=NO)", getTitle(_orig));
    // clear existing heart
		for(UIView* subview in _orig.subviews) {
			if([NSStringFromClass([subview class]) isEqualToString:@"UIImageView"]) {
				NSLog(@"subview origin.x: %f", subview.frame.origin.x);

				if(subview.frame.origin.x <= 15 && subview != nil) {
					// dispatch_async(dispatch_get_main_queue(), ^(void){
						NSLog(@"     -> origin < 15. Removing now! (this is a previously added heart)");
						if(subview != nil) {
							[subview removeFromSuperview];
						}
					// });
				}
			}
		}
	} else {
		NSLog(@"Adding heart %@ (likeState=YES)", getTitle(_orig));

		// x, y, width, height
		// make x + width <= 20
		CGRect frame = CGRectMake( (IDIOM == IPAD ? 0 : 3.5), 17.5, 14, 14);

// background on iPhone
		// if(IDIOM != IPAD) {
		// 	CGRect backgroundFrame = CGRectMake( 6, 14, 10, 16);
		// 	UIView *bgView = [[UIView alloc] initWithFrame:backgroundFrame];
		// 	[bgView setBackgroundColor:[UIColor olor]];
		// 	if(_orig != nil && _orig.contentView != nil && _orig.contentView.window != nil) {
		// 		NSLog(@"adding heart bg");
		//
		// 		[_orig.contentView addSubview:bgView];
		// 		[_orig.contentView bringSubviewToFront:bgView];
		//
		// 	}
		// }

		// CGRect frame = CGRectMake(_orig.contentView.frame.size.width - 70, 16, 16, 16);
		UIImageView *newView = [[UIImageView alloc] initWithFrame:frame];
		// [heartViews addObject:newView];
		// [heartKeys setObject:newView forKey:title];


		if(newView != nil) {
			// [newView setBackgroundColor:[UIColor whiteColor]];
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

// todo merge with drawLike()
void drawSongLike(UIView* _orig, NSString* title, BOOL likeState) {

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

    int paddingLeft = 0;

    CGRect newFrame = [_orig convertRect:_orig.bounds toView:nil];
    if(newFrame.origin.x == 0) {
      //paddingLeft = 10;
    }

    // if([_orig nextResponder]) {
    //   NSString* vcType = NSStringFromClass([[_orig nextResponder] class]);
    //   if(vcType) {
    //     // alert(@"VC: %@", vcType);
    //     return;
    //     if([vcType isEqualToString:@"Music.SongsViewController"]) {
    //       paddingLeft = 10;
    //     }
    //   }
    //
    // }

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



%hook CompositeCollectionViewController

	/**
		hook the header creation load

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
			 int likeState = findLikedState(title, artist);

			 NSLog(@"Cell = %@/%@, state=%d",title,artist,likeState);


			 // NSLog(@"Got SongCell");

			 // clear out old hearts
			 for(UIView* subview in _orig.contentView.subviews) {
				 NSLog(@"Checking subview:  %@ at origin.x: %f", NSStringFromClass([subview class]), subview.frame.origin.x );

				 if([NSStringFromClass([subview class]) isEqualToString:@"UIImageView"]) {
					 NSLog(@"Removing subview: %@  %@", title, NSStringFromClass([subview class] ));

					 	[subview removeFromSuperview];
					 // if there is a view with this id already created
					 // if([heartKeys objectForKey:title]) {
					 //
						//  // if the SongCell has a heartView, remove it!
						//  if([heartViews containsObject:subview]) {
						// 	 [subview removeFromSuperview];
						//  }
					 // }
					 //
						//  UIView* view = [heartKeys objectForKey:title];
						//  [view removeFromSuperview];
					 // }
					 // if(subview.frame.origin.x <= 15 && subview != nil) {
						//  // dispatch_async(dispatch_get_main_queue(), ^(void){
						// 	 NSLog(@"     -> origin < 15. Removing now! (this is a previously added heart)");
						// 	 if(subview != nil) {
						// 		 // dispatch_sync(dispatch_get_main_queue(), ^(void){
						// 			 [subview removeFromSuperview];
						// 		 // });
						// 	 }
						//  // });
					 // }
				 }
			 }




			  //NSLog(@"Starting background thread %@", [NSThread currentThread]);



				// if([titles objectForKey:title]){
				// 	BOOL storedLike = [[titles objectForKey:title] boolValue];
				// 	NSLog(@"Stored like: %@", storedLike ? @"TRUE" : @"FALSE");
				// }
					//drawLike(_orig, storedLike);
				//} else {
					//drawLike(_orig, NO);
					// dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

						// NSLog(@"Finding liked state");
						// NSLog(@"Got like state: %d", likeState);

						if(likeState != 2) {
							 // [titles setObject:[NSNumber numberWithBool:NO] forKey:title];

							 if(title == getTitle(_orig))
							 		drawLike(_orig, title,  NO);

						} else {
							isLiked = 1;

						  // [titles setObject:[NSNumber numberWithBool:YES] forKey:title];
							// // dispatch_sync(dispatch_get_main_queue(), ^(void){
							if(title == getTitle(_orig))
								drawLike(_orig, title, YES);
							// });
						}
							// dispatch_async(dispatch_get_main_queue(), ^(void){




						NSLog(@"%@: is liked? %@", title, isLiked > 0 ? @"TRUE" : @"FALSE");

            showHideStar(_orig.contentView, likeState);

					    //Background Thread
							// [NSThread sleepForTimeInterval:0f];
					        //Run UI Updates

							// for (UIView *subview in _orig.contentView.subviews){
              //
							// 	if([NSStringFromClass([subview class]) isEqualToString:@"_TtCV5Music4Text9StackView"] && [subview.subviews count] > 0){
							// 		// NSLog(@"UITableViewCellcontentView:found a %@ with %lu subviews!!",
							// 				// NSStringFromClass([subview class]), (unsigned long)[subview.subviews count]);
              //
							// 			NSLog(@"%@ star (1) (origin.x=%f)", (isLiked > 0 ? @"hiding":@"showing"), subview.frame.origin.x);
              //
              //
							// 		for(UIView* textStackView in subview.subviews) {
							// 			NSLog(@"star(1.5) origin.x: %f", textStackView.frame.origin.x);
              //
							// 			// star origin.x should be around 4.0
							// 			if(textStackView != nil && subview.frame.origin.x <= 15) {
							// 				// NSLog(@"     -> origin < 15. Hiding now!");
							// 				//dispatch_async(dispatch_get_main_queue(), ^(void){
							// 				NSLog(@"%@ star (2)", isLiked > 0 ? @"hiding":@"showing");
							// 				// [textStackView removeFromSuperview];
							// 				[textStackView setHidden:(isLiked==1)];
              //
							// 					// if(textStackView != nil && textStackView.window != nil) {
							// 					// 	if(isLiked == 1) {
							// 					// 		textStackView.hidden = YES;
							// 					// 		[textStackView removeFromSuperview];
							// 					// 	} else {
							// 					// 		textStackView.hidden = NO;
							// 					// 	}
							// 					// }
              //
							// 				// });
							// 			}
							// 		}
              //
							// 		// UIView* child = subview.subviews[0];
							// 		// NSLog(@"   -> Stackview child: %@", NSStringFromClass([child class]));
							// 		// NSLog(@"     -> x = %f, width = %f", subview.frame.origin.x, child.frame.size.width);
              //
							// 		// break;
							// 	}
							// }

					// });
				//}


		}

		return _orig;

}
%end

%hook SongsViewController
- (id)init {
  NSLog(@"SongsViewController::init");
  return %orig;
}
%end
%hook MusicTintColorObservingView
- (id)init {
  NSLog(@"MusicTintColorObservingView::init");
  return %orig;
}
%end


%hook MusicSongCell
- (id)init {
  // NSLog(@"SongCell::init");
  return %orig;
}
-(UIColor *)backgroundColor {
  // NSLog(@"SongCell::getBackgroundColor");
  return %orig;
}

-(void)setBackgroundColor:(UIColor *)color {
   // NSLog(@"SongCell::setBackgroundColor");

   // [self setHidden:YES];

    return %orig(color);
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
      NSString* title = getTitle(songCell);
      NSString* artist = getArtistName(songCell);
      int likeState = findLikedState(title, artist);

      UIScrollView* collectionView = ((UIScrollView *)closest(self, @"UICollectionView"));
      // artist -> all songs superview = Music.VerticalScrollStackScrollView
      // all songs superview = UIViewControllerWrapperView
      //logViewInfo([collectionView superview]);

      NSLog(@"%@ likeState: %d", title, likeState);
      //if not changed

      // UIViewControllerWrapperView is iPad, _UIParallaxDimmingView is iPhone
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

%end

//
// %hook a
// - (id)init {
//   return %orig;
// }
// %end

%ctor {
    %init(SongsViewController = objc_getClass("Music.SongsViewController"),
          MusicArtworkComponentImageView = objc_getClass("Music.ArtworkComponentImageView"),
          MusicTintColorObservingView = objc_getClass("Music.MusicTintColorObservingView"),
          MusicSongCell = NSClassFromString(@"Music.SongCell"),
          CompositeCollectionViewController = objc_getClass("Music.CompositeCollectionViewController"));
}
