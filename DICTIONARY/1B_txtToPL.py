# python 01_txtToPL.py 01_scrabble.txt words.pl
import re
import sys

def clean(text, allow_spaces=False):
    # Removes anything that isn't a letter, number, or space (if allowed)
    pattern = r'[^a-zA-Z0-9 ]' if allow_spaces else r'[^a-zA-Z0-9]'
    return re.sub(pattern, '', text).strip()

def parse_line(line):
    line = line.strip()
    if not line: return None

    parts = line.split()
    # Clean the primary word and part of speech
    word = clean(parts[0].lower())
    pos = clean(parts[1].lower())

    rest = " ".join(parts[2:])
    forms = []
    definition = rest

    # Plural handling
    m = re.search(r'pl\.\s+([A-Z, ]+)', rest)
    if m:
        forms = [clean(w.lower()) for w in re.split(r'[,\s]+', m.group(1)) if w]
        definition = rest[m.end():].strip()

    # Verb conjugations
    m2 = re.search(r'([A-Z]+,\s*[A-Z]+,\s*[A-Z]+)', rest)
    if m2 and pos == "v":
        forms = [clean(w.lower()) for w in re.split(r',\s*', m2.group(1)) if w]
        definition = rest[m2.end():].strip()

    # Clean the definition but allow spaces
    definition = clean(definition, allow_spaces=True)
    
    return word, pos, forms, definition

def convert(infile, outfile):
    facts = []
    with open(infile, encoding="utf8") as f:
        for line in f:
            parsed = parse_line(line)
            if not parsed or not parsed[0]: continue

            word, pos, forms, definition = parsed
            
            # Format the forms as valid Prolog atoms
            forms_str = "[" + ",".join(forms) + "]"
            
            # Final safety check: ensure the definition doesn't have internal quotes
            definition = definition.replace('"', '')

            fact = f'entry({word}, {pos}, {forms_str}, "{definition}").'
            facts.append(fact)

    with open(outfile, "w", encoding="utf8") as f:
        f.write("\n".join(facts))

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python script.py input.txt output.pl")
    else:
        convert(sys.argv[1], sys.argv[2])