import UIKit
import MobileCoreServices

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var gameView: UIView!

    @IBOutlet weak var clickCounterLabel: UILabel!
    
    var gameViewWidth : CGFloat!
    var blockWidth : CGFloat!
    
    var xCenter : CGFloat!
    var yCenter : CGFloat!
    var finalBlock : MyBlock!
    
    var blockArray: NSMutableArray = []
    var centersArray: NSMutableArray = []
    var images: [UIImage] = []
    var picNum : Int = 0
    var empty: CGPoint!
    var clickCount : Int = 0
    
    @IBAction func ResetButton(_ sender: Any) {
        clickCount = 0
        scramble()
    }
    
    @objc func clickAction()
    {
        clickCount += 1
        clickCounterLabel.text = String.init(format: "%d", clickCount)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        images = [#imageLiteral(resourceName: "Image1"), #imageLiteral(resourceName: "Image2"), #imageLiteral(resourceName: "Image3"), #imageLiteral(resourceName: "Image4"), #imageLiteral(resourceName: "Image5"), #imageLiteral(resourceName: "Image6"), #imageLiteral(resourceName: "Image7"), #imageLiteral(resourceName: "Image8"), #imageLiteral(resourceName: "Image9"), #imageLiteral(resourceName: "Image10"), #imageLiteral(resourceName: "Image11"), #imageLiteral(resourceName: "Image12"), #imageLiteral(resourceName: "Image13"), #imageLiteral(resourceName: "Image14"), #imageLiteral(resourceName: "Image15"), #imageLiteral(resourceName: "Image16")]
        makeBlocks()
        scramble()
        self.ResetButton(Any.self)
    }
    
    
    func makeBlocks() {
        blockArray = []
        centersArray = []
        
        gameViewWidth = gameView.frame.size.width
        blockWidth = gameViewWidth / 4
        
        xCenter = blockWidth / 2
        yCenter = blockWidth / 2
        
        picNum = 0
        
        for _ in 0..<4 {
            for _ in 0..<4 {
                let blockFrame : CGRect = CGRect(x: 0, y: 0, width: blockWidth, height: blockWidth)
                let block: MyBlock = MyBlock (frame: blockFrame)
                let thisCenter : CGPoint = CGPoint(x: xCenter, y: yCenter)
                
                block.isUserInteractionEnabled = true
                block.image = images[picNum]
                picNum += 1
                
                block.center = thisCenter
                block.originalCenter = thisCenter
                gameView.addSubview(block)
                blockArray.add(block)
                
                xCenter = xCenter + blockWidth
                centersArray.add(thisCenter)
            }
            xCenter = blockWidth / 2
            yCenter = yCenter + blockWidth
        }
        
        finalBlock = blockArray[15] as! MyBlock
        finalBlock.removeFromSuperview()
        blockArray.removeObject(at: 15)
        
    }
    
    func clearBlocks(){
        for i in 0..<15 {
            (blockArray[i] as! MyBlock).removeFromSuperview()
        }
        blockArray = []
    }
    
    func scramble() {
        let temporaryCentersArray: NSMutableArray = centersArray.mutableCopy() as! NSMutableArray
        for anyBlock in blockArray {
            let randomIndex: Int = Int(arc4random()) % temporaryCentersArray.count
            let randomCenter: CGPoint = temporaryCentersArray[randomIndex] as! CGPoint
            (anyBlock as! MyBlock).center = randomCenter
            temporaryCentersArray.removeObject(at: randomIndex)
        }
        empty = temporaryCentersArray[0] as! CGPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let myTouch : UITouch = touches.first!
        
        if (blockArray.contains(myTouch.view as Any))        {
            
            let touchView: MyBlock = (myTouch.view)! as! MyBlock
            
            let xOffset: CGFloat = touchView.center.x - empty.x
            let yOffset: CGFloat = touchView.center.y - empty.y
            
            let distanceBetweenCenters : CGFloat = sqrt(pow(xOffset, 2) + pow(yOffset, 2))
            
            if (distanceBetweenCenters == blockWidth) {
                let temporaryCenter : CGPoint = touchView.center
                
                
                UIView.beginAnimations(nil, context: nil)
                UIView.setAnimationDuration(0.2)
                touchView.center = empty
                UIView.commitAnimations()
                
                self.clickAction()
                
                empty = temporaryCenter
                let gameOver = checkBlocks()
                if gameOver == true {
                    gameView.addSubview(finalBlock)
                }
            }
            
        }
        
    }
    
    func gameOverLogic() {
        for i in 0..<15 {
            (blockArray[i] as! MyBlock).isUserInteractionEnabled = false
        }
        displayFinalBlock()
    }
    
    func checkBlocks() -> Bool {
        var correctBlockCounter = 0
        
        for i in 0..<15 {
            if (blockArray[i] as! MyBlock).center == (blockArray[i] as! MyBlock).originalCenter {
               correctBlockCounter += 1
            }
        }
        if correctBlockCounter == 15 {
            return true
        }
        return false
    }
    
    var newPic: Bool?
    
    @IBAction func uploadImageTaped(_ sender: Any) {

        let myAlert = UIAlertController(title: "Select image from", message: "", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                self.newPic = true
            }
        }
        
        let cameraRollAction = UIAlertAction(title: "Camera Roll", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                imagePicker.mediaTypes = [kUTTypeImage as String]
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
                self.newPic = false
            }
        }
        
        myAlert.addAction(cameraAction)
        myAlert.addAction(cameraRollAction)
        self.present(myAlert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        if mediaType.isEqual(to: kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            images = slice(image: image, into: 4)
            
            clearBlocks()
            makeBlocks()
            scramble()
            
            if newPic == true {
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageError), nil)
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func imageError (image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let alert = UIAlertController(title: "Save failed", message: "Failed to save image", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func slice(image: UIImage, into howMany: Int) -> [UIImage] {

        let width: CGFloat = image.size.width
        let height: CGFloat = image.size.height
        let tileWidth = Int(width / CGFloat(howMany))
        let tileHeight = Int(height / CGFloat(howMany))
        let scale = Int(image.scale)
        var imageSections = [UIImage]()
        let cgImage = image.cgImage!
        var adjustedHeight = tileHeight
        
        var y = 0
        for row in 0 ..< howMany {
            if row == (howMany - 1) {
                adjustedHeight = Int(height) - y
            }
            var adjustedWidth = tileWidth
            var x = 0
            for column in 0 ..< howMany {
                if column == (howMany - 1) {
                    adjustedWidth = Int(width) - x
                }
                let origin = CGPoint(x: x * scale, y: y * scale)
                let size = CGSize(width: adjustedWidth * scale, height: adjustedHeight * scale)
                let tileCgImage = cgImage.cropping(to: CGRect(origin: origin, size: size))!
                imageSections.append(UIImage(cgImage: tileCgImage, scale: image.scale, orientation: image.imageOrientation))
                x += tileWidth
            }
            y += tileHeight
        }
        return imageSections
    }
    
}
class MyBlock : UIImageView {
    var originalCenter: CGPoint!
}
