//
//  DemoSong.h
//  TestForXIB
//
//  Created by VincentHu on 14-4-28.
//  Copyright (c) 2014年 VincentHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"

@interface DemoSong : NSObject
{
    char           *m_pszSongMsg;
    SONG_ATTRIBUTE *m_psSongAttr;
    int             m_iSongStatus;
}
@property(assign,readwrite) int m_iSongStatus;
@property(assign,readwrite) SONG_ATTRIBUTE *m_psSongAttr;

-(id)initWithAttribute :(char *)pszBuffer;
-(id)initByCopy        :(DemoSong *)pcDemoSong;
-(void)UpdateSongAttr  :(char *)pszBuffer;
-(int)SearchSongInArray:(NSMutableArray *)pma;
-(char *)GetSongMsg;
@end
