// #include "preftools.xm"

#define APPLE_MUSIC_TINT_COLOR 0xFF2D55

static int64_t albumArtistPID = 0;

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
						NSLog(@"Failed to bind item_extra: %s", sqlite3_errmsg(db));
						sqlite3_close(db);

						return pid;
					}


					NSLog(@"statement: %@", likeStmt);
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
					NSLog(@"Failed to open db");
			}
	}else{
		NSLog(@"DB does not exist");
			// NSLog(@"database is not exist.");
	}
	return pid;
}

/**
 * album not working yet!
*/
int findLikedState(NSString* title, NSString* artist, NSString* album) {
		NSLog(@"findLikedState(%@, %@, %@)", title, artist, album);
		if(!heartEnabled()) {
			NSLog(@"<error>: like disabled: returning 0!");
			return 0;
		}
		if(title == nil) {
			NSLog(@"<error>: title is nil. Returning 0!");
			return 0;
		}
		if(album != nil) {
			NSLog(@"Using album: %@", album);
		} else if(artist == nil || artist.length == 0) {
			NSLog(@"Using album PID: %lld", albumArtistPID);
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

						//* album not working yet!
						if(album != nil) {
							// NSString* likeStmt = @"SELECT item_stats.liked_state, item_stats.item_pid, item_stats.liked_state_changed "
							// 	"FROM item_stats "
							// 	"INNER JOIN item_extra ON item_extra.item_pid = item_stats.item_pid "
							// 	"INNER JOIN item ON item.item_pid = item_stats.item_pid "
							// 	"INNER JOIN item_artist ON item_artist.item_artist_pid = item.item_artist_pid "
							// 	"INNER JOIN album_artist ON album_artist.album_artist = item_artist.item_artist "
							// 	"INNER JOIN album ON album.album_artist_pid = album_artist.album_artist_pid "
							// 	"WHERE item_extra.title = ? AND album.album = ?";
								NSString* likeStmt = @"SELECT item_stats.liked_state, item_stats.item_pid, item_stats.liked_state_changed \n"
									"FROM item_stats \n"
									"INNER JOIN item_extra ON item_extra.item_pid = item_stats.item_pid \n"
									"INNER JOIN item ON item.item_pid = item_stats.item_pid \n"

									"INNER JOIN album ON album.album_pid = item.album_pid \n"
									"WHERE item_extra.title = ? AND album.album = ?";

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
							if (sqlite3_bind_text(statement2, 2, [album UTF8String], -1, NULL) != SQLITE_OK) {
								NSLog(@"Failed to bind item_extra: %s", sqlite3_errmsg(db));
								sqlite3_close(db);
								return 0;
							}
						} else if(artist != nil && artist.length > 0) {
							NSString* likeStmt = @"SELECT item_stats.liked_state, item_stats.item_pid, item_stats.liked_state_changed \n"
								"FROM item_stats \n"
								"INNER JOIN item_extra ON item_extra.item_pid = item_stats.item_pid \n"
								"INNER JOIN item ON item.item_pid = item_stats.item_pid \n"
								"INNER JOIN item_artist ON item_artist.item_artist_pid = item.item_artist_pid \n"
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
							NSString* likeStmt = [NSString stringWithFormat:@"SELECT liked_state, item_stats.item_pid, liked_state_changed \n"
								"FROM item_stats \n"
								"INNER JOIN item_extra ON item_extra.item_pid = item_stats.item_pid \n"
								"INNER JOIN item ON item.item_pid = item_stats.item_pid \n"
								"WHERE item_extra.title = ? AND item.item_artist_pid = %lld", albumArtistPID];

	            const char *likeStmtStr = [likeStmt UTF8String]; //"SELECT item_pid, liked_state, liked_state_changed FROM item_stats WHERE item_pid = ";

							NSLog(@"preparing statement: %@!", likeStmt);
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
						NSLog(@"Failed to open db");
        }
    }else{
			NSLog(@"DB does not exist");
        // NSLog(@"database is not exist.");
    }
		return 0;
}


void showHideStar(UIView* view, int likeState) {
	NSLog(@"showHideStar (%@):", likeState == 2 ? @"HIDING" : @"SHOWING");
	//logViewInfo(view);
	return;
	for (UIView *subview in view.subviews){

		if([NSStringFromClass([subview class]) isEqualToString:@"_TtCV5Music4Text9StackView"] && [subview.subviews count] > 0){
			// NSLog(@"UITableViewCellcontentView:found a %@ with %lu subviews!!",
					// NSStringFromClass([subview class]), (unsigned long)[subview.subviews count]);

				NSLog(@"%@ star (1) (origin.x=%f)", (likeState == 2 ? @"hiding":@"showing"), subview.frame.origin.x);


			for(UIView* textStackView in subview.subviews) {
				NSLog(@"star(1.5) origin.x: %f", textStackView.frame.origin.x);

				// dispatch_async(dispatch_get_main_queue(), ^{
				// 	[textStackView setHidden:(likeState==2)];
				// });

				// star origin.x should be around 4.0
				if(textStackView != nil && ((subview.frame.origin.x <= 15) )) {
					// NSLog(@"     -> origin < 15. Hiding now!");
					//dispatch_async(dispatch_get_main_queue(), ^(void){
					NSLog(@"%@ star (2)", likeState == 2 ? @"hiding":@"showing");
					// [textStackView removeFromSuperview];
					dispatch_async(dispatch_get_main_queue(), ^{
						[textStackView setHidden:(likeState == 2)];
					});

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
}

void hideStar(UIView* view) {
	//dispatch_async(dispatch_get_main_queue(), ^{
		showHideStar(view, 2); // hacky...
	//});
}

void drawLike(UIView* _orig, NSString* title, int likeState, int paddingLeft, double paddingTop, BOOL solidBackground, UIColor* forceBackgroundColor) {

	if(likeState == 3 && !dislikeEnabled()) {
		likeState = 0; // override
	}
	NSLog(@"drawLike: state=%d", likeState);

	// if(darkEnabled()) solidBackground = false;

	// NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Resource" ofType:@"bundle"];
	NSString* icon = (likeState == 3 ? @"dislike" : @"heart");
	NSString* imageString = [[NSBundle bundleWithPath:resourceBundle] pathForResource:icon ofType:@"png"];
	// NSLog(@" found image: %@",  imageString);
	// UIImage *heartImage = [UIImage imageNamed:@"heart.png" inBundle:[NSBundle bundleWithPath:resourceBundle];

	if(imageString == nil) {
		NSLog(@" image(%@) is nil", icon);
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


	// if(likeState == NO) {
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

	// } else {
		// NSLog(@"Adding heart %@ (likeState=YES)", getTitle(_orig));


    float _paddingLeft = 0;


    CGRect newFrame = [_orig convertRect:_orig.bounds toView:nil];
    if(newFrame.origin.x == 0) {
      _paddingLeft = 4.5; // 5 or more makes the star poke out left (iPhone 6, 12.0)
    }

		_paddingLeft = 2;
		if(IDIOM == IPAD) {
			_paddingLeft = 0;
		}


    if(paddingLeft < 0) {
      paddingLeft = _paddingLeft;
    }

		if(paddingTop < 0) {
			paddingTop = 15.5; // any less than this,
		}


		float width = 17;
		int height = 17;
		if(likeState == 3) {
			_paddingLeft = 2;
			width = 14.5;
			height = 16;
		}
		CGRect frame = CGRectMake(paddingLeft, paddingTop, width, height);

		NSLog(@"getting color: ");
		UIImageView *newView = [[UIImageView alloc] initWithFrame:frame];
		NSLog(@"newView set");


		UIColor* rootColor;

		UIView* sBackground = find([_orig superview], @"Music.NowPlayingCollectionViewSecondaryBackground");
		if(sBackground) {
			rootColor = [sBackground backgroundColor];
		} else {
			rootColor = recursiveBackgroundColor(_orig);
		}



		// if(forceBackgroundColor) {
		// 	rootColor = forceBackgroundColor;
		// } else {
		// 	rootColor = recursiveBackgroundColor(_orig);
		// }
		 // = forceBackgroundColor ? forceBackgroundColor : recursiveBackgroundColor(_orig);

		NSLog(@"got color: %@", rootColor);
		//
		// NSString *colorString = [CIColor colorWithCGColor:rootColor.CGColor].stringRepresentation;
		// NSLog(@"rootColorString = %@", colorString);

		// March 7 / 2019: found a way to support the native background color with other tweaks.
		UIColor* bgColor = rootColor; //darkEnabled() ? rootColor : [UIColor whiteColor];


		if(newView != nil) {
			if(likeState == 2) {
				[newView setTintColor:UIColorFromRGB(APPLE_MUSIC_TINT_COLOR)];
			} else if(likeState == 3) {
				[newView setTintColor:UIColorFromRGB(0x909090)]; // will want to change this. TODO add pro feature to change these colors.
			} else {
				[newView setTintColor:bgColor];
			}
			// [newView setTintColor:[UIColor redColor]];
			[newView setImage:heartImage];

			// if the star is enabled, it sometimes shows while the heart is showing.
			// This sets a background color on the heart to overlay the star.
			// for some reason I can't see the star until after our code runs (~1s on A10X / iOS 11.4). Forcing this option to be set...
			// if(starEnabled()) {
			//if(solidBackground)
				[newView setBackgroundColor:bgColor];
			// }

			if(likeState != 2 && likeState != 3 && solidBackground == NO) {
				[newView setTintColor:nil];
				[newView setBackgroundColor:rootColor];
				[newView setImage:nil];

			}

			if(solidBackground == NO) {
				[newView setBackgroundColor:nil]; // important! This is for when drawing hearts over album art.
			}

			if(starEnabled() && !(likeState == 2 || likeState == 3)) {
				NSLog(@"Star is enalbed, and this song (%@) is not liked! Not adding the heart subview (returning early)!", title);
				return;
			}

			if(_orig &&  _orig.window != nil) {
				NSLog(@"adding heart");

				[_orig addSubview:newView];
				[_orig bringSubviewToFront:newView];

			}

		}
//	}

}
