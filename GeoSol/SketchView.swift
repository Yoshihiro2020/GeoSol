//
//  SketchView.swift
//  GeoSol
//
//  Created by TOMA on 2018/10/18.
//

import UIKit

protocol SketchTool {
    var lineWidth: CGFloat { get set }
    var lineColor: UIColor { get set }
    var lineAlpha: CGFloat { get set }
    
    func setInitialPoint(_ firstPoint: CGPoint)
    func moveFromPoint(_ startPoint: CGPoint, toPoint endPoint: CGPoint)
    func draw()
}

class PenTool: UIBezierPath, SketchTool {
    var path: CGMutablePath
    var lineColor: UIColor
    var lineAlpha: CGFloat
    
    override init() {
        path = CGMutablePath.init()
        lineColor = .black
        lineAlpha = 0
        super.init()
        lineCapStyle = CGLineCap.round
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setInitialPoint(_ firstPoint: CGPoint) {}
    
    func moveFromPoint(_ startPoint: CGPoint, toPoint endPoint: CGPoint) {}
    
    func createBezierRenderingBox(_ previousPoint2: CGPoint, widhPreviousPoint previousPoint1: CGPoint, withCurrentPoint cpoint: CGPoint) -> CGRect {
        let mid1 = middlePoint(previousPoint1, previousPoint2: previousPoint2)
        let mid2 = middlePoint(cpoint, previousPoint2: previousPoint1)
        let subpath = CGMutablePath.init()
        
        subpath.move(to: CGPoint(x: mid1.x, y: mid1.y))
        subpath.addQuadCurve(to: CGPoint(x: mid2.x, y: mid2.y), control: CGPoint(x: previousPoint1.x, y: previousPoint1.y))
        path.addPath(subpath)
        
        var boundingBox: CGRect = subpath.boundingBox
        boundingBox.origin.x -= lineWidth * 2.0
        boundingBox.origin.y -= lineWidth * 2.0
        boundingBox.size.width += lineWidth * 4.0
        boundingBox.size.height += lineWidth * 4.0
        
        return boundingBox
    }
    
    private func middlePoint(_ previousPoint1: CGPoint, previousPoint2: CGPoint) -> CGPoint {
        return CGPoint(x: (previousPoint1.x + previousPoint2.x) * 0.5, y: (previousPoint1.y + previousPoint2.y) * 0.5)
    }
    
    func draw() {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.addPath(path)
        context.setLineCap(.round)
        context.setLineWidth(lineWidth)
        context.setStrokeColor(lineColor.cgColor)
        context.setBlendMode(.normal)
        context.setAlpha(lineAlpha)
        context.strokePath()
    }
}

class EraserTool: PenTool {
    override func draw() {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        context.addPath(path)
        context.setLineCap(.round)
        context.setLineWidth(lineWidth)
        context.setBlendMode(.clear)
        context.strokePath()
        context.restoreGState()
    }
}

class TouchPoint {
    var timestamp: TimeInterval
    var location: CGPoint
    var force: CGFloat
    var altitudeAngle: CGFloat
    var azimuthAngle: CGFloat
    
    init(touch: UITouch, view: UIView){
        self.timestamp = touch.timestamp
        self.location = touch.location(in: view)
        self.force = touch.force
        self.altitudeAngle = touch.altitudeAngle
        self.azimuthAngle = touch.azimuthAngle(in: view)
    }
}

enum SketchToolType {
    case pen
    case eraser
}

enum ImageRenderingMode {
    case scale
    case original
}

class SketchView: UIView {
    public var lineColor = UIColor.black
    public var lineWidth = CGFloat(2)
    public var lineAlpha = CGFloat(1)
    public var stampImage: UIImage?
    public var drawTool: SketchToolType = .pen
    private var currentTool: SketchTool?
    private let pathArray: NSMutableArray = NSMutableArray()
    private let bufferArray: NSMutableArray = NSMutableArray()
    private var currentPoint: CGPoint?
    private var previousPoint1: CGPoint?
    private var previousPoint2: CGPoint?
    private var image: UIImage?
    private var backgroundImage: UIImage?
    private var drawMode: ImageRenderingMode = .original
    
    var stroke = [TouchPoint]()
    public var strokes = [[TouchPoint]]()
    public var states = [String]() //"exist" or "erased"
    var strokeNum = 0
    var connect = [Int]()  //has index as pathNum and element as strokeNum
    let documentDirectoryFileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    
    var timenow: TimeInterval?
    
    var inShapDraw = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepareForInitial()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        prepareForInitial()
    }
    
    private func saveImage (image: UIImage, fileName: String ) {
        //pngで保存する場合
        let pngImageData = image.pngData()
        // jpgで保存する場合
        //    let jpgImageData = UIImageJPEGRepresentation(image, 1.0)
        let fileURL = documentDirectoryFileURL.appendingPathComponent(fileName)
        do {
            try pngImageData!.write(to: fileURL)
        } catch {
            //エラー処理
        }
    }
    
    private func prepareForInitial() {
        backgroundColor = UIColor.clear
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        switch drawMode {
        case .original:
            image?.draw(at: CGPoint.zero)
            break
        case .scale:
            image?.draw(in: self.bounds)
            break
        }
        
        currentTool?.draw()
    }
    
    private func updateCacheImage(_ isUpdate: Bool) {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        
        if isUpdate {
            image = nil
            switch drawMode {
            case .original:
                if let backgroundImage = backgroundImage  {
                    (backgroundImage.copy() as! UIImage).draw(at: CGPoint.zero)
                }
                break
            case .scale:
                (backgroundImage?.copy() as! UIImage).draw(in: self.bounds)
                break
            }
            
            for obj in pathArray {
                if let tool = obj as? SketchTool {
                    tool.draw()
                }
            }
        } else {
            image?.draw(at: .zero)
            currentTool?.draw()
        }
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    private func toolWithCurrentSettings() -> SketchTool? {
        switch drawTool {
        case .pen:
            return PenTool()
        case .eraser:
            return EraserTool()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if touch.type == .stylus{
            if drawTool == SketchToolType.eraser{
                let tpX = touch.location(in: self).x
                let tpY = touch.location(in: self).y
                let minX = tpX - 5
                let maxX = tpX + 5
                let minY = tpY - 5
                let maxY = tpY + 5
                for (i,n) in connect.enumerated() {
                    let stk = strokes[n]
                    for point in stk {
                        let pointXY = (point.location.x, point.location.y)
                        switch pointXY {
                        case (minX...maxX, minY...maxY):
                            erase(pathNum: i)
                            states[n] = "erased"
                            connect.remove(at: i)
                            //1ストロークごとのスクリーンショット取得
                            if tpX > 50 && tpX < 980 && tpY > 0 && tpY < 490 {
                                let rect = self.bounds
                                // ビットマップ画像のcontextを作成.
                                UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
                                let context: CGContext = UIGraphicsGetCurrentContext()!
                                
                                // 対象のview内の描画をcontextに複写する.
                                self.layer.render(in: context)
                                
                                // 現在のcontextのビットマップをUIImageとして取得.
                                let capturedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                                 
                                // contextを閉じる.
                                UIGraphicsEndImageContext()
                                timenow = Date().timeIntervalSince1970
                                let fileName1 = "time" + String(Int(timenow!)) + "_stroke" + String(strokeNum) + "_erased_2022.png"
                                self.saveImage(image: capturedImage, fileName: fileName1)
                                UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil)
                            }
                            return
                        default:
                            break
                        }
                    }
                }
            } else {
                stroke = []
                if drawTool == .pen {
                    states.append("exist")
                }
                
                for point in touches{
                    let touchPoint = TouchPoint(touch: point, view: self)
                    stroke.append(touchPoint)
                }
                //図形書き込み判定
                if touch.location(in: self).x > 51 && touch.location(in: self).y < 490 && touch.location(in: self).x < 980 && touch.location(in: self).y > 0 {
                    inShapDraw = true
                }
                
                
                previousPoint1 = touch.previousLocation(in: self)
                currentPoint = touch.location(in: self)
                currentTool = toolWithCurrentSettings()
                currentTool?.lineWidth = lineWidth
                currentTool?.lineColor = lineColor
                currentTool?.lineAlpha = lineAlpha
                
                guard let penTool = currentTool as? PenTool else { return }
                pathArray.add(penTool)
                penTool.setInitialPoint(currentPoint!)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if touch.type == .stylus && drawTool == SketchToolType.pen {
            for point in touches{
                stroke.append(TouchPoint(touch: point, view: self))
            }
            //図形書き込み判定
            if inShapDraw == true && touch.location(in: self).x > 51 && touch.location(in: self).y < 490 && touch.location(in: self).x < 980 && touch.location(in: self).y > 0 {
                inShapDraw = true
            }else{
                inShapDraw = false
            }
            
            previousPoint2 = previousPoint1
            previousPoint1 = touch.previousLocation(in: self)
            currentPoint = touch.location(in: self)
            
            if let penTool = currentTool as? PenTool {
                let renderingBox = penTool.createBezierRenderingBox(previousPoint2!, widhPreviousPoint: previousPoint1!, withCurrentPoint: currentPoint!)
                
                setNeedsDisplay(renderingBox)
            } else {
                currentTool?.moveFromPoint(previousPoint1!, toPoint: currentPoint!)
                setNeedsDisplay()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.type == .stylus && drawTool == SketchToolType.pen{
            strokes.append(stroke)
            connect.append(strokeNum)
            strokeNum += 1
            
            //1ストロークごとのスクリーンショット追加
            if inShapDraw == true{
                let rect = self.bounds
                // ビットマップ画像のcontextを作成.
                UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
                let context: CGContext = UIGraphicsGetCurrentContext()!
                
                // 対象のview内の描画をcontextに複写する.
                self.layer.render(in: context)
                
                // 現在のcontextのビットマップをUIImageとして取得.
                let capturedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
                 
                // contextを閉じる.
                UIGraphicsEndImageContext()
                timenow = Date().timeIntervalSince1970
                let fileName1 = "time" + String(Int(timenow!)) + "_stroke" + String(strokeNum) + "_exist_2022.png"
                self.saveImage(image: capturedImage, fileName: fileName1)
                UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil)
            }
            
            finishDrawing()
            inShapDraw = false
            
        }
    }
        
    fileprivate func finishDrawing() {
        updateCacheImage(false)
        bufferArray.removeAllObjects()
        currentTool = nil
    }
    
    private func resetTool() {
        currentTool = nil
    }
    
    public func clear() {
        resetTool()
        bufferArray.removeAllObjects()
        pathArray.removeAllObjects()
        strokeNum = 0
        strokes.removeAll()
        states.removeAll()
        connect.removeAll()
        updateCacheImage(true)
        setNeedsDisplay()
    }
    
    func erase(pathNum: Int) {
        guard let tool = pathArray[pathNum] as? SketchTool else { return }
        resetTool()
        bufferArray.add(tool)
        pathArray.removeObject(at: pathNum)
        updateCacheImage(true)
        
        setNeedsDisplay()
    }
    
    public func undo() {
        if canUndo() {
            guard let tool = pathArray.lastObject as? SketchTool else { return }
            resetTool()
            bufferArray.add(tool)
            pathArray.removeLastObject()
            updateCacheImage(true)
            
            setNeedsDisplay()
        }
    }
    
    public func redo() {
        if canRedo() {
            guard let tool = bufferArray.lastObject as? SketchTool else { return }
            resetTool()
            pathArray.add(tool)
            bufferArray.removeLastObject()
            updateCacheImage(true)
            
            setNeedsDisplay()
        }
    }
    
    func canUndo() -> Bool {
        return pathArray.count > 0
    }
    
    func canRedo() -> Bool {
        return bufferArray.count > 0
    }
}
