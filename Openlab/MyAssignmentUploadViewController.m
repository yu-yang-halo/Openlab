//
//  MyAssignmentUploadViewController.m
//  Openlab
//
//  Created by admin on 16/7/22.
//  Copyright © 2016年 cn.lztech  合肥联正电子科技有限公司. All rights reserved.
//

#import "MyAssignmentUploadViewController.h"
#import "UploadCollectionViewCell.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import "MyObjectDataBean.h"
#import "ElApiService.h"
#import <SDWebImage/SDWebImageManager.h>
#import "ImageUtils.h"
#import <Toast/UIView+Toast.h>
#import <MBProgressHUD/MBProgressHUD.h>
@interface MyAssignmentUploadViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,TZImagePickerControllerDelegate>{
    NSMutableArray *uploadImages;
}
@property(nonatomic,strong) ReportInfo *mreportInfo;
@property(nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong) NSMutableArray *photos;
@property(nonatomic,strong) UIImage *addImage;
@end

@implementation MyAssignmentUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.title=@"请上传作业";
     CGRect bounds=[[UIScreen mainScreen] bounds];
    
     self.view.backgroundColor=[UIColor whiteColor];
    
     self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(commit:)];
    //创建一个layout布局类
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    //设置布局方向为垂直流布局
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(157, 150);
    layout.minimumInteritemSpacing=3;
    layout.minimumLineSpacing=3;

    
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 0,bounds.size.width,bounds.size.height) collectionViewLayout:layout];
    
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    [_collectionView registerNib:[UINib nibWithNibName:@"UploadCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"uploadcell"];
    
    self.collectionView.backgroundColor=[UIColor whiteColor];

    
    
    [self.view addSubview:_collectionView];
    
    
    self.photos=[NSMutableArray new];
    uploadImages=[NSMutableArray new];

    self.addImage=[UIImage imageNamed:@"icon_addpic"];
    
    
    if(_reportList!=nil){
        
        for (ReportInfo *info in _reportList) {
            if(info.assignmentId==_assignmentId){
                self.mreportInfo=info;
                break;
            }
        }
    }
  
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(_mreportInfo!=nil){
            NSArray *arr=[_mreportInfo.fileName componentsSeparatedByString:@","];
            
            for (NSString *name in arr) {
                NSString *url=[[ElApiService shareElApiService] getWebImageURL:name];
                
                NSData *data=[[ElApiService shareElApiService] requestURLSync:url];
                
                if(data==nil){
                    continue;
                }
                UIImage *image=[UIImage imageWithData:data];
                if(image==nil){
                    continue;
                }
                [_photos addObject:image];
                
            }
            
        }
        
         [_photos addObject:_addImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [_collectionView reloadData];
        });
        

    });
    
    
    
    
    
}


-(void)commit:(id)sender{
    NSLog(@"%@",sender);
    
    NSLog(@"%@",uploadImages);
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"上传中...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL uploadSUC=NO;
        for(UIImage *image in uploadImages){
            
            NSString *base64String=[ImageUtils encodeToBase64String:image format:@"PNG"];
            
            uploadSUC=[[ElApiService shareElApiService] submitReport:_courseCode file:base64String desc:@"" assignmentId:_assignmentId];
            
            if(!uploadSUC){
                break;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(uploadSUC){
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self.view.window makeToast:@"上传错误，请重试"];
            }
            [hud hide:YES];
        });
        
        
    });
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *  UICollectionView Delegate and DataSource
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_photos count];
    
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UploadCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"uploadcell" forIndexPath:indexPath];
    
    if(cell==nil){
        cell=[[[NSBundle mainBundle] loadNibNamed:@"UploadCollectionViewCell" owner:nil options:nil] lastObject];
        
    }
    
    BOOL isOpenAlblum=NO;
    
    if(indexPath.row==[_photos count]-1){
         isOpenAlblum=YES;
    }
    
     cell.imageIcon.image= [_photos objectAtIndex:indexPath.row];
     cell.imageIcon.tag=indexPath.row;
    [cell.imageIcon setUserInteractionEnabled:isOpenAlblum];
    if(isOpenAlblum){
        UITapGestureRecognizer *gr=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAlbum:)];
        gr.numberOfTapsRequired=1;
        
        [cell.imageIcon addGestureRecognizer:gr];
        
    }
    return cell;
    
}
-(void)openAlbum:(UIGestureRecognizer *)gr{
    NSLog(@"tag %d",gr.view.tag);
    TZImagePickerController *tzPickerController=[[TZImagePickerController alloc] initWithMaxImagesCount:6 delegate:self];
    
   
    tzPickerController.allowPickingVideo=NO;
    tzPickerController.allowTakePicture=YES;
    tzPickerController.sortAscendingByModificationDate=NO;
    tzPickerController.title=@"选择上传照片";
    
    [self presentViewController:tzPickerController animated:YES completion:^{
        
    }];
    
    
}
#pragma mark picker delegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    int loc=[self.photos count]-1;
    [uploadImages addObjectsFromArray:photos];
    [self.photos insertObjects:photos atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc,[photos count])]];
    
    [_collectionView reloadData];
}

@end
