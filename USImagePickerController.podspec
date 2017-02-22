Pod::Spec.new do |s|
  s.name         = "USImagePickerController"
  s.version      = "0.0.1"
  s.summary      = "A photo picker for iOS 7+."
  s.homepage     = "https://github.com/marujun/USImagePickerController"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "marujun" => "marujunyy@qq.com" }
  s.source       = { :git => "https://github.com/marujun/USImagePickerController.git", :tag => s.version.to_s }
  s.platform     = :ios, "7.0"
  
  s.source_files  = "USImagePickerController/**/*.{h,m}", "ImagePickerSheetController/**/*.{h,m}"
  s.exclude_files = "USImagePickerController/RSKImageCropper/*"
  s.public_header_files  = "USImagePickerController/**/*.{h}", "ImagePickerSheetController/**/*.{h}"
  s.resources = "USImagePickerController/Resource/*", "ImagePickerSheetController/Resource/*"
  
  s.frameworks = 'UIKit', 'CoreFoundation', 'Photos'
  s.requires_arc = true
  s.dependency "RSKImageCropper", "~> 1.6.0"
end