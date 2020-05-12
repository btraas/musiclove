// #include "preftools.xm"
// #include "libcolorpicker.h"
// #import "libcolorpicker.h"


#define APPLE_MUSIC_TINT_COLOR 0xFF2D55


static int64_t albumArtistPID = 0;

UIColor* colorFromHexString(NSString* hexString) {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}
// "SELECT item_stats.liked_state FROM item JOIN item_stats USING (item_pid) WHERE item.ROWID = ?" // ML3Track
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




int findLikedStateRaw(NSString* title, NSString* artist, NSString* album) {

		if(title == nil) {
			NSLog(@"<error>: title is nil. Returning 0!");
			return 0;
		}
		if(album != nil) {
			NSLog(@"Using album: %@", album);
		} else if(artist == nil || artist.length == 0) {
			NSLog(@"Using album artist PID: %lld", albumArtistPID);
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
				NSLog(@"<Error> findLikedStateRaw Failed to step item_stats query (result = %d)!", stepResult);
			}

			sqlite3_finalize(statement2);
            sqlite3_close(db);
        } else {
			NSLog(@"Failed to open db");
        }
    } else {
			NSLog(@"DB does not exist");
        // NSLog(@"database is not exist.");
    }
		return 0;
}

int findLikedState(NSString* title, NSString* artist, NSString* album) {
  NSLog(@"findLikedState(%@, %@, %@)", title, artist, album);
  if(!heartEnabled()) {
    NSLog(@"<error>: like disabled: returning 0!");
    return 0;
  }
  return findLikedStateRaw(title, artist, album);
}


// returns -1 if nothing is changed!
int toggleLikedState(NSString* title, NSString* artist) {
		NSLog(@"toggleLikedState(%@, %@)", title, artist);

		if(!doubleTapLikeEnabled()) {
			NSLog(@"Double tap liking is disabled! Exiting early!");
			return -1;
		}

		// if(!heartEnabled()) {
		// 	NSLog(@"<error>: like disabled: returning 0!");
		// 	return 0;
		// } // TODO add a check for pro / toggling enabled
		if(title == nil) {
			NSLog(@"<error>: title is nil. Returning 0!");
			return 0;
		}
		if(artist == nil || artist.length == 0) {
			NSLog(@"Using album artist PID: %lld", albumArtistPID);
		}


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

						// First get the pid and like state of the item

						if(artist != nil && artist.length > 0) {
							NSString* likeStmt = @"SELECT item_stats.liked_state, item_stats.item_pid, item.in_my_library, item_stats.liked_state_changed \n"
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
							NSString* likeStmt = [NSString stringWithFormat:@"SELECT liked_state, item_stats.item_pid, item.in_my_library, liked_state_changed \n"
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
								int64_t itemPid = sqlite3_column_int64(statement2, 1);
								int inMyLibrary = sqlite3_column_int(statement2, 2);

								// if(inMyLibrary != 1) {
								// 	NSLog(@"Error: %@ is not in the library.", title);
								// 	alert(@"Not supported", [NSString stringWithFormat:@"Please add '%@' to your library before liking it.", title]);
								// 	return -1;
								// }
								NSLog(@"In my library status (%@): %d", title, inMyLibrary);

								// int64_t pid2 = sqlite3_column_int64(statement2, 1);
								// log([NSString stringWithFormat:@"%@ (%lld) liked state: %d", title, pid2, likedState]);
								int newState = (likedState == 2) ? 0 : 2;

								NSString* state = @"default";
								if(likedState == 2) {
									state = @"liked";
								}
								if(likedState == 3) {
									state = @"disliked";
								}
								NSLog(@"Old like state: %d, new state: %d", likedState, newState);
								// log([NSString stringWithFormat:@"%@ / %@ / %@ state = %@", title, subtitle, artist, state]);
								sqlite3_finalize(statement2);


								// -(void)setItemProperties:(id)arg1 forSagaID:(unsigned long long)arg2 completion:(/*^block*/id)arg3 ;

								// Looks like like/dislike calls setItemProperties from HomeSharing.framework/HSCloudClient.h (private)
								//  Or HomeSharing.framework/Support/itunescloudd/CloudConnection.h (iOS 8.1...)
								// See logs below


								/*
								Mar 11 11:45:09 Braydens-iPad Music(HomeSharing)[15599] <Notice>: Setting item properties {
								    "item_stats.liked_state" = 3;
								} for saga ID 182998570...
								Mar 11 11:45:09 Braydens-iPad Music(libMobileGestalt.dylib)[15599] <Notice>: libMobileGestalt MobileGestalt.c:2898: statfs(/mnt4): No such file or directory
								Mar 11 11:45:09 Braydens-iPad itunescloudd[534] <Notice>: Updating item properties for sagaID 182998570. properties={
								    "item_stats.liked_state" = 3;
								Mar 11 11:45:09 Braydens-iPad itunescloudd[534] <Notice>: Issuing immediate property change: {
								    "item_stats.liked_state" = 3;
								Mar 11 11:45:09 Braydens-iPad locationd[582] <Notice>: {"msg":"reduceFreePages", "path":"\134/var\134/root\134/Library\134/Caches\134/locationd\134/sensorRecorder_encryptedC.db", "page_count":13, "freelist_count":0, "loadFactor":"1.000000"}
								Mar 11 11:45:09 Braydens-iPad locationd[582] <Notice>: {"msg":"reduceFreePages", "event":"elapsed", "begin_mach":4031524620360, "end_mach":4031525022166, "elapsed_s":"0.016741917"}
								Mar 11 11:45:09 Braydens-iPad medialibraryd[565] <Notice>: Successfully began transaction for client <MLDClient 0x108eec870 Music> with identifier CF497009-8044-4D20-B06D-FCD901A23F09.
								Mar 11 11:45:09 Braydens-iPad medialibraryd[565] <Notice>: Committing transaction CF497009-8044-4D20-B06D-FCD901A23F09
								Mar 11 11:45:09 Braydens-iPad itunescloudd[534] <Notice>: Sending request: <ICBulkSetItemPropertyRequest: 0x110f61f10 method=POST action=databases/1/items/edit> to URL: databases/1/items/edit -- https://ld-8.itunes.apple.com:443/WebObjects/MZDaap.woa/daap/
								Mar 11 11:45:09 Braydens-iPad itunescloudd[534] <Notice>: Request headers: {
								    "Client-Cloud-Daap-Version" = "1.3/15G77";
								    "Client-Cloud-Purchase-DAAP-Version" = "1.1/iOS-15G77";
								    "Content-Type" = "application/x-dmap-tagged";
								    "X-Apple-Private-Listening" = false;
								    "X-Guid" = 62302671ecd2de8ce2e531ad4285563e126e8ae8;
								}
								Mar 11 11:45:09 Braydens-iPad itunescloudd(iTunesCloud)[534] <Notice>: <ICStoreURLSession: 0x10df0e360> enqueueing request <ICStoreURLRequest: 0x110b65250>[itunescloudd/1.0][requestContext=<ICStoreRequestContext: 0x100d68560>]
								Mar 11 11:45:09 Braydens-iPad itunescloudd(iTunesCloud)[534] <Notice>: <ICStoreURLRequest: 0x110b65250>[itunescloudd/1.0][requestContext=<ICStoreRequestContext: 0x100d68560>] creating mescal signature for request. configuration=<ICURLBagMescalConfiguration: 0x110856af0>; shouldSignBody=1, fields=(null), headers=(null)
								Mar 11 11:45:09 Braydens-iPad assertiond[540] <Notice>: [Music:15599] Attempting to acquire assertion for Music:15599: <BKProcessAssertion: 0x102d49b50; "com.apple.StoreServices.SSSQLiteDatabase.com.apple.itunesstored.2.sqlitedb" (finishTask:180s); id:\M-b\M^@\M-&98F298A5C1D2>
								Mar 11 11:45:09 Braydens-iPad assertiond[540] <Notice>: [Music:15599] Mutating assertion reason from finishTask to finishTaskUnbounded
								Mar 11 11:45:09 Braydens-iPad assertiond[540] <Notice>: [Music:15599] Add assertion: <BKProcessAssertion: 0x102d49b50; id: 15599-A077CF26-F81D-497A-912F-98F298A5C1D2; name: com.apple.StoreServices.SSSQLiteDatabase.com.apple.itunesstored.2.sqlitedb; state: active; reason: finishTaskUnbounded; duration: infs> {
								    owner = <BSProcessHandle: 0x103a64be0; Music:15599; valid: YES>;
								    flags = preventSuspend, preventIdleSleep, preventSuspendOnSleep;
								}
								Mar 11 11:45:09 Braydens-iPad assertiond[540] <Notice>: [Music:15599] Activate assertion: <BKProcessAssertion: 0x102d49b50; "com.apple.StoreServices.SSSQLiteDatabase.com.apple.itunesstored.2.sqlitedb" (finishTask:180s); id:\M-b\M^@\M-&98F298A5C1D2>
								Mar 11 11:45:09 Braydens-iPad assertiond[540] <Notice>: [Music:15599] Canceled allow-idle-sleep timer
								Mar 11 11:45:09 Braydens-iPad assertiond[540] <Notice>: [Music:15599] New process assertion state; preventSuspend, preventThrottleDownUI, preventThrottleDownCPU, preventIdleSleep, preventSuspendOnSleep (assertion 0x102d49b50 added: preventIdleSleep; removed: (none))
								Mar 11 11:45:09 Braydens-iPad assertiond[540] <Notice>: [Music:15599] Setting jetsam priority to 10 [0x11100]
								Mar 11 11:45:09 Braydens-iPad assertiond[540] <Notice>: Creating PowerAssertion on Music:15599
								Mar 11 11:45:09 Braydens-iPad powerd[513] <Notice>: Sleep revert state: 1
								Mar 11 11:45:09 Braydens-iPad powerd[513] <Notice>: Process assertiond.540 Created SystemIsActive "Music:15599:15599-A077CF26-F81D-497A-912F-98F298A5C1D2 [com.apple.StoreServices.SSSQLiteDatabase.com.apple.itunesstored.2.sqlitedb] [0x102d49b50]" age:00:00:00  id:51539650379 [System: SysAct]
								Mar 11 11:45:09 Braydens-iPad assertiond[540] <Notice>: Created PowerAssertion on Music:15599, sleep reverted
								Mar 11 11:45:09 Braydens-iPad itunescloudd(iTunesCloud)[534] <Notice>: <ICStoreURLSession: 0x10df0e360> <ICStoreURLRequest: 0x110b65250>[itunescloudd/1.0][requestContext=<ICStoreRequestContext: 0x100d68560>] created url task <__NSCFLocalDataTask: 0x11120f690>{ taskIdentifier: 1045 } { suspended } (attempt 1/2) for url=https://ld-8.itunes.apple.com:443/WebObjects/MZDaap.woa/daap/databases/1/items/edit
								Mar 11 11:45:09 Braydens-iPad itunescloudd(CFNetwork)[534] <Notice>: TIC Enabling TLS [373:0x110f6f940]
								Mar 11 11:45:09 Braydens-iPad itunescloudd(CFNetwork)[534] <Notice>: TIC TCP Conn Start [373:0x110f6f940]
								Mar 11 11:45:09 Braydens-iPad itunescloudd(CFNetwork)[534] <Notice>: Task <6EBCD054-C8CA-462A-85C2-9D5BB932390F>.<1045> setting up Connection 373
								Mar 11 11:45:09 Braydens-iPad itunescloudd(libnetwork.dylib)[534] <Notice>: [380 <private> <private>] start
								Mar 11 11:45:09 Braydens-iPad atc(MusicLibrary)[522] <Notice>: <private>|got sync preferences changed notification
								Mar 11 11:45:09 Braydens-iPad atc(MusicLibrary)[522] <Notice>: <private>|playlist settings have not changed
								Mar 11 11:45:09 Braydens-iPad atc(MusicLibrary)[522] <Notice>: <private>|got sync preferences changed notification
								Mar 11 11:45:09 Braydens-iPad atc(MusicLibrary)[522] <Notice>: <private>|playlist settings have not changed
								Mar 11 11:45:09 Braydens-iPad itunescloudd(CFNetwork)[534] <Notice>: TIC TLS Event [373:0x110f6f940]: 1, Pending(0)
								Mar 11 11:45:09 Braydens-iPad itunescloudd(CFNetwork)[534] <Notice>: TIC TLS Event [373:0x110f6f940]: 2, Pending(0)
								Mar 11 11:45:09 Braydens-iPad itunescloudd(CFNetwork)[534] <Notice>: TIC TLS Event [373:0x110f6f940]: 11, Pending(0)
								Mar 11 11:45:09 Braydens-iPad itunescloudd(CFNetwork)[534] <Notice>: TIC TLS Event [373:0x110f6f940]: 12, Pending(0)
								Mar 11 11:45:09 Braydens-iPad itunescloudd(CFNetwork)[534] <Notice>: TIC TLS Event [373:0x110f6f940]: 14, Pending(0)

								*/


								NSString* updateStmt = [NSString stringWithFormat:@"UPDATE item_stats \n"
									"SET liked_state = %d, liked_state_changed = 1 \n"
									"WHERE item_pid = %lld", newState, itemPid];

		            const char *updateStmtStr = [updateStmt UTF8String]; //"SELECT item_pid, liked_state, liked_state_changed FROM item_stats WHERE item_pid = ";
								sqlite3_stmt *statement3;

								NSLog(@"preparing statement: %@!", updateStmt);
		            if (sqlite3_prepare_v2(db, updateStmtStr, -1, &statement3, NULL) != SQLITE_OK) {
									NSLog(@"Failed to prepare update stmt: %s", sqlite3_errmsg(db));
									sqlite3_close(db);
									return 0;
								}

								if(sqlite3_step(statement3) == SQLITE_DONE) {
						        NSLog(@"Query Executed");
						    } else {
						        NSLog(@"Query NOT Executed: %s", sqlite3_errmsg(db));
						    }
						    sqlite3_finalize(statement3);


		            sqlite3_close(db);
								return newState;
								//alert([NSString stringWithFormat:@"%@ state", title], state);
            } else {
							NSLog(@"<Error> ToggleLikedState Failed to step item_stats query (result = %d)!", stepResult);
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
		return -1;
}


// New May 2019


/**
 * album not working yet!
*/
int findStarRating(NSString* title, NSString* artist, NSString* album) {
		NSLog(@"findStarRating(%@, %@, %@)", title, artist, album);
		if(!ratingEnabled()) {
			NSLog(@"<error>: rating disabled: returning 0!");
			return 0;
		}
		if(title == nil) {
			NSLog(@"<error>: title is nil. Returning 0!");
			return 0;
		}
		if(album != nil) {
			NSLog(@"Using album: %@", album);
		} else if(artist == nil || artist.length == 0) {
			NSLog(@"Using album artist PID: %lld", albumArtistPID);
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
								NSString* likeStmt = @"SELECT item_stats.user_rating, item_stats.liked_state, item_stats.item_pid, item_stats.liked_state_changed  \n"
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
							NSString* likeStmt = @"SELECT item_stats.user_rating, item_stats.liked_state, item_stats.item_pid, item_stats.liked_state_changed \n"
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
							NSString* likeStmt = [NSString stringWithFormat:@"SELECT item_stats.user_rating, liked_state, item_stats.item_pid, liked_state_changed \n"
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
                int userRating = sqlite3_column_int(statement2, 0);
								// int64_t pid2 = sqlite3_column_int64(statement2, 1);
								// log([NSString stringWithFormat:@"%@ (%lld) liked state: %d", title, pid2, likedState]);
								NSString* state = @"default";
                if(userRating == 0) {
									state = @"0";
								}
								if(userRating == 20) {
									state = @"1";
								}
								if(userRating == 40) {
									state = @"2";
								}
                if(userRating == 60) {
									state = @"3";
								}
                if(userRating == 80) {
									state = @"4";
								}
                if(userRating == 100) {
									state = @"5";
								}
								// log([NSString stringWithFormat:@"%@ / %@ / %@ state = %@", title, subtitle, artist, state]);
								sqlite3_finalize(statement2);
		            sqlite3_close(db);
								return userRating;
								//alert([NSString stringWithFormat:@"%@ state", title], state);
            } else {
							NSLog(@"<Error> findStarRating Failed to step item_stats query (result = %d)!", stepResult);
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

// End May 2019

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

void drawLike(UIView* _orig, NSString* title, int likeState, double paddingLeft, double paddingTop, BOOL solidBackground, UIColor* forceBackgroundColor) {

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

    CGRect newFrame = [_orig convertRect:_orig.bounds toView:nil];

		if(paddingLeft < 0) { // then automatic.
			if(IDIOM == IPAD) {
				paddingLeft = 0;
			} else {
				if(newFrame.origin.x == 0) {
		      paddingLeft = 2.5; // 5 or more makes the star poke out left (iPhone 6, 12.0)
		    }
				if(likeState == 3) {
					paddingLeft += 1.5;
				}
			}
		}


		if(paddingTop < 0) {
			paddingTop = 15.5; // any less than this,
		}


		float width = 17;
		int height = 17;
		if(likeState == 3) {
			// if(IDIOM != IPAD)  {
			// 	paddingLeft = 4.5;
			// }
			width = 15;
			height = 16;
		}
		CGRect frame = CGRectMake(paddingLeft, paddingTop, width, height);

		NSLog(@"getting color: ");
		UIImageView *newView = [[UIImageView alloc] initWithFrame:frame];
		NSLog(@"newView set");


		UIColor* rootColor;

        float ver = [[[UIDevice currentDevice] systemVersion] floatValue];

        UIView* sBackground;
        if(ver >= 13.0) {
            sBackground = find([_orig superview], @"MusicApplication.NowPlayingCollectionViewSecondaryBackground");
        } else {
            sBackground	= find([_orig superview], @"Music.NowPlayingCollectionViewSecondaryBackground");
        }

		if(sBackground) {
			rootColor = [sBackground backgroundColor];
		} else {
			rootColor = recursiveBackgroundColor(_orig);
		}

		UICollectionViewCell* songCell = (UICollectionViewCell*)_orig;
		if([songCell isSelected]) {
			rootColor = [[songCell selectedBackgroundView] backgroundColor];
			// rootColor = nil;
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
				[newView setTintColor:colorFromHexString(getLikeColor())]; // fallback to apple pink
				// [newView setTintColor:UIColorFromRGB(APPLE_MUSIC_TINT_COLOR))];
			} else if(likeState == 3) {
				[newView setTintColor:colorFromHexString(getDislikeColor())]; // fallback to red (#ff0000)

				// [newView setTintColor:UIColorFromRGB(0x909090)]; // will want to change this. TODO add pro feature to change these colors.
			} else {
        NSLog(@"likeState = %d, returning!", likeState);
        [newView removeFromSuperview];
        return;
				// [newView setTintColor:bgColor];
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
				// [newView setTintColor:nil];
				// [newView setBackgroundColor:rootColor];
				// [newView setImage:nil];
        NSLog(@"likeState = %d and solidbackground=NO, returning!", likeState);

        [newView removeFromSuperview];
        return;

			}

			// if(solidBackground == NO) {
				[newView setBackgroundColor:nil]; // important! This is for when drawing hearts over album art.
			// }

			if(starEnabled() && !(likeState == 2 || likeState == 3)) {
				NSLog(@"Star is enalbed, and this song is not liked! Not adding the heart subview (returning early)!");
				return;
			}

			if(_orig) {
				NSLog(@"adding heart");

				[_orig addSubview:newView];
				[_orig bringSubviewToFront:newView];

			} else {
        NSLog(@"_orig is nil!: %@", _orig);
      }

		}
//	}

}


void drawRating(UIView* _orig, NSString* title, int rating, int likeState, double paddingLeft, double paddingTop, BOOL solidBackground, UIColor* forceBackgroundColor) {

	if(!ratingEnabled()) {
		rating = 0; // override
    return;
	}
	NSLog(@"drawRating: rating=%d, likeState=%d", rating, likeState);

	// if(darkEnabled()) solidBackground = false;

	// NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Resource" ofType:@"bundle"];
	NSString* icon;

  if(likeState == 2) {
    switch(rating) {
      case 100: icon = @"5heart"; break;
      case 80: icon = @"4heart"; break;
      case 60: icon = @"3herat"; break;
      case 40: icon = @"2heart"; break;
      case 20: icon = @"1heart"; break;
      default: icon = @"0heart"; break;
    }
  } else {
    switch(rating) {
      case 100: icon = @"5star"; break;
      case 80: icon = @"4star"; break;
      case 60: icon = @"3star"; break;
      case 40: icon = @"2star"; break;
      case 20: icon = @"1star"; break;
      default: icon = @"0star"; break;
    }
  }

	NSString* imageString = [[NSBundle bundleWithPath:resourceBundle] pathForResource:icon ofType:@"png"];
	// NSLog(@" found image: %@",  imageString);
	// UIImage *heartImage = [UIImage imageNamed:@"heart.png" inBundle:[NSBundle bundleWithPath:resourceBundle];

	if(imageString == nil) {
		NSLog(@" image(%@) is nil", icon);
		return;
	}
	UIImage *image = [UIImage imageWithContentsOfFile:imageString];
	if(image == nil) {
		NSLog(@" image is nil");

		return;
	}

	// UIImage *heartImage = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/heart@2x.png", bundle]];
	image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
	if(image == nil) {
		NSLog(@" image is nil");
		return;
	}


	// if(likeState == NO) {
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



    CGRect newFrame = [_orig convertRect:_orig.bounds toView:nil];

		if(paddingLeft < 0) { // then automatic.
			if(IDIOM == IPAD) {
				paddingLeft = 0;
			} else {
				if(newFrame.origin.x == 0) {
		      paddingLeft = 2.5; // 5 or more makes the star poke out left (iPhone 6, 12.0)
		    }
				if(rating == 80) {
					paddingLeft += 1.5;
				}
			}

		}

		// if(paddingTop < 0) {
		// 	paddingTop = 15.5; // any less than this,
		// }
    //
    // paddingTop = 3;

		float width = 17;
		int height = 47;
		// if(rating == 80) {
		// 	// if(IDIOM != IPAD)  {
		// 	// 	paddingLeft = 4.5;
		// 	// }
		// 	width = 15;
		// 	height = 16;
		// }
		CGRect frame = CGRectMake(paddingLeft, paddingTop, width, height);

		NSLog(@"getting color: ");
		UIImageView *newView = [[UIImageView alloc] initWithFrame:frame];
    // NSString* desc = [newView description];
    newView.accessibilityLabel = title;
    // NSLog(@"desc: %@", desc);
		NSLog(@"newView set");


		UIColor* rootColor;

        float ver = [[[UIDevice currentDevice] systemVersion] floatValue];

        UIView* sBackground;

        if(ver >= 13.0) {
            sBackground = find([_orig superview], @"MusicApplication.NowPlayingCollectionViewSecondaryBackground");
        } else {
            sBackground = find([_orig superview], @"Music.NowPlayingCollectionViewSecondaryBackground");
        }

		if(sBackground) {
			rootColor = [sBackground backgroundColor];
		} else {
			rootColor = recursiveBackgroundColor(_orig);
		}

		UICollectionViewCell* songCell = (UICollectionViewCell*)_orig;
		if([songCell isSelected]) {
			rootColor = [[songCell selectedBackgroundView] backgroundColor];
			// rootColor = nil;
		}

		NSLog(@"got color: %@", rootColor);
		//
		// NSString *colorString = [CIColor colorWithCGColor:rootColor.CGColor].stringRepresentation;
		// NSLog(@"rootColorString = %@", colorString);

		// March 7 / 2019: found a way to support the native background color with other tweaks.
		UIColor* bgColor = rootColor; //darkEnabled() ? rootColor : [UIColor whiteColor];


		if(newView != nil) {
			// if(rating == 100) {
			// 	[newView setTintColor:colorFromHexString(getLikeColor())]; // fallback to apple pink
			// 	// [newView setTintColor:UIColorFromRGB(APPLE_MUSIC_TINT_COLOR))];
			// } else if(rating == 80) {
			// 	[newView setTintColor:colorFromHexString(getDislikeColor())]; // fallback to red (#ff0000)
      //
			// 	// [newView setTintColor:UIColorFromRGB(0x909090)]; // will want to change this. TODO add pro feature to change these colors.
			// } else {
			// 	[newView setTintColor:bgColor];
			// }
			// [newView setTintColor:[UIColor redColor]];
			[newView setImage:image];

			// if the star is enabled, it sometimes shows while the heart is showing.
			// This sets a background color on the heart to overlay the star.
			// for some reason I can't see the star until after our code runs (~1s on A10X / iOS 11.4). Forcing this option to be set...
			// if(starEnabled()) {
			//if(solidBackground)
				[newView setBackgroundColor:bgColor];
			// }

			// if(rating != 100 && rating != 80 && solidBackground == NO) {
			// 	[newView setTintColor:nil];
			// 	[newView setBackgroundColor:rootColor];
			// 	[newView setImage:nil];
      //
			// }

			// if(solidBackground == NO ) {
				[newView setBackgroundColor:nil]; // important! This is for when drawing hearts over album art.
			// }

			// if(starEnabled() && !(rating == 100 || rating == 80)) {
			// 	NSLog(@"Star is enabled, and this song is not rated! Not adding the star subview (returning early)!");
			// 	return;
			// }

			if(_orig &&  _orig.window != nil) {
				NSLog(@"adding stars");

				[_orig addSubview:newView];
				[_orig bringSubviewToFront:newView];

			}

		}
//	}

}
