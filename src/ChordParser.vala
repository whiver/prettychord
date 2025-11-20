using Gee;

namespace PrettyChord {
    public class ChordToken : Object {
        public string text { get; set; }
        public bool is_chord { get; set; }

        public ChordToken (string text, bool is_chord) {
            this.text = text;
            this.is_chord = is_chord;
        }
    }

    public class Line : Object {
        public ArrayList<ChordToken> tokens { get; set; }
        public Line () {
            tokens = new ArrayList<ChordToken> ();
        }
    }

    public class Song : Object {
        public string title { get; set; }
        public string artist { get; set; }
        public string key { get; set; }
        public ArrayList<Line> lines { get; set; }

        public Song () {
            lines = new ArrayList<Line> ();
            title = _("Untitled");
            artist = "";
            key = "";
        }
    }

    public class ChordParser : Object {
        public Song parse (string text) {
            var song = new Song ();
            
            foreach (var line_text in text.split ("\n")) {
                string trimmed = line_text.strip ();
                if (trimmed.has_prefix ("{") && trimmed.has_suffix ("}")) {
                    process_directive (song, trimmed);
                    continue;
                }

                var line = new Line ();
                var sb = new StringBuilder ();
                bool in_chord = false;
                
                for (int i = 0; i < line_text.length; i++) {
                    char c = line_text[i];
                    if (c == '[') {
                        if (sb.len > 0) {
                            line.tokens.add (new ChordToken (sb.str, false));
                            sb.truncate (0);
                        }
                        in_chord = true;
                    } else if (c == ']') {
                        if (in_chord) {
                            line.tokens.add (new ChordToken (sb.str, true));
                            sb.truncate (0);
                            in_chord = false;
                        } else {
                            sb.append_c (c);
                        }
                    } else {
                        sb.append_c (c);
                    }
                }
                if (sb.len > 0) {
                    line.tokens.add (new ChordToken (sb.str, false));
                }
                song.lines.add (line);
            }
            return song;
        }

        private void process_directive (Song song, string directive) {
            string content = directive.substring (1, directive.length - 2);
            string[] parts = content.split (":", 2);
            string key = parts[0].strip ().down ();
            string val = (parts.length > 1) ? parts[1].strip () : "";

            switch (key) {
                case "title":
                case "t":
                    song.title = val;
                    break;
                case "artist":
                case "a":
                    song.artist = val;
                    break;
                case "key":
                case "k":
                    song.key = val;
                    break;
            }
        }
    }
}
