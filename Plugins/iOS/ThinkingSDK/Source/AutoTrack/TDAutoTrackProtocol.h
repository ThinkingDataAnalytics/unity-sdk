//
//  TDAutoTrackProtocol.h
//  ThinkingSDK
//
//  Created by Yangxiongon 2022/7/1.
//

#ifndef TDAutoTrackProtocol_h
#define TDAutoTrackProtocol_h

#import <UIKit/UIKit.h>

@protocol TDUIViewAutoTrackDelegate

@optional

/**
 UITableView event properties

 @return event properties
 */
- (NSDictionary *)thinkingAnalytics_tableView:(UITableView *)tableView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

/**
 APPID UITableView event properties
 
 @return event properties
 */
- (NSDictionary *)thinkingAnalyticsWithAppid_tableView:(UITableView *)tableView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 UICollectionView event properties

 @return event properties
 */
- (NSDictionary *)thinkingAnalytics_collectionView:(UICollectionView *)collectionView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

/**
 APPID UICollectionView event properties

 @return event properties
 */
- (NSDictionary *)thinkingAnalyticsWithAppid_collectionView:(UICollectionView *)collectionView autoTrackPropertiesAtIndexPath:(NSIndexPath *)indexPath;

@end


@protocol TDAutoTracker

@optional

- (NSDictionary *)getTrackProperties;


- (NSDictionary *)getTrackPropertiesWithAppid;

@end

/**
 Automatically track the page
 */
@protocol TDScreenAutoTracker <TDAutoTracker>

@optional

/**
 Attributes for custom page view events
 */
- (NSString *)getScreenUrl;

/**
 Configure the properties of the APPID custom page view event
 */
- (NSDictionary *)getScreenUrlWithAppid;

@end

#endif /* TDAutoTrackProtocol_h */
