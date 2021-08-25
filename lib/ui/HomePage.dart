

import 'dart:io';

import 'package:agenda_de_contatos/helpers/contact_help.dart';
import 'package:agenda_de_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //inicializando a classe do bd
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts;

  }

  /*  @override
  void initState() {
    super.initState();

    Contact c = Contact();
    c.name = "Pedro Araujo";
    c.email = "pedro@gmail.com";
    c.phone = "1020934";
    c.img = "kakaksdnkdna";

    helper.saveContact(c);

    //como vai retornar no futuro usa-se AWAIT ou a funcao THEN
    helper.getAllContact().then((list){
      print(list);
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Contatos"),
        centerTitle: true,
        //actions: [],
      ),
      backgroundColor: Colors.white,

      //botao flutuante
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index){
            return _contactCard(context, index);
          }
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index){
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    //se ele tem uma imagem ele pega um arquivo, caso contrario pega a nossa imagem
                    image: contacts[index].img != null ?
                      FileImage(File(contacts[index].img)) : AssetImage("images/download.png")
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contacts[index].name ?? "", //se o nome for vazio
                      style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                    ),
                    Text(contacts[index].email ?? "", //se o email for vazio
                      style: TextStyle(fontSize: 18.0),
                    ),
                    Text(contacts[index].phone ?? "", //se o nome for vazio
                      style: TextStyle(fontSize: 18.0),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: (){
        _showContactPage(contact: contacts[index]);
      },
    );
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact,)
      ),
    );
    if(recContact != null){
      if(contact != null){
        //atualizando contato existente
        await helper.updateContact(recContact);
      } else{
        //salvando novo contato
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts(){
    helper.getAllContact().then((list){
      setState(() {
        contacts = list;
      });
    });
  }
}
