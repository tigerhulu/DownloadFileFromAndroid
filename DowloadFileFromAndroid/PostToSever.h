//
//  PostToSever.h
//  GetFileFromAndroidTest
//
//  Created by VincentHu on 14-4-24.
//  Copyright (c) 2014年 VincentHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
#import "DemoSong.h"

@interface PostToSever : NSObject
{
    char *m_pszLocalIP;
    char *m_pszServerIP;
    int  m_iServerPort;
    int  m_iSocket;
    BOOL m_bReceivedCount;
    int  m_iWillReceivedConut;
    int  m_iHaveReceivedCount;
}

- (NSString *)GetRouterIP;
- (NSString *)GetLocalIP;

-(RET_VAL)SetIpAndPort;
-(RET_VAL)SendMsgToServer :(CONN_SERVER_MSG_TYPE)eMsgType :(void*)parameter;
-(RET_VAL)ProcessMsgWhoAmI;
-(RET_VAL)ProcessMsgGetSongList:(NSMutableArray*)pmaArray;
-(RET_VAL)ProcessMsgDownloadSong:(DemoSong*)pcDemoSong;
-(RET_VAL)Disconnect;
-(int)ParseSongAttribute:(char *)pszBuffer :(NSMutableArray *)pmaSong;

@end
