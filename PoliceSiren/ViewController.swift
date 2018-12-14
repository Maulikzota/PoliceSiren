//
//  ViewController.swift
//  PoliceSiren
//
//  Created by Maulik on 11/18/16.
//  Copyright © 2016 Maulik. All rights reserved.
//

//importing UIKit and AudioKit library v4.3
import UIKit
import AudioKit

class ViewController: UIViewController {
    
    //Initiallizing variables
    //Label to display the frequency of the sound
    @IBOutlet var frequencyLabel: UILabel!
    
    //Label to display the amplitude of the sound
    @IBOutlet var amplitudeLabel: UILabel!
    
    //Button to Start and Stop Recording
    @IBOutlet var audioAnalyse:UIButton!
    
    //Slider to enter User vehicle Speed
    @IBOutlet weak var userspeed: UISlider!
    
    //Label to display the entered user vehicle speed
    @IBOutlet var userspeedvalue: UILabel!
    
    //Slider to enter emergency vehicle Speed greater than user's speed
    @IBOutlet weak var emergencyspeed: UISlider!
    
    //Label to display the emergency vehicle Speed
    @IBOutlet var emergencyspeedvalue: UILabel!
    
    //Slider to enter the counter for alert
    @IBOutlet weak var alertcounter: UISlider!
    
    //Label to display the counter value
    @IBOutlet weak var alertcountervalue: UILabel!
    
    //Segement for changing type of emergency vehicle
    @IBOutlet var typeofvehicle: UISegmentedControl!
    
    //Inward velocity for emergency vehicle
    var inwardVelocity: Double = 0.0;
    
    //Outward velocity for emergency vehicle
    var outwardvelocity: Double = 0.0;
    
    //Variable to access Microphone
    var mic: AKMicrophone!
    
    //Variable to track the frequency
    var tracker: AKFrequencyTracker!
    
    //Variable for highpass filter
    var highpassfilter : AKHighPassFilter!
    var silence: AKBooster!
    
    //Variable for alert counter
    var acount=0
    
    //Variable for safe counter
    var scount=0
    
    //Variable for alert flag
    var aflag = false
    
    //Variable for safe flag
    var sflag = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Settings for recording the audio files
        AKAudioFile.cleanTempDirectory()
        AKSettings.audioInputEnabled = true
        
        //Initializing sample rate to 44100
        AKSettings.sampleRate = 44100
        AKSettings.bufferLength = .longest
        
        do  {
            try AKSettings.setSession(category: .playAndRecord, with: .defaultToSpeaker)
        }catch {
            print("Errored setting category.")
        }
        
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        
        //Using Highpass filter for removing any frequency that does not fall in the given criteria
        highpassfilter = AKHighPassFilter(mic)
        highpassfilter.cutoffFrequency = 3500
        highpassfilter.resonance = 0.0
        tracker = AKFrequencyTracker.init(highpassfilter)
        silence = AKBooster(tracker, gain: 0)
        AudioKit.output = silence
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
    }
    
    //Start/Stop button for staring and stopping the application.
    @IBAction func recordTapped(_ sender: UIButton) {
        let text = audioAnalyse.titleLabel!.text
        if text == "Tap to Start"{
            audioAnalyse.setTitle("Tap to Stop", for: .normal);
            mic.start()
            
            //Timer for scheduling the recording of sound input
            Timer.scheduledTimer(timeInterval: 0.015, target: self, selector: #selector(ViewController.updateUI), userInfo: nil, repeats: true)
        }else{
            
            //Initializing the initial values for alert flag and alert counter
            acount=0
            self.view.backgroundColor = .white
            aflag = false
            audioAnalyse.setTitle("Tap to Start", for: .normal);
            mic.stop();
        }
    }
    
    //Calculating the frequency range using the Doppler effect
    //Assuming the wind velocity as 340.29m/s
    //Conversion factor from miles/hr to meters/sec is 0.44704
    
    func calculateVelocity(_ sfrequency: Double){
        let windvelocity = 340.29
        let userv = Int(userspeed.value)
        let emerv = Int(emergencyspeed.value)
        let v1 = windvelocity+(userv * 0.44704)
        let v2 = windvelocity - (userv + emerv) * 0.44704
        let v3 = windvelocity + (userv + emerv) * 0.44704
        inwardVelocity = (v1/v2) * sfrequency
        outwardvelocity = (v1/v3) * sfrequency
        print("Frequency1 or Outward: ",outwardvelocity)
        print("Frequency3 or Inward: ",inwardVelocity)
    }
    
    //User input for setting the counter for considering the alert
    //Ideal counter is 15 to 17
    @IBAction func alertCounterChanged(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        alertcountervalue.text = "\(currentValue)"
    }
    
    //User input for setting users driving speed of the vehicle
    //Ideal value would be close to 45miles/hr to 55miles/hr
    @IBAction func userSpeedChanged(_ sender: UISlider) {
        let currentValue1 = Int(sender.value)
        userspeedvalue.text = "\(currentValue1)"
    }
    
    //User input for setting emergency vehicle's speed greater than user's vehicle speed
    //Ideal value would be close to 5miles/hr to 10miles/hr greater than user's vehicle speed
    @IBAction func emergencySpeedChanged(_ sender: UISlider) {
        let currentValue2 = Int(sender.value)
        emergencyspeedvalue.text = "\(currentValue2)"
    }
    
    //Segmented options for emergency vehicle's frequency
    //Ideal settings for any emergency vehicle would be between 1500 to 2000
    @IBAction func calculateFrequency(_ sender: UIButton){
        switch typeofvehicle.selectedSegmentIndex {
        case 0:
            calculateVelocity(1500.00);
            break;
        case 1:
            calculateVelocity(1500.00);
            break;
        case 2:
            calculateVelocity(2000.00);
            break;
        default:
            calculateVelocity(1500.00);
            break;
        }
    }
    
    //UpdateUI function for constantly changing the frequency's from the surrounding
    @objc func updateUI() {
        
        //Considering the Amplitude factor as 0.15 because most of the emergency vehicle has
        //amplitude or loudness greater than 0.15.
        if tracker.amplitude > 0.10 {
           
            //Condition for checing the range of the frequency using doppler effect
            if( inwardVelocity < tracker.frequency || outwardvelocity > tracker.frequency){
                
                //If the frequency falls within the range then the alert counter increments
                //Also at the same time the safe counter decrements
                acount += 1
                if scount>0 {
                    scount -= 1
                }
                
                //If the alert counter is more then the value and alert flag was false
                //than the screen color is changed to red for alert, alert flag
                //is set to true and safe counter set to zero.
                if(acount > Int(alertcounter.value) && aflag==false){
                    aflag = true
                    scount=0
                    self.view.backgroundColor = .red
                }
            }
                
                //If the frequency is not within the range than the safe counter
                //increases and alert counter decreases
            else{    
                if(acount>0){
                    scount += 1
                    acount -= 1
                    
                    //If the safe counter is more then the value, alert counter is less
                    //than the set value and alert flag was true than the screen color is
                    //changed to green for safe, alert flag is set to false.
                    if(acount < Int(alertcounter.value) && aflag==true && scount > Int(alertcounter.value)){
                        aflag = false
                        self.view.backgroundColor = .green
                    }
                }
            }
            
            frequencyLabel.text = String(format: "%0.1f Hz", tracker.frequency)
        }
        //If the amplitude fator is less than 0.1 which means than there is no more emergency
        //vehicle around or there is nothing much to analyze so the screen color is changed
        //back to white, alert flag set to false and alert counter set to zero.
        if  tracker.amplitude < 0.1{
            self.view.backgroundColor = .white
            aflag = false
            acount=0
        }
        amplitudeLabel.text = String(format: "%0.2f", tracker.amplitude)
    }
    
    
    
}

