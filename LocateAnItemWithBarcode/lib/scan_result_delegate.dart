typedef ScanResultDelegate = void Function(String text);

ScanResultDelegate? _scanResultDelegate;

void setScanResultDelegate(ScanResultDelegate? delegate) {
  _scanResultDelegate = delegate;
}

void notifyScanResult(String text) {
  _scanResultDelegate?.call(text);
}
