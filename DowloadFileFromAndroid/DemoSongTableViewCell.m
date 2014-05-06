//
//  DemoSongTableViewCell.m
//  DowloadFileFromAndroid
//
//  Created by VincentHu on 14-5-5.
//  Copyright (c) 2014年 VincentHu. All rights reserved.
//

#import "DemoSongTableViewCell.h"

@implementation DemoSongTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)SetCellData:(DemoSong *)pcDemoSong
{
    self.ib_tfTitle.text =[NSString stringWithFormat:@"%@.%s", [NSString stringWithUTF8String:pcDemoSong.m_psSongAttr->pszTitle], pcDemoSong.m_psSongAttr->pszType];
    if(strlen(pcDemoSong.m_psSongAttr->pszArtist))
    {
        [self.ib_tfArtist setText:[NSString stringWithUTF8String:pcDemoSong.m_psSongAttr->pszArtist]];
    }
    else
    {
        [self.ib_tfArtist setText:@"未知"];
    }
    if(pcDemoSong.m_iSongStatus == NOT_DOWNLOADED)
    {
        [self.ib_pvDownload setHidden:NO];
        [self.ib_pvDownload setProgress:0];
    }
    else if(pcDemoSong.m_iSongStatus == HAVE_DOWNLOADED)
    {
        [self.ib_tfDowlodSize setHidden:YES];
        [self.ib_pvDownload setHidden:NO];
        [self.ib_pvDownload setProgress:100];
    }
    else
    {
        [self.ib_tfDowlodSize setHidden:YES];
        [self.ib_pvDownload setHidden:YES];
    }
    self.ib_tfSize.text = [self GetFriendlySize:[[NSString stringWithUTF8String:pcDemoSong.m_psSongAttr->pszSize] intValue]];
}
-(NSString *)GetFriendlySize:(int)iSize
{
    
    double dSize = iSize;
    if( iSize > (1024*1024) )
	{
		dSize /= (1024*1024);
        return [NSString stringWithFormat:@"%0.2f Mb",dSize];
	}
	else if ( iSize > 1024 )
	{
        dSize /= 1024;
	    return [NSString stringWithFormat:@"%0.2f Kb",dSize];
    }
	else
	{
         return [NSString stringWithFormat:@"%d bytes",iSize];
    }
}
/*-(void)cellUpdateProgresssbar:(double)dProcessCount
{
    [self.ib_pvDownload setProgress:dProcessCount animated:NO];
}*/

-(void)cellUpdateProgresssbar:(int)iReceiveSize :(int)iTotalSize
{
    [self.ib_pvDownload setProgress:(double)iReceiveSize/iTotalSize animated:NO];
    self.ib_tfSize.text = [NSString stringWithFormat:@"%@/%@",[self GetFriendlySize:iReceiveSize],[self GetFriendlySize:iTotalSize]];
}

-(void)SetCellWhenFinished:(int)iTotalSize
{
    self.ib_tfSize.text = [NSString stringWithFormat:@"%@",[self GetFriendlySize:iTotalSize]];
    [self.ib_pvDownload setProgress:1.0 animated:NO];
}

@end
