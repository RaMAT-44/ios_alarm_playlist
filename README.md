# Music Alarm App

A powerful iOS app that functions as an alarm clock to play music from your selected playlists every morning. The app is designed to stay active and continue playing music until the phone is switched off.

## Features

### 🎵 **Music Playback**
- Play music from your device's music library
- Select from your existing playlists
- Continuous playback with playlist looping
- Music controls (play, pause, next, previous)

### ⏰ **Alarm Functionality**
- Set daily recurring alarms
- Background processing to ensure reliability
- Push notifications for alarm triggers
- Automatic music playback when alarm goes off

### 🔄 **Persistent Operation**
- App stays active in the background
- Prevents device idle timeout during alarm
- Background app refresh for continuous monitoring
- Keeps running until device is powered off

### 🎛️ **User Interface**
- Beautiful gradient design with modern UI
- Easy-to-use time picker
- Playlist selection interface
- Real-time status display
- Music controls during playback

## Technical Implementation

### Core Components

1. **AlarmManager.swift**
   - Manages alarm scheduling and notifications
   - Handles background processing
   - Triggers music playback at specified times

2. **MusicPlayer.swift**
   - Controls music playback using MediaPlayer framework
   - Manages playlist queues and song progression
   - Handles audio session configuration for background playback

3. **PlaylistManager.swift**
   - Accesses device music library
   - Manages playlist selection and authorization
   - Filters playable content

4. **ContentView.swift**
   - SwiftUI-based user interface
   - Responsive design with playlist picker
   - Real-time status updates

### Permissions Required

- **Music Library Access**: To access and play your music playlists
- **Notifications**: For alarm notifications and reminders
- **Background App Refresh**: To keep the app active in background
- **Audio Playback**: For continuous music playback

## Setup Instructions

### Prerequisites
- iOS 17.0 or later
- Xcode 15.0 or later
- Valid Apple Developer account for device testing

### Installation
1. Clone or download the project
2. Open `MusicAlarmApp.xcodeproj` in Xcode
3. Connect your iOS device
4. Build and run the app on your device

### First Time Setup
1. Grant music library access when prompted
2. Allow notification permissions
3. Enable background app refresh in Settings
4. Create playlists in the Music app if you haven't already

## Usage

### Setting Up an Alarm
1. **Select Time**: Use the time picker to set your desired alarm time
2. **Choose Playlist**: Tap "Choose Playlist" and select your preferred music playlist
3. **Activate Alarm**: Toggle the "Alarm Active" switch to ON
4. **Verify Status**: Check the status display to confirm your alarm is set

### When Alarm Triggers
- Music will automatically start playing from your selected playlist
- You'll see music controls to pause, skip, or change songs
- The app will continue playing until you tap "Stop Alarm"
- To fully stop the alarm, toggle the alarm switch to OFF

### Background Operation
- The app uses background processing to stay active
- It schedules periodic checks to ensure alarm functionality
- Music playback continues even when the app is not in foreground
- The device idle timer is disabled during alarm playback

## Technical Details

### Background Processing
- Uses `BGTaskScheduler` for background app refresh
- Implements `UIBackgroundModes` for audio playback
- Maintains active audio session for continuous playback

### Audio Session Configuration
- Configured for `.playback` category with background support
- Supports AirPlay and Bluetooth connectivity
- Handles audio interruptions gracefully

### Notification System
- Local notifications for alarm triggers
- Custom notification categories for alarm actions
- Scheduled notifications for daily recurring alarms

## Troubleshooting

### Common Issues

**Alarm doesn't go off:**
- Ensure background app refresh is enabled in Settings
- Check that notifications are allowed
- Verify the alarm toggle is ON
- Make sure the selected playlist has songs

**Music doesn't play:**
- Check music library permissions
- Verify the playlist has playable songs
- Ensure volume is turned up
- Try selecting a different playlist

**App stops working in background:**
- Enable background app refresh for the app
- Check that the phone isn't in Low Power Mode
- Ensure the app isn't force-closed from the app switcher

### Settings to Check
1. **Settings > Privacy & Security > Media & Apple Music** - Enable access
2. **Settings > Notifications** - Allow notifications for the app
3. **Settings > General > Background App Refresh** - Enable for the app
4. **Settings > Battery** - Disable Low Power Mode if active

## Important Notes

- The app requires physical device testing (simulator won't work for music playback)
- Playlists must be created in the Music app before they can be used
- The app works best with downloaded music (not streaming-only content)
- Background operation may be limited by iOS power management
- For best results, keep the device plugged in during overnight use

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Verify all permissions are granted
3. Restart the app and try again
4. Ensure your device has sufficient battery

## License

This project is created for educational and personal use. Make sure to comply with Apple's App Store guidelines if you plan to distribute the app.

---

**Note**: This app is designed to provide a reliable alarm experience with music playback. While it implements best practices for background operation, iOS may still limit background activity based on system resources and user behavior patterns.