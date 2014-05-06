//
//  Common.h
//  GetFileFromAndroidTest
//
//  Created by VincentHu on 14-4-24.
//  Copyright (c) 2014年 VincentHu. All rights reserved.
//

#ifndef GetFileFromAndroidTest_Common_h
#define GetFileFromAndroidTest_Common_h

#define MESSAGE_GET_SONG_LIST "get_share_song_list"
#define MESSAGE_DOWNLOAD_SONG "download_song"
#define MESSAGE_WHOAMI        "who_am_i"
#define MESSAGE_DISCONNECT    "disconnect"
#define MESSAGE_OVER          "over"
#define END_SYMBOL            "\r\n"
#define END                   "end"

#define SONG_HEADER_ID       "_id:"
#define SONG_HEADER_DATA     "_data:"
#define SONG_HEADER_TITLE    "title:"
#define SONG_HEADER_TYPE     "mime_type:"
#define SONG_HEADER_ARTIST   "artist:"
#define SONG_HEADER_ALBUM     "album:"
#define SONG_HEADER_SIZE      "_size:"
#define SONG_HEADER_DURATION  "duration:"
#define SONG_HEADER_SENDER    "sender:"
#define SONG_HEADER_RECEIVE   "receiver:"
#define SONG_HEADER_RECEIVEIP "receiver_ip:"
#define SONG_HEADER_END       "end"

#define LEN_SONG_HEADER_ID        4
#define LEN_SONG_HEADER_DATA      6
#define LEN_SONG_HEADER_TITLE     6
#define LEN_SONG_HEADER_TYPE      10
#define LEN_SONG_HEADER_ARTIST    7
#define LEN_SONG_HEADER_ALBUM     6
#define LEN_SONG_HEADER_SIZE      6
#define LEN_SONG_HEADER_DURATION  9
#define LEN_SONG_HEADER_SENDER    7
#define LEN_SONG_HEADER_RECEIVE   9
#define LEN_SONG_HEADER_RECEIVEIP 12
#define LEN_SONG_HEADER_END       3


#define LEN_SONG_ID        32
#define LEN_SONG_DATA      256
#define LEN_SONG_TITLE     128
#define LEN_SONG_TYPE      16
#define LEN_SONG_SIZE      16
#define LEN_SONG_ARTIST    64
#define LEN_SONG_ALBUM     64
#define LEN_SONG_SEND      64
#define LEN_SONG_RECEIVE   64
#define LEN_SONG_RECEIVEIP 64

#define LEN_MAX_IP_ADDRESS 64
#define LEN_MAX_FILE_NAME  128
#define LEN_MAX_MSG        256
#define BUFFER_SIZE        1024*32

#define NOT_DOWNLOADED     0
#define HAVE_DOWNLOADED    1
#define DOWNLOAD_FINISH    2

typedef	enum _conn_server_msg_type	CONN_SERVER_MSG_TYPE;
enum _conn_server_msg_type
{
	MSG_WHOAMI              = 0,
	MSG_GET_SONG_LIST       = 1,
	MSG_DOWNLOAD_SONG       = 2,
	MSG_OVER                = 3,
	MSG_DISCONNECT          = 4,
};

typedef struct _song_attribute_
{
	char pszID        [LEN_SONG_ID];
    char pszData      [LEN_SONG_DATA];
    char pszTitle     [LEN_SONG_TITLE];
    char pszType      [LEN_SONG_TYPE];
    char pszArtist    [LEN_SONG_ARTIST];
    char pszAlbum     [LEN_SONG_ALBUM];
    char pszSize      [LEN_SONG_SIZE];
    char pszDuration  [LEN_SONG_SIZE];
    char pszSender    [LEN_SONG_SEND];
    char pszReceiver  [LEN_SONG_RECEIVE];
    char pszReceiverIP[LEN_SONG_RECEIVEIP];
    
} SONG_ATTRIBUTE;

typedef	enum _ret_val	RET_VAL;
enum _ret_val
{
	RET_OK                = 0,
	RET_FAILED            = 1,
    RET_CONN_FALIED       = 2,
    RET_SEND_DATA_FAILED  = 3,
    RET_REC_DATA_FAILED   = 4,
    RET_OPNE_FILE_FAILED  = 5,
    RET_WRITE_FILE_FAILED = 6,
    RET_MAX
};

static char DemoErrorMsg[][LEN_MAX_FILE_NAME] =
{
    "OK",
    "FAILED",
    "Connection Failed",
    "Send Data Failed",
    "Receive Data Failed",
    "Open File Failed",
    "Write to File Failed",
};

#endif
