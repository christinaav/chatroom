import 'dart:io';

ServerSocket server;
List<ChatClient> clients = [];
List<String> names = [];
String username;
var counter = 0;

void main() {
  ServerSocket.bind('192.168.43.203', 3000).then((ServerSocket socket) {
    server = socket;

    server.listen((client) {
      handleConnection(client);
    });
  });
}

handleConnection(Socket client) {
  print('Connection from '
      '${client.remoteAddress.address}:${client.remotePort}');

  if (!clients.contains(client)) {
    clients.add(ChatClient(client));
  }

  client.write("Ciao! "
      "Ci sono ${clients.length - 1} membri attivi.\n");
  for (String m in names) client.write('$m\n');
}

removeClient(ChatClient client) {
  clients.remove(client);
  print("Si sono connessi ${clients.length}.");
}

distributeMessage(ChatClient client, String message, List<String> names) {
  for (ChatClient c in clients) {
    c.write(message + "\n");
  }
}

String getUsername(String string) {
  String temp = '';
  for (int i = 0; i < string.length; i++) {
    if (string[i] != ':') {
      temp = temp + string[i];
    }
    if (string[i] == ':') {
      break;
    }
  }
  return temp;
}

String getMessage(String string) {
  String temp = '';
  for (int i = 0; i < string.length; i++) {
    if (string[i] == ':') {
      for (int j = i + 1; j < string.length; j++) {
        temp = temp + string[j];
      }
      break;
    }
  }
  return temp;
}

usersList(String message) {
  String temp = getUsername(message);
  if (message.contains(':CONNECT')) {
    if (names.contains(temp))
      print('nome esiste già');
    else
      names.add(temp);
  }
  if (message.contains(':DISCONNECT')) names.remove(temp);
  print('\n\n\n\n\n');
  for (String x in names) print(x);
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
    if (!message.contains(':CONNECT') && !message.contains(':DISCONNECT'))
      distributeMessage(this, message, names);
    else
      usersList(message);
    getUsername(message);
    getMessage(message);
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
