#include "MusicLove.h"

BOOL heartEnabled() {
	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
  return settings[@"show-song-heart"] ? [settings[@"show-song-heart"] boolValue] : YES;
}

BOOL starEnabled() {
	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
  BOOL enabled =  settings[@"show-song-popularity"] ? [settings[@"show-song-popularity"] boolValue] : YES;
  // NSLog(@"starEnabled: %@", enabled ? @"YES" : @"NO");
  return enabled;
}
BOOL darkEnabled() {
	NSDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPrefsPlistPath];
  return settings[@"support-dark-tweak"] ? [settings[@"support-dark-tweak"] boolValue] : NO;
}
