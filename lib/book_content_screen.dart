import 'package:flutter/material.dart';

class BookContentScreen extends StatefulWidget {
  final String title;
  final String content;
  final int totalPages;

  const BookContentScreen({
    required this.title,
    required this.content,
    required this.totalPages,
  });

  @override
  _BookContentScreenState createState() => _BookContentScreenState();
}

class _BookContentScreenState extends State<BookContentScreen> {
  int currentPage = 1;
  final int wordsPerPage = 3750;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'web/assets/img/PageMage_logo_long2_small.png',
            fit: BoxFit.contain,
            height: 60,
          ),
        ),
      ),
      body: Container(
        width: 500,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    // Display the current page content
                    getPageContent(widget.content, currentPage),
                    style: TextStyle(
                      fontSize: 16.0,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                if (currentPage > 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentPage--;
                      });
                    },
                    child: Text('Previous Page'),
                  ),
                Text('Page $currentPage of ${widget.totalPages}'),
                if (currentPage < widget.totalPages)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentPage++;
                      });
                    },
                    child: Text('Next Page'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String getPageContent(String content, int page) {
    final int pageStart = (page - 1) * wordsPerPage;
    final int pageEnd = page * wordsPerPage;

    if (pageStart >= content.length) {
      return ''; // Empty page
    }

    String pageContent = content.substring(
      pageStart,
      pageEnd < content.length ? pageEnd : content.length,
    );

    // Check if the last character is part of a word and if the next character is not a space
    if (pageEnd < content.length &&
        !_isWordSeparator(content[pageEnd - 1]) &&
        content[pageEnd] != ' ') {
      // Find the last space character before pageEnd
      int lastSpaceIndex =
          pageContent.substring(0, pageContent.length - 1).lastIndexOf(' ');

      // If a space was found, break the line at that space
      if (lastSpaceIndex >= 0) {
        pageContent =
            pageContent.replaceRange(lastSpaceIndex, lastSpaceIndex + 1, '-\n');
      }
    }
    return pageContent;
  }

  bool _isWordSeparator(String character) {
    // Define word separators (e.g., space, newline, punctuation marks, etc.)
    return character == ' ' ||
        character == '\n' ||
        character == ',' ||
        character == '.' ||
        character == ';';
  }
}
