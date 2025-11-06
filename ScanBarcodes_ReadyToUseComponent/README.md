# ScanBarcodes_ReadyToUseComponent Sample

This simple sample uses the camera to read a single barcode using the BarcodeScanner API.

## Requirements

### Dev tools

* Latest [Flutter SDK](https://flutter.dev/)
* For Android apps: Android SDK (API Level 21+), platforms and developer tools
* For iOS apps: iOS 13+, macOS with latest Xcode and command line tools

### Mobile platforms

* Android 5.0 (API Level 21) and higher
* iOS 13 and higher

## How to run the sample app

### Step 1: Install Flutter & Dependencies

Install [Flutter](https://flutter.dev/) and all required dev tools.

Clone this repository and navigate to the project directory.

```
cd ScanBarcodes_ReadyToUseComponent/
```

Fetch and install the dependencies of this example project via Flutter CLI:

```
flutter pub get
```

Connect a mobile device via USB and run the app.

### Step 2: Start your application

**Android:**

```
flutter run -d <DEVICE_ID>
```

You can get the IDs of all connected devices with `flutter devices`.

**iOS:**

Install Pods dependencies:

```
cd ios/
pod install --repo-update
```

Open the **workspace**(!) `ios/Runner.xcworkspace` in Xcode and adjust the *Signing / Developer Account* settings. Then, build and run the app in Xcode.

> [!NOTE]
>- The license string here grants a time-limited free trial which requires network connection to work.
>- You can request a 30-day trial license via the [Request a Trial License](https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=guide&package=mobile) link.

## Supported Barcode Symbologies

| Linear Barcodes (1D) | 2D Barcodes | Others |
| :------------------- | :---------- | :----- |
| Code 39 (including Code 39 Extended)<br>Code 93<br>Code 128<br>Codabar<br>Interleaved 2 of 5<br>EAN-8<br>EAN-13<br>UPC-A<br>UPC-E<br>Industrial 2 of 5<br><br><br><br><br><br><br><br> | QR Code (including Micro QR Code and Model 1)<br>Data Matrix<br>PDF417 (including Micro PDF417)<br>Aztec Code<br>MaxiCode (mode 2-5)<br>DotCode<br><br><br><br><br><br><br><br><br><br><br><br> | Patch Code<br><br>GS1 Composite Code<br><br>GS1 DataBar<br><li>Omnidirectional</li><li>Truncated, Stacked</li><li>Stacked Omnidirectional, Limited</li><li>Expanded, Expanded Stacked</li><br>Postal Codes<br><li>USPS Intelligent Mail</li><li>Postnet</li><li>Planet</li><li>Australian Post</li><li>UK Royal Mail</li> |

## Support

https://www.dynamsoft.com/company/contact/
