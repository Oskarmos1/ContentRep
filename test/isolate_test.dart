import 'dart:isolate';

class D {
  String name;
  bool isTrue;

  D(this.name, this.isTrue);

  @override
  String toString() {
    return 'Name: $name, isTrue: $isTrue';
  }
}

// This function will run in a separate isolate

void updateDaves(List<dynamic> message) {
  List<D> dList = message[0];
  SendPort sendPort = message[1];

  // Update the 'Dave' entries
  dList.where((d) => d.name == 'Dave').firstWhere((d) => d.isTrue = true);

  // Send the updated list back to the main isolate
  sendPort.send(dList);
}

void main() async {
  // Create a large list of D objects
  List<D> dList = List.generate(1000000, (index) {
    if (index % 100000 == 0) {
      return D('Dave', false); // Insert some 'Dave' entries
    }
    return D('Person_$index', false);
  });

  // Print the list before the update
  print(
      'Before update number of daves recognised: ${dList.where((d) => d.isTrue == true).toList().length}');
  print(
      'Before update number of non-daves recognised: ${dList.where((d) => d.isTrue == false).toList().length}');

  // Create a ReceivePort to get messages from the isolate
  ReceivePort receivePort = ReceivePort();

  // Spawn a new isolate and pass the list and the SendPort
  await Isolate.spawn(updateDaves, [dList, receivePort.sendPort]);

  // Wait for the updated list from the isolate
  List<D> updatedList = await receivePort.first;

  // Print the list after the update to verify
  print(
      'After update number of daves recognised: ${updatedList.where((d) => d.isTrue == true).toList().length}');
  print(
      'After update number of non-daves recognised: ${updatedList.where((d) => d.isTrue == false).toList().length}');
}
