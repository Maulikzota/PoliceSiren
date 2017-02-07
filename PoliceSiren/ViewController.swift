//
//  ViewController.swift
//  PoliceSiren
//
//  Created by Maulik on 11/18/16.
//  Copyright © 2016 Maulik. All rights reserved.
//

import UIKit
//import AVFoundation
import AudioKit

@objc public class AKFFT: NSObject, EZAudioFFTDelegate {
    
    internal let bufferSize: UInt32 = 44100
    internal var fft: EZAudioFFT?
    open var fftData = [Float](zeros: 44099)
    
    public init(_ input: AKNode) {
        super.init()
        fft = EZAudioFFT(maximumBufferSize:vDSP_Length(bufferSize), sampleRate: 44100.0, delegate: self)
        input.avAudioNode.installTap(onBus: 0, bufferSize: bufferSize, format: AudioKit.format) { [weak self] (buffer, time) -> Void in
            if let strongSelf = self {
                buffer.frameLength = strongSelf.bufferSize;
                let offset: Int = Int(buffer.frameCapacity - buffer.frameLength);
                let tail = buffer.floatChannelData?[0];
                strongSelf.fft!.computeFFT(withBuffer: &tail![offset], withBufferSize: strongSelf.bufferSize)
            }
        }
    }
    
    /// Array of FFT data
    @objc public func fft(_ fft: EZAudioFFT!, updatedWithFFTData fftData: UnsafeMutablePointer<Float>, bufferSize: vDSP_Length) {
        DispatchQueue.main.async { () -> Void in
            for i in 0...44099 {
                self.fftData[i] = Float(fftData[i])
            }
        }
    }
    
    
    
}



class ViewController: UIViewController {
    
    @IBOutlet var frequencyLabel: UILabel!
    @IBOutlet var amplitudeLabel: UILabel!
    @IBOutlet var audioAnalyse:UIButton!
//    @IBOutlet var noteNameWithSharpsLabel: UILabel!
//    @IBOutlet var noteNameWithFlatsLabel: UILabel!
//    @IBOutlet var audioInputPlot: EZAudioPlot!
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    var count=0
    var avgFreq = 0.0
    var fft:AKFFT!
    var data:[Float]!

    
    let noteFrequencies = [16.35,17.32,18.35,19.45,20.6,21.83,23.12,24.5,25.96,27.5,29.14,30.87]
    let noteNamesWithSharps = ["C", "C♯","D","D♯","E","F","F♯","G","G♯","A","A♯","B"]
    let noteNamesWithFlats = ["C", "D♭","D","E♭","E","F","G♭","G","A♭","A","B♭","B"]
    
//    func setupPlot() {
//        let plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
//        plot.plotType = .rolling
//        plot.shouldFill = true
//        plot.shouldMirror = true
//        plot.color = UIColor.blue
//        audioInputPlot.addSubview(plot)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        AKAudioFile.cleanTempDirectory()
        
        
//        AKSettings.audioInputEnabled = true
        AKSettings.sampleRate = 44100
        AKSettings.numberOfChannels = 1
        AKSettings.bufferLength = .longest

        
        do{
            try AKSettings.setSession(category: .playAndRecord, with: .defaultToSpeaker)
        } catch { print("Errored setting category.")}
        
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        tracker = AKFrequencyTracker.init(mic)
        silence = AKBooster(tracker, gain: 0)
        AudioKit.output = silence
        AudioKit.start()
    }
    
    @IBAction func recordTapped(sender: UIButton) {
        let text = audioAnalyse.titleLabel!.text
         if text == "Tap to Start"{
//            print("Start");
            audioAnalyse.setTitle("Tap to Stop", for: .normal);
            mic.start()
            fft = AKFFT(mic)
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(ViewController.updateUI), userInfo: nil, repeats: true)
         }else{
//            print("Stop");
            audioAnalyse.setTitle("Tap to Start", for: .normal);
            mic.stop();
        }
    }
    
    func updateUI() {
        
        if tracker.amplitude > 0.1 {
            print("Amplitude: ",tracker.amplitude)
            print("Frequency: ",tracker.frequency)
            data = fft.fftData
            let max = fft.fftData.max()!
            //            let index = fft.fftData.index(of: max)
            //            print("Max: ",max)
            //            print("index: ",index ?? 0.0)
//            var total=0.0
            //            var ctotal=0
//            for i in stride(from: 0, to: data.count, by: 1){
//                //                tracker2=AKFrequencyTracker.init(data[i])
//                total+=data[i]
//            }
            print("Count Data: ",data.count)
            print("Max: ",max)
            //            print("index: ",data.index(of: max) ?? 0.0)
            //            print("Total: ",total)

            
            
            frequencyLabel.text = String(format: "%0.1f Hz", tracker.frequency)
            avgFreq+=tracker.frequency;
            count+=1;
            print("Count: ",count)
            print("AvgFreq: ",avgFreq)
//            var frequency = Float(tracker.frequency)
//            while (frequency > Float(noteFrequencies[noteFrequencies.count-1])) {
//                frequency = frequency / 2.0
//            }
//            while (frequency < Float(noteFrequencies[0])) {
//                frequency = frequency * 2.0
//            }
            
//            var minDistance: Float = 10000.0
//            var index = 0
//            
//            for i in 0..<noteFrequencies.count {
//                let distance = fabsf(Float(noteFrequencies[i]) - frequency)
//                if (distance < minDistance){
//                    index = i
//                    minDistance = distance
//                }
//            }
//            let octave = Int(log2f(Float(tracker.frequency) / frequency))
//            noteNameWithSharpsLabel.text = "\(noteNamesWithSharps[index])\(octave)"
//            noteNameWithFlatsLabel.text = "\(noteNamesWithFlats[index])\(octave)"
        }
        amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
    }
    
    
    
}

//class ViewController: UIViewController,AVAudioRecorderDelegate {
//@IBOutlet var recordButton: UIButton!
//var recordingSession: AVAudioSession!
//var audioRecorder: AVAudioRecorder!
//
//
//override func viewDidLoad() {
//    super.viewDidLoad()
//    // Do any additional setup after loading the view, typically from a nib.
//    recordingSession = AVAudioSession.sharedInstance()
//    do {
//        try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
//        try recordingSession.setActive(true)
//        recordingSession.requestRecordPermission() { [unowned self] allowed in
//            DispatchQueue.main.async {
//                if allowed {
//                    self.loadRecordingUI()
//                } else {
//                    // failed to record!
//                }
//            }
//        }
//    } catch {
//        // failed to record!
//    }
//}
//override func didReceiveMemoryWarning() {
//    super.didReceiveMemoryWarning()
//    // Dispose of any resources that can be recreated.
//}
//
//func loadRecordingUI() {
//    //        recordButton = UIButton(frame: CGRect(x: 64, y: 64, width: 128, height: 64))
//    //        recordButton.setTitle("Tap to Record", for: .normal)
//    //        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
//    //        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
//    //        view.addSubview(recordButton)
//}
//
//func startRecording() {
//    print("Inside Recording")
//    let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
//    
//    let settings = [
//        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//        AVSampleRateKey: 12000,
//        AVNumberOfChannelsKey: 1,
//        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//    ]
//    
//    do {
//        audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
//        audioRecorder.delegate = self
//        audioRecorder.record()
//        print("The value of the path is: ",audioFilename)
//        recordButton.setTitle("Tap to Stop", for: .normal)
//    } catch {
//        finishRecording(success: false)
//    }
//}
//
//func getDocumentsDirectory() -> URL {
//    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//    let documentsDirectory = paths[0]
//    return documentsDirectory
//}
//
//func finishRecording(success: Bool) {
//    audioRecorder.stop()
//    audioRecorder = nil
//    
//    if success {
//        recordButton.setTitle("Tap to Re-record", for: .normal)
//    } else {
//        recordButton.setTitle("Tap to Record", for: .normal)
//        // recording failed :(
//    }
//}
//
//@IBAction func recordTapped(sender: UIButton) {
//    if audioRecorder == nil {
//        startRecording()
//    } else {
//        finishRecording(success: true)
//    }
//}
//
//func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
//    if !flag {
//        finishRecording(success: false)
//    }
//}
//}
