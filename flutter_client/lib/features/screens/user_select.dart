import 'package:flutter/material.dart';

import 'chatscreen.dart';



class user_select extends StatelessWidget {
  const user_select({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcı Seçimi')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text("Kullanıcı 1 Olarak Gir"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20),backgroundColor: Colors.blueAccent),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // currentUser parametresine 'User1' gönderiyoruz
                    builder: (context) => const ChatScreen(currentUser: "User1"),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // --- KULLANICI 2 BUTONU ---
            ElevatedButton.icon(
              icon: const Icon(Icons.person_2),
              label: const Text("Kullanıcı 2 Olarak Gir"),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20), backgroundColor: Colors.red),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // currentUser parametresine 'User2' gönderiyoruz
                    builder: (context) => const ChatScreen(currentUser: "User2"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}