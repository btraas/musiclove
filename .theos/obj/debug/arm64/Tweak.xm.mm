#line 1 "Tweak.xm"








#define Debugger
#define NLOG false

#import "MediaRemote.h"
#import "sqlite3.h"
#import <objc/runtime.h>



#define bundle @"/Library/Application Support/ca.btraas.musiclove.bundle"
#define loveHate @"/Library/MusicUISupport/resources/activity/5dc19ddcf05cbeed152b84bb1cac1eb4/LoveHateControlLoved@2x.png"


#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

#define IS_OBJECT(T) _Generic( (T), id: YES, default: NO)

BOOL iconExists = YES;














static int64_t albumArtistPID = 0;

static NSObject* controller;






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
	
	
	NSLog(@"LOG: %@", message);
	return; 

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
	NSString *filePath =  @"/var/mobile/Media/iTunes_Control/iTunes/MediaLibrary.sqlitedb"; 
	
	NSFileManager *fileManager = [NSFileManager defaultManager];

	int64_t pid = 0;

	if([fileManager fileExistsAtPath:filePath]){
		
			
			
			const char *dbpath = [filePath UTF8String];
			sqlite3 *db;
			
			if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
					

					sqlite3_stmt *statement2;

					NSString* likeStmt = @"SELECT item_artist_pid "
						"FROM item_artist "
						"WHERE item_artist = ?";

					const char *likeStmtStr = [likeStmt UTF8String]; 

					
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
							
							

							
							sqlite3_finalize(statement2);
							sqlite3_close(db);
							return pid;
							
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


		
		

    
    
		
    NSString *filePath =  @"/var/mobile/Media/iTunes_Control/iTunes/MediaLibrary.sqlitedb"; 
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if([fileManager fileExistsAtPath:filePath]){
			
				
        
        const char *dbpath = [filePath UTF8String];
				sqlite3 *db;
				
        if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
						

						sqlite3_stmt *statement2;

						if(artist != nil && artist.length > 0) {
							NSString* likeStmt = @"SELECT liked_state, item_stats.item_pid, liked_state_changed "
								"FROM item_stats "
								"INNER JOIN item_extra ON item_extra.item_pid = item_stats.item_pid "
								"INNER JOIN item ON item.item_pid = item_stats.item_pid "
								"INNER JOIN item_artist ON item_artist.item_artist_pid = item.item_artist_pid "
								"WHERE item_extra.title = ? AND item_artist.item_artist = ?";

	            const char *likeStmtStr = [likeStmt UTF8String]; 

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

	            const char *likeStmtStr = [likeStmt UTF8String]; 

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
								
								
								NSString* state = @"default";
								if(likedState == 2) {
									state = @"liked";
								}
								if(likedState == 3) {
									state = @"disliked";
								}
								
								sqlite3_finalize(statement2);
		            sqlite3_close(db);
								return likedState;
								
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
        
    }
		return 0;
}

NSString* getProperty(NSObject* _orig, NSString* key) {
	unsigned int outCount, i;
	objc_property_t *properties = class_copyPropertyList([_orig class], &outCount);
	

	for(i = 0; i < outCount; i++) {
			

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
	

	free(properties);
	return nil;
	
}

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

@class CompositeCollectionViewController; 
static UICollectionReusableView * (*_logos_orig$_ungrouped$CompositeCollectionViewController$collectionView$viewForSupplementaryElementOfKind$atIndexPath$)(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL, UICollectionView*, NSString *, NSIndexPath *); static UICollectionReusableView * _logos_method$_ungrouped$CompositeCollectionViewController$collectionView$viewForSupplementaryElementOfKind$atIndexPath$(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL, UICollectionView*, NSString *, NSIndexPath *); static UICollectionViewCell * (*_logos_orig$_ungrouped$CompositeCollectionViewController$collectionView$cellForItemAtIndexPath$)(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL, id, NSIndexPath *); static UICollectionViewCell * _logos_method$_ungrouped$CompositeCollectionViewController$collectionView$cellForItemAtIndexPath$(_LOGOS_SELF_TYPE_NORMAL id _LOGOS_SELF_CONST, SEL, id, NSIndexPath *); 

#line 432 "Tweak.xm"


	



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
						if(isLiked <= 0) {

						}


					    
							
					        

							for (UIView *subview in _orig.contentView.subviews){

								if([NSStringFromClass([subview class]) isEqualToString:@"_TtCV5Music4Text9StackView"] && [subview.subviews count] > 0){
									
											

										NSLog(@"%@ star (1) (origin.x=%f)", (isLiked > 0 ? @"hiding":@"showing"), subview.frame.origin.x);


									for(UIView* textStackView in subview.subviews) {
										NSLog(@"star(1.5) origin.x: %f", textStackView.frame.origin.x);

										
										if(textStackView != nil && subview.frame.origin.x <= 15) {
											
											
											NSLog(@"%@ star (2)", isLiked > 0 ? @"hiding":@"showing");
											
											[textStackView setHidden:(isLiked==1)];

												
												
												
												
												
												
												
												

											
										}
									}

									
									
									

									
								}
							}

					
				


		}

		return _orig;

}




static __attribute__((constructor)) void _logosLocalCtor_0907cfcf(int __unused argc, char __unused **argv, char __unused **envp) {
	

    {Class _logos_class$_ungrouped$CompositeCollectionViewController = objc_getClass("Music.CompositeCollectionViewController"); MSHookMessageEx(_logos_class$_ungrouped$CompositeCollectionViewController, @selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:), (IMP)&_logos_method$_ungrouped$CompositeCollectionViewController$collectionView$viewForSupplementaryElementOfKind$atIndexPath$, (IMP*)&_logos_orig$_ungrouped$CompositeCollectionViewController$collectionView$viewForSupplementaryElementOfKind$atIndexPath$);MSHookMessageEx(_logos_class$_ungrouped$CompositeCollectionViewController, @selector(collectionView:cellForItemAtIndexPath:), (IMP)&_logos_method$_ungrouped$CompositeCollectionViewController$collectionView$cellForItemAtIndexPath$, (IMP*)&_logos_orig$_ungrouped$CompositeCollectionViewController$collectionView$cellForItemAtIndexPath$);}
		

}
