import 'dart:io';

// USE ALSO netcat 127.0.0.1 3000

// global variables

ServerSocket server;
List<ChatClient> clients = [];
List<String> names = [];

void main() {
  ServerSocket.bind('192.168.1.195', 3000).then((ServerSocket socket) {
    server = socket;

    server.listen((client) {
      handleConnection(client);
    });
  });
}

void handleConnection(Socket client) {
  print('Connection from '
      '${client.remoteAddress.address}:${client.remotePort}');

  if (!clients.contains(client)) {
    clients.add(ChatClient(client));
  }

  client.write("Ciao! "
      "Ci sono ${clients.length} membri attivi.\n");
}

void removeClient(ChatClient client) {
  clients.remove(client);
}

void distributeMessage(ChatClient client, String message) {
  for (ChatClient c in clients) {
    c.write(message + "\n");
  }
}

class ChatClient {
  Socket _socket;
  String get _address => _socket.remoteAddress.address;
  int get _port => _socket.remotePort;

  ChatClient(Socket s) {
    _socket = s;
    _socket.listen(messageHandler,
        onError: errorHandler, onDone: finishedHandler);
  }

  void messageHandler(data) {
    String message = String.fromCharCodes(data).trim();
    print(String.fromCharCodes(data).trim());
    distributeMessage(this, message);
  }

  void errorHandler(error) {
    print('${_address}:${_port} Error: $error');
    removeClient(this);
    _socket.close();
  }

  void finishedHandler() {
    print('${_address}:${_port} Disconnected');
    removeClient(this);
    _socket.close();
  }

  void write(String message) {
    _socket.write(message);
  }
}
