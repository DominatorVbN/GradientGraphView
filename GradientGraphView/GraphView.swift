//
//  GraphView.swift
//  Flo
//
//  Created by mac on 24/10/18.
//  Copyright © 2018 Dominator. All rights reserved.
//

import UIKit
//Weekly sample data

@IBDesignable public class GraphView: UIView {
    private struct Constants {
        static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
        static let margin: CGFloat = 20.0
        static let topBorder: CGFloat = 60
        static let bottomBorder: CGFloat = 50
        static let colorAlpha: CGFloat = 0.3
        static let circleDiameter: CGFloat = 5.0
    }
    public var graphPoints = [400, 210, 600, 400, 500, 800, 3]
    public var measureindicators : [String] = ["s","m","t","w","t","f","s"]
    // 1
    @IBInspectable public var startColor: UIColor = .red
    @IBInspectable public var endColor: UIColor = .green
    @IBInspectable public var graphTitle : String = "Title"
    @IBInspectable public var titleShadowcolor : UIColor = .clear
    @IBInspectable public var averageShadowcolor : UIColor = .clear
    public var averageValue: Double  {
       return Double(round(100*graphPoints.average)/100)
    }
    public var titleLabel = UILabel()
    public var averageTextLabel = UILabel()
    public var averageValueLabel = UILabel()
    public var maxPointLabel = UILabel()
    public var minPointLabel = UILabel()
    public var numberLineStackView = UIStackView()
    
    public override init(frame:CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height

        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: .allCorners,
                                cornerRadii: Constants.cornerRadiusSize)
        path.addClip()

        // 2
        let context = UIGraphicsGetCurrentContext()!
        let colors = [startColor.cgColor, endColor.cgColor]
        
        // 3
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 4
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        // 5
        let gradient = CGGradient(colorsSpace: colorSpace,
                                  colors: colors as CFArray,
                                  locations: colorLocations)!
        
        // 6
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0, y: bounds.height)
        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: [])
        
        //calculate the x point
        
        let margin = Constants.margin
        let graphWidth = width - margin * 2 - 4
        let columnXPoint = { (column: Int) -> CGFloat in
            //Calculate the gap between points
            let spacing = graphWidth / CGFloat(self.graphPoints.count - 1)
            return CGFloat(column) * spacing + margin + 2
        }
        // calculate the y point
        
        let topBorder = Constants.topBorder
        let bottomBorder = Constants.bottomBorder
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = graphPoints.max()!
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
            let y = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
            return graphHeight + topBorder - y // Flip the graph
        }
        // draw the line graph
        
        UIColor.white.setFill()
        UIColor.white.setStroke()
        
        // set up the points line
        let graphPath = UIBezierPath()
        
        // go to start of line
        graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(graphPoints[0])))
        
        // add points for each item in the graphPoints array
        // at the correct (x, y) for the point
        for i in 1..<graphPoints.count {
            let nextPoint = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
            graphPath.addLine(to: nextPoint)
        }
        //Create the clipping path for the graph gradient
        
        //1 - save the state of the context (commented out for now)
        context.saveGState()
        
        //2 - make a copy of the path
        let clippingPath = graphPath.copy() as! UIBezierPath
        
        //3 - add lines to the copied path to complete the clip area
        clippingPath.addLine(to: CGPoint(x: columnXPoint(graphPoints.count - 1), y:height))
        clippingPath.addLine(to: CGPoint(x:columnXPoint(0), y:height))
        clippingPath.close()
        
        //4 - add the clipping path to the context
        clippingPath.addClip()
        
        let highestYPoint = columnYPoint(maxValue)
        let graphStartPoint = CGPoint(x: margin, y: highestYPoint)
        let graphEndPoint = CGPoint(x: margin, y: bounds.height)
        
        context.drawLinearGradient(gradient, start: graphStartPoint, end: graphEndPoint, options: [])
        context.restoreGState()
        //draw the line on top of the clipped gradient
        graphPath.lineWidth = 2.0
        graphPath.stroke()
        //Draw the circles on top of the graph stroke
        for i in 0..<graphPoints.count {
            var point = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
            point.x -= Constants.circleDiameter / 2
            point.y -= Constants.circleDiameter / 2
            
            let circle = UIBezierPath(ovalIn: CGRect(origin: point, size: CGSize(width: Constants.circleDiameter, height: Constants.circleDiameter)))
            circle.fill()
        }
        //Draw horizontal graph lines on the top of everything
        let linePath = UIBezierPath()
        
        //top line
        linePath.move(to: CGPoint(x: margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: topBorder))
        
        //center line
        linePath.move(to: CGPoint(x: margin, y: graphHeight/2 + topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: graphHeight/2 + topBorder))
        
        //bottom line
        linePath.move(to: CGPoint(x: margin, y:height - bottomBorder))
        linePath.addLine(to: CGPoint(x:  width - margin, y: height - bottomBorder))
        let color = UIColor(white: 1.0, alpha: Constants.colorAlpha)
        color.setStroke()
        
        linePath.lineWidth = 1.0
        linePath.stroke()
        //set up title label
        titleLabel.frame = CGRect(x: 5, y: 5, width: 100, height: UIFont.systemFontSize + 2)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        titleLabel.text = graphTitle
        titleLabel.font = UIFont(name: "AvenirNextCondensed-Medium", size: UIFont.systemFontSize)
        titleLabel.shadowColor = titleShadowcolor
        titleLabel.shadowOffset = CGSize(width: 3, height: 3)
        addSubview(titleLabel)
        
        //set up average label
        averageTextLabel.frame = CGRect(x: 5, y: titleLabel.bounds.maxY + 5 , width:50, height: UIFont.systemFontSize + 2)
        averageTextLabel.textAlignment = .left
        averageTextLabel.textColor = .white
        averageTextLabel.text = "Average : "
        averageTextLabel.font = UIFont(name: "AvenirNextCondensed-Medium", size: UIFont.systemFontSize)
        averageTextLabel.shadowColor = averageShadowcolor
        averageTextLabel.shadowOffset = CGSize(width: 3, height: 3)
        addSubview(averageTextLabel)
        
        //set up average value label
        averageValueLabel.frame = CGRect(x: averageTextLabel.bounds.maxX + 5, y: titleLabel.bounds.maxY + 5 , width: 100, height: UIFont.systemFontSize + 2)
        averageValueLabel.textAlignment = .left
        averageValueLabel.textColor = .white
        averageValueLabel.text = "\(averageValue)"
        averageValueLabel.font = UIFont(name: "AvenirNextCondensed-Medium", size: UIFont.systemFontSize)
        averageValueLabel.shadowColor = averageShadowcolor
        averageValueLabel.shadowOffset = CGSize(width: 3, height: 3)
        addSubview(averageValueLabel)
        
        //set up max label
        maxPointLabel.frame = CGRect(x:  width - margin - 15 , y: topBorder - (UIFont.systemFontSize + 2) , width: 50, height: UIFont.systemFontSize + 2)
        maxPointLabel.textAlignment = .left
        maxPointLabel.textColor = .white
        maxPointLabel.text = "\(maxValue)"
        maxPointLabel.font = UIFont(name: "AvenirNextCondensed-Medium", size: UIFont.systemFontSize)
        maxPointLabel.shadowColor = averageShadowcolor
        maxPointLabel.shadowOffset = CGSize(width: 3, height: 3)
        addSubview(maxPointLabel)
    
        minPointLabel.frame = CGRect(x:  width - margin + 5 , y: (height - bottomBorder) - (UIFont.systemFontSize + 2)/2 , width: 50, height: UIFont.systemFontSize + 2)
        minPointLabel.textAlignment = .left
        minPointLabel.textColor = .white
        minPointLabel.text = "\(0)"
        minPointLabel.font = UIFont(name: "AvenirNextCondensed-Medium", size: UIFont.systemFontSize)
        minPointLabel.shadowColor = averageShadowcolor
        minPointLabel.shadowOffset = CGSize(width: 3, height: 3)
        addSubview(minPointLabel)
        
        //set up stackView
        numberLineStackView.frame = CGRect(x: margin, y: (height - bottomBorder) +  10, width: self.bounds.width - (2  * margin), height: (UIFont.systemFontSize + 2))
        numberLineStackView.alignment = .center
        numberLineStackView.distribution = .equalSpacing
        numberLineStackView.spacing = 8
        for i in measureindicators{
            let lab = UILabel()
            lab.textColor = .white
            lab.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            lab.text = i
            numberLineStackView.addArrangedSubview(lab)
        }
        
        addSubview(numberLineStackView)
    }
}
extension Collection where Element: BinaryInteger {
    /// Returns the average of all elements in the array
    var average: Double {
        return isEmpty ? 0 : Double(Int(total)) / Double(count)
    }
}
extension Collection where Element: Numeric {
    /// Returns the total sum of all elements in the array
    var total: Element { return reduce(0, +) }
}

