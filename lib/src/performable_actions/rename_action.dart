import 'package:backstreets_widgets/extensions.dart';
import 'package:backstreets_widgets/screens.dart';
import 'package:backstreets_widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:orderly/src/shortcuts.dart';

/// The rename performable action.
class RenameAction extends PerformableAction {
  /// Create an instance.
  RenameAction({
    required this.context,
    required this.currentName,
    required this.setName,
  }) : super(
         name: 'Rename',
         activator: renameShortcut,
         invoke: () => context.pushWidgetBuilder(
           (builderContext) => GetText(
             onDone: (name) async {
               builderContext.pop();
               await setName(name);
             },
             labelText: 'New name',
             text: currentName,
             title: 'Rename',
           ),
         ),
       );

  /// The build context to use.
  final BuildContext context;

  /// The current name.
  final String currentName;

  /// The function to call to set the new name.
  final Future<void> Function(String newName) setName;
}
