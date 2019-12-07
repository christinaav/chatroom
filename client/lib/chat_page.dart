import 'package:chatroom/first_screen.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'dart:io';
import 'sign_in.dart';
import 'first_screen.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

BubbleStyle styleSomebody = BubbleStyle(
  nip: BubbleNip.leftTop,
  color: Colors.white,
  elevation: 1,
  margin: BubbleEdges.only(top: 8.0, right: 50.0),
  alignment: Alignment.topLeft,
);

BubbleStyle styleMe = BubbleStyle(
  nip: BubbleNip.rightTop,
  color: Color.fromARGB(255, 225, 255, 199),
  elevation: 1,
  margin: BubbleEdges.only(top: 8.0, left: 50.0),
  alignment: Alignment.topRight,
);

class _ChatPageState extends State<ChatPage> {
  // variabili

  ScrollController _scrollController = new ScrollController();
  final mycontroller = TextEditingController();
  String temp = '';
  bool connected = false;
  String textfield = 'Join the chat!';
  List<String> messages = [];
  String nonmes;
  Socket socketino;
  List<String> users = [];
// metodi

  connect() {
    if (!connected)
      Socket.connect('192.168.1.50', 3000).then((Socket sock) {
        socketino = sock;
        print('mi sono connesso');
        socketino.listen(
          dataHandler,
          onDone: doneHandler,
        );
      });
  }

  dataHandler(data) {
    print(String.fromCharCodes(data).trim());
    temp = String.fromCharCodes(data).trim();
    getUsers(String.fromCharCodes(data).trim());
    setState(() {
      messages.add(temp);
    });
  }

  sendData() {
    if (mycontroller.text.toString() != null &&
        mycontroller.text.toString().isNotEmpty &&
        socketino != null) {
      socketino.write('$name:$nonmes');
    }
    print(temp);
    mycontroller.clear();
  }

  doneHandler() {
    socketino.write('$name:vado via');
    socketino.destroy();
  }

  popout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Log out"),
          content: new Text("Hai effettuato il log out"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return FirstScreen();
                    },
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  myStyle(String message) {
    if (getUsername(message) == name) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(
              imageUrl,
            ),
            radius: 10.0,
            backgroundColor: Colors.transparent,
          ),
          Bubble(
            shadowColor: Colors.black,
            style: styleMe,
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    getUsername(message.toString()),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.normal,
                        fontSize: 15),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    getMessage(message.toString()),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.normal,
                        fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Bubble(
            shadowColor: Colors.black,
            style: styleSomebody,
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    getUsername(message.toString()),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.normal,
                        fontSize: 15),
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    getMessage(message.toString()),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: Colors.green[800],
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.normal,
                        fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            backgroundImage: NetworkImage(
              imageUrl,
            ),
            radius: 10.0,
            backgroundColor: Colors.transparent,
          )
        ],
      );
    }
  }

  String getUsername(String string) {
    // print('Sto filtrando un username: $string');
    if (string[0] != '&') {
      String temp = '';
      for (int i = 0; i < string.length; i++) {
        if (string[i] != ':') {
          temp = temp + string[i];
        }
        if (string[i] == ':') {
          // print(string[i]);
          break;
        }
      }
      return temp;
    }
  }

  String getMessage(String string) {
    // print('Sto filtrando un messaggio: $string');
    if (string[0] != '&') {
      String temp = '';
      for (int i = 0; i < string.length; i++) {
        if (string[i] == ':') {
          for (int j = i + 1; j < string.length; j++) {
            temp = temp + string[j];
            // print('Sto creando il messaggio');
          }
          break;
        }
      }
      // print(temp);
      return temp;
    }
  }

  getUsers(String string) {
    String temp = '';
    if (string[0] == '&') {
      for (int i = 1; i < string.length; i++) {
        temp = temp + string[i];
      }
      print(temp);
      if (!users.contains(temp)) users.add(temp);
    }
  }

  showUsers() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Utenti connessi"),
          content: new Text(''),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        title: Text('Chat with your friends'),
        actions: <Widget>[
          PopupMenuButton<int>(
              itemBuilder: (context) => [
                    PopupMenuItem(
                      child: FlatButton(
                        child: Text(
                          'Online',
                        ),
                        onPressed: null,
                      ),
                    ),
                    PopupMenuItem(
                      child: FlatButton(
                        child: Text('Log out'),
                        onPressed: () {
                          if (connected) {
                            doneHandler();
                            print("mi sono sconesso");
                            popout();
                          } else
                            print("non sono connesso");
                        },
                      ),
                    )
                  ])
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 1.3,
              child: ListView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: <Widget>[
                  Bubble(
                    alignment: Alignment.center,
                    color: Color.fromARGB(255, 212, 234, 244),
                    elevation: 1,
                    margin: BubbleEdges.only(top: 8.0),
                    child: Text('TODAY', style: TextStyle(fontSize: 10)),
                  ),
                  for (var message in messages) myStyle(message),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 8.0),
                        GestureDetector(
                          onTap: () {},
                          child: CircleAvatar(
                            child: Icon(Icons.insert_emoticon,
                                size: 30.0, color: Theme.of(context).hintColor),
                            backgroundColor: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: TextField(
                            onChanged: (text) {
                              nonmes = text;
                            },
                            controller: mycontroller,
                            decoration: InputDecoration(
                              hintText: textfield,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.0),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 5.0,
                              ),
                              GestureDetector(
                                onTap: () {
                                  connect();
                                  connected = true;
                                  textfield = 'Type a message';
                                  sendData();
                                  _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent *
                                        2,
                                    curve: Curves.easeInCirc,
                                    duration: const Duration(milliseconds: 300),
                                  );
                                },
                                child: CircleAvatar(
                                  child: Icon(Icons.send),
                                  backgroundColor: Colors.deepPurple,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.0),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
