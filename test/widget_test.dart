import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_first_app/main.dart'; // Adjust the import path if your app's main file is in a different location

void main() {
  testWidgets('To-Do List app smoke test', (WidgetTester tester) async {
    // Build the To-Do app and trigger a frame.
    await tester.pumpWidget(const ToDoApp());

    // Verify the splash screen is displayed.
    expect(find.text("-MR - MASON-"), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    // Wait for the splash screen to transition.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify the main to-do list page is displayed.
    expect(find.text("To-Do List"), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsOneWidget);

    // Add a task to the default user (Mom).
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify the add task dialog is displayed.
    expect(find.text("Add New Task for Mom"), findsOneWidget);

    // Enter a task and confirm.
    await tester.enterText(find.byType(TextField), "New Task");
    await tester.tap(find.text("Add"));
    await tester.pumpAndSettle();

    // Verify the task is added.
    expect(find.text("New Task"), findsOneWidget);
  });
}
