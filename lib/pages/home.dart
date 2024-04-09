import 'package:efrei_ged/colors.dart';
import 'package:efrei_ged/model/Document.dart';
import 'package:efrei_ged/model/documentType.dart';
import 'package:efrei_ged/supabase.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    void logout() async {
      await supabase.auth.signOut();

      if (context.mounted) {
        Navigator.of(context).pushNamed("/login");
      }
    }

    void showEditDialog(BuildContext context, Document document,
        List<DocumentType> allDocumentTypes, List<DocumentType> documentTypes) {
      showDialog(
        context: context,
        builder: (context) {
          var nameController = TextEditingController(text: document.name);
          MultiSelectController<DocumentType> documentTypesController =
              MultiSelectController();

          return AlertDialog(
            title: Text(
              "Modifier ${document.name}",
              style: TextStyle(color: secondaryColor),
            ),
            content: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Nom",
                  ),
                ),
                const SizedBox(height: 16),
                MultiSelectDropDown<DocumentType>(
                  controller: documentTypesController,
                  onOptionSelected: (options) {},
                  selectedOptions: documentTypes
                      .map((e) => ValueItem(label: e.name, value: e))
                      .toList(),
                  options: allDocumentTypes
                      .map((e) => ValueItem(label: e.name, value: e))
                      .toList(),
                  singleSelectItemStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  chipConfig: const ChipConfig(
                      wrapType: WrapType.wrap, backgroundColor: Colors.red),
                  optionTextStyle: const TextStyle(fontSize: 16),
                  selectedOptionBackgroundColor: Colors.grey.shade300,
                  selectedOptionTextColor: Colors.blue,
                  dropdownMargin: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () async {
                  await supabase.from('Document').update({
                    'name': nameController.text,
                  }).eq('id', document.id);

                  await supabase
                      .from('DocumentToDocumentType')
                      .delete()
                      .eq('document', document.id);

                  await supabase.from('DocumentToDocumentType').upsert(
                        documentTypesController.selectedOptions
                            .map((e) => {
                                  'document': document.id,
                                  'document_type': e.value!.id,
                                })
                            .toList(),
                      );

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Confirmer"),
              ),
            ],
          );
        },
      );
    }

    void showCreateDialog(
      BuildContext context,
      List<DocumentType> allDocumentTypes,
    ) async {
      FilePickerResult? result = kIsWeb
          ? await FilePickerWeb.platform.pickFiles()
          : await FilePicker.platform.pickFiles();

      if (result == null) {
        return;
      }

      if (!context.mounted) {
        return;
      }

      showDialog(
        context: context,
        builder: (context) {
          MultiSelectController<DocumentType> documentTypesController =
              MultiSelectController();

          return AlertDialog(
            title: Text(
              "Créer un document",
              style: TextStyle(color: secondaryColor),
            ),
            content: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Nom",
                  ),
                  readOnly: true,
                  controller:
                      TextEditingController(text: result.files.first.name),
                ),
                const SizedBox(height: 16),
                MultiSelectDropDown<DocumentType>(
                  controller: documentTypesController,
                  onOptionSelected: (options) {},
                  options: allDocumentTypes
                      .map((e) => ValueItem(label: e.name, value: e))
                      .toList(),
                  singleSelectItemStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  chipConfig: const ChipConfig(
                      wrapType: WrapType.wrap, backgroundColor: Colors.red),
                  optionTextStyle: const TextStyle(fontSize: 16),
                  selectedOptionBackgroundColor: Colors.grey.shade300,
                  selectedOptionTextColor: Colors.blue,
                  dropdownMargin: 2,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () async {
                  var currentUserId = supabase.auth.currentUser!.id;
                  var file = result.files.single;
                  var fileName = file.name;
                  var fileBytes = file.bytes;

                  if (fileBytes == null) {
                    throw Exception("File bytes are null");
                  }

                  var path = "$currentUserId/$fileName";

                  await supabase.storage
                      .from("default")
                      .uploadBinary(path, fileBytes);

                  var document = Document.fromJson(await supabase
                      .from('Document')
                      .insert({
                        'name': fileName,
                        'path': path,
                      })
                      .select()
                      .single());

                  await supabase.from('DocumentToDocumentType').upsert(
                        documentTypesController.selectedOptions
                            .map((e) => {
                                  'document': document.id,
                                  'document_type': e.value!.id,
                                })
                            .toList(),
                      );

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Confirmer"),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      body: StreamBuilder(
          stream: supabase.from("DocumentType").stream(
            primaryKey: ["id"],
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final allDocumentTypes =
                snapshot.data?.map((v) => DocumentType.fromJson(v)).toList() ??
                    [];

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Documents",
                        style: TextStyle(
                          color: secondaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showCreateDialog(context, allDocumentTypes);
                        },
                        child: const Text("Créer"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder(
                  stream: supabase.from('Document').stream(primaryKey: ['id']),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final documents = snapshot.data
                            ?.map((v) => Document.fromJson(v))
                            .toList() ??
                        [];

                    return Expanded(
                      child: ListView(
                        children: documents
                            .map(
                              (document) => StreamBuilder(
                                stream: supabase
                                    .from("DocumentToDocumentType")
                                    .stream(
                                  primaryKey: ["document", "document_type"],
                                ).eq('document', document.id),
                                builder: (context, snapshot) {
                                  final documentTypes = (snapshot.data
                                              ?.map(
                                                  (row) => row['document_type'])
                                              .toList() ??
                                          [])
                                      .map(
                                        (v) => allDocumentTypes
                                            .firstWhere((dt) => dt.id == v),
                                      )
                                      .toList();

                                  return Slidable(
                                    startActionPane: ActionPane(
                                      motion: const StretchMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (context) {
                                            showEditDialog(
                                              context,
                                              document,
                                              allDocumentTypes,
                                              documentTypes,
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
                                                .eq('document', document.id);

                                            await supabase
                                                .from('Document')
                                                .delete()
                                                .eq('id', document.id);

                                            await supabase.storage
                                                .from('default')
                                                .remove([document.path]);
                                          },
                                          label: 'Supprimer',
                                          backgroundColor: Colors.red,
                                          icon: Icons.delete,
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      title: Text(
                                        document.name,
                                        style: TextStyle(color: secondaryColor),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: SizedBox(
                                        height: 20,
                                        child: ListView(
                                          children: documentTypes
                                              .map(
                                                (dt) => Text(
                                                  dt.name,
                                                  style: TextStyle(
                                                    color: secondaryColor,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: logout,
                  child: const Text("Se déconnecter"),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
    );
  }
}