//
//  SongDetail+CoreDataProperties.h
//  
//
//  Created by qianfeng0 on 15/12/24.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "SongDetail.h"

NS_ASSUME_NONNULL_BEGIN

@interface SongDetail (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *song_id;
@property (nullable, nonatomic, retain) NSString *pic_radio;
@property (nullable, nonatomic, retain) NSString *pic_small;
@property (nullable, nonatomic, retain) NSString *lrc;
@property (nullable, nonatomic, retain) NSString *album_title;
@property (nullable, nonatomic, retain) NSString *author;
@property (nullable, nonatomic, retain) NSString *title;

@end

NS_ASSUME_NONNULL_END
