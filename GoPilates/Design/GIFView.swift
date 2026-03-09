import SwiftUI
import AVFoundation

// Uses AVPlayer for instant, hardware-accelerated MP4 playback.
// Replaced the GIF decoder since user upgraded media to MP4.

struct GIFView: View {
    let exercise: PilatesExercise

    var body: some View {
        if let _ = Bundle.main.url(forResource: exercise.gifFileName, withExtension: "mp4") {
            SeamlessVideoPlayer(videoName: exercise.gifFileName)
                .scaledToFit()
                .ignoresSafeArea()
        } else {
            ExercisePlaceholderView(exercise: exercise)
        }
    }
}

// MARK: - Premium Placeholder for Missing Videos
struct ExercisePlaceholderView: View {
    let exercise: PilatesExercise
    @State private var pulse = false
    @State private var rotate: Double = 0
    
    // Category colors to match the app's aesthetic
    private var baseColor: Color {
        switch exercise.category {
        case .coreIntegration: return Color(hex: "C4788A")
        case .lowerBody:       return Color(hex: "B8893A")
        case .upperBody:       return Color(hex: "5A7A96")
        case .fullBody:        return Color(hex: "6E9A78")
        case .classical:       return Color(hex: "A86E96")
        case .restorative:     return Color(hex: "8A9CB0")
        }
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [baseColor.opacity(0.15), baseColor.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated rings
            Circle()
                .fill(baseColor.opacity(0.1))
                .frame(width: 220, height: 220)
                .scaleEffect(pulse ? 1.15 : 0.95)
            
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [baseColor.opacity(0.1), baseColor.opacity(0.6), baseColor.opacity(0.1)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 1.5, dash: [8, 4])
                )
                .frame(width: 260, height: 260)
                .rotationEffect(.degrees(rotate))
            
            // SF Symbol and Text
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 120, height: 120)
                        .shadow(color: baseColor.opacity(0.2), radius: 15, y: 8)
                    
                    Image(systemName: exercise.sfSymbol)
                        .font(.system(size: 55, weight: .ultraLight))
                        .foregroundColor(baseColor)
                }
                
                VStack(spacing: 8) {
                    Text(exercise.name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.deepCharcoal)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    Text(exercise.targetMuscles.prefix(3).joined(separator: " • "))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.deepCharcoal.opacity(0.6))
                        .textCase(.uppercase)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
            withAnimation(.linear(duration: 15.0).repeatForever(autoreverses: false)) {
                rotate = 360
            }
        }
    }
}

// Low-level fast AVPlayer
struct SeamlessVideoPlayer: UIViewRepresentable {
    let videoName: String
    
    func makeUIView(context: Context) -> PlayerUIView {
        return PlayerUIView(frame: .zero)
    }
    
    func updateUIView(_ uiView: PlayerUIView, context: Context) {
        if uiView.currentVideo != videoName {
            uiView.play(videoName: videoName)
        }
    }
}

class PlayerUIView: UIView {
    var currentVideo: String?
    private var playerLayer: AVPlayerLayer?
    private var looper: AVPlayerLooper?
    private var queuePlayer: AVQueuePlayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func play(videoName: String) {
        self.currentVideo = videoName
        
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else {
            print("❌ MP4 not found for \(videoName)")
            return
        }

        let item = AVPlayerItem(url: url)
        self.queuePlayer = AVQueuePlayer(playerItem: item)
        self.queuePlayer?.isMuted = true
        self.looper = AVPlayerLooper(player: queuePlayer!, templateItem: item)

        if playerLayer == nil {
            let layer = AVPlayerLayer(player: queuePlayer)
            layer.videoGravity = .resizeAspect
            self.layer.addSublayer(layer)
            self.playerLayer = layer
        } else {
            self.playerLayer?.player = queuePlayer
        }

        queuePlayer?.play()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}
