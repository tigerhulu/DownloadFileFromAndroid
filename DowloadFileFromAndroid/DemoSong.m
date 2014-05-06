//
//  DemoSong.m
//  TestForXIB
//
//  Created by VincentHu on 14-4-28.
//  Copyright (c) 2014年 VincentHu. All rights reserved.
//

#import "DemoSong.h"

@implementation DemoSong
@synthesize m_iSongStatus;
@synthesize m_psSongAttr;

-(id)init
{
    self = [super init];
    if (self)
    {
        m_pszSongMsg   = nil;
        m_psSongAttr   = nil;
    }
    return self;
}
-(id)initWithAttribute:(char *)pszBuffer;
{
    self = [super init];
    if (self)
    {
        m_iSongStatus = NOT_DOWNLOADED;
        m_psSongAttr = malloc(sizeof(SONG_ATTRIBUTE));
        memset(m_psSongAttr, '\0', sizeof(SONG_ATTRIBUTE));
        
        m_pszSongMsg = malloc(strlen(pszBuffer)+1);
        memset(m_pszSongMsg, '\0', strlen(pszBuffer)+1);
        strncpy(m_pszSongMsg, pszBuffer, strlen(pszBuffer));
        
        [self ParseSongAttribute:pszBuffer :m_psSongAttr];
    }
    return self;
}
-(id)initByCopy:(DemoSong *)pcDemoSong;
{
    self = [super init];
    if (self)
    {
        m_iSongStatus = pcDemoSong.m_iSongStatus;
        m_psSongAttr = malloc(sizeof(SONG_ATTRIBUTE));
        m_pszSongMsg = malloc(strlen([pcDemoSong GetSongMsg])+1);
        memset(m_psSongAttr, '\0', sizeof(SONG_ATTRIBUTE));
        memset(m_pszSongMsg, '\0', strlen([pcDemoSong GetSongMsg])+1);
        memcpy(m_pszSongMsg, [pcDemoSong GetSongMsg],  strlen([pcDemoSong GetSongMsg]));
        memcpy(m_psSongAttr, pcDemoSong.m_psSongAttr,  sizeof(SONG_ATTRIBUTE));
    }
    return self;
}
-(void)dealloc
{
    if(m_psSongAttr)
    {
        free(m_psSongAttr);
        m_psSongAttr = nil;
    }
    if(m_pszSongMsg)
    {
        free(m_pszSongMsg);
        m_pszSongMsg = nil;
    }
    [super      dealloc];
}

-(char *)GetSongMsg
{
    return m_pszSongMsg;
}

-(void)UpdateSongAttr:(char *)pszBuffer
{
    if(!pszBuffer)return;
    snprintf(m_psSongAttr->pszData, LEN_SONG_DATA,"%s" ,pszBuffer);
}
-(int)SearchSongInArray:(NSMutableArray *)pma
{
    int iCount = [pma count], iSearched = -1;
    DemoSong *pcTempSong = nil;
    for(int i = 0; i < iCount; i++)
    {
        pcTempSong = [pma objectAtIndex:i];
        if(!strncmp(pcTempSong.m_psSongAttr->pszID , m_psSongAttr->pszID, strlen( m_psSongAttr->pszID)))
        {
            iSearched = i;
            break;
        }
    }
    return iSearched;
}
-(int)ParseSongAttribute:(char *)pszBuffer :(SONG_ATTRIBUTE *)psSongAttr
{
    char *pcTemp = pszBuffer;
 
    pcTemp = strstr(pszBuffer, SONG_HEADER_ID);
    if(pcTemp)
    {
        char *pc = strstr(pcTemp, "\r\n");
        if(pc)
        {
            *pc = '\0';
            snprintf(psSongAttr->pszID, LEN_SONG_ID, "%s", pcTemp + LEN_SONG_HEADER_ID);
            *pc = '\r';
            pszBuffer   = pcTemp;
        }
        else
        {
            return 1;
        }
    }
    
    pcTemp = strstr(pszBuffer, SONG_HEADER_DATA);
    if(pcTemp)
    {
        char *pc = strstr(pcTemp, "\r\n");
        if(pc)
        {
            *pc = '\0';
            snprintf(psSongAttr->pszData, LEN_SONG_DATA, "%s", pcTemp + LEN_SONG_HEADER_DATA);
            *pc = '\r';
            pszBuffer   = pcTemp;
        }
        else
        {
            return 2;
        }
    }
    
    pcTemp = strstr(pszBuffer, SONG_HEADER_TITLE);
    if(pcTemp)
    {
        char *pc = strstr(pcTemp, "\r\n");
        if(pc)
        {
            *pc = '\0';
            snprintf(psSongAttr->pszTitle, LEN_SONG_TITLE, "%s", pcTemp + LEN_SONG_HEADER_TITLE);
            *pc = '\r';
            pszBuffer   = pcTemp;
        }
        else
        {
            return 3;
        }
    }
    
    pcTemp = strstr(pszBuffer, SONG_HEADER_TYPE);
    if(pcTemp)
    {
        char *pc = strstr(pcTemp, "\r\n");
        if(pc)
        {
            *pc = '\0';
            snprintf(psSongAttr->pszType, LEN_SONG_TYPE, "%s", pcTemp + LEN_SONG_HEADER_TYPE);
            *pc = '\r';
            pszBuffer   = pcTemp;
        }
        else
        {
            return 4;
        }
    }
    
    pcTemp = strstr(pszBuffer, SONG_HEADER_ARTIST);
    if(pcTemp)
    {
        char *pc = strstr(pcTemp, "\r\n");
        if(pc)
        {
            *pc = '\0';
            snprintf(psSongAttr->pszArtist, LEN_SONG_ARTIST, "%s", pcTemp + LEN_SONG_HEADER_ARTIST);
            *pc = '\r';
            pszBuffer   = pcTemp;
        }
        else
        {
            return 5;
        }
    }
    
    pcTemp = strstr(pszBuffer, SONG_HEADER_ALBUM);
    if(pcTemp)
    {
        char *pc = strstr(pcTemp, "\r\n");
        if(pc)
        {
            *pc = '\0';
            snprintf(psSongAttr->pszAlbum, LEN_SONG_ALBUM, "%s", pcTemp + LEN_SONG_HEADER_ALBUM);
            *pc = '\r';
            pszBuffer   = pcTemp;
        }
        else
        {
            return 6;
        }
    }
    
    pcTemp = strstr(pszBuffer, SONG_HEADER_SIZE);
    if(pcTemp)
    {
        char *pc = strstr(pcTemp, "\r\n");
        if(pc)
        {
            *pc = '\0';
            snprintf(psSongAttr->pszSize, LEN_SONG_SIZE, "%s", pcTemp + LEN_SONG_HEADER_SIZE);
            *pc = '\r';
            pszBuffer   = pcTemp;
        }
        else
        {
            return 7;
        }
    }
    
    pcTemp = strstr(pszBuffer, SONG_HEADER_DURATION);
    if(pcTemp)
    {
        char *pc = strstr(pcTemp, "\r\n");
        if(pc)
        {
            *pc = '\0';
            snprintf(psSongAttr->pszDuration, LEN_SONG_SIZE, "%s", pcTemp + LEN_SONG_HEADER_DURATION);
            *pc = '\r';
            pszBuffer   = pcTemp;
        }
        else
        {
            return 8;
        }
    }
    
    pcTemp = strstr(pszBuffer, SONG_HEADER_SENDER);
    if(pcTemp)
    {
        char *pc = strstr(pcTemp, "\r\n");
        if(pc)
        {
            *pc = '\0';
            snprintf(psSongAttr->pszSender, LEN_SONG_SEND, "%s", pcTemp + LEN_SONG_HEADER_SENDER);
            *pc = '\r';
            pszBuffer   = pcTemp;
        }
        else
        {
            return 9;
        }
    }
    
    pcTemp = strstr(pszBuffer, SONG_HEADER_RECEIVE);
    if(pcTemp)
    {
        char *pc = strstr(pcTemp, "\r\n");
        if(pc)
        {
            *pc = '\0';
            snprintf(psSongAttr->pszReceiver, LEN_SONG_RECEIVE, "%s", pcTemp + LEN_SONG_HEADER_RECEIVE);
            *pc = '\r';
            pszBuffer   = pcTemp;
        }
        else
        {
            return 10;
        }
    }
    
    pcTemp = strstr(pszBuffer, SONG_HEADER_RECEIVEIP);
    if(pcTemp)
    {
        char *pc = strstr(pcTemp, "\r\n");
        if(pc)
        {
            *pc = '\0';
            snprintf(psSongAttr->pszReceiverIP, LEN_SONG_RECEIVEIP, "%s", pcTemp + LEN_SONG_HEADER_RECEIVEIP);
            *pc = '\r';
            pszBuffer   = pcTemp;
        }
        else
        {
            return 11;
        }
    }
    return 0;
}

@end
