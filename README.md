# Dynamsoft Barcode Reader Flutter Samples

This repository contains all of the Flutter samples created by the Dynamsoft team to demonstrate the Dynamsoft Barcode Reader Flutter SDK.

## Requirements

### Dev tools

* Latest [Flutter SDK](https://flutter.dev/)
* Android: Android SDK (API Level 21+), platforms and developer tools
* iOS: iOS 13+, macOS with latest Xcode and command line tools

### Mobile platforms

* Android 5.0 (API Level 21) and higher
* iOS 13 and higher

## Integration Guide For Your Project

- [Barcode Reader Integration Guide (Ready-To-Use Edition)](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/flutter/user-guide.html)
- [Barcode Reader Integration Guide (Foundational Edition)](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/flutter/foundational-user-guide.html)
- [Driver's License Scanner Guide](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/flutter/driver-license-user-guide.html)

> [!NOTE]
> The Ready-To-Use edition comes with a fully developed and designed UI to help ease the development process and help any developer get the Barcode Reader up and running with a few lines of code. 
> 
> Alternatively, the Foundational edition is the full API that make up the Barcode Reader and does not come with its own UI. Working with the foundational API requires more effort, but allows the user to fully customize the UI and build the barcode scanner from the ground up.

## API Reference

- [BarcodeScanner APIs](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/flutter/api-reference/barcode-scanner/index.html)
- [Foundational APIs](https://www.dynamsoft.com/barcode-reader/docs/mobile/programming/flutter/api-reference/)

## Samples

| Sample Name                                                          | Description                                                                                                         |
|----------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|
| [ScanBarcodes_ReadyToUseComponent](ScanBarcodes_ReadyToUseComponent) | This sample demonstrates the simplest way to implement the Barcode Reader using the `BarcodeScanner` (Ready-To-Use) API. |
| [ScanBarcodes_FoundationalAPI](ScanBarcodes_FoundationalAPI)         | This sample demonstrates the simplest way to implement the Barcode Reader using the Foundational API.      |
| [ScanDriversLicense](ScanDriversLicense)                             | This sample demonstrates how to implement the ability to scan drivers' licenses using the Foundational API.                                          |

## Quick Start

### Step 1: Access the sample folder

```bash
cd ScanBarcodes_ReadyToUseComponent
```

or

```bash
cd ScanBarcodes_FoundationalAPI
 ```

or

```bash
cd ScanDriversLicense
 ```

### Step 2: Install the dependencies of the sample via Flutter CLI:

```
flutter pub get
```

### Step 3: Start the application

Connect a mobile device via USB and run the app.

**Android:**

```
flutter run -d <DEVICE_ID>
```

You can get the IDs of all connected devices by running `flutter devices` in the command-line.

**iOS:**

Before the app can run, the pods need to be installed first:

```
cd ios/
pod install --repo-update
```

Once the pods are installed, it is recommended to run the iOS portion of the app via Xcode as such:

1. Open the generated **xcworkspace** (found at `ios/Runner.xcworkspace`) in Xcode 
2. Access the *Signing & Capabilities* section of the project settings and ensure that it is configured correctly. 
3. Lastly, select the connected physical iOS device and proceed to build and run the app.

> [!NOTE]
>- The license string here grants a time-limited free trial which requires a network connection to work.
>- You can request a 30-day trial license via
   the [Request a Trial License](https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=guide&package=mobile) link.

## License

- You can request a 30-day trial license via the [Trial License](https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=github&package=mobile) portal.

## Support

https://www.dynamsoft.com/company/contact/
