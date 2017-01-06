//
//  ViewController.swift
//  PoliceSiren
//
//  Created by Maulik on 11/18/16.
//  Copyright © 2016 Maulik. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    
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
