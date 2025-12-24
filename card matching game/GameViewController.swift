import UIKit

// MARK: - GameViewController Class

class GameViewController: UIViewController {
    
    // MARK: - Constants
    let maxLevel = 30
    let preGameRevealDuration: TimeInterval = 4.0 // Increased for older adults
    let mismatchDelay: TimeInterval = 1.5 // Longer pause to register the error
    
    // MARK: - Game State Properties
    var level = 1
    var cardViews = [CardView]()
    var matchedPairs = 0
    
    // Card Selection State
    var firstFlippedCard: CardView?
    var secondFlippedCard: CardView?
    
    // State flag to control interaction globally
    var isInteractionEnabled = true

    // Layout flag to handle viewDidLayoutSubviews execution
    var hasInitializedLevel = false

    // MARK: - UI Elements
    let gameBoardView = UIView()
    let levelLabel = UILabel()
    let hintButton = UIButton(type: .system)
    let closeButton = UIButton(type: .system)
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Dark background provides better contrast with the blue cards
        /*view.backgroundColor = UIColor(red: 0.05, green: 0.15, blue: 0.3, alpha: 1.0)*/ // Very dark blue
        setupUI()
        
        // Initial setup for the first level
        resetGameState()
        generateCardViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // This ensures cards are positioned correctly whenever the view size changes
        layoutCardViews()
        
        // Only run the level start sequence once the layout is finalized and not yet started
        if !hasInitializedLevel && cardViews.count > 0 {
            hasInitializedLevel = true
            showAllCardsBriefly()
        }
    }

    // MARK: - UI Setup

    private func setupUI() {
        // --- Shared Button Styling ---
        let buttonFont = UIFont.systemFont(ofSize: 20, weight: .heavy)
        let buttonColor: UIColor = .systemOrange

        // --- Close Button ---
        closeButton.setTitle("Exit", for: .normal)
        closeButton.titleLabel?.font = buttonFont
        closeButton.setTitleColor(buttonColor, for: .normal)
        closeButton.addTarget(self, action: #selector(closeGame), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        // --- Level Label ---
        levelLabel.textAlignment = .center
        levelLabel.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        levelLabel.textColor = .black
        levelLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(levelLabel)

        // --- Hint Button ---
        hintButton.setTitle("💡 HINT", for: .normal)
        hintButton.titleLabel?.font = buttonFont
        hintButton.setTitleColor(buttonColor, for: .normal)
        hintButton.addTarget(self, action: #selector(hintTapped), for: .touchUpInside)
        hintButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hintButton)

        // --- Game Board View ---
        gameBoardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gameBoardView)
        
        // --- Constraints ---
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            closeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            levelLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            levelLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            hintButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            hintButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            hintButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),

            gameBoardView.topAnchor.constraint(equalTo: levelLabel.bottomAnchor, constant: 20),
            gameBoardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            gameBoardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            gameBoardView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Level Management

    func startNewLevel() {
        guard level <= maxLevel else {
            showCompletionAlert()
            return
        }

        levelLabel.text = "Level \(level)/\(maxLevel)"
        hasInitializedLevel = false // Reset layout flag
        resetGameState()
        generateCardViews()
        // Layout and reveal will trigger upon next viewDidLayoutSubviews call
    }
    
    private func resetGameState() {
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
        firstFlippedCard = nil
        secondFlippedCard = nil
        matchedPairs = 0
        isInteractionEnabled = false // Keep disabled until reveal is complete
    }
    
    private func generateCardViews() {
        let maxPairs = 4 + min(level - 1, 11)
        let numberOfPairs = min(maxPairs, 15)

        let availableContents = ["🍎", "🐶", "🚀", "🌟", "🍕", "🚲", "❤️", "🌙", "👑", "💡", "😀", "😎", "🎁", "🎈", "⚽️"]
        let contentSet = Array(availableContents.prefix(numberOfPairs))

        // 1. Build actual pairs with correct IDs
        var cardData: [(id: Int, content: String)] = []
        for (id, content) in contentSet.enumerated() {
            cardData.append((id: id, content: content))
            cardData.append((id: id, content: content))
        }

        // 2. NOW shuffle AFTER assigning IDs
        cardData.shuffle()

        // 3. Create cards
        for item in cardData {
            let cardView = CardView(frame: .zero, identifier: item.id, content: item.content)
            cardViews.append(cardView)
            gameBoardView.addSubview(cardView)

            let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            cardView.addGestureRecognizer(tap)
        }
    }


    private func layoutCardViews() {
        // ... (Layout logic remains the same) ...
        let cardCount = cardViews.count
        guard cardCount > 0 else { return }

        let columns: Int
        let rows: Int
        
        if cardCount <= 8 { (columns, rows) = (4, 2) }
        else if cardCount <= 12 { (columns, rows) = (4, 3) }
        else if cardCount <= 16 { (columns, rows) = (4, 4) }
        else if cardCount <= 20 { (columns, rows) = (5, 4) }
        else { (columns, rows) = (6, 5) }
        
        let containerWidth = gameBoardView.bounds.width
        let containerHeight = gameBoardView.bounds.height
        
        let spacing: CGFloat = 12
        let cardWidth = (containerWidth - CGFloat(columns + 1) * spacing) / CGFloat(columns)
        let cardHeight = (containerHeight - CGFloat(rows + 1) * spacing) / CGFloat(rows)
        
        for (index, cardView) in cardViews.enumerated() {
            let column = index % columns
            let row = index / columns
            
            let x = spacing + CGFloat(column) * (cardWidth + spacing)
            let y = spacing + CGFloat(row) * (cardHeight + spacing)
            
            cardView.frame = CGRect(x: x, y: y, width: cardWidth, height: cardHeight)
        }
    }
    
    // MARK: - Pre-Game Reveal

    private func showAllCardsBriefly() {
        cardViews.forEach { $0.flip(toFlipped: true, animated: false) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + preGameRevealDuration) { [weak self] in
            guard let self = self else { return }
            
            self.cardViews.forEach { $0.flip(toFlipped: false, animated: true) }
            self.isInteractionEnabled = true // Enable interaction only after the final flip back
        }
    }

    // MARK: - Game Flow

    // In GameViewController.swift

    @objc private func cardTapped(_ sender: UITapGestureRecognizer) {
        guard isInteractionEnabled,
              let tappedCard = sender.view as? CardView,
              !tappedCard.isMatched else {
            return
        }
        
        // 1. Check if the card is already flipped (using the new read-only property)
        if tappedCard.isFlipped {
            // Tapped the same card twice, or tapped a card that is currently part of a pair check.
            return
        }

        // 2. Disable interaction to handle the pair selection process
        isInteractionEnabled = false
        
        // 3. Flip the card
        tappedCard.flip(toFlipped: true, animated: true)

        if firstFlippedCard == nil {
            // First card selected
            firstFlippedCard = tappedCard
            isInteractionEnabled = true // Re-enable interaction immediately for the second card flip
            
        } else if secondFlippedCard == nil {
            // Second card selected
            secondFlippedCard = tappedCard
            
            // Check for match after a small visual delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.checkForMatch()
            }
        }
    }
    
    private func checkForMatch() {
        guard let card1 = firstFlippedCard, let card2 = secondFlippedCard else {
            resetSelection()
            return
        }

        if card1.contentIdentifier == card2.contentIdentifier {
            // *** MATCH FOUND! Cards remain open. ***
            
            // 1. Mark as matched in the CardView state
            card1.setMatched()
            card2.setMatched()
            
            matchedPairs += 1
            
            // 2. Check for game win
            if matchedPairs == cardViews.count / 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                    self?.showCompletionAlert()
                }
            }
            resetSelection() // Enables interaction
            
        } else {
            // *** MISMATCH! Cards flip back closed. ***
            
            // Wait for the longer mismatch delay
            DispatchQueue.main.asyncAfter(deadline: .now() + mismatchDelay) { [weak self] in
                guard let self = self else { return }
                
                // Flip them back to closed state
                card1.flip(toFlipped: false, animated: true)
                card2.flip(toFlipped: false, animated: true)
                
                self.resetSelection() // Enables interaction
            }
        }
    }

    private func resetSelection() {
        firstFlippedCard = nil
        secondFlippedCard = nil
        isInteractionEnabled = true
    }
    
    // MARK: - Hint Functionality
    
    @objc private func hintTapped() {
        guard isInteractionEnabled else { return }
        
        // Find the first unmatched, unflipped card
        guard let unmatchedCard1 = cardViews.first(where: { !$0.isMatched && !$0.isFlipped }) else { return }
        let identifierToFind = unmatchedCard1.contentIdentifier
        
        // Find its matching, unflipped pair
        guard let unmatchedCard2 = cardViews.first(where: {
            $0.contentIdentifier == identifierToFind && $0 != unmatchedCard1 && !$0.isFlipped
        }) else { return }
        
        // Brief, slow flash to hint at location
        isInteractionEnabled = false
        
        UIView.animate(withDuration: 0.4, animations: {
            unmatchedCard1.alpha = 0.4
            unmatchedCard2.alpha = 0.4
        }) { _ in
            UIView.animate(withDuration: 0.4, animations: {
                unmatchedCard1.alpha = 1.0
                unmatchedCard2.alpha = 1.0
            }) { [weak self] _ in
                self?.isInteractionEnabled = true
            }
        }
    }
    
    // MARK: - Alerts and Dismissal
    
    private func showCompletionAlert() {
        let title = (level >= maxLevel) ? "Game Complete!" : "Level Passed!"
        let message = (level >= maxLevel) ? "You beat all \(maxLevel) levels! Excellent work." : "Ready for Level \(level + 1)?"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if level < maxLevel {
            alert.addAction(UIAlertAction(title: "Next Level", style: .default) { _ in
                self.level += 1
                self.startNewLevel()
            })
        }
        alert.addAction(UIAlertAction(title: "Main Menu", style: .cancel) { _ in
            self.closeGame()
        })
        present(alert, animated: true)
    }
    
    @objc func closeGame() {
        self.dismiss(animated: true, completion: nil)
    }
}
