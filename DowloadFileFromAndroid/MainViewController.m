//
//  MainViewController.m
//  TestForXIB
//
//  Created by VincentHu on 14-4-25.
//  Copyright (c) 2014年 VincentHu. All rights reserved.
//

#import "MainViewController.h"
#import "DemoSongTableViewCell.h"

@class DemoSongTableViewCell;

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate>
#pragma mark - Private property declaration
@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        //Custom initialization
        [self cleanDownloadFlag];
        m_pcDownloadingIndex  = [[NSIndexPath alloc ] initWithIndex:-1];
        m_pcPostToServer      = [[PostToSever alloc] init];
        m_pmaDownloadedSong   = [[NSMutableArray alloc] initWithCapacity:200];
        m_pmaSharedSong       = [[NSMutableArray alloc] initWithCapacity:200];
        [self initObservers];
    }
    return self;
}

-(void)dealloc
{
    [m_pcPostToServer release];
    [m_pcDownloadingIndex release];
    [self DestroyObservers];
    [super dealloc];
}

-(void)cleanDownloadFlag
{
    m_bDownLoading        = FALSE;
    m_iDownloadCellNumber = -1;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    //Set Connect/Disconnect button
    [ib_btConnect setHidden:NO];
    [ib_btDisConnect setHidden:YES];
    
    //Set title
    ib_naviCtrlShared.title = @"Shared";
    ib_naviCtrlDownloaded.title = @"Downloaded";
    
    //bind talbeview to cell
    [ib_tvShared registerNib:[UINib nibWithNibName:@"DemoSongTableViewCell" bundle:nil] forCellReuseIdentifier:@"DemoSongTableViewCell"];
    [ib_tvDownloaded registerNib:[UINib nibWithNibName:@"DemoSongTableViewCell" bundle:nil] forCellReuseIdentifier:@"DemoSongTableViewCell"];
    
    //Set Dowload button to shared tableview
    [ib_tvShared addSubview:ib_btDownload];
    [ib_btDownload setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:1 alpha:0.5]];
    
    //Set Dowload button to download tableview
    [ib_tvDownloaded addSubview:ib_btDelete];
    [ib_btDelete setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:1 alpha:0.5]];
    
    //Set Goback button to Shared tableview
    [ib_naviCtrlShared.view addSubview:ib_btGoback];
    [ib_btDownload setBackgroundColor:[UIColor colorWithRed:0.1 green:0.1 blue:1 alpha:0.5]];
    CGRect tvRect =[ib_naviCtrlShared.view frame];
    CGRect btRect   =[ib_btDownload frame];
    btRect.origin.x = tvRect.origin.x;
    btRect.origin.y = tvRect.origin.y+30;
    [ib_btGoback setFrame:btRect];
    [ib_btGoback setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)ShowWarningMsg:(RET_VAL)retVal
{
    UIAlertView *alertMessage = [[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithUTF8String:DemoErrorMsg[retVal]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alertMessage show];
}
#pragma mark - Action
-(IBAction)ConnectToServer:(id)sender
{
    RET_VAL retVal = RET_OK;
    retVal = [m_pcPostToServer SetIpAndPort];
    
    if(!retVal)
    {
        retVal = [m_pcPostToServer SendMsgToServer:MSG_WHOAMI :nil];
    }
    if(!retVal)
    {
        retVal = [m_pcPostToServer SendMsgToServer:MSG_GET_SONG_LIST :m_pmaSharedSong];
    }
    
    if(!retVal)
    {
        UITableViewController *sharedController = [UITableViewController new];
        sharedController.tableView.dataSource = self;
        sharedController.tableView.delegate = self;
        
        UITableViewController *downloadController = [UITableViewController new];
        downloadController.tableView.dataSource = self;
        downloadController.tableView.delegate = self;
        
        UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:sharedController];
        UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:downloadController];
        
        ib_tbcMainView.viewControllers = @[nav1, nav2];
        
        [sharedController release];
        [downloadController release];
        [nav1 release];
        [nav2 release];
        
        [self presentViewController:ib_tbcMainView animated:NO completion:nil];
        [ib_btDisConnect setHidden:NO];
        [ib_btConnect    setHidden:YES];
    }
    else
    {
        [self ShowWarningMsg:retVal];
    }
}
-(IBAction)DisConnection:(id)sender
{
    RET_VAL retVal = RET_OK;
    retVal = [m_pcPostToServer Disconnect];
    if(retVal)
    {
        [self ShowWarningMsg:retVal];
    }
    [ib_btDisConnect setHidden:YES];
    [ib_btConnect    setHidden:NO];
}
-(IBAction)DownloadFile:(id)sender
{
    m_bDownLoading = TRUE;
    [ib_btDownload setHidden:YES];
    DemoSong *pcSelectSong = [[DemoSong alloc] initByCopy:[m_pmaSharedSong objectAtIndex:[ib_tvShared indexPathForRowAtPoint:[sender frame].origin].row]];
    
    [NSThread detachNewThreadSelector:@selector(DownloadingProc:) toTarget:self withObject:pcSelectSong];
    
    // GCD grand centeral dispatch
    // NSOperationQueue
}

-(IBAction)GoBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)DeleteFile:(id)sender
{
    [ib_btDelete setHidden:YES];
    
    //Delete the file in Downloaded list
    int iDeleteCell = [ib_tvDownloaded indexPathForRowAtPoint:[sender frame].origin].row;
    
    DemoSong *pcSelectSong = [[DemoSong alloc] initByCopy:[m_pmaDownloadedSong objectAtIndex:iDeleteCell]];
    
    NSString *psFilepath = [NSString stringWithUTF8String:pcSelectSong.m_psSongAttr->pszData];
    
    NSFileManager* pFileManager =[NSFileManager defaultManager];
    
    if(![pFileManager fileExistsAtPath:psFilepath])return;
    if(![pFileManager isReadableFileAtPath:psFilepath])return;
    if(![pFileManager isDeletableFileAtPath:psFilepath])return;
    
    NSError *error = nil;
    if(![pFileManager removeItemAtPath:psFilepath error:&error])return;
    
    [m_pmaDownloadedSong removeObjectAtIndex:iDeleteCell];
    [ib_tvDownloaded reloadData];
    
    //Change the deleted song property in the shared song list
    int iIndex = [pcSelectSong SearchSongInArray:m_pmaSharedSong];
    DemoSong *pcSharedSong =[m_pmaSharedSong objectAtIndex:iIndex];
    pcSharedSong.m_iSongStatus = NOT_DOWNLOADED;
    [ib_tvShared reloadData];
}


#pragma mark - init/Destory Observer
-(void)initObservers
{
    [ [NSNotificationCenter defaultCenter] addObserver:self
											  selector:@selector(UpdateProgressbar:)
												  name:@"UpdateProgressbar"
												object:nil];
}
-(void)DestroyObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
    return;
}

#pragma mark - Update Progressbar
-(void)UpdateProgressbar:(NSNotification*)aNotification
{
    if(m_iDownloadCellNumber< 0 ||m_iDownloadCellNumber > [m_pmaSharedSong count])return;
    
    //double dProcess = [[ [aNotification userInfo] objectForKey:@"value" ] doubleValue];
    
    int iReceivedSize =[[ [aNotification userInfo] objectForKey:@"receivedsize" ] intValue];
    int iTotalSize    =[[ [aNotification userInfo] objectForKey:@"totalsize"    ] intValue];

    NSIndexPath *pcIndex = [NSIndexPath indexPathForRow:m_iDownloadCellNumber inSection:0];
    
    
    DemoSongTableViewCell *pcShareCell = (DemoSongTableViewCell *)[ib_tvShared cellForRowAtIndexPath: pcIndex];
    
    //[pcShareCell cellUpdateProgresssbar:dProcess];
    
    [pcShareCell cellUpdateProgresssbar:iReceivedSize :iTotalSize];
}

#pragma mark - DownloadFile
-(void)DownloadingProc:(DemoSong *)pcSelectedSong
{
    RET_VAL retVal = RET_OK;
    retVal = [m_pcPostToServer SendMsgToServer:MSG_DOWNLOAD_SONG : pcSelectedSong];
    if(!retVal)
    {
        [self performSelectorOnMainThread:@selector(UpdateDownloadList:) withObject:pcSelectedSong waitUntilDone:YES];
        NSIndexPath *pcIndex = [NSIndexPath indexPathForRow:m_iDownloadCellNumber inSection:0];
        DemoSongTableViewCell *pcDemoSongCell = (DemoSongTableViewCell *)[ib_tvShared cellForRowAtIndexPath: pcIndex];
        [pcDemoSongCell SetCellWhenFinished:[[NSString stringWithUTF8String:pcSelectedSong.m_psSongAttr->pszSize] intValue]];
    }
    else
    {
        [self ShowWarningMsg:retVal];
        
    }
    [self cleanDownloadFlag];
}

-(void)UpdateDownloadList:(DemoSong *)pcSelectedSong
{
    //Change Downloaded song status to DOWNLOAD_FINISH
    pcSelectedSong.m_iSongStatus = DOWNLOAD_FINISH;
    [m_pmaDownloadedSong addObject:pcSelectedSong];
    [pcSelectedSong release];
    
    //Change shared song status to HAVE_DOWNLOADED
    DemoSong *pcDemoSong = [m_pmaSharedSong objectAtIndex:m_iDownloadCellNumber];
    pcDemoSong.m_iSongStatus = HAVE_DOWNLOADED;
    
    //send updat notification
    [ib_tvDownloaded reloadData];
}

#pragma mark - UITableView delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if(viewController == ib_naviCtrlDownloaded)
    {
        [ib_tvDownloaded reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == ib_tvShared)
    {
        return [m_pmaSharedSong count];
    }
    else
    {
        return [m_pmaDownloadedSong count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1. cell标识符，使cell能够重用
    static NSString *DemoSongTableCell = @"DemoSongTableViewCell";
    
    // 2. 从TableView中获取标识符为paperCell的Cell
    DemoSongTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DemoSongTableCell];
    
    DemoSong *pcTempSong = nil;
    
    if(tableView == ib_tvShared)
    {
        if(indexPath.row > ([m_pmaSharedSong count]-1))return nil;
        
        pcTempSong = [m_pmaSharedSong objectAtIndex:indexPath.row];
    }
    else
    {
        if(indexPath.row > ([m_pmaDownloadedSong count]-1))return nil;
    
        pcTempSong = [m_pmaDownloadedSong objectAtIndex:indexPath.row];
    }
    // 设置单元格属性
    [cell SetCellData:pcTempSong];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == ib_tvShared)
    {
        if(!m_bDownLoading)
        {
            DemoSong *pcSelectedSong = [m_pmaSharedSong objectAtIndex:indexPath.row];
            if(pcSelectedSong.m_iSongStatus == NOT_DOWNLOADED)
            {
                //Set downlaod button origin
                CGRect cellRect =[tableView rectForRowAtIndexPath:indexPath];
                CGRect btRect   =[ib_btDownload frame];
                btRect.origin.x =  btRect.origin.y =0;
                btRect.origin.x = btRect.origin.x + cellRect.size.width - btRect.size.width;
                btRect.origin.y = cellRect.origin.y + (cellRect.size.height/2) ;
                
                [ib_btDownload setFrame:btRect];
                [ib_btDownload setHidden:NO];
                m_iDownloadCellNumber = indexPath.row;
            }
        }
    }
    else
    {
        //Set delete button origin
        CGRect cellRect =[tableView rectForRowAtIndexPath:indexPath];
        CGRect btRect   =[ib_btDelete frame];
        btRect.origin.x =  btRect.origin.y =0;
        btRect.origin.x = btRect.origin.x + cellRect.size.width - btRect.size.width;
        btRect.origin.y = cellRect.origin.y + (cellRect.size.height/2) ;
        
        [ib_btDelete setFrame:btRect];
        [ib_btDelete setHidden:NO];
      }
}

@end
