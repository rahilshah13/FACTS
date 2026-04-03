import ebooklib
from ebooklib import epub
from bs4 import BeautifulSoup

book = epub.read_epub('00_scrabble.epub')
with open('00_scrabble.txt', 'w', encoding='utf-8') as f:
    for item in book.get_items_of_type(ebooklib.ITEM_DOCUMENT):
        # Parse the HTML content of each chapter
        soup = BeautifulSoup(item.get_content(), 'html.parser')
        # Extract text and write to file
        f.write(soup.get_text() + '\n')