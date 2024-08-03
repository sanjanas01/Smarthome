# Smart Home App

A Flutter application designed to manage smart devices from anywhere with ease. Users can add and control devices from a single, intuitive interface.

## Features

- User authentication with Firebase
- Add locations
- View and manage devices in each location
- Temperature adjustment

## Prerequisites

- Flutter SDK
- Firebase account

## Setup

### 1. Clone the Repository

git clone https://github.com/sanjanas01/Smarthome.git
cd Smarthome


### 2. Install Dependencies

Ensure you have Flutter installed and run:

flutter pub get

### 3. Run the App

Make sure your emulator or device is running, then execute:
flutter run
Note: I have used a Pixel 7 API 34 emulator(412*915 dp Resolution)

How It Works
1. User Login
Upon launching the app, users are prompted to sign in with their account. If they don't have an account, they can create one through Firebase Authentication.

2. Home Page
After logging in, users are directed to the Home Page, where they can:

Add Locations: Enter a location name and tap "Add Location" to save it. Locations help in organizing devices by their physical placement.
View Locations: A list of added locations is displayed. Tap on any location to manage the devices associated with it.

3. Devices Page
When a location is selected, users are taken to the Devices Page, where they can:

Add Devices: Tap the "+" button to add a new device. Enter the device name.
View Devices: Devices are displayed horizontally. Tap on a device to change its background .
Toggle Device State: Tap the circle icon on a device to toggle its active/inactive state.
Change Temperature: Use the temperature widget to set and adjust the temperature.


## Directory Structure

- `lib/`
  - `main.dart`: Entry point of the application.
  - `home.dart`: Screen for managing locations.
  - `devices.dart`: Screen for managing devices.
  - `login.dart`: Page for user login.
  - `create.dart`: Page for creating a new user account.
  - `settings.dart`: Placeholder page for future settings options.


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
