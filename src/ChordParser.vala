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
        public ArrayList<Line> lines { get; set; }

        public Song () {
            lines = new ArrayList<Line> ();
        }
    }

    public class ChordParser : Object {
        public Song parse (string text) {
            var song = new Song ();
            song.title = "Untitled";
            
            foreach (var line_text in text.split ("\n")) {
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
    }
}
