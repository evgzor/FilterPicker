//
//  FLPhotoPICKERViewController.m
//  FilterPicker
//
//  Created by Zorin Evgeny on 02.08.14.
//  Copyright (c) 2014 Z. All rights reserved.
//

#import "FLPhotoPICKERViewController.h"

@interface FLPhotoPICKERViewController ()
{
    //color instance values
    float saturation;
    float brightness;
    float contrast;
    //UI elements
    IBOutlet UIButton *button;
    IBOutlet UIImageView *image;
	UIImagePickerController *imgPicker;
    UIImageView* originalImgView;
}
- (IBAction)grabImage;

-(IBAction)saveToAlbumPicture;


@end

@implementation FLPhotoPICKERViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    imgPicker = [[UIImagePickerController alloc] init];
	imgPicker.allowsEditing = YES;
	imgPicker.delegate = self;
	imgPicker.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    
    originalImgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:image.image.CGImage]];
    [self setUpColorConstant];
    
    NSArray *supportedFilters = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    
    for (CIFilter *filter in supportedFilters) {
        NSString *string = [NSString stringWithFormat:@"%@",[[CIFilter filterWithName:(NSString *)filter] inputKeys]];
        NSLog(@"%@ %@", filter, string);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - image picker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
	image.image = img;
	[picker dismissModalViewControllerAnimated:YES];
    originalImgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:img.CGImage]];
}

#pragma mark - filter process

-(void)brightnessChange:(float)value
{
    brightness = value;
    [self filterColorApply];
}

-(void)sharpChange:(float)value
{
    
    CIImage *inputImage = [[CIImage alloc] initWithImage:originalImgView.image];
    CIFilter *sharpFilter = [CIFilter filterWithName:@"CISharpenLuminance"
                                                     keysAndValues: @"inputImage", inputImage,
                                           @"inputSharpness", [NSNumber numberWithFloat:value], nil];
    [sharpFilter setDefaults];
    CIImage *outputImage = [sharpFilter valueForKey:@"outputImage"];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:outputImage.extent];
    image.image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
}

-(void)saturationChange:(float)value
{
    saturation = value;
    [self filterColorApply];
}

-(void)setUpColorConstant
{
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIColorControls"];
    [colorFilter setDefaults];
    saturation = [[colorFilter valueForKeyPath:@"inputSaturation"] floatValue];
    brightness = [[colorFilter valueForKeyPath:@"inputBrightness"] floatValue];
    contrast = [[colorFilter valueForKeyPath:@"inputContrast"] floatValue];
}

-(void)contrastChange:(float)value
{
    contrast = value;
    [self filterColorApply];
}

-(void)filterColorApply
{
    CIFilter *sharpFilter = [CIFilter filterWithName:@"CIColorControls"];
    [sharpFilter setDefaults];
    [sharpFilter setValue:[[CIImage alloc] initWithImage:originalImgView.image] forKey:@"inputImage"];
    [sharpFilter setValue:[NSNumber numberWithFloat:contrast] forKey:@"inputContrast"];
    [sharpFilter setValue:[NSNumber numberWithFloat:saturation] forKey:@"inputSaturation"];
    [sharpFilter setValue:[NSNumber numberWithFloat:brightness] forKey:@"inputBrightness"];
    
    CIImage *outputImage = [sharpFilter valueForKey:@"outputImage"];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImage = [context createCGImage:outputImage fromRect:outputImage.extent];
    image.image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
}


#pragma mark - user UISlider actions

- (IBAction)sliderBrightnessValueChanged:(UISlider *)sender {
    NSLog(@"slider value = %f", sender.value);
    [self brightnessChange:sender.value - 0.5];
}


- (IBAction)sliderContrastValueChanged:(UISlider *)sender {
    NSLog(@"slider value = %f", sender.value);
    [self contrastChange:sender.value*3.];
}

- (IBAction)sliderSaturationValueChanged:(UISlider *)sender {
    NSLog(@"slider value = %f", sender.value);
    [self saturationChange:sender.value*3.];
}

#pragma mark - user button action

- (IBAction)grabImage {
    [self setUpColorConstant];
	[self presentViewController:imgPicker animated:YES completion:nil];
}

-(IBAction)saveToAlbumPicture
{
    UIImageWriteToSavedPhotosAlbum(image.image,nil,nil,nil);
    
    [[[UIAlertView alloc] initWithTitle:@"Info" message:@"The image has saved" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

@end
