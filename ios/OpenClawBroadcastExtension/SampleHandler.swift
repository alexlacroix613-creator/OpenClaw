import ReplayKit
import CoreMedia
import CoreVideo

final class SampleHandler: RPBroadcastSampleHandler {
    private let frameGate = FrameGate(maxFramesPerSecond: 1)
    private let uploader = BroadcastUploader()

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        uploader.startSession()
    }

    override func broadcastPaused() {
        uploader.pauseSession()
    }

    override func broadcastResumed() {
        uploader.resumeSession()
    }

    override func broadcastFinished() {
        uploader.endSession()
    }

    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        guard sampleBufferType == .video else { return }
        guard frameGate.shouldAcceptFrame() else { return }
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        uploader.processFrame(imageBuffer)
    }
}

final class FrameGate {
    private let minInterval: TimeInterval
    private var lastFrameAt: Date?

    init(maxFramesPerSecond: Double) {
        self.minInterval = 1.0 / maxFramesPerSecond
    }

    func shouldAcceptFrame() -> Bool {
        let now = Date()
        if let lastFrameAt, now.timeIntervalSince(lastFrameAt) < minInterval {
            return false
        }
        lastFrameAt = now
        return true
    }
}

final class BroadcastUploader {
    func startSession() {
        // Notify backend that explicit watch mode started.
    }

    func pauseSession() {}
    func resumeSession() {}

    func endSession() {
        // Notify backend that explicit watch mode ended.
    }

    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        // MVP rules:
        // 1. Downscale frame.
        // 2. Run local OCR/redaction first.
        // 3. Drop sensitive frames.
        // 4. Upload summary, not raw frames, unless user explicitly opts into richer analysis.
    }
}
