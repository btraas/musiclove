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


void showHideStar(UIView* view, int likeState) {
	for (UIView *subview in view.subviews){

		if([NSStringFromClass([subview class]) isEqualToString:@"_TtCV5Music4Text9StackView"] && [subview.subviews count] > 0){
			// NSLog(@"UITableViewCellcontentView:found a %@ with %lu subviews!!",
					// NSStringFromClass([subview class]), (unsigned long)[subview.subviews count]);

				NSLog(@"%@ star (1) (origin.x=%f)", (likeState == 2 ? @"hiding":@"showing"), subview.frame.origin.x);


			for(UIView* textStackView in subview.subviews) {
				NSLog(@"star(1.5) origin.x: %f", textStackView.frame.origin.x);

				// star origin.x should be around 4.0
				if(textStackView != nil && subview.frame.origin.x <= 15) {
					// NSLog(@"     -> origin < 15. Hiding now!");
					//dispatch_async(dispatch_get_main_queue(), ^(void){
					NSLog(@"%@ star (2)", likeState == 2 ? @"hiding":@"showing");
					// [textStackView removeFromSuperview];
					[textStackView setHidden:(likeState==2)];

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
