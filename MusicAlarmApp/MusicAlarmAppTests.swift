import XCTest
@testable import MusicAlarmApp

final class MusicAlarmAppTests: XCTestCase {
    
    var alarmManager: AlarmManager!
    var musicPlayer: MusicPlayer!
    var playlistManager: PlaylistManager!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        alarmManager = AlarmManager()
        musicPlayer = MusicPlayer()
        playlistManager = PlaylistManager()
    }
    
    override func tearDownWithError() throws {
        alarmManager = nil
        musicPlayer = nil
        playlistManager = nil
        try super.tearDownWithError()
    }
    
    // MARK: - AlarmManager Tests
    
    func testAlarmManagerInitialization() throws {
        XCTAssertNotNil(alarmManager, "AlarmManager should be initialized successfully")
    }
    
    func testAlarmCreation() throws {
        let testDate = Date().addingTimeInterval(3600) // 1 hour from now
        let alarm = alarmManager.createAlarm(time: testDate, isEnabled: true, label: "Test Alarm")
        
        XCTAssertNotNil(alarm, "Alarm should be created successfully")
        XCTAssertEqual(alarm.time, testDate, "Alarm time should match the provided time")
        XCTAssertTrue(alarm.isEnabled, "Alarm should be enabled")
        XCTAssertEqual(alarm.label, "Test Alarm", "Alarm label should match")
    }
    
    func testAlarmScheduling() throws {
        let testDate = Date().addingTimeInterval(60) // 1 minute from now
        let alarm = alarmManager.createAlarm(time: testDate, isEnabled: true, label: "Scheduled Alarm")
        
        let expectation = XCTestExpectation(description: "Alarm should be scheduled")
        
        alarmManager.scheduleAlarm(alarm) { success in
            XCTAssertTrue(success, "Alarm should be scheduled successfully")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAlarmCancellation() throws {
        let testDate = Date().addingTimeInterval(120) // 2 minutes from now
        let alarm = alarmManager.createAlarm(time: testDate, isEnabled: true, label: "Cancelled Alarm")
        
        alarmManager.scheduleAlarm(alarm) { _ in
            self.alarmManager.cancelAlarm(alarm) { success in
                XCTAssertTrue(success, "Alarm should be cancelled successfully")
            }
        }
    }
    
    // MARK: - MusicPlayer Tests
    
    func testMusicPlayerInitialization() throws {
        XCTAssertNotNil(musicPlayer, "MusicPlayer should be initialized successfully")
    }
    
    func testPlaylistLoading() throws {
        let expectation = XCTestExpectation(description: "Playlist should load")
        
        musicPlayer.loadPlaylist { success in
            XCTAssertTrue(success, "Playlist should load successfully")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testMusicPlayback() throws {
        let expectation = XCTestExpectation(description: "Music should play")
        
        musicPlayer.play { success in
            XCTAssertTrue(success, "Music should start playing")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testMusicPause() throws {
        musicPlayer.play { _ in
            self.musicPlayer.pause { success in
                XCTAssertTrue(success, "Music should pause successfully")
            }
        }
    }
    
    func testVolumeControl() throws {
        let testVolume: Float = 0.5
        musicPlayer.setVolume(testVolume) { success in
            XCTAssertTrue(success, "Volume should be set successfully")
        }
    }
    
    // MARK: - PlaylistManager Tests
    
    func testPlaylistManagerInitialization() throws {
        XCTAssertNotNil(playlistManager, "PlaylistManager should be initialized successfully")
    }
    
    func testPlaylistCreation() throws {
        let playlist = playlistManager.createPlaylist(name: "Test Playlist")
        XCTAssertNotNil(playlist, "Playlist should be created successfully")
        XCTAssertEqual(playlist.name, "Test Playlist", "Playlist name should match")
    }
    
    func testSongAddition() throws {
        let playlist = playlistManager.createPlaylist(name: "Test Playlist")
        let song = Song(title: "Test Song", artist: "Test Artist", duration: 180)
        
        playlistManager.addSong(song, to: playlist) { success in
            XCTAssertTrue(success, "Song should be added to playlist successfully")
        }
    }
    
    func testPlaylistRetrieval() throws {
        let playlist = playlistManager.createPlaylist(name: "Retrieval Test")
        let song = Song(title: "Test Song", artist: "Test Artist", duration: 180)
        
        playlistManager.addSong(song, to: playlist) { _ in
            self.playlistManager.getPlaylists { playlists in
                XCTAssertNotNil(playlists, "Playlists should be retrieved")
                XCTAssertTrue(playlists.contains { $0.name == "Retrieval Test" }, "Created playlist should be in the list")
            }
        }
    }
    
    // MARK: - Integration Tests
    
    func testAlarmWithMusicIntegration() throws {
        let testDate = Date().addingTimeInterval(300) // 5 minutes from now
        let alarm = alarmManager.createAlarm(time: testDate, isEnabled: true, label: "Music Alarm")
        
        let playlist = playlistManager.createPlaylist(name: "Alarm Playlist")
        let song = Song(title: "Wake Up Song", artist: "Morning Artist", duration: 240)
        
        playlistManager.addSong(song, to: playlist) { _ in
            alarm.playlist = playlist
            
            alarmManager.scheduleAlarm(alarm) { success in
                XCTAssertTrue(success, "Alarm with music should be scheduled successfully")
            }
        }
    }
    
    func testMultipleAlarms() throws {
        let alarm1 = alarmManager.createAlarm(time: Date().addingTimeInterval(60), isEnabled: true, label: "Alarm 1")
        let alarm2 = alarmManager.createAlarm(time: Date().addingTimeInterval(120), isEnabled: true, label: "Alarm 2")
        
        alarmManager.scheduleAlarm(alarm1) { success1 in
            XCTAssertTrue(success1, "First alarm should be scheduled")
            
            self.alarmManager.scheduleAlarm(alarm2) { success2 in
                XCTAssertTrue(success2, "Second alarm should be scheduled")
            }
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidAlarmTime() throws {
        let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
        let alarm = alarmManager.createAlarm(time: pastDate, isEnabled: true, label: "Past Alarm")
        
        alarmManager.scheduleAlarm(alarm) { success in
            XCTAssertFalse(success, "Alarm with past time should not be scheduled")
        }
    }
    
    func testEmptyPlaylist() throws {
        let playlist = playlistManager.createPlaylist(name: "Empty Playlist")
        
        playlistManager.getSongs(in: playlist) { songs in
            XCTAssertEqual(songs.count, 0, "Empty playlist should have no songs")
        }
    }
    
    // MARK: - Performance Tests
    
    func testAlarmManagerPerformance() throws {
        measure {
            for i in 1...100 {
                let testDate = Date().addingTimeInterval(Double(i * 60))
                _ = alarmManager.createAlarm(time: testDate, isEnabled: true, label: "Performance Test \(i)")
            }
        }
    }
    
    func testPlaylistManagerPerformance() throws {
        measure {
            for i in 1...50 {
                let playlist = playlistManager.createPlaylist(name: "Performance Playlist \(i)")
                let song = Song(title: "Song \(i)", artist: "Artist \(i)", duration: 180)
                playlistManager.addSong(song, to: playlist) { _ in }
            }
        }
    }
    
    // MARK: - Data Persistence Tests
    
    func testAlarmPersistence() throws {
        let testDate = Date().addingTimeInterval(600) // 10 minutes from now
        let alarm = alarmManager.createAlarm(time: testDate, isEnabled: true, label: "Persistent Alarm")
        
        alarmManager.saveAlarms { success in
            XCTAssertTrue(success, "Alarms should be saved successfully")
            
            self.alarmManager.loadAlarms { alarms in
                XCTAssertNotNil(alarms, "Alarms should be loaded successfully")
                XCTAssertTrue(alarms.contains { $0.label == "Persistent Alarm" }, "Saved alarm should be in loaded alarms")
            }
        }
    }
    
    func testPlaylistPersistence() throws {
        let playlist = playlistManager.createPlaylist(name: "Persistent Playlist")
        let song = Song(title: "Persistent Song", artist: "Persistent Artist", duration: 200)
        
        playlistManager.addSong(song, to: playlist) { _ in
            self.playlistManager.savePlaylists { success in
                XCTAssertTrue(success, "Playlists should be saved successfully")
                
                self.playlistManager.loadPlaylists { playlists in
                    XCTAssertNotNil(playlists, "Playlists should be loaded successfully")
                    XCTAssertTrue(playlists.contains { $0.name == "Persistent Playlist" }, "Saved playlist should be in loaded playlists")
                }
            }
        }
    }
}

// MARK: - Helper Models

struct Song {
    let title: String
    let artist: String
    let duration: TimeInterval
}

struct Alarm {
    let id: UUID
    var time: Date
    var isEnabled: Bool
    var label: String
    var playlist: Playlist?
    
    init(time: Date, isEnabled: Bool, label: String) {
        self.id = UUID()
        self.time = time
        self.isEnabled = isEnabled
        self.label = label
        self.playlist = nil
    }
}

struct Playlist {
    let id: UUID
    let name: String
    var songs: [Song]
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.songs = []
    }
} 