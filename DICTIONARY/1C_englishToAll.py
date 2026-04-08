# invocation: python 02_englishToAll.py [dry-run | openai]
import sys, os, openai, concurrent.futures

client = openai.OpenAI()
#languages = ["Mandarin Chinese", "Hindi", "Spanish", "French", "Modern Standard Arabic", "Bengali", "Portuguese", "Russian", "Urdu", "Indonesian", "German", "Japanese", "Nigerian Pidgin", "Marathi", "Telugu", "Turkish", "Tamil", "Yue Chinese", "Vietnamese", "Tagalog", "Wu Chinese", "Korean", "Iranian Persian", "Hausa", "Swahili", "Javanese", "Italian", "Western Punjabi", "Kannada", "Gujarati", "Thai", "Amharic", "Bhojpuri", "Yoruba", "Hakka Chinese", "Burmese", "Oromo", "Pashto", "Maithili", "Ukrainian", "Sundanese", "Polish", "Uzbek", "Malayalam", "Sindhi", "Azerbaijani", "Romanian"]
languages = [ "German", "Japanese", "Turkish", "Yue Chinese", "Vietnamese", "Wu Chinese", "Korean", "Hausa", "Swahili", "Javanese", "Western Punjabi", "Kannada", "Gujarati", "Amharic", "Bhojpuri", "Yoruba", "Hakka Chinese", "Oromo", "Sundanese"]

with open("./00_words.pl", "r") as f:
    all_lines = [line.strip() for line in f if line.strip()]

def process_language(lang):
    filename = f"{lang.replace(' ', '_')}.pl"
    
    start_index = 0
    if os.path.exists(filename):
        with open(filename, "r", encoding="utf-8") as f_check:
            start_index = len(f_check.readlines())

    if start_index >= len(all_lines):
        print(f"[{lang}] Already complete.")
        return

    # Open in append mode to continue where we left off
    with open(filename, "a", encoding="utf-8") as f_out:
        for i in range(start_index, len(all_lines)):
            line = all_lines[i]
            try:
                res = client.chat.completions.create(
                    model="gpt-4o",
                    messages=[{"role": "user", "content": f"Translate this Prolog line to {lang}. Output only Prolog:\n{line}"}]
                )
                translation = res.choices[0].message.content.strip()
                f_out.write(translation + "\n")
                f_out.flush() # Ensure it writes to disk immediately
                print(f"[{lang}] ({i+1}/{len(all_lines)}) Completed: {translation}")
            except Exception as e:
                print(f"[{lang}] Error at line {i}: {e}")
                break

def dry_run():
  for lang in languages:
    for line in lang:
      print(f"[{lang}] Translating: {line}")
      print(f"[{lang}] Result: % Translated version of {line}")

if sys.argv[1]  == "dry-run":
  dry_run()
  
else:
  with concurrent.futures.ThreadPoolExecutor(max_workers=len(languages)) as executor:
    executor.map(process_language, languages)