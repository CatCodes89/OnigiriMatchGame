//
//  GameScene.swift
//  OnigiriMatchGame
//
//  Created by Cathy on 2025-06-18.
//

import SpriteKit

// MARK: - TileType Enum

enum TileType: Int {
    case onigiri = 0, onigiri1, onigiri2, onigiri3, onigiri4, onigiri5, onigiri6, onigiri7
    case onigiri8

    static var allNormalCases: [TileType] {
        return [.onigiri, .onigiri1, .onigiri2, .onigiri3, .onigiri4, .onigiri5, .onigiri6, .onigiri7]
    }

    var textureName: String {
        return "onigiri\(self.rawValue == 0 ? "" : "\(self.rawValue)")"
    }
}

// MARK: - GameTile Class

class GameTile: SKSpriteNode {
    var tileType: TileType
    var row: Int
    var column: Int

    init(tileType: TileType, row: Int, column: Int, tileSize: CGFloat) {
        self.tileType = tileType
        self.row = row
        self.column = column

        let texture = SKTexture(imageNamed: tileType.textureName)
        super.init(texture: texture, color: .clear, size: CGSize(width: tileSize, height: tileSize))
        self.isUserInteractionEnabled = false
        self.name = "tile"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - GameScene Class

class GameScene: SKScene {
    
    // MARK: - Properties
    
    let numRows = 6
    let numColumns = 6
    let tileSize: CGFloat = 64
    var levelGoal = 200

    var board: [[GameTile?]] = []
    var menuPanel: SKShapeNode?
    var selectedTile: GameTile?
    var highlightNode: SKNode?

    var progressBackground: SKShapeNode!
    var progressBar: SKShapeNode!
    var goalLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var hintButton: SKLabelNode!
    var powerUpButton: SKLabelNode!
    var powerUpIcon: SKSpriteNode!
    var powerUpCountLabel: SKLabelNode!
    var powerUpBox: SKShapeNode!
    var scoreBox: SKShapeNode!

    var hintsLeft = 3
    var powerUpUsed = false
    var powerUpCount = 1
    var levelCompleted = false
    var isGameOver = false

    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
            let progress = min(CGFloat(score) / CGFloat(levelGoal), 1.0)
            let fullWidth: CGFloat = 200
            let newWidth = fullWidth * progress
            let barHeight: CGFloat = 16
            progressBar.path = CGPath(roundedRect: CGRect(x: 0, y: -barHeight/2, width: newWidth, height: barHeight), cornerWidth: 3, cornerHeight: 3, transform: nil)

            if score >= levelGoal && !levelCompleted {
                levelCompleted = true
                resetHints()
                run(SKAction.wait(forDuration: 0.5)) {
                    self.runWinAnimation()
                }
            }
        }
    }

    // MARK: - Lifecycle
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let background = SKSpriteNode(imageNamed: "GameBkg")
        background.zPosition = -1
        background.position = CGPoint(x: 0, y: 0)
        background.size = self.size
        addChild(background)

        powerUpCount = 1

        addBoardBackground()
        setupBoard()
        setupScoreUI()
        setupPowerUpUI()
        setupMenuButton()

    }

    // MARK: - Board Setup and Management
    
    func addBoardBackground() {
        let boardWidth = self.size.width
        let boardHeight = CGFloat(numRows) * tileSize + 8

        let background = SKShapeNode(rectOf: CGSize(width: boardWidth, height: boardHeight))
        background.fillColor = .black.withAlphaComponent(0.5)
        background.strokeColor = .clear
        background.lineWidth = 0
        background.zPosition = -0.5
        background.position = .zero
        addChild(background)
    }

    func setupBoard() {
        board = []
        for _ in 0..<numRows {
            var tileRow: [GameTile?] = []
            for _ in 0..<numColumns {
                tileRow.append(nil)
            }
            board.append(tileRow)
        }

        for row in 0..<numRows {
            for col in 0..<numColumns {
                let tile = createRandomTile(row: row, column: col)
                addChild(tile)
                board[row][col] = tile
            }
        }
    }

    func createRandomTile(row: Int, column: Int) -> GameTile {
        var availableTypes = TileType.allNormalCases

        if column >= 2,
           let left1 = board[row][column - 1],
           let left2 = board[row][column - 2],
           left1.tileType == left2.tileType {
            availableTypes.removeAll { $0 == left1.tileType }
        }

        if row >= 2,
           let below1 = board[row - 1][column],
           let below2 = board[row - 2][column],
           below1.tileType == below2.tileType {
            availableTypes.removeAll { $0 == below1.tileType }
        }

        let type = availableTypes.randomElement()!
        let tile = GameTile(tileType: type, row: row, column: column, tileSize: tileSize)
        tile.position = pointFor(row: row, column: column)
        return tile
    }

    func pointFor(row: Int, column: Int) -> CGPoint {
        let x = CGFloat(column) * tileSize - CGFloat(numColumns) * tileSize / 2 + tileSize / 2
        let y = CGFloat(row) * tileSize - CGFloat(numRows) * tileSize / 2 + tileSize / 2
        return CGPoint(x: x, y: y)
    }

    // MARK: - UI Setup
    
    func setupScoreUI() {
        let boxWidth: CGFloat = tileSize * 4
        let boxHeight: CGFloat = tileSize * 2.2
        let boxY = CGFloat(numRows) * tileSize / 2 + 100

        scoreBox = SKShapeNode(rectOf: CGSize(width: boxWidth, height: boxHeight), cornerRadius: 8)
        scoreBox.strokeColor = .white
        scoreBox.lineWidth = 2
        scoreBox.fillColor = .black.withAlphaComponent(0.5)
        scoreBox.zPosition = 10
        scoreBox.position = CGPoint(x: 0, y: boxY)
        addChild(scoreBox)

        goalLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        goalLabel.fontSize = 20
        goalLabel.fontColor = .white
        goalLabel.zPosition = 11
        goalLabel.text = "Goal: \(levelGoal) Points"
        goalLabel.position = CGPoint(x: 0, y: boxHeight / 2 - 30)
        scoreBox.addChild(goalLabel)

        let barWidth: CGFloat = 200
        let barHeight: CGFloat = 16

        progressBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 4)
        progressBackground.strokeColor = .white
        progressBackground.fillColor = .darkGray
        progressBackground.position = CGPoint(x: 0, y: goalLabel.position.y - 28)
        progressBackground.zPosition = 11
        scoreBox.addChild(progressBackground)

        progressBar = SKShapeNode()
        progressBar.fillColor = .white
        progressBar.strokeColor = .clear
        progressBar.zPosition = 12
        progressBar.position = CGPoint(x: -barWidth / 2, y: goalLabel.position.y - 28)
        scoreBox.addChild(progressBar)

        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = .white
        scoreLabel.zPosition = 11
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 0, y: progressBackground.position.y - 33)
        scoreBox.addChild(scoreLabel)

        hintButton = SKLabelNode(fontNamed: "AvenirNext-Bold")
        hintButton.fontSize = 20
        hintButton.fontColor = .white
        hintButton.text = "Hint (\(hintsLeft))"
        hintButton.position = CGPoint(x: 0, y: scoreLabel.position.y - 28)
        hintButton.zPosition = 11
        hintButton.name = "hintButton"
        scoreBox.addChild(hintButton)
    }

    func setupPowerUpUI() {
        let boxWidth: CGFloat = tileSize * 4
        let boxHeight: CGFloat = tileSize * 2.2

        powerUpBox = SKShapeNode(rectOf: CGSize(width: boxWidth, height: boxHeight), cornerRadius: 8)
        powerUpBox.strokeColor = .white
        powerUpBox.lineWidth = 2
        powerUpBox.fillColor = .black.withAlphaComponent(0.5)
        powerUpBox.zPosition = 10
        powerUpBox.position = CGPoint(x: 0, y: hintButton.position.y - 250)
        addChild(powerUpBox)

        let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        titleLabel.fontSize = 20
        titleLabel.fontColor = .white
        titleLabel.text = "Power Ups"
        titleLabel.position = CGPoint(x: 0, y: boxHeight / 2 - 30)
        titleLabel.zPosition = 11
        powerUpBox.addChild(titleLabel)

        powerUpIcon = SKSpriteNode(imageNamed: TileType.onigiri8.textureName)
        powerUpIcon.size = CGSize(width: tileSize, height: tileSize)
        powerUpIcon.position = CGPoint(x: 0, y: -10)
        powerUpIcon.zPosition = 11
        powerUpIcon.name = "powerUpIcon"
        powerUpBox.addChild(powerUpIcon)

        powerUpCountLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        powerUpCountLabel.fontSize = 20
        powerUpCountLabel.fontColor = .white
        powerUpCountLabel.text = "(\(powerUpCount))"
        powerUpCountLabel.verticalAlignmentMode = .top
        powerUpCountLabel.horizontalAlignmentMode = .center
        powerUpCountLabel.position = CGPoint(x: 0, y: -tileSize / 2 - 12)
        powerUpCountLabel.zPosition = 11
        powerUpBox.addChild(powerUpCountLabel)

        updatePowerUpUI()
    }

    func updatePowerUpUI() {
        powerUpCountLabel.text = "x\(powerUpCount)"

        if powerUpCount <= 0 {
            powerUpIcon.color = .gray
            powerUpIcon.colorBlendFactor = 0.7
            powerUpCountLabel.fontColor = .gray
        } else {
            powerUpIcon.colorBlendFactor = 0.0
            powerUpCountLabel.fontColor = .white
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        let touchedNodes = nodes(at: location)

        if touchedNodes.contains(where: { $0.name == "hintButton" }) {
            useHint()
            return
        }

        if touchedNodes.contains(where: { $0.name == "powerUpIcon" }) {
            activatePowerUp()
            return
        }

        if touchedNodes.contains(where: { $0.name == "menuButton" }) {
            toggleMenu()
            return
        }

        if touchedNodes.contains(where: { $0.name == "closeMenuButton" }) {
            toggleMenu()
            return
        }

        if touchedNodes.contains(where: { $0.name == "backToMenu" }) {
            let startScene = StartScene(size: self.size)
            startScene.scaleMode = .aspectFill
            self.view?.presentScene(startScene, transition: SKTransition.fade(withDuration: 0.5))
            return
        }

        if touchedNodes.contains(where: { $0.name == "helpButton" }) {
            let helpScene = HelpScene(size: self.size)
            helpScene.scaleMode = .aspectFill
            helpScene.userData = NSMutableDictionary()
            helpScene.userData?["origin"] = "GameScene"
            self.view?.presentScene(helpScene, transition: SKTransition.fade(withDuration: 0.5))
            return
        }

        if touchedNodes.contains(where: { $0.name == "restartGame" }) {
            let newScene = GameScene(size: self.size)
            newScene.scaleMode = .aspectFill
            self.view?.presentScene(newScene, transition: SKTransition.fade(withDuration: 0.5))
            return
        }

        guard let tappedTile = tileAt(point: location) else { return }

        if let first = selectedTile {
            if areAdjacent(tile1: first, tile2: tappedTile) {
                removeHighlight()
                swapTiles(first, tappedTile)
                if !removeMatches() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.swapTiles(first, tappedTile)
                    }
                } else {
                    run(SKAction.wait(forDuration: 0.3)) {
                        self.applyGravityAndRefill()
                    }
                }
                selectedTile = nil
            } else {
                selectedTile = tappedTile
                highlightTile(tappedTile)
            }
        } else {
            selectedTile = tappedTile
            highlightTile(tappedTile)
        }
    }

    // MARK: - Tile Highlighting

    func highlightTile(_ tile: GameTile) {
        removeHighlight()
        let highlight = SKShapeNode(rectOf: CGSize(width: tileSize - 6, height: tileSize - 6), cornerRadius: 4)
        highlight.strokeColor = .yellow
        highlight.lineWidth = 3
        highlight.zPosition = 5
        highlight.position = tile.position
        addChild(highlight)
        highlightNode = highlight
    }

    func removeHighlight() {
        highlightNode?.removeFromParent()
        highlightNode = nil
    }

    // MARK: - Game Logic

    func areAdjacent(tile1: GameTile, tile2: GameTile) -> Bool {
        let dr = abs(tile1.row - tile2.row)
        let dc = abs(tile1.column - tile2.column)
        return (dr == 1 && dc == 0) || (dr == 0 && dc == 1)
    }

    func swapTiles(_ a: GameTile, _ b: GameTile) {
        board[a.row][a.column] = b
        board[b.row][b.column] = a

        (a.row, b.row) = (b.row, a.row)
        (a.column, b.column) = (b.column, a.column)

        let posA = pointFor(row: a.row, column: a.column)
        let posB = pointFor(row: b.row, column: b.column)
        a.run(SKAction.move(to: posA, duration: 0.2))
        b.run(SKAction.move(to: posB, duration: 0.2))

        playSound("Pop.wav")
    }

    func removeMatches() -> Bool {
        var matches: Set<GameTile> = []

        // Check rows
        for row in 0..<numRows {
            var match: [GameTile] = []
            var lastType: TileType?
            for col in 0..<numColumns {
                if let tile = board[row][col] {
                    if tile.tileType == lastType {
                        match.append(tile)
                    } else {
                        if match.count >= 3 {
                            matches.formUnion(match)
                        }
                        match = [tile]
                        lastType = tile.tileType
                    }
                }
            }
            if match.count >= 3 { matches.formUnion(match) }
        }

        // Check columns
        for col in 0..<numColumns {
            var match: [GameTile] = []
            var lastType: TileType?
            for row in 0..<numRows {
                if let tile = board[row][col] {
                    if tile.tileType == lastType {
                        match.append(tile)
                    } else {
                        if match.count >= 3 {
                            matches.formUnion(match)
                        }
                        match = [tile]
                        lastType = tile.tileType
                    }
                }
            }
            if match.count >= 3 { matches.formUnion(match) }
        }

        for tile in matches {
            board[tile.row][tile.column] = nil
            playSound("Sparkle.wav")

            tile.run(SKAction.sequence([
                SKAction.scale(to: 0.0, duration: 0.2),
                SKAction.removeFromParent()
            ]))
        }

        if !matches.isEmpty {
            score += matches.count * 10
        }

        return !matches.isEmpty
    }

    func applyGravityAndRefill() {
        for col in 0..<numColumns {
            var emptySpots: [Int] = []

            for row in (0..<numRows).reversed() {
                if board[row][col] == nil {
                    emptySpots.append(row)
                } else if !emptySpots.isEmpty {
                    let newRow = emptySpots.removeFirst()
                    let tile = board[row][col]!
                    board[newRow][col] = tile
                    board[row][col] = nil
                    tile.row = newRow
                    let newPos = pointFor(row: newRow, column: col)
                    tile.run(SKAction.move(to: newPos, duration: 0.2))
                    emptySpots.append(row)
                }
            }

            for row in emptySpots {
                let tile = createRandomTile(row: row, column: col)
                tile.position.y += CGFloat(numRows) * tileSize
                addChild(tile)
                board[row][col] = tile
                tile.run(SKAction.move(to: pointFor(row: row, column: col), duration: 0.3))
            }
        }

        run(SKAction.wait(forDuration: 0.4)) {
            if self.removeMatches() {
                self.run(SKAction.wait(forDuration: 0.3)) {
                    self.applyGravityAndRefill()
                }
            }
        }
    }

    // MARK: - Hint and Power Up

    func useHint() {
        if hintsLeft <= 0 && score < levelGoal {
            hintButton.fontColor = .gray
            return
        }

        if hintsLeft > 0 {
            hintsLeft -= 1
            hintButton.text = "Hint (\(hintsLeft))"
            playSound("Bell.wav")

            if let matchPair = findValidSwap() {
                highlightHint(for: matchPair)
            } else {
                hintButton.fontColor = .gray
                hintButton.text = "No Moves"
            }

            if hintsLeft == 0 && score < levelGoal {
                hintButton.fontColor = .gray
            }
        }
    }

    func findValidSwap() -> (GameTile, GameTile)? {
        for row in 0..<numRows {
            for col in 0..<numColumns {
                guard let tile = board[row][col] else { continue }

                if col < numColumns - 1, let rightTile = board[row][col + 1] {
                    swapTilesInBoard(tile, rightTile)
                    if checkForMatch() {
                        swapTilesInBoard(tile, rightTile)
                        return (tile, rightTile)
                    }
                    swapTilesInBoard(tile, rightTile)
                }

                if row < numRows - 1, let topTile = board[row + 1][col] {
                    swapTilesInBoard(tile, topTile)
                    if checkForMatch() {
                        swapTilesInBoard(tile, topTile)
                        return (tile, topTile)
                    }
                    swapTilesInBoard(tile, topTile)
                }
            }
        }
        return nil
    }

    func swapTilesInBoard(_ a: GameTile, _ b: GameTile) {
        board[a.row][a.column] = b
        board[b.row][b.column] = a

        (a.row, b.row) = (b.row, a.row)
        (a.column, b.column) = (b.column, a.column)
    }

    func checkForMatch() -> Bool {
        for row in 0..<numRows {
            var count = 1
            for col in 1..<numColumns {
                if let current = board[row][col], let previous = board[row][col - 1],
                   current.tileType == previous.tileType {
                    count += 1
                    if count >= 3 { return true }
                } else {
                    count = 1
                }
            }
        }

        for col in 0..<numColumns {
            var count = 1
            for row in 1..<numRows {
                if let current = board[row][col], let previous = board[row - 1][col],
                   current.tileType == previous.tileType {
                    count += 1
                    if count >= 3 { return true }
                } else {
                    count = 1
                }
            }
        }

        return false
    }

    func highlightHint(for pair: (GameTile, GameTile)) {
        removeHighlight()

        let (tileA, tileB) = pair

        let highlightA = SKShapeNode(rectOf: CGSize(width: tileSize - 6, height: tileSize - 6), cornerRadius: 4)
        highlightA.strokeColor = .cyan
        highlightA.lineWidth = 4
        highlightA.zPosition = 5
        highlightA.position = tileA.position

        let highlightB = SKShapeNode(rectOf: CGSize(width: tileSize - 6, height: tileSize - 6), cornerRadius: 4)
        highlightB.strokeColor = .cyan
        highlightB.lineWidth = 4
        highlightB.zPosition = 5
        highlightB.position = tileB.position

        let container = SKNode()
        container.addChild(highlightA)
        container.addChild(highlightB)

        highlightNode = container
        addChild(container)

        run(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.run { [weak self] in
                self?.removeHighlight()
            }
        ]))
    }

    func activatePowerUp() {
        guard powerUpCount > 0 && !powerUpUsed else { return }

        powerUpUsed = true
        powerUpCount -= 1
        updatePowerUpUI()
        playSound("PowerUp.wav")

        // Clear random cross
        if let randomTile = board.flatMap({ $0 }).compactMap({ $0 }).randomElement() {
            clearCross(at: randomTile)
        }

        run(SKAction.wait(forDuration: 0.6)) {
            self.applyGravityAndRefill()
            self.powerUpUsed = false
        }
    }

    func clearCross(at tile: GameTile) {
        let row = tile.row
        let col = tile.column

        for c in 0..<numColumns {
            if let t = board[row][c] {
                playSound("Sparkle.wav")
                t.run(SKAction.sequence([
                    SKAction.scale(to: 0.0, duration: 0.2),
                    SKAction.removeFromParent()
                ]))
                board[row][c] = nil
            }
        }

        for r in 0..<numRows {
            if r != row, let t = board[r][col] {
                playSound("Sparkle.wav")
                t.run(SKAction.sequence([
                    SKAction.scale(to: 0.0, duration: 0.2),
                    SKAction.removeFromParent()
                ]))
                board[r][col] = nil
            }
        }

        tile.run(SKAction.sequence([
            SKAction.scale(to: 0.0, duration: 0.2),
            SKAction.removeFromParent()
        ]))
        board[row][col] = nil
    }

    // MARK: - Menu Management
    
    func toggleMenu() {
        if let panel = menuPanel {
            panel.removeFromParent()
            menuPanel = nil
        } else {
            let panelWidth: CGFloat = 300
            let panelHeight: CGFloat = 400

            let panel = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: 12)
            panel.fillColor = .black.withAlphaComponent(0.8)
            panel.strokeColor = .white
            panel.lineWidth = 3
            panel.zPosition = 100
            panel.position = CGPoint(x: 0, y: 0)
            addChild(panel)
            menuPanel = panel

            let closeButton = SKLabelNode(text: "Close")
            closeButton.fontName = "AvenirNext-Bold"
            closeButton.fontSize = 24
            closeButton.fontColor = .white
            closeButton.position = CGPoint(x: 0, y: panelHeight/2 - 40)
            closeButton.name = "closeMenuButton"
            panel.addChild(closeButton)

            let startY: CGFloat = 50
            let gap: CGFloat = 60

            let backToMenu = SKLabelNode(text: "Back to Menu")
            backToMenu.fontName = "AvenirNext-Bold"
            backToMenu.fontSize = 22
            backToMenu.fontColor = .white
            backToMenu.position = CGPoint(x: 0, y: startY)
            backToMenu.name = "backToMenu"
            panel.addChild(backToMenu)

            let helpButton = SKLabelNode(text: "Help")
            helpButton.fontName = "AvenirNext-Bold"
            helpButton.fontSize = 22
            helpButton.fontColor = .white
            helpButton.position = CGPoint(x: 0, y: startY - gap)
            helpButton.name = "helpButton"
            panel.addChild(helpButton)

            let restartGame = SKLabelNode(text: "Restart Game")
            restartGame.fontName = "AvenirNext-Bold"
            restartGame.fontSize = 22
            restartGame.fontColor = .white
            restartGame.position = CGPoint(x: 0, y: startY - gap * 2)
            restartGame.name = "restartGame"
            panel.addChild(restartGame)
        }
    }

    func setupMenuButton() {
        let buttonSize: CGFloat = 50
        let margin: CGFloat = 20

        let buttonBackground = SKShapeNode(rectOf: CGSize(width: buttonSize, height: buttonSize), cornerRadius: 8)
        buttonBackground.fillColor = .black.withAlphaComponent(0.5)
        buttonBackground.strokeColor = .white
        buttonBackground.lineWidth = 2
        buttonBackground.zPosition = 1000
        buttonBackground.name = "menuButton"

        buttonBackground.position = CGPoint(
            x: size.width / 2 - margin - buttonSize / 2,
            y: size.height / 2 - margin - buttonSize / 2
        )

        addChild(buttonBackground)

        let lineWidth: CGFloat = 30
        let lineHeight: CGFloat = 4
        let lineSpacing: CGFloat = 8

        for i in 0..<3 {
            let line = SKShapeNode(rectOf: CGSize(width: lineWidth, height: lineHeight), cornerRadius: 2)
            line.fillColor = .white
            line.strokeColor = .clear
            line.position = CGPoint(x: 0, y: CGFloat(i - 1) * lineSpacing)
            line.zPosition = 1001
            buttonBackground.addChild(line)
        }
    }

    // MARK: - Level & Game Flow

    func startNextLevel() {
        levelGoal = 500
        levelCompleted = false
        score = 0

        removeHighlight()
        menuPanel?.removeFromParent()
        menuPanel = nil

        for row in board {
            for tile in row {
                tile?.removeFromParent()
            }
        }

        setupBoard()

        goalLabel.text = "Goal: \(levelGoal) Points"
        resetHints()
    }

    func resetHints() {
        hintsLeft = 3
        hintButton.text = "Hint (\(hintsLeft))"
        hintButton.fontColor = .white
    }

    // MARK: - Utility

    func tileAt(point: CGPoint) -> GameTile? {
        for row in board {
            for tile in row {
                if let tile = tile, tile.contains(point) {
                    return tile
                }
            }
        }
        return nil
    }

    func playSound(_ filename: String) {
        run(SKAction.playSoundFileNamed(filename, waitForCompletion: false))
    }

    func runWinAnimation() {
        playSound("Victory.wav")

        let fallDuration = 1.2
        let fadeDuration = 1.0

        for row in board {
            for tile in row {
                if let tile = tile {
                    let fall = SKAction.moveBy(x: 0, y: -size.height, duration: fallDuration)
                    let fadeOut = SKAction.fadeOut(withDuration: fadeDuration)
                    let remove = SKAction.removeFromParent()
                    let seq = SKAction.sequence([SKAction.group([fall, fadeOut]), remove])
                    tile.run(seq)
                }
            }
        }

        let winLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        winLabel.text = "You Win!!!"
        winLabel.fontSize = 48
        winLabel.fontColor = .yellow
        winLabel.zPosition = 1000
        winLabel.alpha = 0
        winLabel.position = CGPoint(x: 0, y: size.height / 2 + 50)
        addChild(winLabel)

        let fadeIn = SKAction.fadeIn(withDuration: 1.0)
        let moveDown = SKAction.moveTo(y: 0, duration: 1.5)
        moveDown.timingMode = .easeOut
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()

        let sequence = SKAction.sequence([fadeIn, moveDown, wait, fadeOut, remove])
        winLabel.run(sequence)

        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.5),
            SKAction.run { [weak self] in
                self?.startNextLevel()
            }
        ]))
    }
}
