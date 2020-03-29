# ImageScrollView

A control to help you display an image, with zoomable and scrollable features easily.

### About
When you make an application, which has a photo viewer feature, the photo viewer usually needs to have zoomable and scrollable features, to allow the user to view more photo details.  
This control help you display image, with zoomable and scrollable features easily.

#### Compatible

- iOS 7 and later (requires iOS 8 if you want to add it to project using CocoaPod)
- Swift 4.2 (for earlier Swift version, please use earlier ImageScrollView version).

### Usage

#### Cocoapod
Add below line to Podfile:  

```
pod 'ImageScrollView'
```  
and run below command in Terminal to install:  
`pod install`

Note: If above pod isn't working, try using below pod definition in Podfile:  
`pod 'ImageScrollView', :git => 'https://github.com/huynguyencong/ImageScrollView.git'`
#### Manual
In iOS 7, you cannot use Cocoapod to install. In this case, you need add it manually. Simply, add file `ImageSrollView.swift` in folder `Sources` to your project

#### Simple to use
Drag an UIScrollView to your storyboard, change Class and Module in Identity Inspector to ImageScrollView. Also, create an IBOutlet in your source file.

![image](http://s10.postimg.org/jd12ztvkp/Tut1.jpg)

```
import ImageScrollView
```

```
@IBOutlet weak var imageScrollView: ImageScrollView!
```

```
let myImage = UIImage(named: "my_image_name")
imageScrollView.display(image: myImage)
```
That's all. Now try zooming and scrolling to see the result.

You can set delegate to catch event. This delegate is inheritted from `UIScrollViewDelegate`.

```
imageScrollView.imageScrollViewDelegate = self
```

```
extension ViewController: ImageScrollViewDelegate {
    func imageScrollViewDidChangeOrientation(imageScrollView: ImageScrollView) {
        print("Did change orientation")
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print("scrollViewDidEndZooming at scale \(scale)")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll at offset \(scrollView.contentOffset)")
    }
}
```

### Note: 

- If your image is aligned left instead of center, try calling below method:

```superViewOfImageScrollView.layoutIfNeeded()```

`superViewOfImageScrollView` is the view that ImageScrollView is added to.

- If you add the ImageScrollView by code, then your image can't display after calling `display(image:)` method, make sure your `ImageScrollView` has updated its size. Try to call `view.layoutIfNeeded()` before, or try to call `display(image:)` in `viewDidAppear`

### About this source
This open source is based on PhotoScroller demo avaiable on Apple's site. The original source was written in Objective C. This open source rewrote it by using Swift, and added some new features:
- Double tap to zoom.
- Smoother. Fixed bug when zooming out, the control auto zooms from center, and not from the corner.

### License
ImageScrollView is released under the MIT license. See LICENSE for details. Copyright © Nguyen Cong Huy
