import 'dart:convert';
import 'dart:typed_data';
import 'package:programmer/json_file_handler.dart';
import 'package:programmer/reg_provider.dart';
import 'package:programmer/register_list.dart';
import 'package:programmer/register_view.dart';
import 'package:programmer/serial_wr.dart';
import 'package:flutter/material.dart' hide Chip;
import 'package:flutter/services.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:provider/provider.dart';
import 'package:programmer/chip.dart';

class UIpage extends StatefulWidget {
  const UIpage({super.key});

  @override
  _UIpageState createState() => _UIpageState();
}

class _UIpageState extends State<UIpage> {
  List<String> availablePorts = [];
  List<Chip> availableChips = RegisterList.chipList;
  Chip selectedChip = Chip(registers: []);
  String selectedChipName = "";
  List<String> _logs = ["Serial console log"];
  String selectedPort = "";
  SerialWR serialWR = SerialWR();
  double upperSectionRatio = 0.2;
  Set<LogicalKeyboardKey> _pressedKeys = Set<LogicalKeyboardKey>();
  ScrollController _consoleLogController = ScrollController();

  @override
  void initState() {

    // Serial ports

    availablePorts = SerialPort.availablePorts;
    if (availablePorts.isNotEmpty) {
      selectedPort = availablePorts.first;
      serialWR.begin(selectedPort);
    }

    if (selectedPort != "" && serialWR.initialized) {
      serialWR.listen((String newLine) {
        //print(newLine);
        addLog(newLine);
      });
    }

    // Available chips
    bool done = false;
    if (availableChips.isNotEmpty) {
      for (Chip c in availableChips) {
        if (c.selected) {
          selectedChip = c;
          done = true;
          break;
        }
      }
      if (!done) {
        selectedChip = availableChips.first;
      }
    }
    selectedChipName = selectedChip.nameId;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Programmer',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: DropdownButton<String>(
                value: selectedPort,
                icon: const Icon(Icons.menu),
                iconSize: 24,
                elevation: 16,
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onTap: () {
                  setState(() {
                    availablePorts = SerialPort.availablePorts;
                  });
                },
                onChanged: (String? newValue) {
                  // handle port change
                  setState(() {
                    if (availablePorts.isNotEmpty) {
                      serialWR.port.close();
                      selectedPort = availablePorts.firstWhere((t) => t == newValue, orElse: () => availablePorts.first);
                      serialWR.begin(selectedPort);
                      serialWR.listen((String newLine) {
                        //print(newLine);
                        addLog(newLine);
                      });
                    }
                  });
                },
                items: availablePorts
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25.0, right: 25.0),
              child: DropdownButton<String>(
                value: selectedChipName,
                icon: const Icon(Icons.electric_bolt),
                iconSize: 15,
                elevation: 16,
                underline: Container(
                  height: 2,
                  color: Colors.deepPurpleAccent,
                ),
                onTap: () {
                  availableChips = RegisterList.chipList;
                },
                onChanged: (String? newValue) {
                  setState(() {
                    selectedChip = availableChips.firstWhere(
                      (tchip) => tchip.nameId == newValue,
                      orElse: () {
                        if (availableChips.isNotEmpty) {
                          return availableChips.first;
                        }
                        return Chip(registers: []);
                      },
                    );
                    for (Chip c in RegisterList.chipList) {
                      c.selected = false;
                      if (c.nameId == selectedChip.nameId) {
                        c.selected = true;
                        selectedChipName = c.nameId;
                      }
                    }

                  });
                },
                items: availableChips.map<DropdownMenuItem<String>>((Chip c) {
                  return DropdownMenuItem<String>(
                    value: c.nameId,
                    child: Text(c.nameId),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ElevatedButton(
                onPressed: () {
                  JsonFileHandler.writeChipsToJsonFile(RegisterList.chipList);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Saved to .json files"),
                    ),
                  );
                },
                child: const Icon(Icons.save),
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            double availableHeight = constraints.maxHeight;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // First section (registers) takes adjustable space
                SizedBox(
                  height: availableHeight * upperSectionRatio,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300.0, // Maximum width of each item
                        crossAxisSpacing: 2.0,
                        mainAxisSpacing: 2.0,
                        childAspectRatio: 1.95, // Adjust aspect ratio if needed
                      ),
                      itemCount: RegisterList.getChipRegisters(selectedChip).length,
                      itemBuilder: (context, index) {
                        return Consumer<RegProvider>(
                          builder: (context, appState, _) => RegisterView(
                              register: RegisterList.getChipRegisters(selectedChip)[index]),
                        );
                      },
                    ),
                  ),
                ),
                // Draggable divider
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: (details) {
                    setState(() {
                      upperSectionRatio += details.delta.dy / availableHeight;
                      if (upperSectionRatio < 0.1) upperSectionRatio = 0.1;
                      if (upperSectionRatio > 0.9) upperSectionRatio = 0.9;
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeUpDown,
                    child: Container(
                      height: 4.0,
                      color: Colors.grey,
                      child: Center(
                        child: Icon(Icons.drag_handle, color: Colors.black45),
                      ),
                    ),
                  ),
                ),
                // Second section (Log/Console) takes the remaining height
                SizedBox(
                  height: availableHeight * (1 - (upperSectionRatio + 0.02)),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 20, left: 10, right: 90),
                    child: SelectionArea(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Scrollbar(
                          controller: _consoleLogController,
                          thumbVisibility: true,
                          child: ListView.builder(
                            itemCount: _logs.length,
                            controller: _consoleLogController,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                  _logs[index],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'RobotoMono',
                                      fontSize: 14),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: FloatingActionButton(
                heroTag: 'reset_button', // Unique hero tag
                onPressed: () {
                  Uint8List c = prepareCommandData(
                      selectedChip.nameId, "RESET", Uint8List(0));
                  serialWR.print_serial(c);
                },
                child: Text('Reset'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: FloatingActionButton(
                heroTag: 'hiz_button', // Unique hero tag
                onPressed: () {
                  Uint8List c = prepareCommandData(
                      selectedChip.nameId, "HIZ", Uint8List(0));
                  serialWR.print_serial(c);
                },
                child: Text('HiZ'),
              ),
            ),
            FloatingActionButton(
              heroTag: 'update_button', // Unique hero tag
              onPressed: () => sendRegData(),
              child: Icon(Icons.update),
            ),
          ],
        ),
      ),
    );
  }

  void sendRegData() {
    serialWR.print_serial(prepareCommandData(
        selectedChip.nameId, "DATA", RegisterList.getSendData(selectedChip)));
    print(RegisterList.getSendData(selectedChip).toString());
    _logs.add("PROGRAMMING DATA SENT");
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey); // Add the pressed key
      if (_checkForShortcut()) {
        return KeyEventResult.handled;
      }
      ; // Check for keyboard shortcut
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey); // Remove key on release
    }

    return KeyEventResult.ignored; // Mark event as handled
  }

  bool _checkForShortcut() {
    bool isControlPressed =
        _pressedKeys.contains(LogicalKeyboardKey.controlLeft) ||
            _pressedKeys.contains(LogicalKeyboardKey.controlRight);

    bool isSPressed = _pressedKeys.contains(LogicalKeyboardKey.keyP);

    if (isControlPressed && isSPressed) {
      sendRegData();
      return true;
    }

    return false;
  }

  Uint8List prepareCommandData(
      String chipID, String commandText, Uint8List data) {
    if (chipID.contains(":")) {
      addLog("ERROR: chip Id can't contain the : character");
    }

    if (commandText.contains(":")) {
      addLog("ERROR: chip Id can't contain the : character");
    }

    chipID = "$chipID:";
    commandText = "$commandText:";

    Uint8List command = ascii.encode(commandText);
    Uint8List cid = ascii.encode(chipID);

    Uint8List toSend = Uint8List(cid.length + data.length + command.length + 1);
    for (int i = 0; i < cid.length; i++) {
      toSend[i] = cid[i];
    }

    for (int i = 0; i < command.length; i++) {
      toSend[i + cid.length] = command[i];
    }

    for (int i = 0; i < data.length; i++) {
      toSend[i + cid.length + command.length] = data[i];
    }
    toSend[toSend.length-1] = ascii.encode('\n').first;
    print("tosend: ${toSend}");
    return toSend;
  }

  void _scrollToBottomIfNecessary(double currentPos, double prevMaxScroll) {
    if (_consoleLogController.hasClients) {
      // Check if the user is at the bottom of the ListView

      if (currentPos == prevMaxScroll) {
        // Scroll to the bottom if already at the bottom
        print("equal, scrolling");
        _consoleLogController.animateTo(
            _consoleLogController.position.maxScrollExtent,
            duration: Duration(milliseconds: 150),
            curve: Curves.easeIn);

        // jumpTo(maxScrollExtent);
      }

      prevMaxScroll = _consoleLogController.position.maxScrollExtent;
      print("prev: $prevMaxScroll   current: $currentPos}");
    }
  }

  void addLog(String log) {
    double currentScrollPosition = _consoleLogController.position.pixels;
    double prevMaxScroll = _consoleLogController.position.maxScrollExtent;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottomIfNecessary(currentScrollPosition, prevMaxScroll);
    });

    setState(() {
      //CommandProcessor.processCommand(newLine);
      _logs.add(log);
    });
  }
}
