# ImageScrollView

This is a control that will help you to display an image, with zoomable and scrollable features easily.

### About
When you make an application, which has a photo viewer feature, the photo viewer usually needs to have zoomable and scrollable features, that allows your user viewing photo more details. 
This control will help you to display images, with zoomable and scrollable features easily.

![Demo](ReadMeImages/demo.gif)

#### Compatible

- iOS 9 and later.
- Swift 5.0 and later (for earlier Swift version, please use earlier ImageScrollView version).

### Usage

#### Cocoapod
Add below line to your Podfile:  

```
pod 'ImageScrollView'
```  

then run below command in Terminal to install:  

`pod install`

Note: If the above pod doesn't work, try using below pod definition in Podfile:  

`pod 'ImageScrollView', :git => 'https://github.com/huynguyencong/ImageScrollView.git'`

#### Swift Package Manager

In Xcode, select menu File -> Swift Packages -> Add Package Dependency. Select a target, then add this link to the input field:
`https://github.com/huynguyencong/ImageScrollView.git`

#### Manual
Sometimes just want to install manually, just simply add the file `ImageSrollView.swift` in the folder `Sources` to your project.

#### Simple to use
Drag an UIScrollView to your storyboard, change Class and Module in Identity Inspector to ImageScrollView. Also, create an IBOutlet in your source file.

![How to config ImageScrollView in storyboard](ReadMeImages/storyboard-demo.jpeg?raw=true)

```swift
import ImageScrollView
```

```swift
@IBOutlet weak var imageScrollView: ImageScrollView!
```

```swift
// Important: This setup method should be called once, usually in your viewDidLoad() method
imageScrollView.setup()

let myImage = UIImage(named: "my_image_name")
imageScrollView.display(image: myImage)
```
That's all. Now try zooming and scrolling to see the result.

You can set delegate to catch event. This delegate is inheritted from `UIScrollViewDelegate`.

```swift
imageScrollView.imageScrollViewDelegate = self
```

```swift
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

- If you have any problem about layout, image position, make sure you have called the setup() method of the ImageScrollView. Or you can try calling the method `layoutIfNeeded()` of the view controller's view:

```swift
view.layoutIfNeeded()
```


### About this source
This open source is based on PhotoScroller demo avaiable on Apple's site. The original source was written in Objective C. This open source rewrote it by using Swift, and added some new features:
- Double tap to zoom.
- Smoother. Fixed bug when zooming out, the control auto zooms from center, and not from the corner.

### License
ImageScrollView is released under the MIT license. See LICENSE for details. Copyright © Nguyen Cong Huy
