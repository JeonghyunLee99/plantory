import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/instance_manager.dart';
import 'package:get/route_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:unicons/unicons.dart';
import '../../data/person.dart';
import '../../data/plant.dart';
import '../../utils/colors.dart';
import '../plant/input_field.dart';

class TimelineAddPage extends StatefulWidget{

  const TimelineAddPage({Key? key, required this.person}) : super(key: key);

  final Person person;

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TimelineAddPage();
  }

}

class _TimelineAddPage extends State<TimelineAddPage>{

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  late Plant plant;
  var image;

  @override
  initState() {
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Color(0xffEEF1F1),
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffEEF1F1),
        title: const Text(
          "Add Timeline",
          style: TextStyle(color: primaryColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black54,),
          onPressed: () { Navigator.pop(context); },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: IconButton(
                onPressed: () async{
                  if(_formKey.currentState!.validate()){
                    plant.timelines!.add({
                      'image': image != null ? base64Encode(image) : null,
                      'date': dateController.text,
                      'title' : titleController.text,
                      'content' : contentController.text
                    });

                    var usersCollection = firestore.collection('users');
                    await usersCollection.doc(widget.person.uid).update(
                        {
                          "plants": widget.person.plantsToJson(widget.person.plants!)
                        }).then((value) => Get.back());
                  }
                },
                icon: Icon(Icons.check, color: Colors.black54,)
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                          child: GestureDetector(
                            child: image == null ? Container() : Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: MediaQuery.of(context).size.width * 0.6,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: Image.memory(image, fit: BoxFit.cover,).image,
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width * 0.1))
                                ),
                            ),
                            onTap: () {
                              var picker = ImagePicker();
                              showDialog(
                                barrierColor: Colors.black54,
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Center(child: Text("사진 선택")),
                                  titlePadding: EdgeInsets.all(15),
                                  content: SizedBox(
                                    width: double.infinity,
                                    height: MediaQuery.of(context).size.height * 0.2,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Divider(thickness: 1,color: Colors.black54,),
                                          ListTile(title: Text("카메라"),
                                            leading: Icon(Icons.camera_alt_outlined),
                                            onTap: () async{
                                              await picker.pickImage(source: ImageSource.camera)
                                                  .then((value) =>  Navigator.of(context).pop(value));},

                                          ),
                                          Divider(thickness: 1),
                                          ListTile(title: Text("갤러리"),
                                            leading: Icon(Icons.photo_camera_back),
                                            onTap: () async{
                                              await picker.pickImage(source: ImageSource.gallery)
                                                  .then((value) =>  Navigator.of(context).pop(value));},
                                          ),
                                          Divider(thickness: 1),
                                        ],
                                      ),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(0),
                                  actions: [
                                    TextButton(
                                      child: const Text('취소'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              ).then((value) async{
                                if(value != null){
                                  image = await value.readAsBytes();
                                  setState(() {});
                                }
                              });
                            },
                          )
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InputField(
                        isEditable: false,
                        label: "식물",
                        hint: "",
                        controller: nameController,
                        emptyText: false,
                        icon: Icon(UniconsLine.flower),
                        onTap: (){
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("식물 선택"),
                                  IconButton(
                                      onPressed: (){
                                        Get.back();
                                      },
                                      icon: Icon(Icons.close,color: Colors.black54,)
                                  )
                                ],
                              ),
                              content: SizedBox(
                                height: MediaQuery.of(context).size.height * 0.4,
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: widget.person.plants!.length,
                                  itemBuilder: (BuildContext context, int index) =>
                                       Column(
                                         children: [
                                           Divider(thickness: 1,),
                                           GestureDetector(
                                             child: Row(children: [
                                               Padding(
                                                 padding: const EdgeInsets.all(8.0),
                                                 child: Text(widget.person.plants![index]!.name!,style: TextStyle(fontWeight: FontWeight.bold),),
                                               ),
                                               Padding(
                                                 padding: const EdgeInsets.all(8.0),
                                                 child: Text(widget.person.plants![index]!.type!),
                                               ),
                                             ],),
                                             onTap: (){
                                               setState(() {
                                                 plant = widget.person.plants![index]!;
                                                 nameController.text = widget.person.plants![index]!.name!;
                                               });
                                               Navigator.of(context).pop();
                                             },

                                           ),
                                           index == widget.person.plants!.indexOf(widget.person.plants!.last) ? Divider(thickness: 1,) : Container(),
                                         ],
                                       )
                                ),
                              ),
                            );
                          });
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InputField(
                        onTap: () async{
                          dateController.text = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(), //초기값
                            firstDate: DateTime(DateTime.now().year-1), //시작일
                            lastDate: DateTime(DateTime.now().year+1), //마지막일
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light(), //다크 테마
                                child: child!,
                              );
                            },
                          ).then((value) => value != null ? DateFormat('yyyy-MM-dd').format(value) : dateController.text );
                        },
                        controller: dateController,
                        isEditable: false,
                        label: '날짜',
                        emptyText: false,
                        icon: Icon(Icons.calendar_month_outlined),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        controller: titleController,
                        maxLength: 20,
                        validator: (value){
                          if (value.toString().isEmpty) {
                            return '제목을 입력해주세요';
                          }
                        },
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(height:0.1),
                          labelText: "제목",
                        ),
                      ),
                      TextFormField(
                        controller: contentController,
                        keyboardType: TextInputType.multiline,
                        maxLength: 50,
                        maxLines: null,
                        validator: (value){
                          if (value.toString().isEmpty) {
                            return '내용을 입력해주세요';
                          }
                        },
                        decoration: InputDecoration(
                          labelStyle: const TextStyle(height:0.1),
                          labelText: "내용",
                          hintText:  "식물에게 하고 싶은말, 변화 등을 적어보세요!",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          var picker = ImagePicker();
          showDialog(
            barrierColor: Colors.black54,
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Center(child: Text("사진 선택")),
              titlePadding: EdgeInsets.all(15),
              content: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Divider(thickness: 1,color: Colors.black54,),
                      ListTile(title: Text("카메라"),
                        leading: Icon(Icons.camera_alt_outlined),
                        onTap: () async{
                          await picker.pickImage(source: ImageSource.camera,maxWidth: 1024, maxHeight: 1024)
                              .then((value) =>  Navigator.of(context).pop(value));},

                      ),
                      Divider(thickness: 1),
                      ListTile(title: Text("갤러리"),
                        leading: Icon(Icons.photo_camera_back),
                        onTap: () async{
                          await picker.pickImage(source: ImageSource.gallery,maxWidth: 1024, maxHeight: 1024)
                              .then((value) =>  Navigator.of(context).pop(value));},
                      ),
                      Divider(thickness: 1),
                    ],
                  ),
                ),
              ),
              contentPadding: EdgeInsets.all(0),
              actions: [
                TextButton(
                  child: const Text('취소'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ).then((value) async{
            if(value != null){
              image = await value.readAsBytes();
              setState(() {});
            }
          });
        },
        heroTag: null,
        child: Icon(Icons.camera_alt_outlined,),backgroundColor: primaryColor,),
    );
  }

}
