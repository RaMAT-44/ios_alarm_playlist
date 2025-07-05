import Foundation
import MediaPlayer
import AVFoundation

class MusicPlayer: ObservableObject {
    static let shared = MusicPlayer()
    
    @Published var isPlaying = false
    @Published var currentSong: MPMediaItem?
    @Published var currentPlaylist: [MPMediaItem] = []
    @Published var currentIndex = 0
    
    private let player = MPMusicPlayerController.applicationMusicPlayer
    private var timer: Timer?
    
    private init() {
        setupPlayer()
        setupNotifications()
    }
    
    private func setupPlayer() {
        // Configure audio session for background playback
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetooth])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session: \(error)")
        }
        
        // Configure music player
        player.repeatMode = .all
        player.shuffleMode = .off
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playbackStateChanged),
            name: .MPMusicPlayerControllerPlaybackStateDidChange,
            object: player
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nowPlayingItemChanged),
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: player
        )
        
        player.beginGeneratingPlaybackNotifications()
    }
    
    func startPlayback() {
        guard let selectedPlaylist = PlaylistManager.shared.selectedPlaylist else {
            print("No playlist selected")
            return
        }
        
        let songs = selectedPlaylist.items.compactMap { $0 as? MPMediaItem }
        guard !songs.isEmpty else {
            print("No songs in playlist")
            return
        }
        
        currentPlaylist = songs
        currentIndex = 0
        
        let mediaItemCollection = MPMediaItemCollection(items: songs)
        player.setQueue(with: mediaItemCollection)
        player.play()
        
        DispatchQueue.main.async {
            self.isPlaying = true
            self.currentSong = songs.first
        }
        
        // Start timer to keep app alive
        startKeepAliveTimer()
    }
    
    func pausePlayback() {
        player.pause()
        DispatchQueue.main.async {
            self.isPlaying = false
        }
    }
    
    func resumePlayback() {
        player.play()
        DispatchQueue.main.async {
            self.isPlaying = true
        }
    }
    
    func stopPlayback() {
        player.stop()
        timer?.invalidate()
        timer = nil
        
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentSong = nil
        }
        
        // Re-enable idle timer
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func nextSong() {
        if currentIndex < currentPlaylist.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = 0 // Loop back to first song
        }
        
        player.skipToNextItem()
        updateCurrentSong()
    }
    
    func previousSong() {
        if currentIndex > 0 {
            currentIndex -= 1
        } else {
            currentIndex = currentPlaylist.count - 1 // Loop to last song
        }
        
        player.skipToPreviousItem()
        updateCurrentSong()
    }
    
    private func updateCurrentSong() {
        DispatchQueue.main.async {
            if self.currentIndex < self.currentPlaylist.count {
                self.currentSong = self.currentPlaylist[self.currentIndex]
            }
        }
    }
    
    private func startKeepAliveTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // This timer helps keep the app active
            // We can add periodic tasks here if needed
        }
    }
    
    @objc private func playbackStateChanged() {
        DispatchQueue.main.async {
            switch self.player.playbackState {
            case .playing:
                self.isPlaying = true
            case .paused, .stopped:
                self.isPlaying = false
            default:
                break
            }
        }
    }
    
    @objc private func nowPlayingItemChanged() {
        DispatchQueue.main.async {
            self.currentSong = self.player.nowPlayingItem
            
            // Update current index
            if let nowPlaying = self.player.nowPlayingItem,
               let index = self.currentPlaylist.firstIndex(of: nowPlaying) {
                self.currentIndex = index
            }
        }
    }
    
    deinit {
        player.endGeneratingPlaybackNotifications()
        timer?.invalidate()
    }
}