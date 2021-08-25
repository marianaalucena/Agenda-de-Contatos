import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//definindo os nomes das colunas do bd
final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String phoneColumn = "phoneColumn";
final String emailColumn = "emailColumn";
final String imgColumn = "imgColumn";


class ContactHelper {
  //singleton: a classe vai conter apenas um objeto no codigo

  static final ContactHelper _instance = ContactHelper.internal();
  factory ContactHelper() => _instance;

  ContactHelper.internal();

  //declarando o banco de dados
  Database _db;

  //inicializando o bd
  Future<Database> get db async {
    if(_db != null){
      return _db;
    } else{
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async{
    //databasePath: local onde o bd vai ser armazenado
    final databasePath = await getDatabasesPath();

    //caminho para o arquivo que vai estar armazenando no bd
    final path = join(databasePath, "contactsnew.db");

    //quando abrimos o bd pela primeira vez ele vai criar a tabela
    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async {
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, "
            "$phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    //obtendo o bd
    Database dbContact = await db;

    //transformnado o contato em mapa para poder inserir no bd
    //id que o contato vai ter
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async{
    //obtendo o bd
    Database dbContact = await db;

    //procurando o contato que tem o id = ao que foi passado
    //query: obter os dados que voce quer
    List<Map> maps = await dbContact.query(contactTable,
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
      where: "$idColumn = ?",
      whereArgs: [id]);

    if(maps.length > 0){
      return Contact.fromMap(maps.first);
    } else{
      //contato nao foi encontrado
      return null;
    }
  }

  Future<int> deleteContact(int id) async {
    //obtendo o bd
    Database dbContact = await db;

    //delete retorna um int indicando se deu certo ou nao
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    //obtendo o bd
    Database dbContact = await db;

    //update retorna um int indicando se deu certo ou nao
    return await dbContact.update(contactTable, contact.toMap(), where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  Future<List> getAllContact() async {
    //obtendo o bd
    Database dbContact = await db;

    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    List<Contact> listContact = List();

    //transformando cada contato em mapa e colocando na lista de contato
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }

    return listContact;
  }

  //obtendo a quantidade de contatos na lista
  Future<int> getNumber() async{
    //obtendo o bd
    Database dbContact = await db;

    //obtendo a contagem e retornando a quantidade de elementos da tabela
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));

  }

  //fechando o bd
  Future close() async{
    //obtendo o bd
    Database dbContact = await db;

    dbContact.close();
  }

}

//molde do contato, como ele sera criado
class Contact {

  //cada contato com id unico
  int id;
  String name;
  String email;
  String phone;

  //img fica como string porque nao tem como add uma img ao bd, armazenamos o local
  String img;

  Contact();

  //esse construtor porque os dados serao armazenados em formato de mapa
  Contact.fromMap(Map map) {
    id = map[idColumn];
    name = map[nameColumn];
    phone = map[phoneColumn];
    email = map[emailColumn];
    img = map [imgColumn];
  }

  //pegando o contato e transformando em mapa
  Map toMap(){
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}