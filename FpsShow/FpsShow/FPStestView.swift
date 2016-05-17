//
//  FPStestView.swift
//  FpsShow
//
//  Created by Tangguo on 16/5/17.
//  Copyright © 2016年 何月. All rights reserved.
//

import UIKit

let SCREENWIDTH = UIScreen.mainScreen().bounds.size.width
let SCREENHEIGHT = UIScreen.mainScreen().bounds.size.height

class FPStestView: UIWindow {

    
    var _fpsLable:UILabel!
    var _disp:CADisplayLink!
    
    var _frames:Int!
    var _timeStamp:CFAbsoluteTime!
    
    //单例
    class var shareInstance: FPStestView {
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var staticInstance : FPStestView? = nil
        }
        dispatch_once(&Static.onceToken) {
            
            Static.staticInstance = FPStestView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        }
        
        return Static.staticInstance!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.windowLevel = UIWindowLevelAlert + 1;
        self.backgroundColor = UIColor.orangeColor()
        self.hidden = false
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.size.width/2
        
        _frames = 0
        _timeStamp = 0
        
        _fpsLable = UILabel()
        _fpsLable.frame = self.bounds
        _fpsLable.textColor = UIColor.whiteColor()
        _fpsLable.textAlignment = .Center
        _fpsLable.font = UIFont.systemFontOfSize(12)
        self.addSubview(_fpsLable)
        
        /*CADisplayLink 默认每秒运行60次，将它的frameInterval属性设置为2，意味CADisplayLink每隔一帧运行一次，有效的使游戏逻辑每秒运行30次*/
        
        _disp = CADisplayLink(target: self, selector: #selector(runFPS(_:)))
        //_disp.frameInterval = 2 //每秒运行帧数
        _disp.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSRunLoopCommonModes)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(fpsViewPan(_:)))
        self.addGestureRecognizer(pan)
        
        
    }
    
    func runFPS(disp:CADisplayLink) {
        
        let now = CFAbsoluteTimeGetCurrent();
        if ( (now - _timeStamp) > 0.5 ) {
            
            let val = 1.0 * CGFloat(disp.frameInterval) * CGFloat(_frames) / CGFloat(( now - _timeStamp ))
            
            _fpsLable.text = "\((Int(val)))"
            
            _timeStamp = now
            _frames = 0
            
        }else {
            
            _frames = _frames + 1
        }
    }
    
    func fpsViewPan(recognizer:UIPanGestureRecognizer) {
        
        let point = recognizer.translationInView(UIApplication.sharedApplication().keyWindow)
        
        if recognizer.state == .Began {
            self.superview?.bringSubviewToFront(self)
        }
        
        var selfFrame = self.frame
        selfFrame.origin.x += point.x
        selfFrame.origin.y += point.y
        
        selfFrame.origin.x = min(selfFrame.origin.x,SCREENWIDTH - self.frame.size.width)
        selfFrame.origin.x = max(selfFrame.origin.x,0)
        selfFrame.origin.y = min(selfFrame.origin.y,SCREENHEIGHT - self.frame.size.height)
        selfFrame.origin.y = max(selfFrame.origin.y,0)
        
        self.frame = selfFrame
        
        recognizer.setTranslation(CGPointZero, inView: UIApplication.sharedApplication().keyWindow)
        
        if recognizer.state == .Ended {
            
            checkMyFrame()
        }
    }
    
    //检测帧数
    func checkMyFrame() {
        
        var selfFrame = self.frame
        
        if selfFrame.origin.x < SCREENWIDTH/2 {
            
            selfFrame.origin.x = 0
        }else {
            selfFrame.origin.x = SCREENWIDTH - selfFrame.size.width
        }
        
        UIView.animateWithDuration(0.4,
                                   delay: 0,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 1,
                                   options: .BeginFromCurrentState,
                                   animations: {
                                    self.frame = selfFrame
        }) { (finished) in
        }
        
    }


}
