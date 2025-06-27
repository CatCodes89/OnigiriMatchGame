//
//  AudioManager.swift
//  OnigiriMatchGame
//
//  Created by Cathy on 2025-06-27.
//

import AVFoundation

class AudioManager {
    static let shared = AudioManager()

    var audioPlayer: AVAudioPlayer?

    func playBackgroundMusic(named fileName: String) {
        if audioPlayer == nil || audioPlayer?.isPlaying == false {
            if let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") {
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.numberOfLoops = -1 // Loop forever
                    audioPlayer?.volume = 0.1
                    audioPlayer?.prepareToPlay()
                    audioPlayer?.play()
                } catch {
                    print("Could not play background music: \(error)")
                }
            }
        }
    }

    func stopBackgroundMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
}
