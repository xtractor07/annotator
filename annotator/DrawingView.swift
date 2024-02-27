//
//  DrawingView.swift
//  annotator
//
//  Created by Kumar Aman on 26/02/24.
//

import Foundation
import UIKit

struct Line {
    var points: [CGPoint]
    var color: UIColor
}

class DrawingView: UIView {
    var lines = [Line]()
    var redoLines = [Line]()
    var currentColor = UIColor.black
    var drawableImageFrame: CGRect = .zero
    var isDrag = false // Used to determine if the touch was a drag

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self), drawableImageFrame.contains(point) else { return }
        isDrag = false // Prepare for potential drag
        redoLines.removeAll()
        // Start a potential line; this will turn into a dot if no movement is detected
        lines.append(Line(points: [point], color: currentColor))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self), drawableImageFrame.contains(point) else { return }
        isDrag = true // Confirming it's a drag
        guard var lastLine = lines.popLast() else { return }
        lastLine.points.append(point)
        lines.append(lastLine)
        setNeedsDisplay()
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if there was any movement to determine if it's a drag or a tap (dot)
        if !isDrag && drawableImageFrame.contains(location) {
            // It's a tap, draw a dot.
            // Directly create a dot as a Line object with the same starting and ending point.
            let dot = Line(points: [location, location], color: currentColor)
            lines.append(dot)
        }
        
        // Reset the drag flag for the next interaction.
        isDrag = false
        setNeedsDisplay()
    }

    private func addPointToLastLine(_ point: CGPoint) {
        guard var lastLine = lines.popLast() else { return }
        lastLine.points.append(point)
        lines.append(lastLine)
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        lines.forEach { line in
            context.beginPath()
            context.setStrokeColor(line.color.cgColor)
            context.setFillColor(line.color.cgColor) // For filling dots
            context.setLineWidth(2)
            context.setLineCap(.round)
            
            if line.points.count == 2 && line.points[0] == line.points[1] {
                // It's a dot
                let dotOrigin = line.points[0]
                context.addArc(center: dotOrigin, radius: 2.5, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
                context.fillPath() // Fill the dot
            } else {
                // It's a line
                line.points.forEach { point in
                    if point == line.points.first {
                        context.move(to: point)
                    } else {
                        context.addLine(to: point)
                    }
                }
                context.strokePath()
            }
        }
    }

    
    func undo() {
        guard let lastLine = lines.popLast() else { return }
        redoLines.append(lastLine)
        setNeedsDisplay()
    }

    func redo() {
        guard let lineToRedo = redoLines.popLast() else { return }
        lines.append(lineToRedo)
        setNeedsDisplay()
    }
    
    // Renamed to setStrokeColor for clarity
    func setStrokeColor(_ color: UIColor) {
        currentColor = color
    }
    
    func clearDrawing() {
        lines.removeAll()
        redoLines.removeAll()
        setNeedsDisplay() // Redraw the view without any lines or dots
    }
}

