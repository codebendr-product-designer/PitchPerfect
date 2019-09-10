//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by codebendr on 06/09/2019.
//  Copyright © 2019 just pixel. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController {
    
    var audioRecorder: AVAudioRecorder!
    let stopRecordingSegue = "stopRecordingSegue"
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
    }
    
    func configureUI(isRecording: Bool) {
        recordingLabel.text = isRecording ? "Recording in Progress" : "Tap to Record"
        stopRecordingButton.isEnabled = isRecording
        recordButton.isEnabled = !isRecording
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true)
            audioRecorder = try AVAudioRecorder(url: filePath!, settings: [:])
            audioRecorder.delegate = self
            print("recording")
        } catch {
            print("error recording")
        }
        
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        
        configureUI(isRecording: true)
        
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        audioRecorder.stop()
        try! AVAudioSession.sharedInstance().setActive(false)
        configureUI(isRecording: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination
        if let playSoundsViewController = destination as? PlaySoundsViewController {
            playSoundsViewController.recordedAudioURL = sender as? URL
        }
    }
    
}

// MARK: - AVAudioRecorderDelegate
extension RecordSoundsViewController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: stopRecordingSegue, sender: recorder.url)
        } else {
            let alert = Alerts.show(Alerts.AudioRecordingError, message: Alerts.RecordingFailedMessage)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

