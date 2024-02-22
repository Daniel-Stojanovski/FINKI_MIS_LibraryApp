import 'package:flutter/material.dart';
import 'package:library_app/main.dart';

class BookDetailsScreen extends StatelessWidget {
  final String title;
  final String author;
  final String category;
  final double price;

  final Book book;
  final Function(Book) onBuy;

  BookDetailsScreen({
    required this.title,
    required this.author,
    required this.category,
    required this.price,
    required this.onBuy,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Title: $title'),
            Text('Author: $author'),
            Text('Category: $category'),
            Text('Price: \$$price'),
            ElevatedButton(
              onPressed: () {
                onBuy(book);
              },
              child: Text('Buy'),
            ),
          ],
        ),
      ),
    );
  }
}
