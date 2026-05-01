import AVFoundation
import AVKit
import CoreMedia
import UIKit

final class PetPiPHost: NSObject,
                        ObservableObject,
                        AVPictureInPictureControllerDelegate,
                        AVPictureInPictureSampleBufferPlaybackDelegate {

    private let displayLayer = AVSampleBufferDisplayLayer()
    private var pipController: AVPictureInPictureController?
    private var displayLink: CADisplayLink?
    private let frameSize = CGSize(width: 360, height: 360)
    private let timescale: CMTimeScale = 12
    private var frameIndex: Int64 = 0
    private var isPaused = false

    override init() {
        super.init()
        displayLayer.videoGravity = .resizeAspect
        displayLayer.backgroundColor = UIColor.clear.cgColor

        guard AVPictureInPictureController.isPictureInPictureSupported() else { return }

        let source = AVPictureInPictureController.ContentSource(
            sampleBufferDisplayLayer: displayLayer,
            playbackDelegate: self
        )
        let controller = AVPictureInPictureController(contentSource: source)
        controller.delegate = self
        controller.requiresLinearPlayback = true
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        self.pipController = controller
    }

    func start() {
        configureAudioSessionForPiP()
        startFramePump()
        pipController?.startPictureInPicture()
    }

    func stop() {
        pipController?.stopPictureInPicture()
        stopFramePump()
    }

    private func configureAudioSessionForPiP() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("PiP audio session failed: \(error)")
        }
    }

    private func startFramePump() {
        guard displayLink == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(renderFrame))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 4, maximum: 12, preferred: 8)
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopFramePump() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func renderFrame() {
        guard !isPaused else { return }
        guard let pixelBuffer = makePixelBuffer(size: frameSize) else { return }
        drawPetFrame(into: pixelBuffer, frame: frameIndex)
        guard let sample = makeSampleBuffer(from: pixelBuffer, frameIndex: frameIndex, timescale: timescale) else { return }
        if displayLayer.status == .failed { displayLayer.flush() }
        displayLayer.enqueue(sample)
        frameIndex += 1
    }

    private func makePixelBuffer(size: CGSize) -> CVPixelBuffer? {
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        var buffer: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32BGRA, attrs as CFDictionary, &buffer)
        return buffer
    }

    private func drawPetFrame(into pixelBuffer: CVPixelBuffer, frame: Int64) {
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

        guard let context = CGContext(
            data: baseAddress,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        ) else { return }

        context.clear(CGRect(x: 0, y: 0, width: width, height: height))
        let t = CGFloat(frame % 120) / 120.0
        let bob = sin(t * .pi * 2.0) * 10.0
        let body = CGRect(x: 78, y: 88 + bob, width: 204, height: 204)

        context.setFillColor(UIColor.systemCyan.withAlphaComponent(0.68).cgColor)
        context.fillEllipse(in: body)
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.92).cgColor)
        context.setLineWidth(5)
        context.strokeEllipse(in: body.insetBy(dx: 4, dy: 4))

        context.setFillColor(UIColor.black.withAlphaComponent(0.86).cgColor)
        context.fillEllipse(in: CGRect(x: 134, y: 166 + bob, width: 28, height: 34))
        context.fillEllipse(in: CGRect(x: 224, y: 166 + bob, width: 28, height: 34))
    }

    private func makeSampleBuffer(from pixelBuffer: CVPixelBuffer, frameIndex: Int64, timescale: CMTimeScale) -> CMSampleBuffer? {
        var formatDescription: CMVideoFormatDescription?
        CMVideoFormatDescriptionCreateForImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescriptionOut: &formatDescription
        )
        guard let formatDescription else { return nil }

        var timing = CMSampleTimingInfo(
            duration: CMTime(value: 1, timescale: timescale),
            presentationTimeStamp: CMTime(value: frameIndex, timescale: timescale),
            decodeTimeStamp: .invalid
        )
        var sampleBuffer: CMSampleBuffer?
        CMSampleBufferCreateReadyWithImageBuffer(
            allocator: kCFAllocatorDefault,
            imageBuffer: pixelBuffer,
            formatDescription: formatDescription,
            sampleTiming: &timing,
            sampleBufferOut: &sampleBuffer
        )
        return sampleBuffer
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, setPlaying playing: Bool) {
        isPaused = !playing
    }

    func pictureInPictureControllerTimeRangeForPlayback(_ pictureInPictureController: AVPictureInPictureController) -> CMTimeRange {
        CMTimeRange(start: .zero, duration: CMTime(value: 1_000_000, timescale: 1))
    }

    func pictureInPictureControllerIsPlaybackPaused(_ pictureInPictureController: AVPictureInPictureController) -> Bool {
        isPaused
    }

    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, didTransitionToRenderSize newRenderSize: CMVideoDimensions) {}

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        skipByInterval skipInterval: CMTime,
        completion completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
