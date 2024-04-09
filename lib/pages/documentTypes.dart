import 'package:efrei_ged/colors.dart';
import 'package:efrei_ged/model/documentType.dart';
import 'package:efrei_ged/supabase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DocumentTypesPage extends StatelessWidget {
  const DocumentTypesPage({super.key});

  void showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        var nameController = TextEditingController();

        return AlertDialog(
          title: Text(
            "Créer un type de document",
            style: TextStyle(color: secondaryColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nom",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                await supabase.from("DocumentType").insert({
                  "name": nameController.text,
                });

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Créer"),
            ),
          ],
        );
      },
    );
  }

  void showEditDialog(
    BuildContext context,
    DocumentType documentType,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        var nameController = TextEditingController(text: documentType.name);

        return AlertDialog(
          title: Text(
            "Modifier le type ${documentType.name}",
            style: TextStyle(color: secondaryColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nom",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Annuler"),
            ),
            ElevatedButton(
              onPressed: () async {
                await supabase.from("DocumentType").update({
                  "name": nameController.text,
                }).eq("id", documentType.id);

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Efrei GED",
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showCreateDialog(context);
                  },
                  label: const Text("Type"),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
          StreamBuilder(
            stream: supabase.from("DocumentType").stream(
              primaryKey: ["id"],
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final allDocumentTypes = snapshot.data
                      ?.map((v) => DocumentType.fromJson(v))
                      .toList() ??
                  [];

              return Expanded(
                child: ListView(
                  children: allDocumentTypes
                      .map(
                        (documentType) => Slidable(
                          startActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  showEditDialog(
                                    context,
                                    documentType,
                                  );
                                },
                                label: 'Modifier',
                                backgroundColor: Colors.blue,
                                icon: Icons.edit,
                              ),
                            ],
                          ),
                          endActionPane: ActionPane(
                            motion: const StretchMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) async {
                                  await supabase
                                      .from('DocumentToDocumentType')
                                      .delete()
                                      .eq('document_type', documentType.id);

                                  await supabase
                                      .from('DocumentType')
                                      .delete()
                                      .eq('id', documentType.id);
                                },
                                label: 'Supprimer',
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              documentType.name,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed("/home");
            },
            child: const Text("Retour"),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
