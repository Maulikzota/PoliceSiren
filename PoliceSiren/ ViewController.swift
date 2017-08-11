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

class ViewController: UIViewController {
    
    @IBOutlet var frequencyLabel: UILabel!
    @IBOutlet var amplitudeLabel: UILabel!
    @IBOutlet var audioAnalyse:UIButton!
    @IBOutlet weak var userspeed: UISlider!
    @IBOutlet var userspeedvalue: UILabel!
    @IBOutlet weak var emergencyspeed: UISlider!
    @IBOutlet var emergencyspeedvalue: UILabel!
    @IBOutlet weak var alertcounter: UISlider!
    @IBOutlet var alertcountervalue: UILabel!
    @IBOutlet var typeofvehicle: UISegmentedControl!
    var inwardVelocity: Double = 0.0;
    var stadyvelocity: Double = 0.0;
    var outwardvelocity: Double = 0.0;
    
    
//    @IBOutlet var noteNameWithSharpsLabel: UILabel!
//    @IBOutlet var noteNameWithFlatsLabel: UILabel!
//    @IBOutlet var audioInputPlot: EZAudioPlot!
    
    var mic: AKMicrophone!
    var tracker: AKFrequencyTracker!
    var silence: AKBooster!
    var acount=0
    var scount=0
    var avgFreq = 0.0
    var aflag = false
    var sflag = true
//    var fft:AKFFT!
    var data:[Double]!
    var fdata:[Double]!

    
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
//        let bpf = AKBandPassFilter(tracker)
//        bpf.centerFrequency=1500
//        bpf.bandwidth=600
        silence = AKBooster(tracker, gain: 0)
        AudioKit.output = silence
        AudioKit.start()
    }
    
    @IBAction func recordTapped(_ sender: UIButton) {
        let text = audioAnalyse.titleLabel!.text
         if text == "Tap to Start"{
//            print("Start");
            audioAnalyse.setTitle("Tap to Stop", for: .normal);
            mic.start()
//            fft = AKFFT(mic)
//            print("in start Counter: ",acount)
            Timer.scheduledTimer(timeInterval: 0.002, target: self, selector: #selector(ViewController.updateUI), userInfo: nil, repeats: true)
         }else{
//            print("Stop");
            acount=0
            self.view.backgroundColor = .white
            aflag = false
//            print("in stop Counter: ",acount)
            audioAnalyse.setTitle("Tap to Start", for: .normal);
            mic.stop();
        }
    }
    
    func calculateVelocity(_ sfrequency: Double){
        let windvelocity = 340.29
        let userv = Int(userspeed.value)
        let emerv = Int(emergencyspeed.value)
        let v1 = windvelocity+(userv * 0.44704)
        let v2 = windvelocity - (userv + emerv) * 0.44704
        let v3 = windvelocity + (userv + emerv) * 0.44704
        inwardVelocity = (v1/v2) * sfrequency
        outwardvelocity = (v1/v3)*sfrequency
        print("Frequency1: ",outwardvelocity)
        print("Frequency3: ",inwardVelocity)
    }
    
    
    @IBAction func alertCounterChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        
        alertcountervalue.text = "\(currentValue)"
    }
    
    @IBAction func userSpeedChanged(_ sender: UISlider) {
        let currentValue1 = Int(sender.value)
        
        userspeedvalue.text = "\(currentValue1)"
    }
    
    @IBAction func emergencySpeedChanged(_ sender: UISlider) {
        let currentValue2 = Int(sender.value)
        
        emergencyspeedvalue.text = "\(currentValue2)"
    }
    
    
    
    
    
    @IBAction func calculateFrequency(_ sender: UIButton){
        switch typeofvehicle.selectedSegmentIndex {
        case 0:
            calculateVelocity(495.00);
            break;
        case 1:
            calculateVelocity(1000.00);
            break;
        case 2:
            calculateVelocity(1500.00);
            break;
        default:
            calculateVelocity(1000.00);
            break;
        }
    }
    
    
    func updateUI() {
//        outwardvelocity < tracker.frequency && tracker.frequency < inwardVelocity 
         if tracker.amplitude > 0.1 {
            if( outwardvelocity < tracker.frequency){
                acount += 1
                print("Counter: ",acount)
                if(acount > Int(alertcounter.value) && aflag==false){
                    aflag = true
                    print("Alert")
                    self.view.backgroundColor = .red
                }
                if (acount < Int(alertcounter.value) && aflag==true) {
                    aflag = false
                    print("Safe")
                    self.view.backgroundColor = .green
                }
            }else{
                if(acount>0){
                    acount -= 1
                    print("Counter: ",acount)
                    if(acount < Int(alertcounter.value) && aflag==true){
                        print("Safe2")
                        aflag = false
                        self.view.backgroundColor = .blue
                    }
                }
            }
            
//            print("Amplitude: ",tracker.amplitude)
//            print("Frequency: ",tracker.frequency)
            frequencyLabel.text = String(format: "%0.1f Hz", tracker.frequency)
            }
        amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
    }
    
    
    
}
