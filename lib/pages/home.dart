import 'package:efrei_ged/colors.dart';
import 'package:efrei_ged/model/Document.dart';
import 'package:efrei_ged/model/documentType.dart';
import 'package:efrei_ged/supabase.dart';
import 'package:file_picker/_internal/file_picker_web.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchText = "";

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
          var descriptionController =
              TextEditingController(text: document.description);

          return AlertDialog(
            title: Text(
              "Modifier ${document.name}",
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
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
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
                  chipConfig: const ChipConfig(
                    wrapType: WrapType.wrap,
                    backgroundColor: Colors.transparent,
                  ),
                  optionTextStyle: const TextStyle(fontSize: 16),
                  dropdownMargin: 2,
                  fieldBackgroundColor: Colors.transparent,
                  dropdownBackgroundColor: Colors.transparent,
                  optionsBackgroundColor: Colors.transparent,
                  searchBackgroundColor: Colors.transparent,
                  optionBuilder: (ctx, item, selected) => selected
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.label,
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.label,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                  dropdownBorderRadius: 8,
                  borderColor: secondaryColor,
                  borderWidth: 1.25,
                  borderRadius: 8,
                  clearIcon: Icon(
                    Icons.clear,
                    color: secondaryColor,
                  ),
                  suffixIcon: Icon(
                    Icons.arrow_drop_down,
                    color: secondaryColor,
                  ),
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

                  await supabase.from('DocumentToDocumentType').insert(
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
          TextEditingController descriptionController = TextEditingController();

          return AlertDialog(
            title: Text(
              "Créer un document",
              style: TextStyle(color: secondaryColor),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
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
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description",
                  ),
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
                  dropdownMargin: 2,
                  fieldBackgroundColor: Colors.transparent,
                  searchBackgroundColor: Colors.transparent,
                  dropdownBackgroundColor: Colors.transparent,
                  hint: "Sélectionner les types du document",
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
                        'description': descriptionController.text,
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
                      "Efrei GED",
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        showCreateDialog(context, allDocumentTypes);
                      },
                      label: const Text("Document"),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchBar(
                  hintText: "Rechercher",
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),
              ),
              StreamBuilder(
                stream: supabase.from('Document').stream(primaryKey: ['id']),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final documents = (snapshot.data ?? [])
                      .map((v) => Document.fromJson(v))
                      .toList()
                      .where((document) {
                    return document.name
                        .toLowerCase()
                        .contains(searchText.toLowerCase());
                  });

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
                                final documentTypes = (snapshot.data ?? [])
                                    .map((row) => row['document_type'])
                                    .toList()
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
                                      child: documentTypes.isNotEmpty
                                          ? ListView(
                                              scrollDirection: Axis.horizontal,
                                              children: documentTypes
                                                  .map(
                                                    (dt) => Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                        right: 8,
                                                      ),
                                                      child: Text(
                                                        dt.name,
                                                        style: TextStyle(
                                                          color: secondaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            )
                                          : const Text(
                                              "Aucun type",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.download),
                                      onPressed: () async {
                                        await FileSaver.instance.saveFile(
                                          name: document.name,
                                          bytes: await supabase.storage
                                              .from('default')
                                              .download(document.path),
                                        );
                                      },
                                      color: secondaryColor,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: logout,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                    ),
                    child: Text(
                      "Se déconnecter",
                      style: TextStyle(color: secondaryColor),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("/document-types");
                    },
                    child: const Text("Types de documents"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
