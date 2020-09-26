//
//  BackgroundMusic.swift
//  SpeedTyper
//
//  Created by Carlos Rivas on 8/14/19.
//  Copyright © 2019 CarlosRivas. All rights reserved.
//

import Foundation
import AVFoundation

class BackgroundMusic {
    static let shared = BackgroundMusic()
    private var audioPlayer: AVAudioPlayer?
    private var isPaused = false;
    
    //Will Play Music
    func startBackgroundMusic() {
        if let bundle = Bundle.main.path(forResource: "Midnight_Cassette_Urban_Mix_Cut", ofType: "mp3") {
            let backgroundMusic = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf:backgroundMusic as URL)
                guard let audioPlayer = audioPlayer else { return }
                audioPlayer.numberOfLoops = -1
                audioPlayer.volume = 0.25
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                isPaused = false;
            } catch {
                print(error)
            }
        }
    }
    
    //Will Stop Music
    func stopBackgroundMusic() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.stop()
    }
    
    //Will Pause Music
    func pauseBackgroundMusic() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.pause()
        isPaused = true;
    }
    
    //Will Resume Music
    func resumeBackgroundMusic() {
        guard let audioPlayer = audioPlayer else { return }
        if (!isPaused) { return }
        audioPlayer.play()
        isPaused = false;
    }
    
    //Returns whether the Audio Player is currently playing
    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
}
