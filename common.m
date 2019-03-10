#include <CommonCrypto/CommonDigest.h>
#include "MusicLove.h"
#include <objc/runtime.h>


#define NLOG false

#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

#define IS_OBJECT(T) _Generic( (T), id: YES, default: NO)

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
                green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
                 blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
                alpha:1.0]


// void log(NSString* message) {
// 	// NSString *str = @"LowPowerCheck -- Brayden";
// 	// printf("ALERTMSG: %s\n", [message UTF8String]);
// 	NSLog(@"LOG: %@", message);
// 	return; // for debug only
//
// }

void nlog(NSString* message) {
	if(NLOG) NSLog(@"nlog: %@", message);
}

void alert(NSString* title, NSString* message) {
	NSLog(@"ALERT: %@ %@", title, message);

	if(!title || !message) {
		return;
	}



	NSLog(@"Init alert");

	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
	  message: message
	  delegate:nil
	  cancelButtonTitle: @"Close"
	  otherButtonTitles:nil];

	NSLog(@"Showing");
  [alert show];
  [alert release];

}



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

void logProperties(NSObject* _orig) {
  NSLog(@"Properties:");
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
					NSLog(@"  -> %@: %@ = %@", propertyName, propertyType, [_orig valueForKey:propertyName]);



			}
	}
	// NSLog(@"Freeing properties");

	free(properties);
	// NSLog(@"After free()");
}


void logSubviews(UIView* _orig) {
  NSString* parentClass = NSStringFromClass([_orig class]);
  NSLog(@"%@:", parentClass);

  for(UIView* subview in _orig.subviews) {
    NSString* subviewClass = NSStringFromClass([subview class]);
    NSLog(@"  -> %@ origin.x: %f", subviewClass, subview.frame.origin.x);

  }
}

void logViewInfo(UIView* _orig) {
  NSLog(@"");
  NSLog(@"%@:", NSStringFromClass([_orig class]));

  NSLog(@"Superview:");
  NSLog(@"  -> %@", NSStringFromClass([_orig.superview class]));

  NSLog(@"Subviews:");
  for(UIView* subview in _orig.subviews) {
    NSString* subviewClass = NSStringFromClass([subview class]);
    NSLog(@"  -> %@ origin.x: %f", subviewClass, subview.frame.origin.x);
  }

}

/**
 Emulates jQuery's .closest() function
 // go up the chain to find the closest recursive parent with this class
*/
UIView* closest(UIView* view, NSString* ofType) {
  NSString* thisType = NSStringFromClass([view class]);
  if([thisType isEqualToString:ofType]) {
    return view;
  }

  if([view superview]) {
    return closest([view superview], ofType);
  } else {
    return nil;
  }

}

UIColor* recursiveBackgroundColor(UIView* view) {
	UIColor* thisColor = [view backgroundColor];

	if(thisColor != nil) {
		return thisColor;
	}

  if([view superview]) {
    return recursiveBackgroundColor([view superview]);
  } else {
    return nil;
  }
}

/**
 Emulates jQuery's find() function
 // go down the chain to find the first recursive child with this class
*/
UIView* find(UIView* view, NSString* ofType) {
	NSString* thisType = NSStringFromClass([view class]);
	if([thisType isEqualToString:ofType]) {
    return view;
  }
	for(UIView* subview in view.subviews) {
    NSString* subviewClass = NSStringFromClass([subview class]);
		if([subviewClass isEqualToString: ofType]) {
			return subview;
		}
  }
	for(UIView* subview in view.subviews) {
		UIView* found = find(subview, ofType);
    if(found != nil) {
			return found;
		}
  }

	return nil;

}

NSString* classNameOf(NSObject* obj) {
  return NSStringFromClass([obj class]);
}
BOOL isClass(NSObject* obj, NSString* className) {
  NSString* objClassName = classNameOf(obj);
  return [objClassName isEqualToString: className];
}

NSString* sha1(NSString* str) {

  const char *cStr = [str UTF8String];
  unsigned char result[CC_SHA1_DIGEST_LENGTH];
  CC_SHA1(cStr, strlen(cStr), result);
  NSString *s = [NSString  stringWithFormat:
             @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
             result[0], result[1], result[2], result[3], result[4],
             result[5], result[6], result[7],
             result[8], result[9], result[10], result[11], result[12],
             result[13], result[14], result[15],
             result[16], result[17], result[18], result[19]
             ];

  return s;
}

NSString*  getDataFrom(NSString *url) {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];

    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;

    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];

    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, (int)[responseCode statusCode]);
        return nil;
    }

    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

void setPref(NSString* key, NSString* value) {
  // @"/var/mobile/Library/Preferences/ca.btraas.musiclove.plist"

  NSDictionary* settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];

  // NSMutableDictionary* prefs = [[NSMutableDictionary alloc] initWithContentsOfFile: filename];
  NSString* pref = (NSString*)[settings valueForKey: key];
  NSLog(@"current %@ is %@", key, pref);
  NSLog(@"new %@ is %@", key, value);

  [settings setValue: value forKey: key];

  [settings writeToFile: kPrefsPlistPath atomically: YES];
  NSLog(@"written to file atomically");


  // [settings release];  // not needed if you use Automatic Reference Counting in your project
  // NSLog(@"released settings dict");

}
