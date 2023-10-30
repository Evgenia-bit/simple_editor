import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SafeArea(child: EditorView()),
    );
  }
}

class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final controller = TextEditingController();
  final editor = Editor('');
  late final undoRedoManager = UndoRedoManager(editor);
  @override
  void initState() {
    undoRedoManager.backup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextField(
        controller: controller,
        maxLines: 5,
        onChanged: (v) {
          editor.text = v;
          undoRedoManager.backup();
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.undo),
            onPressed: () {
              undoRedoManager.undo();
              controller.text = editor.text;
            },
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            child: const Icon(Icons.redo),
            onPressed: () {
              undoRedoManager.redo();
              controller.text = editor.text;
            },
          ),
        ],
      ),
    );
  }
}


/// Originator
class Editor {
  String text;
  Editor(this.text);

  Memento save() {
    return EditorMemento(text);
  }

  void restore(Memento memento) {
    text = memento.getState();
  }
}


/// Memento
abstract interface class Memento {
  getState();
}

class EditorMemento implements Memento {
  final String state;

  EditorMemento(this.state);

  @override
  getState() {
    return state;
  }
}


/// Caretaker
class UndoRedoManager {
  final List<Memento> _undoList = [];
  final List<Memento> _redoList = [];
  final Editor editor;
  UndoRedoManager(this.editor);

  void backup() {
    _undoList.add(editor.save());
    _redoList.clear();
  }

  void undo() {
    if (_undoList.length < 2) return;
    final memento = _undoList.removeLast();
    _redoList.add(memento);
    editor.restore(_undoList.last);
  }

  void redo() {
    if (_redoList.isEmpty) return;
    final memento = _redoList.removeLast();
    _undoList.add(memento);
    editor.restore(memento);
  }
}
