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
#import "ImagePreviewController.h"
#import <Masonry/Masonry.h>
#import <UITextView+Placeholder/UITextView+Placeholder.h>
#import <pop/POP.h>
@interface MyAssignmentUploadViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,TZImagePickerControllerDelegate,UITextViewDelegate>{
    NSMutableArray *uploadImages;
    NSMutableDictionary *cacheDelStates;
}
@property(nonatomic,strong) ReportInfo *mreportInfo;
@property(nonatomic,strong) UICollectionView *collectionView;
@property(nonatomic,strong) NSMutableArray *photos;
@property(nonatomic,strong) UIImage *addImage;
@property(nonatomic,strong) UITextView *descriptionTF;
@end

@implementation MyAssignmentUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     CGRect bounds=[[UIScreen mainScreen] bounds];
    
     self.view=[[UIView alloc] initWithFrame:bounds];
     self.automaticallyAdjustsScrollViewInsets=NO;
    
     self.view.backgroundColor=[UIColor whiteColor];
    
     self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStylePlain target:self action:@selector(commit:)];
    //创建一个layout布局类
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    //设置布局方向为垂直流布局
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(157, 150);
    layout.minimumInteritemSpacing=3;
    layout.minimumLineSpacing=3;
    
    
    self.descriptionTF=[[UITextView alloc] initWithFrame:CGRectZero];
    [_descriptionTF.layer setBorderColor:[[UIColor colorWithWhite:0.4 alpha:0.1] CGColor]];
    [_descriptionTF setFont:[UIFont systemFontOfSize:15]];
    
    
    [_descriptionTF.layer setBorderWidth:1];
    [_descriptionTF.layer setCornerRadius:2];
    
    [_descriptionTF setBackgroundColor:[UIColor whiteColor]];
    [_descriptionTF setPlaceholder:@"请描述说明"];
    _descriptionTF.delegate=self;
    UIView *topView=[[UIView alloc] initWithFrame:CGRectMake(0,0,320,40)];
    [topView setBackgroundColor:[UIColor colorWithWhite:0.86 alpha:0.6]];
    UIButton *hideBtn=[[UIButton alloc] initWithFrame:CGRectMake(320-60,0,60,40)];
    [hideBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [hideBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [hideBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [hideBtn addTarget:self action:@selector(closeKeyBoard) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:hideBtn];
    [_descriptionTF setInputAccessoryView:topView];
    
    
    
    self.collectionView=[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    [_collectionView registerNib:[UINib nibWithNibName:@"UploadCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"uploadcell"];
    
    self.collectionView.backgroundColor=[UIColor whiteColor];

    [self.view addSubview:_descriptionTF];
    
    [self.view addSubview:_collectionView];
    
    
    [_descriptionTF mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(self.view.mas_top).with.offset(70);
        make.left.equalTo(self.view.mas_left).with.offset(5);
        make.right.equalTo(self.view.mas_right).with.offset(-5);
        make.height.mas_equalTo(100);
        
        
    }];
    
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(_descriptionTF.mas_bottom).with.offset(10);
        make.left.equalTo(self.view.mas_left).with.offset(0);
        make.right.equalTo(self.view.mas_right).with.offset(0);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(0);
        
    }];
    
    
    
    
    self.photos=[NSMutableArray new];
    cacheDelStates=[NSMutableDictionary new];
    uploadImages=[NSMutableArray new];

    self.addImage=[UIImage imageNamed:@"icon_addpic"];
    [_photos addObject:_addImage];
    
    if(_reportList!=nil){
        
        for (ReportInfo *info in _reportList) {
            if(info.assignmentId==_assignmentId){
                self.mreportInfo=info;
                break;
            }
        }
    }
    
    if(_mreportInfo!=nil){
        _descriptionTF.text=_mreportInfo.desc;
    }
    
    
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"数据加载中";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(_mreportInfo!=nil){
            NSArray *arr=[_mreportInfo.attachFileName componentsSeparatedByString:@","];
            
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
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [hud hide:YES];
            [_collectionView reloadData];
        });
        

    });
    
    
    
    
    
}
-(void)closeKeyBoard{
    [_descriptionTF resignFirstResponder];
}
-(void)commit:(id)sender{
    
    NSLog(@"%@",sender);
    NSLog(@"%@",uploadImages);
    
    
    NSString *desc=[_descriptionTF text];
    
    if([[desc stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]){
        [self.view makeToast:@"请填写描述信息"];
        return;
    }
    if(uploadImages==nil||[uploadImages count]<=0){
        [self.view makeToast:@"没有添加新的内容,无法上传"];
        return;
    }

    
    MBProgressHUD *hud=[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText=@"上传中...";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL uploadSUC=NO;
        for(UIImage *image in uploadImages){
            
            NSString *base64String=[ImageUtils encodeToBase64String:image format:@"PNG"];
            
            uploadSUC=[[ElApiService shareElApiService] submitReport:_courseCode file:base64String desc:desc assignmentId:_assignmentId];
            
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
    cell.imageIcon.gestureRecognizers=nil;
    
    BOOL isOpenAlblum=NO;
    
    if(indexPath.row==0){
         isOpenAlblum=YES;
    }
    
     cell.imageIcon.image= [_photos objectAtIndex:indexPath.row];
     cell.imageIcon.tag=indexPath.row;
    
    

    
     cell.delIcon.tag=indexPath.row;
    id state=[cacheDelStates objectForKey:@(indexPath.row)];
    
    if(state==nil){
         [cell.delIcon setHidden:YES];
    }else{
        
         [cell.delIcon setHidden:![state boolValue]];
    }
    
   
    [cell.delIcon addTarget:self action:@selector(delImage:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.imageIcon setUserInteractionEnabled:YES];
    UITapGestureRecognizer *gr=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openAlbum:)];
    gr.numberOfTapsRequired=1;
    
    [cell.imageIcon addGestureRecognizer:gr];
    UITapGestureRecognizer *gr2=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAlbum:)];
    gr2.numberOfTapsRequired=2;
    
    [cell.imageIcon addGestureRecognizer:gr2];
    
    if([uploadImages containsObject:[_photos objectAtIndex:indexPath.row]]){
        NSLog(@"this is upload image  row is %d",indexPath.row);
        
        UILongPressGestureRecognizer *longPressGR=[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        
        [cell.imageIcon addGestureRecognizer:longPressGR];
        
    }
    
    return cell;
    
}
-(void)delImage:(UIButton *)sender{
    [cacheDelStates setObject:@(NO) forKey:@(sender.tag)];
    [uploadImages removeObject:[_photos objectAtIndex:sender.tag]];
    [_photos removeObjectAtIndex:sender.tag];
    [_collectionView reloadData];
}
-(void)longPress:(UIGestureRecognizer *)gr{
    
    
    if(gr.state==UIGestureRecognizerStateBegan){
        NSLog(@"longPress begin tag %d",gr.view.tag);
        
        NSArray *views=[[gr.view superview] subviews];
        NSLog(@"views : %@, count : %d",views,[views count]);
        
        [views enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            UIView *delView=(UIView *)obj;
            if(delView.frame.size.height<40){
                [delView setHidden:NO];
                [cacheDelStates setObject:@(YES) forKey:@(gr.view.tag)];
                /*
                 * animate
                 */
                POPSpringAnimation *anim=[POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
                anim.fromValue=@(10);
                anim.toValue=@(0);
                anim.springBounciness=0.01;
                anim.springSpeed=0.01;
                
                
                [delView.layer pop_addAnimation:anim forKey:@"rotation"];
            }
           
            
        }];

        
    }
    
    
}
-(void)showAlbum:(UIGestureRecognizer *)gr{
    NSLog(@"showAlbum tag %@",gr.view);
    UIImageView *imView=(UIImageView *)gr.view;
    
    ImagePreviewController *previewVC=[[ImagePreviewController alloc] init];
    [previewVC setPhoto:imView.image];
    
    [self.navigationController pushViewController:previewVC animated:YES];

    
}
-(void)openAlbum:(UIGestureRecognizer *)gr{
    if(gr.view.tag==0){
        TZImagePickerController *tzPickerController=[[TZImagePickerController alloc] initWithMaxImagesCount:6 delegate:self];
        
        
        tzPickerController.allowPickingVideo=NO;
        tzPickerController.allowTakePicture=YES;
        tzPickerController.sortAscendingByModificationDate=NO;
        tzPickerController.title=@"选择上传照片";
        
        [self presentViewController:tzPickerController animated:YES completion:^{
            
        }];
    }else{
        NSArray *views=[[gr.view superview] subviews];
        [views enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIView *delView=(UIView *)obj;
            if(delView.frame.size.height<40){
                if(!delView.isHidden){
                   [delView setHidden:YES];
                    [cacheDelStates setObject:@(NO) forKey:@(gr.view.tag)];
                }
            }
        }];
        

    }
   
    
    
}
#pragma mark picker delegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    int loc=[self.photos count];
    [uploadImages addObjectsFromArray:photos];
    [self.photos insertObjects:photos atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(loc,[photos count])]];
    
    [_collectionView reloadData];
}


#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    NSLog(@"textViewShouldBeginEditing...");
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    NSLog(@"textViewShouldEndEditing...");
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"textViewDidBeginEditing...");
}
- (void)textViewDidEndEditing:(UITextView *)textView{
  NSLog(@"textViewDidEndEditing...");
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSLog(@"shouldChangeTextInRange... %@",text);
    return YES;

}
- (void)textViewDidChange:(UITextView *)textView{
    NSLog(@"textViewDidChange... ");
 
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
     NSLog(@"textViewDidChangeSelection... ");
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0){
    NSLog(@"shouldInteractWithURL... %@",URL);
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange NS_AVAILABLE_IOS(7_0){
    NSLog(@"shouldInteractWithTextAttachment...");
    return YES;
}

@end
