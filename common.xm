#define IDIOM    UI_USER_INTERFACE_IDIOM()
#define IPAD     UIUserInterfaceIdiomPad

#define IS_OBJECT(T) _Generic( (T), id: YES, default: NO)

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

NSString* classNameOf(NSObject* obj) {
  return NSStringFromClass([obj class]);
}
BOOL isClass(NSObject* obj, NSString* className) {
  NSString* objClassName = classNameOf(obj);
  return [objClassName isEqualToString: className];
}
