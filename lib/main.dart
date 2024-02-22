import 'package:library_app/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import 'package:library_app/book_content_screen.dart';
import 'package:library_app/book_details_screen.dart';
import 'package:library_app/book_requests_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:library_app/auth.dart';

import 'package:library_app/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';

// Daniel Stojanovski 193177

Future<String?> getUserEmail() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  if (user != null) {
    return user.email;
  } else {
    return null;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyCQ8SW2yEUntcpQ2ELjOsHIbhjEgDUuQWI',
      authDomain: 'YOUR_AUTH_DOMAIN',
      databaseURL: 'YOUR_DATABASE_URL',
      projectId: 'flutterbookapp-268b1',
      storageBucket: 'YOUR_STORAGE_BUCKET',
      messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
      appId: '1:30767448503:android:ec0de35b765505e1dbe832',
    ),
  );
  String? userEmail = await getUserEmail();
  runApp(MyApp(
    userEmail: userEmail,
  ));
}

// ==== BOOK CLASS ====
class Book {
  final String title;
  final String author;
  final String category;
  final String content;
  final double price;
  late int totalPages;
  bool isOwned;
  bool isFree;

  Book({
    required this.title,
    required this.author,
    required this.category,
    required this.content,
    required this.price,
    this.isOwned = false,
    this.isFree = false,
  }) {
    totalPages = (content.length / 3750).ceil(); //3750 characters per page.
  }
}

class MyApp extends StatelessWidget {
  final String? userEmail;

  MyApp({Key? key, this.userEmail}) : super(key: key);

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    print('Email main: ${userEmail}');

    return MaterialApp(
      home: WidgetTree(
        userEmail: userEmail,
      ),
    );
  }
}

class BooksLibraryApp extends StatefulWidget {
  final String? userEmail;
  final List<Book> books;

  BooksLibraryApp({Key? key, this.userEmail, this.books = const []})
      : super(key: key);

  @override
  _BooksLibraryAppState createState() => _BooksLibraryAppState();
}

class _BooksLibraryAppState extends State<BooksLibraryApp> {
  List<Book> initBooks = [];
  List<Book> books = [];
  int readPages = 0;
  String searchQuery = '';
  String selectedOwnedGenre = 'All';
  String selectedGenresGenre = 'All';
  String selectedFreeGenre = 'All';
  Book? lastReadBook;

  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    loadBooksData();
    books = widget.books;
  }

  Future<void> loadBooksData() async {
    final String data = await rootBundle.loadString('web/assets/data.json');
    final List<dynamic> jsonList = json.decode(data);

    initBooks = jsonList
        .map((bookJson) => Book(
              title: bookJson['title'],
              author: bookJson['author'],
              category: bookJson['category'],
              content: bookJson['content'],
              price: bookJson['price'] ?? 0.0,
              isOwned: bookJson['isOwned'] ?? false,
              isFree: bookJson['free'] ?? false == true,
            ))
        .toList();

    setState(() {});
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) =>
      //         BookRequestsScreen(books: books, userEmail: widget.userEmail),
      //   ),
      // );
      _navigateToBookRequestsScreen();
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            userEmail: widget.userEmail,
          ),
        ),
      );
    }
  }

  void _navigateToBookRequestsScreen() async {
    final updatedBooks = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookRequestsScreen(
          books: books, // current books list
          userEmail: widget.userEmail,
        ),
      ),
    );

    if (updatedBooks != null) {
      setState(() {
        books = updatedBooks;
      });
    }
  }

  List<Book> searchBooks(String query, List<Book> searchFrom) {
    return searchFrom.where((book) {
      final titleMatches =
          book.title.toLowerCase().contains(query.toLowerCase());
      final authorMatches =
          book.author.toLowerCase().contains(query.toLowerCase());
      final categoryMatches =
          book.category.toLowerCase().contains(query.toLowerCase());
      return titleMatches || authorMatches || categoryMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (initBooks.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading Books...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      books = initBooks;
    }

    return Scaffold(
      // ==== APP BAR ====
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'web/assets/img/PageMage_logo_long2_small.png',
            fit: BoxFit.contain,
            height: 60,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // ==== SEARCH BAR ====
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 40,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Search',
                    contentPadding: EdgeInsets.all(8.0),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),

            // ==== OWNED SECTION ====
            buildCategorySection(
                'Owned',
                (searchQuery != '')
                    ? searchBooks(searchQuery, ownedBooks())
                    : ownedBooks()),

            // ==== BOOKS SECTION ====
            buildCategorySection(
                'Books',
                (searchQuery != '')
                    ? searchBooks(
                        searchQuery, booksByCategory(selectedGenresGenre))
                    : booksByCategory(selectedGenresGenre)),

            // ==== FREE SECTION ====
            buildCategorySection(
                'Free',
                (searchQuery != '')
                    ? searchBooks(searchQuery, freeBooks())
                    : freeBooks()),
          ],
        ),
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

  List<Book> ownedBooks() {
    return books.where((book) => book.isOwned).toList();
  }

  List<Book> freeBooks() {
    return books.where((book) => book.isFree == true).toList();
  }

  List<Book> booksByCategory(String category) {
    if (category == 'All') {
      return books;
    } else if (category == 'Fiction') {
      return books
          .where((book) =>
              book.category.toLowerCase().contains(category.toLowerCase()) &&
              book.category.toLowerCase() != 'non-fiction' &&
              book.category.toLowerCase() != 'science fiction')
          .toList();
    } else {
      return books
          .where((book) =>
              book.category.toLowerCase().contains(category.toLowerCase()))
          .toList();
    }
  }

  Widget buildCategorySection(String title, List<Book> booksList) {
    if (title == 'Owned') {
      booksList.sort((a, b) {
        if (a == lastReadBook) return -1;
        if (b == lastReadBook) return 1;
        return (a.isOwned == b.isOwned)
            ? 0
            : a.isOwned
                ? -1
                : 1;
      });
    }

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
              if (title == 'Books' || title == 'Free') SizedBox(width: 20),
              if (title == 'Books') buildGenrePills('Books', booksList),
              if (title == 'Free' && title != 'Books')
                buildGenrePills('Free', booksList),
            ],
          ),
        ),
        booksList.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'No books to list',
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
                        final book = booksList[index];
                        Color bookColor;
                        switch (book.category.toLowerCase()) {
                          case 'fiction':
                            bookColor = Colors.red;
                            break;
                          case 'science fiction':
                            bookColor = Colors.red;
                            break;
                          case 'non-fiction':
                            bookColor = Colors.lightBlue;
                            break;
                          case 'mystery':
                            bookColor = Colors.blueGrey;
                            break;
                          case 'fantasy':
                            bookColor = Colors.deepPurple;
                            break;
                          case 'romance':
                            bookColor = Colors.pinkAccent;
                            break;
                          default:
                            bookColor = Colors.white;
                            break;
                        }

                        return Container(
                          width: 120,
                          child: InkWell(
                            onTap: () {
                              // Check if the book is owned
                              // if owned, open the book
                              if (ownedBooks().contains(book)) {
                                lastReadBook = book;
                                setState(() {});
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookContentScreen(
                                      title: book.title,
                                      content: book.content,
                                      totalPages: book.totalPages,
                                    ),
                                  ),
                                );
                              }
                              // Check if the book is free
                              // if free, open the book
                              else if (book.isFree) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookContentScreen(
                                      title: book.title,
                                      content: book.content,
                                      totalPages: book.totalPages,
                                    ),
                                  ),
                                );
                              }
                              // else the book is not owned
                              // then, open the book details
                              else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookDetailsScreen(
                                      title: book.title,
                                      author: book.author,
                                      category: book.category,
                                      price: book.price,
                                      book: book,
                                      onBuy: (Book boughtBook) {
                                        setState(() {
                                          boughtBook.isOwned = true;
                                        });
                                        lastReadBook = boughtBook;
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                BookContentScreen(
                                              title: boughtBook.title,
                                              content: boughtBook.content,
                                              totalPages: boughtBook.totalPages,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Card(
                              color: bookColor,
                              child: Stack(
                                children: [
                                  Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          book.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          book.author,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        Text(
                                          book.category,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (book.isOwned && title == 'Books')
                                    buildOwnedTag(book),
                                  if (title != 'Free') buildFreeTag(book),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ],
    );
  }

  Widget buildGenrePills(String categoryType, List<Book> booksList) {
    final genres = Set<String>();

    for (final book in booksList) {
      if ((categoryType != 'Owned' || book.isOwned) &&
          (categoryType == 'Books' ||
              (categoryType == 'Free' && book.isFree))) {
        genres.add(book.category);
      }
    }

    final selectedGenres = (categoryType == 'Owned'
        ? selectedOwnedGenre
        : (categoryType == 'Books' ? selectedGenresGenre : selectedFreeGenre));
    final allGenres = genres.toList();

    return Row(
      children: [
        FilterChip(
          label: Text('All'),
          selected: selectedGenres == 'All',
          onSelected: (isSelected) {
            setState(() {
              if (categoryType == 'Owned') {
                selectedOwnedGenre = isSelected ? 'All' : 'All';
              } else if (categoryType == 'Books') {
                selectedGenresGenre = isSelected ? 'All' : 'All';
              } else if (categoryType == 'Free') {
                selectedFreeGenre = isSelected ? 'All' : 'All';
              }
            });
          },
        ),
        SizedBox(width: 10.0),
        Container(
          width: MediaQuery.of(context).size.width - 180,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 10.0,
              children: allGenres.map((genre) {
                if (genre != 'All') {
                  // remaining pills
                  return FilterChip(
                    label: Text(genre),
                    selected: selectedGenres == genre,
                    onSelected: (isSelected) {
                      setState(() {
                        if (categoryType == 'Owned') {
                          selectedOwnedGenre = isSelected ? genre : 'All';
                        } else if (categoryType == 'Books') {
                          selectedGenresGenre = isSelected ? genre : 'All';
                        } else if (categoryType == 'Free') {
                          selectedFreeGenre = isSelected ? genre : 'All';
                        }
                      });
                    },
                  );
                } else {
                  return SizedBox.shrink();
                }
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildFreeTag(Book book) {
    if (book.isFree) {
      return Align(
        alignment: Alignment.topRight,
        child: Container(
          padding: EdgeInsets.all(4),
          color: Colors.blue,
          child: Text(
            'Free',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  buildOwnedTag(Book book) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        padding: EdgeInsets.all(4),
        color: Colors.green,
        child: Text(
          'Owned',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
