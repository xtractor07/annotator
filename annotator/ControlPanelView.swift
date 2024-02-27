//
//  ControlPanelView.swift
//  annotator
//
//  Created by Kumar Aman on 26/02/24.
//

import Foundation
import UIKit

class ControlPanelView: UIView {
    // Define buttons
    let undoButton = UIButton(type: .system)
    let redoButton = UIButton(type: .system)
    let colorPickerButton = UIButton(type: .system) // Using button to represent color picker
    let saveButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        // Setup buttons with system images
        undoButton.setImage(UIImage(systemName: "arrow.uturn.backward"), for: .normal)
        redoButton.setImage(UIImage(systemName: "arrow.uturn.forward"), for: .normal)
        colorPickerButton.setImage(UIImage(systemName: "paintbrush"), for: .normal)
        saveButton.setImage(UIImage(systemName: "square.and.arrow.down"), for: .normal)
        
        // Create a stack view for the buttons
        let stackView = UIStackView(arrangedSubviews: [undoButton, redoButton, colorPickerButton, saveButton])
        stackView.distribution = .fill
        stackView.alignment = .trailing // Align items to the trailing edge (right side)
        stackView.spacing = 14 // Standard minimal gap between buttons
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        // Optionally, add a spacer view to push buttons to the right
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.insertArrangedSubview(spacerView, at: 0) // Add spacer to the beginning of the stack
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8) // Add trailing constraint with standard gap
        ])
    }
}

