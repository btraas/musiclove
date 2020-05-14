#import "UIKit/UIKit.h"
#import "MusicLove.h"

NSString* vcArtist = @"";
NSString* vcAlbum = @"";

UIColor* secondaryBackground = nil;


NSMutableDictionary *likeDict;
BOOL likeDictInit = NO;

NSMutableDictionary *ratingDict;
BOOL ratingDictInit = NO;



NSString* getTitle(NSObject* _orig) {
	return getProperty(_orig, @"title");
}
NSString* getArtistName(NSObject* _orig) {
	return getProperty(_orig, @"artistName");
}


NSString* findSongCellArtist(UIView* songCell) {
	UIScrollView* collectionView = ((UIScrollView *)closest(songCell, @"UICollectionView"));


    float ver = [[[UIDevice currentDevice] systemVersion] floatValue];

    // iOS < 13
    if(ver < 13.0 && songCell && (collectionView == NULL || isClass([[collectionView superview] superview], @"UIViewControllerWrapperView")
                    || isClass([[collectionView superview] superview], @"_UIParallaxDimmingView"))) {
        return getArtistName(songCell);
    }

	if(getArtistName(songCell)) {
	    return getArtistName(songCell);

//    // UIViewControllerWrapperView is iPad? (untested iOS 13), TintColorObservingView is iPhone
//    elsif(songCell && (collectionView == NULL || isClass([[collectionView superview] superview], @"UIViewControllerWrapperView")
//                    || isClass([[collectionView superview] superview], @"MusicApplication.TintColorObservingView"))) {
//        return getArtistName(songCell);

		// VerticalScrollStackScrollView is for the artist only. "getArtistName() will get the album name instead..."
	} else if(isClass([[collectionView superview] superview], @"MusicApplication.VerticalScrollStackScrollView")
              || isClass([[collectionView superview] superview], @"Music.VerticalScrollStackScrollView")
              || isClass([[collectionView superview] superview], @"_TtC5MusicP33_5364BCBBBF924B0F2B3BC61F02267B0216SplitDisplayView")) {
		return vcArtist;
	}
	return nil;

}


void setViewTag(UIView* view, NSString* tag) {
  view.accessibilityLabel = tag;
}

NSString* getViewTag(UIView* view) {
  return view.accessibilityLabel;
}

BOOL viewHasTag(UIView* view, NSString* tag) {
  return [view.accessibilityLabel isEqualToString:tag];
}

void updateMusicLoveWithLikeState(UIView* songCell, NSString* title, int likeState) {
	UIScrollView* collectionView = ((UIScrollView *)closest(songCell, @"UICollectionView"));

	// one is iPad, one is iPhone
	if(isClass([[collectionView superview] superview], @"MusicApplication.VerticalScrollStackScrollView") // iOS 13
    || isClass([[collectionView superview] superview], @"Music.VerticalScrollStackScrollView")
	|| isClass([[collectionView superview] superview], @"_TtC5MusicP33_5364BCBBBF924B0F2B3BC61F02267B0216SplitDisplayView")) {
		drawLike(songCell, title, likeState, 3, 7, NO, secondaryBackground);
	} else {
		drawLike(songCell, title, likeState, -1, -1, YES, secondaryBackground);
	}
	// showHideStar(find(songCell, @"UITableViewCellContentView"), likeState);

}

void updateMusicLoveWithRating(UIView* songCell, NSString* title, int rating, int likeState) {
	UIScrollView* collectionView = ((UIScrollView *)closest(songCell, @"UICollectionView"));


	// void drawRating(UIView* _orig, int rating, int likeState, double paddingLeft, double paddingTop, BOOL solidBackground, UIColor* forceBackgroundColor) {

	int paddingTop = 0;
	if(songCell.frame.size.height > 50) {
		paddingTop = 3;
	}

	// one is iPad, one is iPhone
	if(isClass([[collectionView superview] superview], @"MusicApplication.VerticalScrollStackScrollView") // iOS 13
    || isClass([[collectionView superview] superview], @"Music.VerticalScrollStackScrollView") // iOS < 13
	|| isClass([[collectionView superview] superview], @"_TtC5MusicP33_5364BCBBBF924B0F2B3BC61F02267B0216SplitDisplayView")) {

		drawRating(songCell, title, rating, likeState, -1, paddingTop, NO, secondaryBackground);
	} else {
		drawRating(songCell, title, rating, likeState, -1, paddingTop, YES, secondaryBackground);
	}
	if(rating != 0) {
		hideStar(find(songCell, @"UITableViewCellContentView"));
	}
	// showHideStar(find(songCell, @"UITableViewCellContentView"), likeState);

}



int updateMusicLoveUI(UIView* songCell) {

	// UIView* songCell = self;

	// UIScrollView* collectionView = ((UIScrollView *)closest(songCell, @"UICollectionView"));

  if(!songCell) {
		NSLog(@"songCell empty!");
		return -1;
	}



	NSLog(@"updateMusicLoveUI: alpha: %.2f (tmp)", songCell.alpha);

	NSString* title = getTitle(songCell);
	NSString* artist = getArtistName(songCell);

	NSLog(@"Found title: %@ and artist: %@", title, artist);

	if(!artist) {
	    artist = findSongCellArtist(songCell);
	}

	if(artist == nil || [artist length] == 0 || artist == NULL || [artist length] < 2) {
		artist = vcArtist;
	}
	NSString* combined = [NSString stringWithFormat:@"%@ _by_ %@", title, artist];

	if(title == nil || artist == nil || [artist length] == 0 || !artist) {
		NSLog(@"title/artist empty!");
		return -1;
	}

  setViewTag(songCell, title);

	// to remove the popularity star
	if((!starEnabled() || ratingEnabled())) {
		NSLog(@" Finding %@ _TtCVV5Music4Text7Drawing4View...", title);
		// UIView* star = find( songCell, @"_TtCVV5Music4Text7Drawing4View");
		UIView* star = findWithOrigin( songCell, @"_TtCVV5Music4Text7Drawing4View", 0, -10.5);
		if(!star) {
            star = findWithOrigin( songCell, @"_TtCVV5MusicApplication4Text7Drawing4View", 0, -10.5);
        }

		if(star && star != nil) {
			NSLog(@" Found _TtCVV5Music4Text7Drawing4View at 0,-10.5 !!");
			[star removeFromSuperview];
			songCell.alpha = 1.1;

		} else {
			NSLog(@" Could not find _TtCVV5Music4Text7Drawing4View at 0,-10.5 !!");
		}
	} else {
		songCell.alpha = 1.1;
	}


	NSLog(@"Properties of %@ SongCell:", title);
	logProperties(songCell);
	logViewInfo(songCell);


	// if(songCell.alpha < 1.2) {
		if(ratingEnabled()) {
			// UIView* ratings = findWithSize( songCell, @"UIImageView", 17, 47); // TESTING this removal


			// if(!ratings || ratings == nil || ![ratings.accessibilityLabel isEqualToString:title]) {
				// int likeState = 0;



				int likeState;
				if([likeDict objectForKey:combined] != nil) {
					NSNumber *num = likeDict[combined];
					likeState = [num intValue];
					NSLog(@"Already loaded %@ (likeState=%d)!", combined, likeState);
				} else {
					likeState = findLikedStateRaw(title, artist, nil);
					[likeDict setValue:[NSNumber numberWithInt:likeState] forKey:combined];
					NSLog(@"Loaded %@ from disk (likeState=%d)!", combined, likeState);
				}

				// int rating;
				// if([ratingDict objectForKey:combined] != nil) {
				// 	NSNumber *num = ratingDict[combined];
				// 	rating = [num intValue];
				// 	NSLog(@"Already loaded %@ (rating=%d)!", combined, rating);
				// } else {
				// 	rating = findStarRating(title, artist, nil);
				// 	[ratingDict setValue:[NSNumber numberWithInt:rating] forKey:combined];
				// 	NSLog(@"Loaded %@ from disk (rating=%d)!", combined, rating);
				// }


				// int likeState = findLikedStateRaw(title, artist, nil); // can possibly be merged into one call...
				int rating = findStarRating(title, artist, nil);
				NSString* newTitle = getTitle(songCell);

				if([newTitle isEqualToString:title]) { // check if the view has been recycled...
					updateMusicLoveWithRating(songCell, title, rating, likeState);
					// if(songCell.alpha == 1.1) {
					// 	songCell.alpha = 1.2;
					// }

				} else {
					NSLog(@"%@ rating (from artist): title changed! (from %@ to %@)", title, title, newTitle);
				}
			//}

			return -1;

		} else {

			UIView* like = findWithSize( songCell, @"UIImageView", HEART_HEIGHT, HEART_WIDTH);
			UIView* dislike = findWithSize( songCell, @"UIImageView", 15 ,16);


			// float width = 17;
			// int height = 17;
			// if(likeState == 3) {
			// 	// if(IDIOM != IPAD)  {
			// 	// 	paddingLeft = 4.5;
			// 	// }
			// 	width = 15;
			// 	height = 16;
			// }


			// already determined
			int likeState;
			if([likeDict objectForKey:combined] != nil) {
				NSNumber *num = likeDict[combined];
				likeState = [num intValue];
				NSLog(@"Already loaded %@ (likeState=%d)!", combined, likeState);
			} else {
				likeState = findLikedState(title, artist, nil);
				[likeDict setValue:[NSNumber numberWithInt:likeState] forKey:combined];
				NSLog(@"Loaded %@ from disk (likeState=%d) (no rating)!", combined, likeState);
			}

			if(like && likeState == 2) {
				NSLog(@"Already displayed like for %@!", combined);
				return 2;
			}
			if(dislike && likeState == 3) {
				NSLog(@"Already displayed dislike for %@!", combined);
				return 3;
			}


			// BOOL changed = NO;
			// if((likeState == 2 && (!like || like == nil))) {
			// 	changed = YES;
			// }
			// if((likeState == 3 && (!dislike || dislike == nil))) {
			// 	changed = YES;
			// }
			// if(like && like != nil && ![like.accessibilityLabel isEqualToString:title]) {
			// 	changed = YES;
			// }
			// if(dislike && dislike != nil && ![dislike.accessibilityLabel isEqualToString:title]) {
			// 	changed = YES;
			// }

			// if(changed) {
				NSString* newTitle = getTitle(songCell);

				if([newTitle isEqualToString:title]) { // check if the view has been recycled...
					updateMusicLoveWithLikeState(songCell, title, likeState);
					if(songCell.alpha == 1.1) {
						songCell.alpha = 1.2;
					}
				} else {
					NSLog(@"%@ likeState (from artist): title changed! (from %@ to %@)", title, title, newTitle);
				}
			// }
			return likeState;
		}
//	}


	// int likeState = findLikedState(title, artist, nil);
	// NSString* newTitle = getTitle(songCell);
	//
	// if([newTitle isEqualToString:title]) { // check if the view has been recycled...
	//
	// 	updateMusicLoveWithLikeState(songCell, likeState);
	//
	// } else {
	// 	NSLog(@"%@ likeState (from artist): title changed! (from %@ to %@)", title, title, newTitle);
	//
	// }
	return 0;
}

NSTimer* tapTimer = nil;
int tapCount = 0;
int tappedRow = -1;

UICollectionView* cv = nil;
NSIndexPath* tapPath = nil;
BOOL playSong = NO;

void songCellTapped(UIViewController* controller, UICollectionView* collectionView, NSMutableDictionary* cellMap, NSIndexPath *indexPath) {
  // NSLog(@"");
  // NSLog(@"didSelectItemAtIndexPath!!");
  // NSLog(@"");

  NSLog(@"DoubleTap: checking for double tap, first tap, new row, !!");

  if(tapCount == 1 && tapTimer != nil && tappedRow == indexPath.row){
      //double tap - Put your double tap code here
      NSLog(@"DoubleTap: Double tap!");
      tapCount = 0;
      tappedRow = -1;
      tapPath = nil;

      [tapTimer invalidate];
      tapTimer = nil;

      UIView* cell = nil;
      if(indexPath) {
        NSNumber* row = [NSNumber numberWithInt:indexPath.row];
        cell = [cellMap objectForKey:row];
      }

      if(!cell) {
        NSLog(@"No cell found!");
        return;
      }


      NSString* title = getTitle((NSObject*)cell);
      NSString* artist = findSongCellArtist((UIView*)cell);
      if(title == nil || artist == nil) {
        return;
      }
      NSLog(@"Toggling likeState for %@ (by %@)", title, artist);

      // THIS WORKS LOCALLY BUT DOESN't SYNC!!

      int newLikeState = toggleLikedState(title, artist);
      if(newLikeState > -1) { // Returns -1 if nothing was updated
        [likeDict removeAllObjects]; // clear like cache
        updateMusicLoveUI((UIView*)cell); // do this so it can handle the stars
        // updateMusicLoveWithLikeState((UIView*)cell, title, newLikeState);
      }

      return; // ensure code below isn't run

      // Maybe Sync daemon is here?

      //  --> x <--

      // UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
      // [self.button addGestureRecognizer:longPress];
      // [longPress release];

      // UILongPressGestureRecognizer* lp = [[UILongPressGestureRecognizer alloc] init];
      // [lp setValue:UIGestureRecognizerStateEnded forKey:@"state"];
      // lp.state = UIGestureRecognizerStateEnded;
      // [cv handleLongPress:UIGestureRecognizerStateEnded];



      // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Double Tap" message:@"You double-tapped the row" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
      // [alert show];
      // [alert release];
  } else if(tapCount == 0){
      //This is the first tap. If there is no tap till tapTimer is fired, it is a single tap
      NSLog(@"DoubleTap: First tap!");

      tapCount = 1;
      tappedRow = indexPath.row;

      cv = collectionView;
      tapPath = indexPath;

      NSLog(@"DoubleTap: testing tapTimer!");
      if(tapTimer != nil){
        NSLog(@"DoubleTap: invalidating tapTimer!");
          [tapTimer invalidate];
          tapTimer = nil;
      }
      NSLog(@"DoubleTap: setting tapTimer!");
      tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:controller selector:@selector(tapTimerFired:) userInfo:nil repeats:NO];

  }


  if(indexPath && tappedRow != indexPath.row){
     NSLog(@"DoubleTap: Tap on new row!");

      //tap on new row
      tapCount = 1;
      tappedRow = indexPath.row;

      cv = collectionView;
      tapPath = indexPath;

      if(tapTimer != nil){

          [tapTimer invalidate];
          tapTimer = nil;
      }
      tapTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:controller selector:@selector(tapTimerFired:) userInfo:nil repeats:NO];

  } else {
    NSLog(@"DoubleTap: Not a new row!");

  }
  NSLog(@"DoubleTap: End");
  NSLog(@"DoubleTap");
}
