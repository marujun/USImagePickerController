##照片选择器、图片浏览器 组件的DEMO

>USImagePickerController 

备注：iOS7~8.0使用ALAsset ----- iOS8.1及以上使用PHAsset

```objc
/*!
 @property
 @brief 是否允许编辑选择的照片，默认为NO
 */
@property (nonatomic, assign) BOOL allowsEditing;

/*!
 @property
 @brief 裁剪已选照片时的遮罩区域尺寸的宽高比(allowsEditing必须设置为YES)，默认为1
 */
@property (nonatomic, assign) CGFloat cropMaskAspectRatio;

/*!
 @property
 @brief 是否允许选择多张照片，默认为NO
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;

/*!
 @property
 @brief 在允许选择多张照片的情况，最大选择张数，默认无限制
 */
@property (nonatomic, assign) NSInteger maxSelectNumber;

/*!
 @property
 @brief 是否已选择使用原图，默认为NO
 */
@property (nonatomic, assign, readonly) BOOL selectedOriginalImage;
```

>ImagePickerSheetController

类似系统短信中的快速选择照片空间


>USAssetsPageViewController

图片浏览器
