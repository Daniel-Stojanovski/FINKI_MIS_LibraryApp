import 'package:flutter/material.dart';
import 'package:library_app/main.dart';

class BookSwapScreen extends StatefulWidget {
  final List<Book> books;
  final String? userEmail;

  BookSwapScreen({required this.books, required this.userEmail});

  @override
  _BookSwapScreenState createState() => _BookSwapScreenState();
}

class _BookSwapScreenState extends State<BookSwapScreen> {
  late List<Book> books;

  Book selectedBookLeft = Book(
    title: '',
    author: '',
    category: '',
    content: '',
    price: 0.00,
  ); // for left bookholder
  Book selectedBookRight = Book(
    title: '',
    author: '',
    category: '',
    content: '',
    price: 0.00,
  ); // for right bookholder
  bool canSelectRight = false;
  String searchQuery = '';

  String selectedGenre = 'All';
  String selectedGenresGenre = 'All';
  String selectedOwnedGenre = 'All';

  bool isRightPlaceholderLocked = true;

  @override
  void initState() {
    super.initState();
    books = widget.books;
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

  List<Book> ownedBooks() {
    return books.where((book) => book.isOwned).toList();
  }

  // void _onItemTapped(int index) {
  //   if (index == 1) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => BooksLibraryApp(books: books),
  //       ),
  //     );
  //   } else if (index == 2) {
  //     //
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // Check if books are still loading
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
          // ==== SWAP TEXT ====
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Swap Books',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ),
          ),
          // ==== SWAP CONTAINER ====
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBookPlaceholderLeft(),
                  Text(
                    'FOR',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  _buildBookPlaceholderRight(
                      isLocked: isRightPlaceholderLocked),
                ],
              ),
            ),
          ),
          Column(
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
            ],
          ),
          // ==== BOOKS SECTION ====
          canSelectRight
              ? buildCategorySection(
                  'Books',
                  (searchQuery != '')
                      ? searchBooks(searchQuery,
                          books.where((book) => !book.isOwned).toList())
                      : books.where((book) => !book.isOwned).toList())
              : buildCategorySection(
                  'Owned',
                  (searchQuery != '')
                      ? searchBooks(searchQuery, ownedBooks())
                      : ownedBooks()),
          // ==== REQUEST BUTTON  ====
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
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
                    child: Text('Request'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookPlaceholderLeft({String price = ''}) {
    Color bookColor;
    return Column(
      children: [
        DragTarget<Book>(
          onAccept: (data) {
            setState(() {
              isRightPlaceholderLocked = false;
              selectedBookLeft = data;
            });
          },
          builder: (context, candidateData, rejectedData) {
            switch (selectedBookLeft.category.toLowerCase()) {
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
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
              child: selectedBookLeft.title.isEmpty
                  ? Container(
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Text(
                          '+',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : Card(
                      color: bookColor,
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  selectedBookLeft.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  selectedBookLeft.author,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Text(
                                  selectedBookLeft.category,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
        SizedBox(height: 8),
        Text(
          'price: \$${selectedBookLeft.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildBookPlaceholderRight(
      {String price = '', bool isLocked = false}) {
    Color bookColor;
    return Column(
      children: [
        DragTarget<Book>(
          onWillAccept: (data) {
            return !isRightPlaceholderLocked;
          },
          onAccept: (data) {
            setState(() {
              isRightPlaceholderLocked = false;
              selectedBookRight = data;
            });
          },
          builder: (context, candidateData, rejectedData) {
            switch (selectedBookRight.category.toLowerCase()) {
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
              height: 200,
              decoration: BoxDecoration(
                color: isLocked ? Colors.grey[300] : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
              ),
              child: selectedBookRight.title.isEmpty
                  ? isLocked
                      ? Center(
                          child: Icon(
                            Icons.lock,
                            size: 40,
                            color: Colors.grey,
                          ),
                        )
                      : Container(
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              '+',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                  : Card(
                      color: bookColor,
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  selectedBookRight.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  selectedBookRight.author,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Text(
                                  selectedBookRight.category,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
        SizedBox(height: 8),
        Text(
          'price: \$${selectedBookRight.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
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
                        // TODO: Build map function to generate colors for all categories
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
                          child: Card(
                            color: bookColor,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (!canSelectRight) {
                                    selectedBookLeft = book;
                                    canSelectRight = true;
                                  } else {
                                    selectedBookRight = book;
                                  }
                                });
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
}
