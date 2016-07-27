//
//  CatboardBanner.swift
//  TastyImitationKeyboard
//
//  Created by Alexei Baboulevitch on 10/5/14.
//  Copyright (c) 2014 Alexei Baboulevitch ("Archagon"). All rights reserved.
//

import UIKit

/*
This is the demo banner. The banner is needed so that the top row popups have somewhere to go. Might as well fill it
with something (or leave it blank if you like.)
*/
@available(iOSApplicationExtension 9.0, *)
extension UIStackView {
    
    convenience init(axis:UILayoutConstraintAxis, spacing:CGFloat) {
        self.init()
        self.axis = axis
        self.spacing = spacing
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func anchorStackView(toView view:UIView, anchorX:NSLayoutXAxisAnchor, equalAnchorX:NSLayoutXAxisAnchor, anchorY:NSLayoutYAxisAnchor, equalAnchorY:NSLayoutYAxisAnchor) {
        view.addSubview(self)
        anchorX.constraintEqualToAnchor(equalAnchorX).active = true
        anchorY.constraintEqualToAnchor(equalAnchorY).active = true
        
    }
}

@available(iOSApplicationExtension 9.0, *)
class CatboardBanner: ExtraView, UIScrollViewDelegate{
    var wordListView:UIStackView = UIStackView(axis:.Horizontal, spacing:10);
    var catSwitch: UISwitch = UISwitch()
    var catLabel: UILabel = UILabel()
    var wordList1:[String] = ["ASFSAF","膳宿","C","safasdfopkopekopkhopegeor"]
    var wordList:NSMutableArray = NSMutableArray()
    var enWordList:NSMutableArray = NSMutableArray()
    var keyboard:Catboard!
    var scrview = UIScrollView()

    var btNextPage = UIButton()
    var btPrevPage = UIButton()
    var wordDictionary:NSDictionary = NSDictionary()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollViewWillBeginDecelerating(scrollView:UIScrollView) {
        var ptOffset = scrollView.contentOffset
        if ptOffset.x < 0 {
            ptOffset.x = 0
        }
        else{
//        ptOffset.x = ptOffset.x + UIScreen.mainScreen().bounds.width - 70
        if ptOffset.x > scrview.contentSize.width - (UIScreen.mainScreen().bounds.width - 70) {
            ptOffset.x = scrview.contentSize.width - (UIScreen.mainScreen().bounds.width - 70)
        }
        }
        scrollView.setContentOffset(ptOffset, animated: true)
    }
    
    required init(globalColors: GlobalColors.Type?, darkMode: Bool, solidColorMode: Bool) {
        super.init(globalColors: globalColors, darkMode: darkMode, solidColorMode: solidColorMode)
        
        //self.addSubview(self.catLabel)
        
        scrview.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 30)
//        scrview.delaysContentTouches = false;
        scrview.pagingEnabled = false;
        scrview.delegate = self

        
        scrview.translatesAutoresizingMaskIntoConstraints = false;
        self.addConstraint(NSLayoutConstraint(item: scrview, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scrview, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0))
        scrview.addConstraint(NSLayoutConstraint(item: scrview, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 30.0))
        self.addConstraint(NSLayoutConstraint(item: scrview, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        
        self.addSubview(scrview)
//        wordListView.anchorStackView(toView: scrview, anchorX: wordListView.centerXAnchor, equalAnchorX: wordListView.centerXAnchor, anchorY: wordListView.centerYAnchor, equalAnchorY: wordListView.centerYAnchor)

//        wordListView.leadingAnchor.constraintEqualToAnchor(scrview.layoutMarginsGuide.leadingAnchor, constant: 0).active = true
//        wordListView.trailingAnchor.constraintEqualToAnchor(scrview.layoutMarginsGuide.trailingAnchor, constant: 0).active = true
        
        scrview.addSubview(self.wordListView)
        scrview.backgroundColor = UIColor.darkGrayColor();
        
        
        self.wordListView.backgroundColor = UIColor.darkGrayColor();
        
        btNextPage.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 24, 0, 24, 30)
        btNextPage.setTitle(">", forState: UIControlState.Normal)
        btNextPage.backgroundColor = UIColor.lightGrayColor()
        btNextPage.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btNextPage.setTitleColor(UIColor.blueColor(), forState: UIControlState.Highlighted)
        btNextPage.addTarget(self, action: #selector(CatboardBanner.onNextPage(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        
        btNextPage.translatesAutoresizingMaskIntoConstraints = false;
        self.addConstraint(NSLayoutConstraint(item: btNextPage, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: btNextPage, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0))
        btNextPage.addConstraint(NSLayoutConstraint(item: btNextPage, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 24.0))
        btNextPage.addConstraint(NSLayoutConstraint(item: btNextPage, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 30.0))
        
        self.addSubview(btNextPage);
        
        btPrevPage.frame = CGRectMake(UIScreen.mainScreen().bounds.width - 48, 0, 24, 30)
        btPrevPage.setTitle("<", forState: UIControlState.Normal)
        btPrevPage.backgroundColor = UIColor.lightGrayColor()
        btPrevPage.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btPrevPage.setTitleColor(UIColor.blueColor(), forState: UIControlState.Highlighted)
        btPrevPage.addTarget(self, action: #selector(CatboardBanner.onPrevPage(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btPrevPage.translatesAutoresizingMaskIntoConstraints = false;
        self.addConstraint(NSLayoutConstraint(item: btPrevPage, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: -24.0))
        self.addConstraint(NSLayoutConstraint(item: btPrevPage, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0))
        btPrevPage.addConstraint(NSLayoutConstraint(item: btPrevPage, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .Width, multiplier: 1.0, constant: 24.0))
        btPrevPage.addConstraint(NSLayoutConstraint(item: btPrevPage, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 30.0))
        self.addSubview(btPrevPage);
//        self.catSwitch.on = NSUserDefaults.standardUserDefaults().boolForKey(kCatTypeEnabled)
        //self.catSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75)
        //        self.catSwitch.addTarget(self, action: Selector("respondToSwitch"), forControlEvents: UIControlEvents.ValueChanged)
        keyboard = nil
        wordDictionary = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("word", ofType: "plist")!)!

        self.updateAppearance()
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

//        self.catSwitch.center = self.center
//        self.catLabel.center = self.center
//        self.catLabel.frame.origin = CGPointMake(self.catSwitch.frame.origin.x + self.catSwitch.frame.width + 8, self.catLabel.frame.origin.y)
    }
    
    func onNextPage(sender:AnyObject)
    {
        var ptOffset = scrview.contentOffset
        ptOffset.x = ptOffset.x + UIScreen.mainScreen().bounds.width - 70
        if ptOffset.x > scrview.contentSize.width - (UIScreen.mainScreen().bounds.width - 70) {
            ptOffset.x = scrview.contentSize.width - (UIScreen.mainScreen().bounds.width - 70)
        }
        scrview.setContentOffset(ptOffset, animated: true)
    }
    
    func onPrevPage(sender:AnyObject)
    {
        var ptOffset = scrview.contentOffset
        ptOffset.x = ptOffset.x - (UIScreen.mainScreen().bounds.width - 70)
        if ptOffset.x < 0 {
            ptOffset.x = 0
        }
        scrview.setContentOffset(ptOffset, animated: true)
    }

    
    func respondToSwitch() {
        NSUserDefaults.standardUserDefaults().setBool(self.catSwitch.on, forKey: kCatTypeEnabled)
        self.updateAppearance()
    }
    
    func respondToAddWord(sender:AnyObject)
    {
        (keyboard as Catboard).inputWord(sender.currentTitle!!)
    }
    
    func respondToDownWord(sender:AnyObject)
    {
        (sender as! UIView).backgroundColor = UIColor.blueColor()
    }
    
    func respondToUpWord(sender:AnyObject)
    {
        (sender as! UIView).backgroundColor = UIColor.darkGrayColor()
    }

    
    var nWord = 0
    func addWordsIn(dic:NSDictionary, curString:String)
    {

        let word = dic.valueForKey("word")
        
        if word != nil {
            wordList.addObject(word!)
            enWordList.addObject(curString)
            nWord += 1
        }
        for key in ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"] {
            if nWord > 30 {
                return
            }
            let worDic = dic.valueForKey(key )
            if (worDic == nil)
            {
                continue
            }
            
             addWordsIn(worDic as! (NSDictionary), curString: curString+(key ))
            
            
        }
    }
    
    func findWords(inputTxt:String)
    {
//        print("findWords")
        wordList.removeAllObjects()
        enWordList.removeAllObjects()
        nWord = 0
        let strInput = inputTxt.lowercaseString
        if strInput == "" {
            updateAppearance()
            return
        }
        
        wordList.addObject(strInput)
        var i = 0
        var curBranch:NSDictionary? = wordDictionary
        while i<strInput.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) {
            
            let chCur = strInput.substringWithRange(Range<String.Index>(start:strInput.startIndex.advancedBy(i), end: strInput.startIndex.advancedBy(i + 1)))
            
            let curKey = curBranch!.valueForKey(chCur)
            if (curKey == nil) {
                break
            }
            
            curBranch! = (curBranch!.valueForKey(chCur) as! NSDictionary)
            i += 1
        }
        
        if i == strInput.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) {
            addWordsIn(curBranch!, curString: strInput)
        }
        updateAppearance()
    }
    
    func updateAppearance() {
//        var iWord:CGFloat = 0
        var i = 0
        
        for subView in wordListView.arrangedSubviews {
            //wordListView.removeArrangedSubview(subView)
            subView.removeFromSuperview()
            //wordListView.arrangedSubviews[0].removeFromSuperview()
        }

        
        i = 0
        var szContent:CGSize = CGSizeMake(0, 0)
        while i<wordList.count {
            let word = wordList.objectAtIndex(i)
            let btWord:UIButton = UIButton();
            btWord.setTitle(word as? String, forState: UIControlState.Normal)
            btWord.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            btWord.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
            btWord.backgroundColor = UIColor.darkGrayColor();
            //btWord.titleLabel?.font = UIFont.systemFontOfSize(20)
            btWord.addTarget(self, action: #selector(CatboardBanner.respondToAddWord(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            btWord.addTarget(self, action: #selector(CatboardBanner.respondToDownWord(_:)), forControlEvents: UIControlEvents.TouchDown)
            btWord.addTarget(self, action: #selector(CatboardBanner.respondToUpWord(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//            btWord.addTarget(self, action: #selector(CatboardBanner.respondToUpWord(_:)), forControlEvents: UIControlEvents.TouchUpOutside)
            btWord.addTarget(self, action: #selector(CatboardBanner.respondToDownWord(_:)), forControlEvents: UIControlEvents.TouchDragInside)
            btWord.addTarget(self, action: #selector(CatboardBanner.respondToUpWord(_:)), forControlEvents: UIControlEvents.TouchDragExit)
            wordListView.addArrangedSubview(btWord)
            szContent.width = szContent.width + btWord.frame.size.width + 10
            i += 1
        }
        
        i = 0
        while i<enWordList.count {
            let word = enWordList.objectAtIndex(i)
            let btWord:UIButton = UIButton();
            btWord.setTitle(word as? String, forState: UIControlState.Normal)
            btWord.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            btWord.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Highlighted)
            btWord.backgroundColor = UIColor.darkGrayColor();
            //btWord.titleLabel?.font = UIFont.systemFontOfSize(20)
            btWord.addTarget(self, action: #selector(CatboardBanner.respondToAddWord(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            btWord.addTarget(self, action: #selector(CatboardBanner.respondToDownWord(_:)), forControlEvents: UIControlEvents.TouchDown)
            btWord.addTarget(self, action: #selector(CatboardBanner.respondToUpWord(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//            btWord.addTarget(self, action: #selector(CatboardBanner.respondToUpWord(_:)), forControlEvents: UIControlEvents.TouchUpOutside)
            btWord.addTarget(self, action: #selector(CatboardBanner.respondToDownWord(_:)), forControlEvents: UIControlEvents.TouchDragEnter)
            btWord.addTarget(self, action: #selector(CatboardBanner.respondToUpWord(_:)), forControlEvents: UIControlEvents.TouchDragExit)
            wordListView.addArrangedSubview(btWord)
            szContent.width = szContent.width + btWord.frame.size.width + 10
            i += 1
        }
        wordListView.anchorStackView(toView: scrview, anchorX: wordListView.centerXAnchor, equalAnchorX: wordListView.centerXAnchor, anchorY: wordListView.centerYAnchor, equalAnchorY: wordListView.centerYAnchor)
//        scrview.contentSize = szContent
        
//        for word in wordList {
//            iWord += 1
//            let btWord:UIButton = UIButton();
//            btWord.setTitle(word as? String, forState: UIControlState.Normal)
//            btWord.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
//            btWord.setTitleColor(UIColor.blueColor(), forState: UIControlState.Highlighted)
//            btWord.addTarget(self, action: #selector(CatboardBanner.respondToAddWord(_:)), forControlEvents: UIControlEvents.TouchUpInside)
//            wordListView.addArrangedSubview(btWord)
//            
//        }
        
//        if self.catSwitch.on {
//            self.catLabel.text = "😺"
//            self.catLabel.alpha = 1
//        }
//        else {
//            self.catLabel.text = "🐱"
//            self.catLabel.alpha = 0.5
//        }
        
//        self.catLabel.sizeToFit()
    }

}
