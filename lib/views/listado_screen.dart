import 'package:flutter/material.dart';
import '../controllers/database_helper.dart';
import 'detalle_cuenta_screen.dart';
import '../widgets/app_drawer.dart';

class ListadoScreen extends StatefulWidget {
  @override
  _ListadoScreenState createState() => _ListadoScreenState();
}

class _ListadoScreenState extends State<ListadoScreen> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _searchController.addListener(_filterUsers);
  }

  Future<void> _fetchUsers() async {
    final users = await DatabaseHelper().getUsers();
    setState(() {
      _users = users;
      _filteredUsers = users;
    });
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        return user['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listado',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nombre',
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  color: index % 2 == 0 ? Color(0xFFE0F7FA) : Color(0xFFF4FCFF),
                  child: ListTile(
                    title: Text(
                      user['name'],
                      style: TextStyle(color: Colors.black),
                    ),
                    subtitle: Text(
                      '${user['phone']} ${user['email']}',
                      style: TextStyle(color: Colors.black54),
                    ),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleCuentaScreen(
                            name: user['name'],
                            email: user['email'],
                            phone: user['phone'],
                            birthdate: user['birthdate'],
                            address: user['address'],
                            password: user['password'],
                            userId: user['id'].toString(),
                          ),
                        ),
                      );

                      if (result == true) {
                        _fetchUsers(); // Refresh the list
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

