import 'package:dynamsoft_capture_vision_flutter/dynamsoft_capture_vision_flutter.dart';

enum EnumResultStatus {
  finished,
  cancelled,
  error,
}

class VINScanResult {
  EnumResultStatus resultStatus;
  String? errorString = "";
  VINData? data;
  VINScanResult({
    required this.resultStatus,
    this.errorString,
    this.data,
  });
}

class VINData {
  String? vinString;
  String? WMI;
  String? region;
  String? VDS;
  String? checkDigit;
  String? modelYear;
  String? plantCode;
  String? serialNumber;

  Map<String, String> toMap() {
    return {
      if (vinString != null) 'vinString': vinString!,
      if (WMI != null) 'WMI': WMI!,
      if (region != null) 'region': region!,
      if (VDS != null) 'VDS': VDS!,
      if (checkDigit != null) 'checkDigit': checkDigit!,
      if (modelYear != null) 'modelYear': modelYear!,
      if (plantCode != null) 'plantCode': plantCode!,
      if (serialNumber != null) 'serialNumber': serialNumber!
    };
  }

  static VINData? fromParsedResultItem(ParsedResultItem item) {
    var parsedFields = item.parsedFields;
    if(parsedFields.isEmpty) {
      return null;
    }
    var data = VINData();
    data.vinString = parsedFields["vinString"]?.value;
    data.WMI = parsedFields["WMI"]?.value;
    data.region = parsedFields["region"]?.value;
    data.VDS = parsedFields["VDS"]?.value;
    data.checkDigit = parsedFields["checkDigit"]?.value;
    data.modelYear = parsedFields["modelYear"]?.value;
    data.plantCode = parsedFields["plantCode"]?.value;
    data.serialNumber = parsedFields["serialNumber"]?.value;
    return data;
  }
}

