import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';

class scanQRCodeScreen extends StatefulWidget {
  const scanQRCodeScreen({super.key});

  @override
  State<scanQRCodeScreen> createState() => _ScanQRCode();
}

class _ScanQRCode extends State<scanQRCodeScreen> {
  List<String> _scannedCodes = [];
  List<Map<String, bool>> _checkList = [
    {'Details': false},
    {'Locations': false},
    {'Challenges': false},
    {'Location Challenges': false},
  ];
  bool _isContinueEnabled = false;

  List<Map<String, String?>> _rawData = [
    {'Details': null},
    {'Locations': null},
    {'Challenges': null},
    {'Location Challenges': null},
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _showInputDialog(BuildContext context) async {
    String enteredCode = '';

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Code'),
          content: TextField(
            onChanged: (value) {
              enteredCode = value;
            },
            decoration: InputDecoration(hintText: 'Enter code here'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleCode(enteredCode);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _handleCode(String code)
  {
    if(code == "")
      {
        return;
      }

    List<String> codes = code.split('|');

    if(codes.length < 1)
      {
        return;
      }

    setState(() {
      for (var c in codes) {
        String category = c.substring(0, 3);
        String categoryKey = "";

        if (category.contains('d=')) {
          categoryKey = 'Details';
        } else if (category.contains('ch=')) {
          categoryKey = 'Challenges';
        } else if (category.contains('l=')) {
          if (category[0] == 'c') {
            categoryKey = 'Location Challenges';
          }
          if (category[0] == 'l') {
            categoryKey = 'Locations';
          }
        }

        for (var item in _rawData) {
          if (item.containsKey(categoryKey)) {
            print(item[categoryKey]);
            item[categoryKey] = c.split('=')[1];
            break;
          }
        }
      }
    });

    _update_checklist();
  }

  Future<void> _scanQRCode() async {
    ScanResult result = await BarcodeScanner.scan();
    setState(() {
      String rawData = result.rawContent;
      String category = rawData.substring(0, 3);
      String categoryKey = "";

      if (category.contains('d=')) {
        categoryKey = 'Details';
      } else if (category.contains('ch=')) {
        categoryKey = 'Challenges';
      } else if (category.contains('l=')) {
        if (category[0] == 'c') {
          categoryKey = 'Location Challenges';
        }
        if (category[0] == 'l') {
          categoryKey = 'Locations';
        }
      }

      for (var item in _rawData) {
        if (item.containsKey(categoryKey)) {
          print(item[categoryKey]);
          item[categoryKey] = rawData.split('=')[1];
          break;
        }
      }
    });
    print(_rawData);
    _update_checklist();

  }

  void _update_checklist()
  {
    setState(() {
      for (var item in _rawData) {
        if(item.values.first != null)
          {
            _setChecklistItem(item.keys.first, true);
          } else {
            _setChecklistItem(item.keys.first, false);
        }
      }
    });
  }

  void _setChecklistItem(String key, bool value) {
    setState(() {
      for (var item in _checkList) {
        if (item.containsKey(key)) {
          item[key] = value;
          break;
        }
      }
    });
  }

  void _resetChecklist() {
    setState(() {
      for (var item in _checkList) {
        item[item.keys.first] = false;
      }
      _scannedCodes.clear();
      _isContinueEnabled = false;
    });
  }

  void _continue()
  {
    // TODO: Check validation

    Navigator.pushNamed(context, '/qr/process', arguments: _rawData);
  }

  @override
  Widget build(BuildContext context) {
    bool isAllChecked = _checkList.every((item) => item.values.first);
    _isContinueEnabled = _checkList.isNotEmpty && isAllChecked;
    bool isAnyChecked = _checkList.any((item) => item.values.first);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Crawl'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isAnyChecked ? Column(
              children: [
                SizedBox(height: 10),
                for (var item in _checkList)
                  ListTile(
                    title: Text(item.keys.first),
                    trailing: Checkbox(
                      value: item.values.first,
                      onChanged: (value) => null,
                    ),
                  ),
                SizedBox(height: 20),
              ],
            ) : SizedBox(),
            _isContinueEnabled == false ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: isAnyChecked == false ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _scanQRCode,
                    child: const Text('Scan QR Code'),
                  ),
                  isAnyChecked == false ? ElevatedButton(
                    onPressed: () {
                      _showInputDialog(context);
                    },
                    child: const Text('Enter Code Instead'),
                  ) : SizedBox(),
                ],
              ),
            ) : SizedBox(),
            const SizedBox(height: 20),
            if (isAnyChecked)
              Card(
                elevation: .5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _resetChecklist,
                        child: const Text('Restart'),
                      ),
                      ElevatedButton(
                        onPressed: _isContinueEnabled ? () {
                          _continue();
                        } : null,
                        child: const Text('Continue'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      )
    );
  }
}
