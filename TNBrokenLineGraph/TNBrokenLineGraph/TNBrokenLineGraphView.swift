//
//  TNBrokenLineGraphView.swift
//  TNBrokenLineGraph
//
//  Created by wwy on 16/3/30.
//  Copyright © 2016年 wwy. All rights reserved.
//

enum TNXCoordinateValueShowType: Int {
    case linearValue =  0 // x坐标值是均匀的
    case valuesShow // 根据数据,将值显示在x轴上
}


import UIKit

class TNBrokenLineGraphView: UIView {

    // 绘制线的模型
    var brokenLineModelArr: [TNBrokenLineGraphModel] = []
    
//    // x轴的坐标值间距
//    var _xValueSpace: CGFloat = 40.0
//    
    
    // x轴坐标的个数
    var xValueCount: Int = 3
    // y轴坐标的个数
    var yValueCount: Int = 10
    
    // x,y 最大坐标值
    var xMaxValue: CGFloat?
    var yMaxValue: CGFloat?
    
    //原点坐标
    var _zeroPoint: CGPoint!
    // 多余长度
    let _excessLength: CGFloat = 20.0
    var _xUnitValueLength: CGFloat!
    var _yUnitValueLength: CGFloat!
    
    
    // 储存图层,重绘时删除
    var _allLayerArr: [CAShapeLayer] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        self.xMaxValue = 100
        self.yMaxValue = 10_000
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - 重绘
    override func drawRect(rect: CGRect) {
        if xMaxValue == nil  {
            return
        }
        
        if yMaxValue == nil {
            return
        }
       

        // 绘制坐标系
        self.drawCoordinate()
        
        
        // 绘制折线
        self.drawBrokenLine()
        

    }
    
    
    
    
    //MARK: - 绘制坐标系
    func drawCoordinate() {
        
        // 视图高度
        let height = self.bounds.size.height
        let width = self.bounds.size.width
        
        // 设置边距
        let xSpace: CGFloat = 20.0
        var ySpace: CGFloat = 40.0 // 需要重新设置
        
        
        let markerLineFont = UIFont.systemFontOfSize(10)
        let markerLineAttr = [NSFontAttributeName: markerLineFont]
        
        let xValueFont = UIFont.systemFontOfSize(12)
        let xValueAttr = [NSFontAttributeName: xValueFont]
        
        // 防止y值显示不全,重新设置 ySpace
        let yMaxValueStr = NSString(format: "%.1f", yMaxValue!)
        let yMaxValueSize = yMaxValueStr.boundingRectWithSize(CGSize(width: CGFloat(MAXFLOAT) , height:  CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: xValueAttr, context: nil)
        ySpace = yMaxValueSize.width + 2
        
        
        // 获得原点坐标
        _zeroPoint = CGPointMake(ySpace, height - xSpace)
        // 绘制x轴和y轴
        // x轴
        UIGraphicsGetCurrentContext()
        let context = UIGraphicsGetCurrentContext()
        let xAxisPath = UIBezierPath()
        xAxisPath.moveToPoint(_zeroPoint)
        // x轴的终点坐标
        let xAxisMaxPoint = CGPointMake(width, height - xSpace)
        xAxisPath.addLineToPoint(xAxisMaxPoint)
        CGContextAddPath(context, xAxisPath.CGPath)
        
        print("x轴的终点坐标 \(xAxisMaxPoint)")
        // 绘制x箭头
        let arrowAngle = CGFloat(M_PI / 6.0)
        let arrowLong: CGFloat = 10.0
        let xArrowPath = UIBezierPath()
        xArrowPath.moveToPoint(CGPointMake(xAxisMaxPoint.x - cos(arrowAngle) * arrowLong, xAxisMaxPoint.y - sin(arrowAngle) * arrowLong))
        xArrowPath.addLineToPoint(xAxisMaxPoint)
        xArrowPath.addLineToPoint(CGPointMake(xAxisMaxPoint.x - cos(arrowAngle) * arrowLong, xAxisMaxPoint.y + sin(arrowAngle) * arrowLong))
        CGContextAddPath(context, xArrowPath.CGPath)
        
        
        // 绘制x分割线
        let xMarkerLine: NSString = "|"
        _xUnitValueLength = (width - _excessLength - _zeroPoint.x) / CGFloat(xMaxValue!) // 单位长度
        
        for index in 0 ... xValueCount {
            // 分割线
            // 值
            let value = ( xMaxValue! / CGFloat(xValueCount)) * CGFloat(index)
            // 坐标
            let x = _zeroPoint.x + _xUnitValueLength * value
            
            if index != 0 {
                xMarkerLine.drawAtPoint(CGPointMake(x - 1.5, height - 35), withAttributes: markerLineAttr)
            }
            
            let xValueStr = NSString(format: "%.1f", value)
            let xValueSize = xValueStr.boundingRectWithSize(CGSize(width: CGFloat(MAXFLOAT) , height:  CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: xValueAttr, context: nil)
            xValueStr.drawAtPoint(CGPoint(x: x - xValueSize.width / 2.0,y: height - xSpace + 2), withAttributes: xValueAttr)
            
        }
        
        
        // y轴
        let yAxisPath = UIBezierPath()
        yAxisPath.moveToPoint(_zeroPoint)
        //y轴的终点坐标
        let yAxisMaxPoint = CGPointMake(ySpace, 0)
        yAxisPath.addLineToPoint(yAxisMaxPoint)
        CGContextAddPath(context, yAxisPath.CGPath)
        
        // y箭头
        let yArrowPath = UIBezierPath()
        yArrowPath.moveToPoint(CGPointMake(ySpace - sin(arrowAngle) * arrowLong, cos(arrowAngle) * arrowLong))
        yArrowPath.addLineToPoint(CGPointMake(ySpace, 0))
        yArrowPath.addLineToPoint(CGPointMake(ySpace + sin(arrowAngle) * arrowLong, cos(arrowAngle) * arrowLong))
        CGContextAddPath(context, yArrowPath.CGPath)
        
        CGContextSetLineWidth(context, 1.0)
        CGContextStrokePath(context)
        
        // y分割线
        let yMarkLine: NSString = "—"
        _yUnitValueLength = (_zeroPoint.y - _excessLength) / yMaxValue!
        for index in 0 ... yValueCount  {
            // 分割线
            if index != 0 {
                
                let value = ( yMaxValue! / CGFloat(yValueCount)) * CGFloat(index)
                let y = _zeroPoint.y - _yUnitValueLength * value
               
                print(y - _excessLength)
                // 值
                let yValueStr = NSString(format: "%.1f",value)
                let yValueSize = yValueStr.boundingRectWithSize(CGSize(width: CGFloat(MAXFLOAT) , height:  CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: xValueAttr, context: nil)
                yValueStr.drawAtPoint(CGPoint(x: ySpace - yValueSize.width - 2,y: y - yValueSize.height / 2.0), withAttributes: xValueAttr)
                
                 yMarkLine.drawAtPoint(CGPointMake(ySpace + 3 ,y - yValueSize.height / 2.0), withAttributes: markerLineAttr)
                
            }
            
        }
        
    }
    
    
    func drawBrokenLine() {
        
        // 清除绘制的轨迹线
        UIColor.clearColor().set()
        
        // 移除以前的折线
        if _allLayerArr.count > 0 {
            for anylayer in _allLayerArr {
                anylayer.removeFromSuperlayer()
            }
        }
        
        
        // 绘制折线
        for lineModel in self.brokenLineModelArr {
            
            // 获得路径
            let funcLinePath = UIBezierPath()
            let firstPoint = self.getPointFromeValues(lineModel.valueArr![0])
            funcLinePath.moveToPoint(firstPoint)
            funcLinePath.lineCapStyle = .Round
            funcLinePath.lineJoinStyle = .Round
            var index: Int = 0
            for pointValue in lineModel.valueArr! {
                if index != 0 {
                    let point = self.getPointFromeValues(pointValue)
                    funcLinePath.addLineToPoint(point)
                    funcLinePath.moveToPoint(point)
                    funcLinePath.stroke()
                }
                index =  index + 1
            }
            
           
            
            //创建CAShapLayer
            let lineLayer = self.setUpLineLayer(lineModel.lineColor!, width: CGFloat(lineModel.width!))
            lineLayer.path = funcLinePath.CGPath
            
            let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
            pathAnimation.duration = 3.0
            pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            pathAnimation.fromValue = 0.0
            pathAnimation.toValue = 1.0
            pathAnimation.autoreverses = false
            lineLayer.addAnimation(pathAnimation, forKey: "lineLayerAnimation-\(index)")
            lineLayer.strokeEnd = 1.0
            self.layer.addSublayer(lineLayer)
            _allLayerArr.append(lineLayer)
            
        }
        
        
        

    }
    
    
    
    
    func setUpLineLayer(color: UIColor,width: CGFloat) ->CAShapeLayer{
        
        let lineLayer = CAShapeLayer()
        lineLayer.lineCap = kCALineCapRound
        lineLayer.lineJoin = kCALineJoinBevel // 斜角
        lineLayer.strokeEnd = 1
        lineLayer.strokeColor = color.CGColor
        lineLayer.lineWidth = width
        return lineLayer
        
    }
    
    
    //MARK: - 根据值,获得坐标
    func getPointFromeValues(xyValue: CGPoint) -> CGPoint {
        let x = xyValue.x * _xUnitValueLength + _zeroPoint.x
        let y = _zeroPoint.y - (xyValue.y * _yUnitValueLength)
        let point = CGPoint(x: x, y: y)
       
        return point
    }
    

    
    
    
    

}
