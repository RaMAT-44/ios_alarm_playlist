import SwiftUI
import MediaPlayer

struct ContentView: View {
    @StateObject private var alarmManager = AlarmManager.shared
    @StateObject private var musicPlayer = MusicPlayer.shared
    @StateObject private var playlistManager = PlaylistManager.shared
    @State private var selectedTime = Date()
    @State private var showingPlaylistPicker = false
    @State private var isAlarmOn = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [.purple.opacity(0.6), .blue.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        VStack(spacing: 10) {
                            Image(systemName: "alarm.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                            
                            Text("Music Alarm")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        // Alarm Time Picker
                        VStack(spacing: 15) {
                            Text("Set Alarm Time")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            DatePicker("Alarm Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(15)
                                .padding(.horizontal)
                        }
                        
                        // Playlist Selection
                        VStack(spacing: 15) {
                            Text("Select Playlist")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Button(action: { showingPlaylistPicker = true }) {
                                HStack {
                                    Image(systemName: "music.note.list")
                                    Text(playlistManager.selectedPlaylist?.name ?? "Choose Playlist")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(15)
                                .foregroundColor(.black)
                            }
                            .padding(.horizontal)
                        }
                        
                        // Alarm Toggle
                        VStack(spacing: 15) {
                            Toggle("Alarm Active", isOn: $isAlarmOn)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .onChange(of: isAlarmOn) { value in
                                    if value {
                                        alarmManager.scheduleAlarm(at: selectedTime)
                                    } else {
                                        alarmManager.cancelAlarm()
                                    }
                                }
                        }
                        
                        // Current Status
                        VStack(spacing: 10) {
                            Text("Status")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text(alarmManager.isAlarmActive ? "Alarm is set for \(selectedTime.formatted(date: .omitted, time: .shortened))" : "No alarm set")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .background(Color.black.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        // Music Controls (when alarm is playing)
                        if musicPlayer.isPlaying {
                            VStack(spacing: 15) {
                                Text("Now Playing")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Text(musicPlayer.currentSong?.title ?? "Unknown")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                
                                HStack(spacing: 30) {
                                    Button(action: { musicPlayer.previousSong() }) {
                                        Image(systemName: "backward.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Button(action: { musicPlayer.pausePlayback() }) {
                                        Image(systemName: "pause.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Button(action: { musicPlayer.nextSong() }) {
                                        Image(systemName: "forward.fill")
                                            .font(.title)
                                            .foregroundColor(.white)
                                    }
                                }
                                
                                Button("Stop Alarm") {
                                    musicPlayer.stopPlayback()
                                    isAlarmOn = false
                                }
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(15)
                            }
                            .padding()
                            .background(Color.black.opacity(0.2))
                            .cornerRadius(15)
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingPlaylistPicker) {
            PlaylistPickerView()
        }
        .onAppear {
            playlistManager.loadPlaylists()
        }
    }
}

struct PlaylistPickerView: View {
    @StateObject private var playlistManager = PlaylistManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List(playlistManager.playlists, id: \.persistentID) { playlist in
                Button(action: {
                    playlistManager.selectedPlaylist = playlist
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "music.note.list")
                            .foregroundColor(.blue)
                        VStack(alignment: .leading) {
                            Text(playlist.name ?? "Unknown Playlist")
                                .font(.headline)
                            Text("\(playlist.items.count) songs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if playlist.persistentID == playlistManager.selectedPlaylist?.persistentID {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .foregroundColor(.primary)
            }
            .navigationTitle("Select Playlist")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}