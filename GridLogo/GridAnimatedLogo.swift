//
//  GridAnimatedLogo.swift
//  GridLogo
//
//  Created by Nicholas Velloff on 6/27/15.
//  Copyright (c) 2015 Rituwall, Inc. All rights reserved.
//

import UIKit

public class AnimatedGridLogo: UIView {
    
    var mystic: CGFloat = 4
    var turns = 9
    var xstep = [1,0,-1,0]
    var ystep = [0,1,0,-1]
    
    var md: CGFloat!
    var strokeRatio: CGFloat!
    var last: CGPoint!
    var curr: CGPoint!
    var scalestep: CGFloat!
    
    weak var bgLayer: CAShapeLayer?
    weak var fgLayer: CAShapeLayer?
    var pathAnimationIn: CABasicAnimation!
    var pathAnimationOut: CABasicAnimation!
    var pathAnimationGroup: CAAnimationGroup!
    
    private var duration: CFTimeInterval = 5.0
    private var startPos: CGFloat = 0.0
    private var endPos: CGFloat = 1.0
    private var reverses = false
    private var repeatCount: Float = 14.5
    private var lineWidth: CGFloat?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    public convenience init(mystic: CGFloat, duration: CFTimeInterval, lineWidth: CGFloat?) {
        self.init(frame: CGRectZero)
        self.mystic = mystic
        self.duration = duration
        self.repeatCount = 1
        self.reverses = false
        self.lineWidth = lineWidth
        setup()
    }
    
    public convenience init(mystic: CGFloat, lineWidth: CGFloat?) {
        self.init(frame: CGRectZero)
        self.mystic = mystic
        self.lineWidth = lineWidth
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    func setup() {
        self.alpha = 0
        self.md = CGFloat(mystic * mystic)
        self.strokeRatio = CGFloat(md) / CGFloat(mystic)
        self.userInteractionEnabled = false
        addBackground()
        setupAnimation()
    }
    
    var logoPath: UIBezierPath {
        get{
            self.curr = CGPoint.zero
            self.last = CGPoint.zero
            let path = UIBezierPath()
            path.moveToPoint(curr)
            
            for var i=0; i < turns; i++ {
                scalestep = round((CGFloat(i) + 1) / 2.0) * CGFloat(md)
                curr = CGPoint(x: CGFloat(last.x) + (scalestep * CGFloat(xstep[i % 4])), y: CGFloat(last.y) + (scalestep * CGFloat(ystep[i % 4]))).toInt()
                
                if i + 1 == turns {
                    curr = CGPoint(x: CGFloat(curr.x) - (md * CGFloat(xstep[i % 4])), y: CGFloat(curr.y) - (md * CGFloat(ystep[i % 4]))).toInt()
                }
                
                path.addLineToPoint(curr)
                last  = curr
            }
            return path
        }
    }
    
    func setupAnimation() {
        if fgLayer == nil {
            
            let foreground = shapeLayerWithLogoPath(UIColor(red: 1, green: 246/255, blue: 153/255, alpha: 1), lineJoin: kCALineJoinMiter)
            self.fgLayer = foreground
            self.layer.addSublayer(foreground)
        }
        pathAnimationIn = CABasicAnimation(keyPath: "strokeEnd")
        pathAnimationIn.fromValue = self.startPos
        pathAnimationIn.toValue = self.endPos
        pathAnimationIn.duration = self.duration / 2
        pathAnimationIn.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        pathAnimationOut = CABasicAnimation(keyPath: "strokeStart")
        pathAnimationOut.fromValue = self.startPos
        pathAnimationOut.toValue = self.endPos
        pathAnimationOut.duration = self.duration / 2
        pathAnimationOut.beginTime = self.duration / 2
        pathAnimationOut.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        pathAnimationGroup = CAAnimationGroup()
        pathAnimationGroup.animations = [pathAnimationIn, pathAnimationOut]
        pathAnimationGroup.duration = self.duration
        pathAnimationGroup.repeatCount = self.repeatCount
        pathAnimationGroup.removedOnCompletion = false
        pathAnimationGroup.fillMode = kCAFillModeBackwards
    }
    
    public func show(completionHandler: (() -> Void)? = nil) {
        UIView.animateWithDuration(0.5, animations: {
            self.alpha = 1
            self.startAnimation()
        }, completion: { _ in
            completionHandler?()
        })
    }
    
    public func hide(completionHandler: (() -> Void)? = nil) {
        UIView.animateWithDuration(0.5, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.endAnimation()
            completionHandler?()
        })
    }
    
    func startAnimation() {
        self.fgLayer?.removeAllAnimations()
        self.fgLayer?.addAnimation(pathAnimationGroup, forKey: "group")
    }
    
    func endAnimation() {
        self.fgLayer?.removeAllAnimations()
    }
    
    func shapeLayerWithLogoPath(strokeColor: UIColor, lineJoin: String) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = logoPath.CGPath
        shapeLayer.strokeColor = strokeColor.CGColor
        shapeLayer.fillColor = nil
        if lineWidth == nil {
            shapeLayer.lineWidth = self.strokeRatio
        } else {
            shapeLayer.lineWidth = self.lineWidth!
        }
        shapeLayer.lineJoin = lineJoin
        return shapeLayer
    }
    
    func addBackground() {
        if bgLayer == nil {
            let background = shapeLayerWithLogoPath(UIColor(red: 51/255, green: 51/255, blue: 48/255, alpha: 1), lineJoin: kCALineJoinMiter)
            self.bgLayer = background
            self.layer.addSublayer(background)
        }
    }
    
    override public func needsUpdateConstraints() -> Bool {
        return true
    }
    
}