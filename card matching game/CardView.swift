import Foundation
import UIKit

class CardView: UIView {
    
    // MARK: - Appearance
    let cardCornerRadius: CGFloat = 20.0
    
    // Orange tile color (same as your image)
    let backColor = UIColor(red: 0.95, green: 0.50, blue: 0.15, alpha: 1.0) // #F27F26 approx
    
    // Front face color
    let frontColor: UIColor = .white
    
    // MARK: - Properties
    let contentIdentifier: Int
    let frontLabel = UILabel()
    let backView = UIView()
    private let backIcon = UILabel()   // <- For white question mark
    
    private var _isFlipped = false
    var isFlipped: Bool { return _isFlipped || isMatched }
    var isMatched = false
    
    // MARK: - Init
    init(frame: CGRect, identifier: Int, content: String) {
        self.contentIdentifier = identifier
        super.init(frame: frame)
        setupViews(content: content)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupViews(content: String) {
        self.backgroundColor = .clear
        self.layer.cornerRadius = cardCornerRadius
        self.layer.masksToBounds = false
        
        // Shadow to match modern card UI
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.15
        self.layer.shadowRadius = 6
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        // --- BACK VIEW (DEFAULT SIDE) ---
        backView.backgroundColor = backColor
        backView.layer.cornerRadius = cardCornerRadius
        backView.clipsToBounds = true
        
        // White "?" identical to your image
        backIcon.text = "?"
        backIcon.textColor = .white
        backIcon.font = UIFont.systemFont(ofSize: 60, weight: .bold)
        backIcon.textAlignment = .center
        backView.addSubview(backIcon)
        
        // --- FRONT VIEW ---
        frontLabel.text = content
        frontLabel.textAlignment = .center
        frontLabel.font = UIFont.systemFont(ofSize: 60, weight: .bold)
        frontLabel.backgroundColor = frontColor
        frontLabel.layer.cornerRadius = cardCornerRadius
        frontLabel.clipsToBounds = true
        
        addSubview(frontLabel)
        addSubview(backView)
        
        frontLabel.isHidden = true
        backView.isHidden = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frontLabel.frame = bounds
        backView.frame = bounds
        backIcon.frame = bounds
    }
    
    // MARK: - Flip Animation
    func flip(toFlipped: Bool, animated: Bool) {
        if isMatched { return }
        guard _isFlipped != toFlipped else { return }
        
        _isFlipped = toFlipped
        
        let options: UIView.AnimationOptions = toFlipped ? .transitionFlipFromRight : .transitionFlipFromLeft
        let duration = animated ? 0.35 : 0
        
        UIView.transition(with: self, duration: duration, options: options, animations: {
            self.frontLabel.isHidden = !self._isFlipped
            self.backView.isHidden = self._isFlipped
        })
    }
    
    // MARK: - Match Handling
    func setMatched() {
        isMatched = true
        _isFlipped = true
        
        self.frontLabel.isHidden = false
        self.backView.isHidden = true
        
        UIView.animate(withDuration: 0.5) {
            self.alpha = 0.3
            self.layer.shadowOpacity = 0.0
        }
    }
}

