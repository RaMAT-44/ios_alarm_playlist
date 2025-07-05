import Foundation
import MediaPlayer

class PlaylistManager: ObservableObject {
    static let shared = PlaylistManager()
    
    @Published var playlists: [MPMediaPlaylist] = []
    @Published var selectedPlaylist: MPMediaPlaylist?
    @Published var authorizationStatus: MPMediaLibraryAuthorizationStatus = .notDetermined
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        authorizationStatus = MPMediaLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            loadPlaylists()
        case .notDetermined:
            requestAuthorization()
        case .denied, .restricted:
            print("Media library access denied")
        @unknown default:
            print("Unknown authorization status")
        }
    }
    
    func requestAuthorization() {
        MPMediaLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                if status == .authorized {
                    self?.loadPlaylists()
                }
            }
        }
    }
    
    func loadPlaylists() {
        guard authorizationStatus == .authorized else {
            print("Not authorized to access media library")
            return
        }
        
        let query = MPMediaQuery.playlists()
        guard let collections = query.collections else {
            print("No playlists found")
            return
        }
        
        let validPlaylists = collections.compactMap { $0 as? MPMediaPlaylist }
            .filter { playlist in
                // Filter out empty playlists and system playlists
                guard let items = playlist.items as? [MPMediaItem],
                      !items.isEmpty else {
                    return false
                }
                
                // Check if playlist has playable items
                let playableItems = items.filter { item in
                    guard let assetURL = item.assetURL else { return false }
                    return assetURL.scheme == "ipod-library" || assetURL.scheme == "file"
                }
                
                return !playableItems.isEmpty
            }
        
        DispatchQueue.main.async {
            self.playlists = validPlaylists
            
            // If no playlist is selected, select the first one
            if self.selectedPlaylist == nil && !validPlaylists.isEmpty {
                self.selectedPlaylist = validPlaylists.first
            }
        }
        
        // Also create a default "All Songs" playlist if no playlists exist
        if validPlaylists.isEmpty {
            createDefaultPlaylist()
        }
    }
    
    private func createDefaultPlaylist() {
        let songsQuery = MPMediaQuery.songs()
        guard let songs = songsQuery.items, !songs.isEmpty else {
            print("No songs found in library")
            return
        }
        
        // Create a virtual "All Songs" playlist
        let allSongsCollection = MPMediaItemCollection(items: songs)
        
        // We can't create actual playlists programmatically, so we'll use the songs collection
        // For now, we'll use the first available playlist or suggest user to create one
        print("Found \(songs.count) songs in library")
        
        DispatchQueue.main.async {
            // If we have songs but no playlists, we can still work with individual songs
            if self.playlists.isEmpty {
                print("No playlists available. User should create playlists in Music app.")
            }
        }
    }
    
    func getSongsFromPlaylist(_ playlist: MPMediaPlaylist) -> [MPMediaItem] {
        guard let items = playlist.items as? [MPMediaItem] else {
            return []
        }
        
        return items.filter { item in
            // Filter for playable items
            guard let assetURL = item.assetURL else { return false }
            return assetURL.scheme == "ipod-library" || assetURL.scheme == "file"
        }
    }
    
    func selectPlaylist(_ playlist: MPMediaPlaylist) {
        selectedPlaylist = playlist
    }
    
    func getPlaylistInfo(_ playlist: MPMediaPlaylist) -> (name: String, songCount: Int) {
        let name = playlist.name ?? "Unknown Playlist"
        let songCount = getSongsFromPlaylist(playlist).count
        return (name: name, songCount: songCount)
    }
}