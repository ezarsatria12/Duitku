import 'dart:async';
import 'package:flutter/material.dart';
import 'package:duitku/models/note.dart';
import 'package:duitku/utils/database_helper.dart';
import 'package:intl/intl.dart';

class NoteDetail extends StatefulWidget {

  final String appBarTitle;
  final Note note;

  NoteDetail(this. note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {

    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {

  static var _priorities = ['Pemasukan', 'Pengeluaran'];

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  NoteDetailState(this.note, this.appBarTitle);

  @override
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.title;

    titleController.text = note.title;
    descriptionController.text = note.description;

    return WillPopScope(

        onWillPop: () {
          // Write some code to control things, when user press Back navigation button in device navigationBar
          moveToLastScreen();
        },

        child: Scaffold(
          backgroundColor: Color(0xff252525),
          appBar: AppBar(
            title: Text(appBarTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outlined),
                  onPressed: () {
                    setState(() {
                      debugPrint("Delete button clicked");
                      _delete();
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                      setState(() {
                        debugPrint("Save button clicked");
                        _save();
                      });
                  },
                ),
              ],
              backgroundColor: Color(0xFF252525),
            leading: IconButton(icon: Icon(
                Icons.arrow_back),
                onPressed: () {
                  // Write some code to control things, when user press back button in AppBar
                  moveToLastScreen();
                }
            )

          ),

          body: Padding(
            padding: const EdgeInsets.fromLTRB(26.0, 2.5, 26.0, 2.5),
            child: ListView(
              children: <Widget>[

                // First element
                ListTile(
                  title: DropdownButton(
                      items: _priorities.map((String dropDownStringItem) {
                        return DropdownMenuItem<String> (
                          value: dropDownStringItem,
                          child: Text(dropDownStringItem),
                        );
                      }).toList(),

                      style: TextStyle(
                        color: Colors.white,
                      ),
                      dropdownColor: Color(0xFF3b3b3b),
                      borderRadius: BorderRadius.circular(10.0),

                      value: getPriorityAsString(note.priority),

                      onChanged: (valueSelectedByUser) {
                        setState(() {
                          debugPrint('User selected $valueSelectedByUser');
                          updatePriorityAsInt(valueSelectedByUser);
                        });
                      }
                  ),
                ),

                // Second Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white,
                      fontSize: 20,
                    ),
                    onChanged: (value) {
                      debugPrint('Something changed in Title Text Field');
                      updateTitle();
                    },
                    decoration: InputDecoration(
                        labelText: 'Judul',
                        filled: true,
                        fillColor: Color(0xFF3b3b3b),
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white),
                        errorStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 4.0),
                          borderRadius: BorderRadius.circular(10.0),
                        )
                    ),
                  ),
                ),

                // Third Element
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    controller: descriptionController,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (value) {
                      debugPrint('Something changed in Description Text Field');
                      updateDescription();
                    },
                    decoration: InputDecoration(
                        labelText: 'Nominal',
                        filled: true,
                        fillColor: Color(0xFF3b3b3b),
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white),
                        errorStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 4.0),
                          borderRadius: BorderRadius.circular(10.0),
                        )
                    ),
                  ),
                ),

                // Fourth Element


              ],
            ),
          ),


        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Convert the String priority in the form of integer before saving it to Database
  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'Pemasukan':
        note.priority = 1;
        break;
      case 'Pengeluaran':
        note.priority = 2;
        break;
    }
  }

  // Convert int priority to String priority and display it to user in DropDown
  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];  // 'High'
        break;
      case 2:
        priority = _priorities[1];  // 'Low'
        break;
    }
    return priority;
  }

  // Update the title of Note object
  void updateTitle(){
    note.title = titleController.text;
  }

  // Update the description of Note object
  void updateDescription() {
    note.description = descriptionController.text;
  }

  // Save data to database
  void _save() async {

    moveToLastScreen();

    note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (note.id != null) {  // Case 1: Update operation
      result = await helper.updateNote(note);
    } else { // Case 2: Insert Operation
      result = await helper.insertNote(note);
    }

    if (result != 0) {  // Success
      _showAlertDialog('Status', 'Note Saved Successfully');
    } else {  // Failure
      _showAlertDialog('Status', 'Problem Saving Note');
    }

  }

  void _delete() async {

    moveToLastScreen();

    // Case 1: If user is trying to delete the NEW NOTE i.e. he has come to
    // the detail page by pressing the FAB of NoteList page.
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    // Case 2: User is trying to delete the old note that already has a valid ID.
    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      _showAlertDialog('Status', 'Note Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Note');
    }
  }

  void _showAlertDialog(String title, String message) {

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }

}