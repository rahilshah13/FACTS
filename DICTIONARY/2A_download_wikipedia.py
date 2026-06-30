import requests, bz2, mwparserfromhell, io
from lxml import etree

DATA_URL = "https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-pages-articles-multistream.xml.bz2"
INDEX_URL = "https://dumps.wikimedia.org/enwiki/latest/enwiki-latest-pages-articles-multistream-index.txt.bz2"
HEADERS = {'User-Agent': 'WikiDataExtractor/1.0'}

def get_offset(page_id):
    decompressor = bz2.BZ2Decompressor()
    with requests.get(INDEX_URL, headers=HEADERS, stream=True) as r:
        buffer = b""
        for chunk in r.iter_content(chunk_size=8192):
            data = decompressor.decompress(chunk)
            if data:
                buffer += data
                lines = buffer.split(b'\n')
                buffer = lines[-1]
                for line in lines[:-1]:
                    parts = line.decode('utf-8', errors='ignore').split(':')
                    if len(parts) >= 3 and parts[1] == str(page_id):
                        return int(parts[0])
    return None

def fetch_and_parse(page_id, block_offset):
    headers = {**HEADERS, 'Range': f'bytes={block_offset}-{block_offset + 1000000}'}
    r = requests.get(DATA_URL, headers=headers)    
    decompressor = bz2.BZ2Decompressor()
    decompressed_data = decompressor.decompress(r.content)    
    parser = etree.XMLParser(recover=True)
    root = etree.fromstring(b"<root>" + decompressed_data + b"</root>", parser=parser)    
    page = root.xpath(f".//page[id='{page_id}']")
    if page:
        text = page[0].xpath(".//text")[0].text
        return mwparserfromhell.parse(text).strip_code()

def total_pages():
    decompressor = bz2.BZ2Decompressor()
    pages = 0
    with requests.get(INDEX_URL, headers=HEADERS, stream=True) as r:
        for chunk in r.iter_content(chunk_size=8192):
            data = decompressor.decompress(chunk)
            if data:
                pages += data.count(b'\n')    
    return pages


page_id = 1
offset = get_offset(page_id)
if offset:
    print(fetch_and_parse(page_id, offset))

print(f"Total number of pages: {total_pages()}")
