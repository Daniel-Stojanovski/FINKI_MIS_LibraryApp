import 'package:library_app/book_swap_screen.dart';
import 'package:library_app/profile_screen.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
import 'package:library_app/main.dart';

class BookRequestsScreen extends StatefulWidget {
  final List<Book> books;
  final String? userEmail;

  BookRequestsScreen({Key? key, required this.books, required this.userEmail})
      : super(key: key);

  @override
  _BookRequestsScreenState createState() => _BookRequestsScreenState();
}

class _BookRequestsScreenState extends State<BookRequestsScreen> {
  late List<Book> books;
  late String? userEmail;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    books = widget.books;
    userEmail = widget.userEmail;
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => BooksLibraryApp(books: books),
      //   ),
      // );
      Navigator.pop(context, books);
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userEmail: userEmail),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading Books...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Swap'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==== YOUR REQUESTS  ====
          buildCategorySection(
            'Your Requests',
            books,
          ),
          // ==== REQUEST BUTTON  ====
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookSwapScreen(
                      books: books,
                      userEmail: widget.userEmail,
                    ),
                  ),
                );
              },
              child: Container(
                width: 100,
                child: Center(
                  child: Text('Add Request'),
                ),
              ),
            ),
          ),
          // ==== OTHER REQUESTS  ====
          buildCategorySection(
            'Other Requests',
            books,
          )
        ],
      ),
      // ==== BOTTOM NAV ====
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Swap',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Books',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget buildCategorySection(String title, List<Book> booksList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        booksList.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'No requests',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              )
            : Container(
                height: 200,
                child: Stack(
                  children: <Widget>[
                    ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: booksList.length,
                      itemBuilder: (context, index) {
                        return null;
                        // final book = booksList[index];
                      },
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}
