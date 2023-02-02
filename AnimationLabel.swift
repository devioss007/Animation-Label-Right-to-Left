import UIKit

final class AnimationLabel: UILabel {
    
    // MARK: UI Components
    
    private let containerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 300)
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.01
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
        return label
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textColor = .clear
        return label
    }()
    
    // MARK: Properties
    
    private let textForLabel: String
    
    // MARK: Init
    
    init(with text: String) {
        textForLabel = text
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        containerLabel.text = text.replacingOccurrences(of: " ", with: "o")
        
        makeContainerLabelView(subView: containerLabel, superView: self)
        
        makeResultLabelView(subView: resultLabel, superView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI methods
    
    private func makeResultLabelView(subView: UILabel, superView: UILabel) {
        superView.addSubview(resultLabel)
        let conX = subView.centerYAnchor.constraint(equalTo: superView.centerYAnchor)
        let conY = subView.centerXAnchor.constraint(equalTo: superView.centerXAnchor)
        NSLayoutConstraint.activate([conX, conY])
    }
    
    private func makeContainerLabelView(subView: UILabel, superView: UILabel) {
        superView.addSubview(containerLabel)
        let conLeading = subView.leadingAnchor.constraint(equalTo: superView.leadingAnchor)
        let conTrailing = subView.trailingAnchor.constraint(equalTo: superView.trailingAnchor)
        let conTop = subView.topAnchor.constraint(equalTo: superView.topAnchor)
        let conBottom = subView.bottomAnchor.constraint(equalTo: superView.bottomAnchor)
        NSLayoutConstraint.activate([conLeading, conTrailing, conTop, conBottom])
    }
    
    // MARK: Life Cycle Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFontSize()
    }
    
    // MARK: Private Functions
    
    private func updateFontSize() {
        let fontsize = getFontSizeForLabel(containerLabel)
        
        resultLabel.text = textForLabel
        resultLabel.font = UIFont.boldSystemFont(ofSize: fontsize)
        
        resultLabel.subviews.forEach { item in
            guard let label = item as? UILabel else { return }
            label.font = resultLabel.font
        }
    }
    
    private func getFontSizeForLabel(_ label: UILabel) -> CGFloat {
        let text: NSMutableAttributedString = NSMutableAttributedString(attributedString: label.attributedText!)
        text.setAttributes([NSAttributedString.Key.font: label.font as Any], range: NSMakeRange(0, text.length))
        let context: NSStringDrawingContext = NSStringDrawingContext()
        context.minimumScaleFactor = label.minimumScaleFactor
        text.boundingRect(with: label.frame.size, options: NSStringDrawingOptions.usesLineFragmentOrigin, context: context)
        let adjustedFontSize: CGFloat = label.font.pointSize * context.actualScaleFactor
        return ceil(adjustedFontSize)
    }
    
    // MARK: Public functions
    
    func startAnimation() {
        resultLabel.subviews.forEach { subview in
            subview.removeFromSuperview()
        }
        
        self.layer.layoutIfNeeded()
        
        var arrString = textForLabel.components(separatedBy: " ")
        
        for i in 0..<arrString.count - 1 {
            arrString[i].append(" ")
        }
        
        if arrString.count >= 5 {
            arrString[arrString.count - 2] += arrString[arrString.count - 1]
            arrString.remove(at: arrString.count - 1)
        }
        
        let sumLetters = resultLabel.text!.count
        
        for i in 0..<arrString.count {
            let text = arrString[i]
            
            let itemLetters = arrString[i].count
            let widthNewLabel: CGFloat = resultLabel.bounds.width * CGFloat(itemLetters) / CGFloat(sumLetters)
            let newLabel = UILabel(frame: CGRect(x: resultLabel.bounds.width * (0.5 + Double(i) * 0.18), y: 0.0, width: widthNewLabel, height: resultLabel.bounds.height))
            newLabel.text = text
            newLabel.numberOfLines = resultLabel.numberOfLines
            newLabel.translatesAutoresizingMaskIntoConstraints = resultLabel.translatesAutoresizingMaskIntoConstraints
            newLabel.font = resultLabel.font
            newLabel.alpha = 0.0
            
            resultLabel.addSubview(newLabel)
            
            newLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            newLabel.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            
            newLabel.leadingAnchor.constraint(equalTo: i == 0 ? resultLabel.leadingAnchor : resultLabel.subviews[i - 1].trailingAnchor).isActive = true
            
            UIView.animate(withDuration: 0.7 - Double(i) / 30, delay: Double(i) * 2 / 10, options: .curveEaseOut, animations: {
                newLabel.alpha = 1.0
                self.layer.layoutIfNeeded()
            })
        }
    }
}
