/* How to Hook with Logos
Hooks are written with syntax similar to that of an Objective-C @implementation.
You don't need to #include <substrate.h>, it will be done automatically, as will
the generation of a class list and an automatic constructor.


*/

#define Debugger
#define NLOG false

#import "MediaRemote.h"
#import "sqlite3.h"
#import <objc/runtime.h>

// #define kBundlePath @"/Library/Application Support/ca.btraas.MusicLove.bundle"
// #define loveHate @"/Library/MusicUISupport/resources/activity/f8262465c21c8bd9405e4b7f873754f8/LoveHateControlLoved.png"
#define bundle @"/Library/Application Support/ca.btraas.musiclove.bundle"
#define loveHate @"/Library/MusicUISupport/resources/activity/5dc19ddcf05cbeed152b84bb1cac1eb4/LoveHateControlLoved@2x.png"
// #define loveHate @"/Library/Application Support/ca.btraas.musiclove.bundle/heart@2x.png"

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

#define IS_OBJECT(T) _Generic( (T), id: YES, default: NO)

BOOL iconExists = YES;

// @interface UITableViewCellContentView
// @property (nonatomic, copy, readwrite) *backgroundColor;
// @end

// iTunes_Control/iTunes/MediaLibrary.sqlitedb -> item_stats.liked_state
//  (2 = liked, 3 = disliked)
// item_pid is id



// NSString* title;
// NSString* subtitle;
// static NSString* albumArtist = @""; // if an album is open, the artist won't show
static int64_t albumArtistPID = 0;

static NSObject* controller;
// static NSMutableDictionary *titles = [[NSMutableDictionary alloc] init];
// static NSMutableArray *heartViews = [[NSMutableArray alloc] init];
//
// static NSMutableDictionary *heartKeys = [[NSMutableDictionary alloc] init];


static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T') {
            if (strlen(attribute) <= 4) {
                break;
            }
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "@";
}



void log(NSString* message) {
	// NSString *str = @"LowPowerCheck -- Brayden";
	// printf("ALERTMSG: %s\n", [message UTF8String]);
	NSLog(@"LOG: %@", message);
	return; // for debug only

}

void nlog(NSString* message) {
	if(NLOG) log(message);
}

void alert(NSString* title, NSString* message) {
	NSLog(@"ALERT: %@ %@", title, message);

	if(!title || !message) {
		return;
	}



	log(@"Init alert");

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
	  message: message
	  delegate:nil
	  cancelButtonTitle: @"Close"
	  otherButtonTitles:nil];

	log(@"Showing");
  [alert show];
  [alert release];

}

int64_t getArtistPID(NSString* artist) {
	NSString *filePath =  @"/var/mobile/Media/iTunes_Control/iTunes/MediaLibrary.sqlitedb"; //[documentsDirectory stringByAppendingPathComponent:@"Questiondata.db"];
	// NSLog(@"filePath,%@",filePath);
	NSFileManager *fileManager = [NSFileManager defaultManager];

	int64_t pid = 0;

	if([fileManager fileExistsAtPath:filePath]){
		// NSLog(@"Database file found.");
			// alertMsg(@"Database exists!");
			// NSMutableArray *retArray =  [[NSMutableArray alloc] init];
			const char *dbpath = [filePath UTF8String];
			sqlite3 *db;
			// NSLog(@"Opening db.");
			if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
					// NSLog(@"DB opened!");

					sqlite3_stmt *statement2;

					NSString* likeStmt = @"SELECT item_artist_pid "
						"FROM item_artist "
						"WHERE item_artist = ?";

					const char *likeStmtStr = [likeStmt UTF8String]; //"SELECT item_pid, liked_state, liked_state_changed FROM item_stats WHERE item_pid = ";

					// NSLog(@"preparing statement!");
					if (sqlite3_prepare_v2(db, likeStmtStr, -1, &statement2, NULL) != SQLITE_OK) {
						NSLog(@"Failed to prepare like stmt: %s", sqlite3_errmsg(db));
						sqlite3_close(db);

						return pid;
					}

					if (sqlite3_bind_text(statement2, 1, [artist UTF8String], -1, NULL) != SQLITE_OK) {
						log([NSString stringWithFormat:@"Failed to bind item_extra: %s", sqlite3_errmsg(db)]);
						sqlite3_close(db);

						return pid;
					}


					log(likeStmt);
					int stepResult = sqlite3_step(statement2);
					if (stepResult == SQLITE_ROW ) {
							pid = sqlite3_column_int64(statement2, 0);
							// int64_t pid2 = sqlite3_column_int64(statement2, 1);
							// log([NSString stringWithFormat:@"%@ (%lld) liked state: %d", title, pid2, likedState]);

							// log([NSString stringWithFormat:@"%@ / %@ / %@ state = %@", title, subtitle, artist, state]);
							sqlite3_finalize(statement2);
							sqlite3_close(db);
							return pid;
							//alert([NSString stringWithFormat:@"%@ state", title], state);
					} else {
						NSLog(@"Failed to step item_stats query (result = %d)!", stepResult);
					}

					sqlite3_finalize(statement2);
					sqlite3_close(db);
			} else {
					log(@"Failed to open db");
			}
	}else{
		log(@"DB does not exist");
			// NSLog(@"database is not exist.");
	}
	return pid;
}

int findLikedState(NSString* title, NSString* artist) {
		NSLog(@"findLikedState(%@, %@)", title, artist);
		if(title == nil) {
			NSLog(@"<error>: title is nil. Returning 0!");
			return 0;
		}
		if(artist == nil || artist.length == 0) {
			NSLog(@"Using album PID: %lld", albumArtistPID);
		}

		if(!iconExists) {
			return 0;
		}


		// int64_t artistPID = findArtistPID(artist);
		// NSLog(@"artist %@ PID: %lld", artist, artistPID);

    // NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    // NSString *documentsDirectory = [paths objectAtIndex:0];
		// /var/mobile/Media/iTunes_Control/iTunes/MediaLibrary.sqlitedb
    NSString *filePath =  @"/var/mobile/Media/iTunes_Control/iTunes/MediaLibrary.sqlitedb"; //[documentsDirectory stringByAppendingPathComponent:@"Questiondata.db"];
    // NSLog(@"filePath,%@",filePath);
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if([fileManager fileExistsAtPath:filePath]){
			// NSLog(@"Database file found.");
				// alertMsg(@"Database exists!");
        // NSMutableArray *retArray =  [[NSMutableArray alloc] init];
        const char *dbpath = [filePath UTF8String];
				sqlite3 *db;
				// NSLog(@"Opening db.");
        if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
						// NSLog(@"DB opened!");

						sqlite3_stmt *statement2;

						if(artist != nil && artist.length > 0) {
							NSString* likeStmt = @"SELECT liked_state, item_stats.item_pid, liked_state_changed "
								"FROM item_stats "
								"INNER JOIN item_extra ON item_extra.item_pid = item_stats.item_pid "
								"INNER JOIN item ON item.item_pid = item_stats.item_pid "
								"INNER JOIN item_artist ON item_artist.item_artist_pid = item.item_artist_pid "
								"WHERE item_extra.title = ? AND item_artist.item_artist = ?";

	            const char *likeStmtStr = [likeStmt UTF8String]; //"SELECT item_pid, liked_state, liked_state_changed FROM item_stats WHERE item_pid = ";

							NSLog(@"preparing statement: %@", likeStmt);
	            if (sqlite3_prepare_v2(db, likeStmtStr, -1, &statement2, NULL) != SQLITE_OK) {
								NSLog(@"Failed to prepare like stmt: %s", sqlite3_errmsg(db));
								sqlite3_close(db);
								return 0;
							}

							if (sqlite3_bind_text(statement2, 1, [title UTF8String], -1, NULL) != SQLITE_OK) {
								NSLog(@"Failed to bind item_extra: %s", sqlite3_errmsg(db));
								sqlite3_close(db);
								return 0;
							}
							if (sqlite3_bind_text(statement2, 2, [artist UTF8String], -1, NULL) != SQLITE_OK) {
								NSLog(@"Failed to bind item_extra: %s", sqlite3_errmsg(db));
								sqlite3_close(db);
								return 0;
							}

						} else {
							NSString* likeStmt = [NSString stringWithFormat:@"SELECT liked_state, item_stats.item_pid, liked_state_changed "
								"FROM item_stats "
								"INNER JOIN item_extra ON item_extra.item_pid = item_stats.item_pid "
								"INNER JOIN item ON item.item_pid = item_stats.item_pid "
								"WHERE item_extra.title = ? AND item.item_artist_pid = %lld", albumArtistPID];

	            const char *likeStmtStr = [likeStmt UTF8String]; //"SELECT item_pid, liked_state, liked_state_changed FROM item_stats WHERE item_pid = ";

							NSLog(@"preparing statement: %@!", likeStmt);
	            if (sqlite3_prepare_v2(db, likeStmtStr, -1, &statement2, NULL) != SQLITE_OK) {
								NSLog(@"Failed to prepare like stmt: %s", sqlite3_errmsg(db));
								sqlite3_close(db);
								return 0;
							}

							if (sqlite3_bind_text(statement2, 1, [title UTF8String], -1, NULL) != SQLITE_OK) {
								log([NSString stringWithFormat:@"Failed to bind item_extra: %s", sqlite3_errmsg(db)]);
								sqlite3_close(db);
								return 0;
							}

						}

						int stepResult = sqlite3_step(statement2);
            if (stepResult == SQLITE_ROW ) {
                int likedState = sqlite3_column_int(statement2, 0);
								// int64_t pid2 = sqlite3_column_int64(statement2, 1);
								// log([NSString stringWithFormat:@"%@ (%lld) liked state: %d", title, pid2, likedState]);
								NSString* state = @"default";
								if(likedState == 2) {
									state = @"liked";
								}
								if(likedState == 3) {
									state = @"disliked";
								}
								// log([NSString stringWithFormat:@"%@ / %@ / %@ state = %@", title, subtitle, artist, state]);
								sqlite3_finalize(statement2);
		            sqlite3_close(db);
								return likedState;
								//alert([NSString stringWithFormat:@"%@ state", title], state);
            } else {
							NSLog(@"<Error> Failed to step item_stats query (result = %d)!", stepResult);
						}

						sqlite3_finalize(statement2);
            sqlite3_close(db);
        } else {
						log(@"Failed to open db");
        }
    }else{
			log(@"DB does not exist");
        // NSLog(@"database is not exist.");
    }
		return 0;
}

NSString* getProperty(NSObject* _orig, NSString* key) {
	unsigned int outCount, i;
	objc_property_t *properties = class_copyPropertyList([_orig class], &outCount);
	// NSLog(@"Loaded %d properties", outCount);

	for(i = 0; i < outCount; i++) {
			// nlog(@"Loading property %d/%d on thread %@", i, outCount, [NSThread currentThread]);

			objc_property_t property = properties[i];
			if(property == nil) {
				continue;
			}
			const char *propName = property_getName(property);
			if(propName) {
					const char *propType = getPropertyType(property);
					NSString *propertyName = [NSString stringWithCString:propName encoding:[NSString defaultCStringEncoding]];
					NSString *propertyType = [NSString stringWithCString:propType encoding:[NSString defaultCStringEncoding]];
					if(propertyName == nil || propertyType == nil){
						continue;
					}
					nlog([NSString stringWithFormat:@"  -> %@: %@ = %@", propertyName, propertyType, [_orig valueForKey:propertyName]]);


					if([propertyName isEqualToString:key]) {
						free(properties);
						return [_orig valueForKey:propertyName];
					}
			}
	}
	// NSLog(@"Freeing properties");

	free(properties);
	return nil;
	// NSLog(@"After free()");
}

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
			[newView setBackgroundColor:[UIColor whiteColor]];
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
						if(isLiked <= 0) {

						}


					    //Background Thread
							// [NSThread sleepForTimeInterval:0f];
					        //Run UI Updates

							for (UIView *subview in _orig.contentView.subviews){

								if([NSStringFromClass([subview class]) isEqualToString:@"_TtCV5Music4Text9StackView"] && [subview.subviews count] > 0){
									// NSLog(@"UITableViewCellcontentView:found a %@ with %lu subviews!!",
											// NSStringFromClass([subview class]), (unsigned long)[subview.subviews count]);

										NSLog(@"%@ star (1) (origin.x=%f)", (isLiked > 0 ? @"hiding":@"showing"), subview.frame.origin.x);


									for(UIView* textStackView in subview.subviews) {
										NSLog(@"star(1.5) origin.x: %f", textStackView.frame.origin.x);

										// star origin.x should be around 4.0
										if(textStackView != nil && subview.frame.origin.x <= 15) {
											// NSLog(@"     -> origin < 15. Hiding now!");
											//dispatch_async(dispatch_get_main_queue(), ^(void){
											NSLog(@"%@ star (2)", isLiked > 0 ? @"hiding":@"showing");
											// [textStackView removeFromSuperview];
											[textStackView setHidden:(isLiked==1)];

												// if(textStackView != nil && textStackView.window != nil) {
												// 	if(isLiked == 1) {
												// 		textStackView.hidden = YES;
												// 		[textStackView removeFromSuperview];
												// 	} else {
												// 		textStackView.hidden = NO;
												// 	}
												// }

											// });
										}
									}

									// UIView* child = subview.subviews[0];
									// NSLog(@"   -> Stackview child: %@", NSStringFromClass([child class]));
									// NSLog(@"     -> x = %f, width = %f", subview.frame.origin.x, child.frame.size.width);

									// break;
								}
							}

					// });
				//}


		}

		return _orig;

}
%end



%ctor {
	//%init(SongCell = objc_getClass("Music.SongCell"));

    %init(CompositeCollectionViewController = objc_getClass("Music.CompositeCollectionViewController"));
		//%init(ViewController = objc_getClass("HookExampleApp.ViewController"));

}
