//
//  Catboard.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 9/24/14.
//  Copyright (c) 2014 Alexei Baboulevitch ("Archagon"). All rights reserved.
//

import UIKit

/*
This is the demo keyboard. If you're implementing your own keyboard, simply follow the example here and then
set the name of your KeyboardViewController subclass in the Info.plist file.
*/

let kCatTypeEnabled = "kCatTypeEnabled"

class Catboard: KeyboardViewController {
    
    let takeDebugScreenshot: Bool = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        NSUserDefaults.standardUserDefaults().registerDefaults([kCatTypeEnabled: true])
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOSApplicationExtension 9.0, *) {
            (bannerView as! CatboardBanner).scrview.contentSize = CGSizeMake((bannerView as! CatboardBanner).wordListView.frame.width, 0)
        } else {
            // Fallback on earlier versions
        }
    }
    private var proxy: UITextDocumentProxy {
        return textDocumentProxy as! UITextDocumentProxy
    }

    private var lastWordTyped: String? {
        if let documentContextBeforeInput = proxy.documentContextBeforeInput as NSString? {
            let length = documentContextBeforeInput.length
            if length > 0 && NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").characterIsMember(documentContextBeforeInput.characterAtIndex(length - 1))
            {
                let components = documentContextBeforeInput.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").invertedSet)

                return components[components.endIndex - 1]
            }
            else{
                return ""
            }
     }
     return nil
    }

    override func keyPressed(key: Key) {
        let textDocumentProxy = self.textDocumentProxy
        
        
        let keyOutput = key.outputForCase(self.shiftState.uppercase())

        if #available(iOSApplicationExtension 9.0, *) {
            if let lastWord = lastWordTyped
            {
                if !NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").characterIsMember((key.lowercaseOutput! as NSString).characterAtIndex(0)) {
                    (bannerView as! CatboardBanner).findWords("")
                }
                else{
                    (bannerView as! CatboardBanner).findWords(lastWord + key.lowercaseOutput!)
                }
            }
            else{
                (bannerView as! CatboardBanner).findWords(key.lowercaseOutput!)
            }
        } else {
            // Fallback on earlier versions
        }
        if !NSUserDefaults.standardUserDefaults().boolForKey(kCatTypeEnabled) {
            textDocumentProxy.insertText(keyOutput)
            return
        }
        
//        if key.type == .Character || key.type == .SpecialCharacter {
//            
//            if let context = textDocumentProxy.documentContextBeforeInput {
//                if context.characters.count < 2 {
//                    textDocumentProxy.insertText(keyOutput)
//                    return
//                }
//                
//                var index = context.endIndex
//                
//                index = index.predecessor()
//                if context[index] != " " {
//                    textDocumentProxy.insertText(keyOutput)
//                    return
//                }
//                
//                index = index.predecessor()
//                if context[index] == " " {
//                    textDocumentProxy.insertText(keyOutput)
//                    return
//                }
//
//                textDocumentProxy.insertText("\(randomCat())")
//                textDocumentProxy.insertText(" ")
//                textDocumentProxy.insertText(keyOutput)
//                return
//            }
//            else {
//                textDocumentProxy.insertText(keyOutput)
//                return
//            }
//        }
//        else
//        {
            textDocumentProxy.insertText(keyOutput)
            return
//        }
    }
    
    override func backspaceDown(sender: KeyboardKey)
    {
        super.backspaceDown(sender)
        updateSuggestion()
    }
    
    override func backspaceRepeatCallback()
    {
        super.backspaceRepeatCallback()
        updateSuggestion()
    }
    
    override func setupKeys() {
        super.setupKeys()
        
        if takeDebugScreenshot {
            if self.layout == nil {
                return
            }
            
            for page in keyboard.pages {
                for rowKeys in page.rows {
                    for key in rowKeys {
                        if let keyView = self.layout!.viewForKey(key) {
                            keyView.addTarget(self, action: "takeScreenshotDelay", forControlEvents: .TouchDown)
                        }
                    }
                }
            }
        }
    }
    
    override func createBanner() -> ExtraView? {
        if #available(iOSApplicationExtension 9.0, *) {
            let banner = CatboardBanner(globalColors: self.dynamicType.globalColors, darkMode: false, solidColorMode: self.solidColorMode())
            banner.keyboard = self
            return banner
            
        } else {
            return nil
        }
    }
    
    func updateSuggestion() {
        if #available(iOSApplicationExtension 9.0, *) {
            if let lastWord = lastWordTyped
            {
                (bannerView as! CatboardBanner).findWords(lastWord)
            }
            else{
                (bannerView as! CatboardBanner).findWords("")
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func takeScreenshotDelay() {
        NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("takeScreenshot"), userInfo: nil, repeats: false)
    }
    
    func inputWord(word:String)
    {
        if let lastWord = lastWordTyped{
            for letter in lastWord.characters {
                proxy.deleteBackward()
            }
        }
        proxy.insertText(word)
        updateSuggestion()
    }
    
    func takeScreenshot() {
        if !CGRectIsEmpty(self.view.bounds) {
            UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
            
            let oldViewColor = self.view.backgroundColor
            self.view.backgroundColor = UIColor(hue: (216/360.0), saturation: 0.05, brightness: 0.86, alpha: 1)
            
            let rect = self.view.bounds
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
            var context = UIGraphicsGetCurrentContext()
            self.view.drawViewHierarchyInRect(self.view.bounds, afterScreenUpdates: true)
            let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let name = (self.interfaceOrientation.isPortrait ? "Screenshot-Portrait" : "Screenshot-Landscape")
            let imagePath = "/Users/archagon/Documents/Programming/OSX/RussianPhoneticKeyboard/External/tasty-imitation-keyboard/\(name).png"
            
            if let pngRep = UIImagePNGRepresentation(capturedImage) {
                pngRep.writeToFile(imagePath, atomically: true)
            }
            
            self.view.backgroundColor = oldViewColor
        }
    }
}

func randomCat() -> String {
    let cats = "🐱😺😸😹😽😻😿😾😼🙀"
    
    let numCats = cats.characters.count
    let randomCat = arc4random() % UInt32(numCats)
    
    let index = cats.startIndex.advancedBy(Int(randomCat))
    let character = cats[index]
    
    return String(character)
}
