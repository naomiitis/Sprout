import SwiftUI

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var animate = false
    @State private var confettiPieces: [ConfettiPiece] = []
    
    let colors: [Color] = [.sproutGreen, .sproutGreenDark, .sproutYellow, .sproutOrange, .sproutGreenLight]
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                Circle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .position(
                        x: animate ? piece.endX : piece.startX,
                        y: animate ? piece.endY : piece.startY
                    )
                    .opacity(animate ? 0 : 1)
                    .rotationEffect(.degrees(animate ? piece.rotation : 0))
            }
        }
        .onAppear {
            generateConfetti()
            withAnimation(.easeOut(duration: 1.5)) {
                animate = true
            }
        }
    }
    
    private func generateConfetti() {
        confettiPieces = (0..<50).map { _ in
            ConfettiPiece(
                id: UUID(),
                color: colors.randomElement() ?? .sproutGreen,
                size: CGFloat.random(in: 6...12),
                startX: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                startY: -20,
                endX: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                endY: UIScreen.main.bounds.height + 100,
                rotation: Double.random(in: 0...720)
            )
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id: UUID
    let color: Color
    let size: CGFloat
    let startX: CGFloat
    let startY: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let rotation: Double
}

