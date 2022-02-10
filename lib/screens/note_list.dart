import 'dart:async';
import 'package:flutter/material.dart';
import 'package:duitku/models/note.dart';
import 'package:duitku/utils/database_helper.dart';
import 'package:duitku/screens/note_detail.dart';
import 'package:sqflite/sqflite.dart';


class NoteList extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {

    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {

    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      backgroundColor: Color(0xff252525),

      appBar: AppBar(
        title: Text('Duitku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            tooltip: 'Increase volume by 10',
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                title: const Text('APP INFO'),
                content: const Text('Kelompok 4 XII RPL 2'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ),
        ],
        backgroundColor: Color(0xFF252525),
      ),

      body: getNoteListView(

      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('FAB clicked');
          navigateToDetail(Note('', '', 2), 'Add Note');
        },

        backgroundColor: Color(0xFF3b3b3b),

        tooltip: 'Add Note',

        child: Icon(Icons.add),

      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  ListView getNoteListView() {

    TextStyle titleStyle = Theme.of(context).textTheme.subhead;

    return ListView.builder(


      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: getPriorityColor(this.noteList[position].priority)),
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.fromLTRB(26.0, 5.5, 26.0, 5.5),
          color: Color(0xFF3b3b3b),
          elevation: 2.0,
          child: ListTile(



            title: Text(this.noteList[position].title, style: TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
            ),

            subtitle: Text(this.noteList[position].date,
            style: TextStyle(
              color: Colors.white,
            ),
            ),



            trailing: Text(this.noteList[position].description, style: TextStyle(
              color: getPriorityColor(this.noteList[position].priority),
              fontSize: 18,

            ),
            ),


            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(this.noteList[position],'Edit Note');
            },

          ),
        );
      },
    );
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.green;
        break;
      case 2:
        return Colors.red;
        break;

      default:
        return Colors.red;
    }
  }

  // Returns the priority icon


  void _delete(BuildContext context, Note note) async {

    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Berhasil Dihapus');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {

    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {

    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {

      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }
}

