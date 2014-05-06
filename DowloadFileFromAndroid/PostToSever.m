//
//  PostToSever.m
//  GetFileFromAndroidTest
//
//  Created by VincentHu on 14-4-24.
//  Copyright (c) 2014年 VincentHu. All rights reserved.
//

#import "PostToSever.h"
#import <netinet/in.h>
#import <sys/socket.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation PostToSever

- (id)init
{
    self = [super init];
    if (self)
    {
        m_pszServerIP    = (char*)malloc(LEN_MAX_IP_ADDRESS);
        m_pszLocalIP     = (char*)malloc(LEN_MAX_IP_ADDRESS);
        [self initVars];
    }
    return self;
}

-(void)initVars
{
    memset(m_pszServerIP, 0, LEN_MAX_IP_ADDRESS);
    m_bReceivedCount = FALSE;
    m_iHaveReceivedCount = 0;
    m_iWillReceivedConut = 0;
    m_iServerPort = -1;
    m_iSocket     = -1;
}

-(void)dealloc
{
    if(m_pszServerIP)
    {
        free(m_pszServerIP);
        m_pszServerIP = nil;
    }
    if(m_pszLocalIP)
    {
        free(m_pszLocalIP);
        m_pszLocalIP = nil;
    }
    [super dealloc];
}
-(void)CleanSocket:(char *)buffer
{
    if(buffer)
    {
        free(buffer);
        buffer = nil;
        close(m_iSocket);
        m_iSocket = -1;
    }
}

#pragma mark Get IP && Set IP
-(RET_VAL)SetIpAndPort
{
    NSString *pszTemp = [self GetRouterIP];
    if(pszTemp == nil) return RET_CONN_FALIED;
    snprintf(m_pszServerIP, LEN_MAX_IP_ADDRESS, "%s",[pszTemp UTF8String]);
    m_iServerPort = 5001;
    
    return RET_OK;
}

- (NSString *)GetLocalIP
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}
- (NSString *)GetRouterIP
{
    NSString *pszRouterIP = nil;
    NSString *pszLocaIP   = [self GetLocalIP];
    
    if(![pszLocaIP isEqualToString:@"error"])
    {
        snprintf(m_pszLocalIP, LEN_MAX_IP_ADDRESS, "%s", [pszLocaIP UTF8String]);
        
        NSArray *results = [pszLocaIP componentsSeparatedByString:@"."];
        pszRouterIP = [NSString stringWithFormat:@"%@.%@.%@.1",[results objectAtIndex:0],[results objectAtIndex:1],[results objectAtIndex:2]];
    }
    return pszRouterIP;
}

#pragma mark Communication with Server
-(RET_VAL)SendMsgToServer : (CONN_SERVER_MSG_TYPE)eMsgType :(void *)parameter
{
    RET_VAL retVal = RET_FAILED;
    switch (eMsgType)
    {
        case MSG_WHOAMI:
            retVal = [self ProcessMsgWhoAmI];
            break;
            
        case MSG_GET_SONG_LIST:
            retVal = [self ProcessMsgGetSongList:(NSMutableArray *)parameter];
            break;
            
        case MSG_DOWNLOAD_SONG:
            retVal = [self ProcessMsgDownloadSong:(DemoSong *)parameter];
            break;
            
        case MSG_DISCONNECT:
            retVal = [self Disconnect];
            break;
            
        default:
            break;
    }
    return retVal;
}

-(BOOL)ConnectToServer
{
    NSString *serverip = [NSString stringWithUTF8String:m_pszServerIP];
    
    struct sockaddr_in client_addr;
    bzero(&client_addr, sizeof(client_addr));
    client_addr.sin_family = AF_INET;
    client_addr.sin_addr.s_addr = htons(INADDR_ANY); // auto to get local address
    client_addr.sin_port = htons(0);                  // system auto allocated
    
    m_iSocket= socket(AF_INET, SOCK_STREAM, 0);
    if (m_iSocket < 0)
    {
        printf("Create Socket Failed!\n");
        return FALSE;
    }
    
    if (bind(m_iSocket, (struct sockaddr*)&client_addr, sizeof(client_addr)))
    {
        printf("Client Bind Port Failed!\n");
        return FALSE;
    }
    
    struct sockaddr_in  server_addr;
    bzero(&server_addr, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    
    // set ip
    if (inet_aton([serverip UTF8String], &server_addr.sin_addr) == 0)
    {
        printf("Server IP Address Error!\n");
        return FALSE;
    }
    server_addr.sin_port = htons(m_iServerPort);
    socklen_t server_addr_length = sizeof(server_addr);
    
    // connect to server
    if (connect(m_iSocket, (struct sockaddr*)&server_addr, server_addr_length)< 0)
    {
        NSLog(@"Can Not Connect To %@!\n", serverip);
        return FALSE;
    }
    return TRUE;
}

-(RET_VAL)ProcessMsgWhoAmI
{
    if(![self ConnectToServer])return RET_CONN_FALIED;
    
    RET_VAL bRetVal = RET_OK;
    char *buffer = malloc(BUFFER_SIZE);
    snprintf(buffer, LEN_MAX_MSG, MESSAGE_WHOAMI"\r\n%s\r\n%s",m_pszLocalIP,"vincentHu");
    if (send(m_iSocket, buffer, BUFFER_SIZE, 0) < 0)
    {
        NSLog(@"send who am i msg error.");
        bRetVal = RET_SEND_DATA_FAILED;
    }
    [self CleanSocket:buffer];
    return bRetVal;

}

-(RET_VAL)ProcessMsgGetSongList:(NSMutableArray*)pmaArray;
{
    if(![self ConnectToServer])return RET_CONN_FALIED;
    
    RET_VAL bRetVal = RET_OK;
    char *buffer = malloc(BUFFER_SIZE);
    bzero(buffer, BUFFER_SIZE);
    
    if(!buffer)
    {
        NSLog(@"memory alloc failed");
    }
    snprintf(buffer, LEN_MAX_MSG, MESSAGE_GET_SONG_LIST"\r\n");
    
    if (send(m_iSocket, buffer, BUFFER_SIZE, 0) < 0)
    {
        [self CleanSocket:buffer];
        return RET_SEND_DATA_FAILED;
    }
    bzero(buffer, BUFFER_SIZE);
    
    int length = 0, iParsed = 0, iLeft = 0;
    usleep(200);
    while((length = (int)recv(m_iSocket, (buffer + iLeft), (BUFFER_SIZE- iLeft), 0))!=0)
    {
        
         if (length < 0)
         {
             NSLog(@"Recieve Data From Server %sFailed!\n", m_pszServerIP);
             bRetVal = RET_REC_DATA_FAILED;
             break;
         }
         length += iLeft;
         iParsed = [self ParseSongAttribute:buffer :pmaArray];
         iLeft = length - iParsed;
         if(iLeft > 0)
         {
             strncpy(buffer, buffer+iParsed, iLeft);
             bzero(buffer + iLeft, BUFFER_SIZE-iLeft);
         }
         else
         {
             length = iParsed = iLeft = 0;
             bzero(buffer, BUFFER_SIZE);
         }
        if(m_iWillReceivedConut == m_iHaveReceivedCount)break;
        usleep(200);
    }
    // clean socket
    [self CleanSocket:buffer];
    return bRetVal;
}

-(int)ParseSongAttribute:(char *)buffer :(NSMutableArray *)pmaSong
{
    int iParsed = 0, iWillParsed = 0, iBufferLen = (int)strlen(buffer);
    
    char *pszSongMsg = malloc(1024);
    memset(pszSongMsg, '\0', 1024);
    
    char *pszBuffer = buffer;
    char *pcTemp = pszBuffer;
    if(pcTemp && !m_bReceivedCount)
    {
        char *pc = strstr(pcTemp, "\r\n");
        if(pc)
        {
            *pc = '\0';
            m_iWillReceivedConut = atoi(pcTemp);
            *pc = '\r';
            NSString *pstemp = [NSString stringWithFormat:@"%d",m_iWillReceivedConut];
            iWillParsed =  (int)strlen([pstemp UTF8String]) + strlen("\r\n") ;
            iParsed    +=  iWillParsed;
            pszBuffer  +=  iWillParsed;
        }
        m_bReceivedCount = TRUE;
    }
    
    while(pszBuffer && iParsed < iBufferLen)
    {
        pcTemp = strstr(pszBuffer, SONG_HEADER_ID);
        if(pcTemp)
        {
            char *pcEndTemp =strstr(pcTemp, "\r\n"SONG_HEADER_END"\r\n");
            if(pcEndTemp)
            {
                *pcEndTemp = '\0';
                snprintf(pszSongMsg, 1024, "%s\r\nend\r\n", pcTemp);
                *pcEndTemp = '\r';
                iWillParsed =  (int)strlen(pszSongMsg) ;
                iParsed    +=  iWillParsed;
                pszBuffer  +=  iWillParsed;
                
                m_iHaveReceivedCount++;
                DemoSong *pcSong = [[[DemoSong alloc] initWithAttribute:pszSongMsg] autorelease];
                [pmaSong addObject:pcSong];
                memset(pszSongMsg, 0, 1024);
            }
            else
            {
                break;
            }
        }
        else
        {
            break;
        }
    }
    free(pszSongMsg);
    pszSongMsg = nil;
    return iParsed;
}

-(RET_VAL)ProcessMsgDownloadSong:(DemoSong*)pcDemoSong;
{
    if(![self ConnectToServer])return RET_CONN_FALIED;
    
    RET_VAL retVal = RET_OK;
    char *buffer = malloc(BUFFER_SIZE);
    if(!buffer)
    {
        NSLog(@"memory alloc failed");
        return RET_FAILED;
    }
    bzero(buffer, BUFFER_SIZE);
    
    snprintf(buffer, LEN_MAX_MSG, MESSAGE_DOWNLOAD_SONG"\r\n");
    if (send(m_iSocket, buffer, BUFFER_SIZE, 0) < 0)
    {
        // clean socket
        [self CleanSocket:buffer];
        return RET_SEND_DATA_FAILED;
    }
    
    usleep(20);
    snprintf(buffer, BUFFER_SIZE, "%s",[pcDemoSong GetSongMsg]);
    if (send(m_iSocket, buffer, BUFFER_SIZE, 0) < 0)
    {
        // clean socket
        [self CleanSocket:buffer];
        return RET_SEND_DATA_FAILED;
    }
    bzero(buffer, BUFFER_SIZE);
    
    usleep(100);
    
    NSString *filepath = [NSString stringWithFormat:@"%@%s.%s", NSTemporaryDirectory(),pcDemoSong.m_psSongAttr->pszTitle,pcDemoSong.m_psSongAttr->pszType];
    
    FILE *fp = fopen([filepath UTF8String], "w+");
    if (fp == NULL)
    {
        NSLog(@"File:\t%@ Can Not Open To Write!\n", filepath);
        // clean socket
        [self CleanSocket:buffer];
        return RET_OPNE_FILE_FAILED;
    }
    [pcDemoSong UpdateSongAttr:(char *)[filepath UTF8String]];
    bzero(buffer, sizeof(buffer));
    
    int length = 0,iReceivedSize = 0, iSize = [[NSString stringWithUTF8String:pcDemoSong.m_psSongAttr->pszSize] intValue];
    __block int itimer =0;
    while((length = (int)recv(m_iSocket, buffer, BUFFER_SIZE, 0))!=0)
    {
        if (length < 0)
        {
            NSLog(@"Recieve Data From Server Failed!\n"   );
            retVal = RET_REC_DATA_FAILED;
            break;
        }
        
        int write_length = fwrite(buffer, sizeof(char), length, fp);
        if (write_length < length)
        {
            NSLog(@"File:\t%@ Write Failed!\n", filepath);
            retVal = RET_WRITE_FILE_FAILED;
            break;
        }
        iReceivedSize += length;
        if(iReceivedSize == iSize)break;

        /*NSDictionary * dic = [NSDictionary dictionaryWithObject: [NSNumber numberWithDouble:(double)iReceivedSize/(double)iSize] forKey:@"value"];*/
        NSArray *objArr = [NSArray arrayWithObjects:[NSNumber numberWithInt:iSize], [NSNumber numberWithInt:iReceivedSize], nil];
        NSArray *keyArr = [NSArray arrayWithObjects:@"totalsize", @"receivedsize",nil];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjects:objArr forKeys:keyArr];
        
        //NSDictionary * dic = [NSDictionary dictionaryWithObject: [NSNumber numberWithInt:iSize] forKey:@"totalsize"];
        
        //dic = [NSDictionary dictionaryWithObject: [NSNumber numberWithInt:iReceivedSize] forKey:@"receivedsize"];
        
        if(itimer == 10)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateProgressbar" object:nil userInfo:dic];
                itimer = 0;
            });
        }
        itimer ++;
        usleep(100);
    }
    snprintf(buffer, LEN_MAX_MSG, MESSAGE_OVER"\r\n");
    send(m_iSocket, buffer, BUFFER_SIZE, 0);
    
    NSLog(@"Recieve File:\t %@ From Server[%s] Finished!\n", filepath, m_pszServerIP);
    
    fclose(fp);
    // clean socket
    [self CleanSocket:buffer];
    return retVal;
}
-(RET_VAL)Disconnect
{
    if(![self ConnectToServer])return RET_CONN_FALIED;
    
    RET_VAL retVal = RET_OK;
    char *buffer = malloc(BUFFER_SIZE);
    if(!buffer)
    {
        NSLog(@"memory alloc failed");
        return RET_FAILED;
    }
    bzero(buffer, BUFFER_SIZE);
    
    snprintf(buffer, LEN_MAX_MSG, MESSAGE_DISCONNECT"\r\n%s\r\n%s",m_pszLocalIP,"vincentHu");
    if (send(m_iSocket, buffer, BUFFER_SIZE, 0) < 0)
    {

        retVal = RET_SEND_DATA_FAILED;
    }
    // clean socket
    [self CleanSocket:buffer];
    return retVal;
}
@end
