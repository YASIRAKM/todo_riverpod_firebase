import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_flutter_toto_app/main.dart';
import 'package:riverpod_flutter_toto_app/model/todo_model.dart';
import 'package:riverpod_flutter_toto_app/provider/auth_provider.dart';
import 'package:riverpod_flutter_toto_app/provider/todo_provider.dart';
import 'package:riverpod_flutter_toto_app/view/authentication_view/login_page.dart';
import 'package:riverpod_flutter_toto_app/widgets/text_field.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoNotifierProvider);

    return Scaffold(
      appBar: _appBar(ref),
      body: bodyMethod(todos, ref),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.lightBlueAccent,
        onPressed: () {
          addTodoDialog(context, ref);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  bodyMethod(List<Todo> todos, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(
          height: 8,
        ),
        filterField(),
        const SizedBox(
          height: 8,
        ),
        Expanded(
          child: todos.isEmpty
              ? const Center(
                  child: Text("No todos"),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: const Offset(
                                  0, 3), // Adjust the offset as needed
                            ),
                          ],
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 2),
                        onTap: () {
                          editTodoDialog(context, ref, todos[index]);
                        },
                        title: Text(todos[index].title),
                        subtitle: Text(todos[index].content),
                        trailing: todos[index].status == 0
                            ? null
                            : TextButton(
                                onPressed: () {
                                  ref
                                      .read(todoNotifierProvider.notifier)
                                      .deleteTodo(context, todos[index]);
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                )),
                      ),
                    );
                  },
                  itemCount: todos.length,
                ),
        ),
      ],
    );
  }

  filterField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Consumer(builder: (context, ref, child) {
        String selected = ref.watch(filterProvider);
        return Row(
          children: [
            filterButtons(
              title: "All",
              isSelected: selected == "all",
              onTap: () {
                ref.read(filterProvider.notifier).state = "all";
                ref.read(todoNotifierProvider.notifier).fetchAllTodos();
              },
            ),
            const SizedBox(
              width: 6,
            ),
            filterButtons(
              title: "Done",
              isSelected: selected == "done",
              onTap: () {
                ref.read(filterProvider.notifier).state = "done";
                ref
                    .read(todoNotifierProvider.notifier)
                    .fetchAllTodos(titleFilter: "1");
              },
            ),
            const SizedBox(
              width: 6,
            ),
            filterButtons(
              title: "Undone",
              isSelected: selected == "undone",
              onTap: () {
                ref.read(filterProvider.notifier).state = "undone";
                ref
                    .read(todoNotifierProvider.notifier)
                    .fetchAllTodos(titleFilter: "0");
              },
            ),
          ],
        );
      }),
    );
  }

  filterButtons(
      {required String title,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border:
                  Border.all(color: isSelected ? Colors.black : Colors.grey)),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
          child: Text(
            title,
            style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w300),
          )),
    );
  }

  AppBar _appBar(WidgetRef ref) {
    return AppBar(
      title: const Text("TODO"),
      actions: [
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              PopupMenuItem<String>(
                onTap: () {
                  ref.read(authNotifierProvider.notifier).signOut().then(
                    (value) {
                      navKey.currentState?.pushAndRemoveUntil(
                        CupertinoPageRoute(
                          builder: (context) => AuthScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  );
                },
                value: 'logout',
                child: const Text('Logout'),
              ),
            ];
          },
        )
      ],
    );
  }

  Future<void> addTodoDialog(BuildContext context, WidgetRef ref) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    await showModalBottomSheet(
      backgroundColor: Colors.white,
      showDragHandle: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 12,
              ),
              buildTextField(titleController, "Title", Icons.title,
                  isBorder: true),
              const SizedBox(
                height: 6,
              ),
              buildTextField(descriptionController, "Content", Icons.details,
                  isBorder: true),
              const SizedBox(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        var uuid = const Uuid();
                        Todo newTodo = Todo(
                            title: titleController.text,
                            content: descriptionController.text,
                            id: uuid.v4(),
                            date: DateTime.now(),
                            status: 0);
                        ref
                            .read(todoNotifierProvider.notifier)
                            .addTodo(context, newTodo);
                        Navigator.pop(context);
                      },
                      child: const Text('Add'),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> editTodoDialog(
      BuildContext context, WidgetRef ref, Todo todo) async {
    final titleController = TextEditingController(text: todo.title);
    final descriptionController = TextEditingController(text: todo.content);
    ref.read(checkboxProvider.notifier).state = todo.status == 1;

    await showModalBottomSheet(
      backgroundColor: Colors.white,
      showDragHandle: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 12,
              ),
              buildTextField(titleController, "Title", Icons.title,
                  isBorder: true),
              const SizedBox(
                height: 6,
              ),
              buildTextField(descriptionController, "Content", Icons.details,
                  isBorder: true),
              const SizedBox(
                height: 6,
              ),
              Consumer(builder: (context, ref, child) {
                final isChecked = ref.watch(checkboxProvider);
                return ListTile(
                  title: const Text("Mark as done"),
                  trailing: Checkbox(
                    shape: const CircleBorder(),
                    value: isChecked,
                    onChanged: (value) {
                      ref.read(checkboxProvider.notifier).state =
                          value ?? false;
                    },
                  ),
                );
              }),
              const SizedBox(
                height: 6,
              ),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        final isChecked = ref.read(checkboxProvider);
                        final updatedTodo = Todo(
                            id: todo.id,
                            title: titleController.text,
                            content: descriptionController.text,
                            date: todo.date,
                            status: isChecked ? 1 : 0);
                        ref
                            .read(todoNotifierProvider.notifier)
                            .updateTodo(context, updatedTodo);
                        Navigator.pop(context);
                      },
                      child: const Text('Update'),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
