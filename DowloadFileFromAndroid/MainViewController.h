//
//  MainViewController.h
//  TestForXIB
//
//  Created by VincentHu on 14-4-25.
//  Copyright (c) 2014年 VincentHu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PostToSever.h"
#import "AppDelegate.h"

@interface MainViewController : UIViewController
{
    IBOutlet UITabBarController     *ib_tbcMainView;
    IBOutlet UINavigationController *ib_naviCtrlShared;
    IBOutlet UINavigationController *ib_naviCtrlDownloaded;
    IBOutlet UITableView            *ib_tvShared;
    IBOutlet UITableView            *ib_tvDownloaded;
    IBOutlet UIButton               *ib_btConnect;
    IBOutlet UIButton               *ib_btDisConnect;
    IBOutlet UIButton               *ib_btDownload;
    IBOutlet UIButton               *ib_btGoback;
    IBOutlet UIButton               *ib_btDelete;
    
    AppDelegate     *m_pcAppDelegate;
    BOOL            m_bDownLoading;
    int             m_iDownloadCellNumber;
    NSIndexPath     *m_pcDownloadingIndex;
    PostToSever     *m_pcPostToServer;
    NSMutableArray  *m_pmaSharedSong;
    NSMutableArray  *m_pmaDownloadedSong;
}
-(IBAction)ConnectToServer:(id)sender;
-(IBAction)GoBack:(id)sender;
-(void)UpdateProgressbar:(NSNotification*)aNotification;

@property(assign, readwrite)AppDelegate     *m_pcAppDelegate;
@end
