
class NotesManager {
  final List<Map<String, dynamic>> _notes = [];

  void addNote(String note, DateTime timestamp) {
    _notes.add({"note": note, "timestamp": timestamp});
  }

  List<String> getNotes() {
    return _notes.map((note) => note["note"] as String).toList();
  }

  String searchNotes(String query) {
    for (var note in _notes) {
      if (note["note"].toLowerCase().contains(query.toLowerCase())) {
        return note["note"];
      }
    }
    return "Sorry, no relevant notes found.";
  }
}