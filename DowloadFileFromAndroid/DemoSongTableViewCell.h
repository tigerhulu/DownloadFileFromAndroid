//
//  DemoSongTableViewCell.h
//  DowloadFileFromAndroid
//
//  Created by VincentHu on 14-5-5.
//  Copyright (c) 2014年 VincentHu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DemoSong.h"

@interface DemoSongTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UITextField    *ib_tfTitle;      // song title
@property (strong, nonatomic) IBOutlet UITextField    *ib_tfArtist;     // Artist
@property (strong, nonatomic) IBOutlet UITextField    *ib_tfSize;       // Size
@property (strong, nonatomic) IBOutlet UITextField    *ib_tfDowlodSize; // DowlodSize
@property (strong, nonatomic) IBOutlet UIProgressView *ib_pvDownload;   // process bar


-(void)SetCellData:(DemoSong *)pcDemoSong;
//-(void)cellUpdateProgresssbar:(double)dProcessCount;
-(void)cellUpdateProgresssbar:(int)iReceiveSize :(int)iTotalSize;
-(void)SetCellWhenFinished:(int)iTotalSize;
@end
