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

    public abstract class SongItem : Object {}

    public class LyricLine : SongItem {
        public ArrayList<ChordToken> tokens { get; set; }
        public bool is_chorus { get; set; }
        
        public LyricLine (bool is_chorus = false) {
            tokens = new ArrayList<ChordToken> ();
            this.is_chorus = is_chorus;
        }
    }

    public class TabBlock : SongItem {
        public ArrayList<string> lines { get; set; }
        
        public TabBlock () {
            lines = new ArrayList<string> ();
        }
    }

    public enum CommentType {
        REGULAR,
        ITALIC,
        BOX
    }

    public class Comment : SongItem {
        public string text { get; set; }
        public CommentType comment_type { get; set; }
        
        public Comment (string text, CommentType comment_type) {
            this.text = text;
            this.comment_type = comment_type;
        }
    }

    public class Song : Object {
        public string title { get; set; }
        public string subtitle { get; set; }
        public string artist { get; set; }
        public string key { get; set; }
        public string copyright { get; set; }
        public ArrayList<SongItem> items { get; set; }

        public Song () {
            items = new ArrayList<SongItem> ();
            title = _("Untitled");
            subtitle = "";
            artist = "";
            key = "";
            copyright = "";
        }
    }

    public class ChordParser : Object {
        private bool in_chorus = false;
        private bool in_tab = false;
        private TabBlock? current_tab = null;

        public Song parse (string text) {
            var song = new Song ();
            in_chorus = false;
            in_tab = false;
            current_tab = null;
            
            foreach (var line_text in text.split ("\n")) {
                string trimmed = line_text.strip ();
                
                if (trimmed.has_prefix ("{") && trimmed.has_suffix ("}")) {
                    process_directive (song, trimmed);
                    continue;
                }

                if (in_tab) {
                    if (current_tab != null) {
                        current_tab.lines.add (line_text);
                    }
                    continue;
                }

                if (trimmed.length == 0) continue;

                var line = new LyricLine (in_chorus);
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
                song.items.add (line);
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
                case "subtitle":
                case "st":
                    song.subtitle = val;
                    break;
                case "artist":
                case "a":
                    song.artist = val;
                    break;
                case "key":
                case "k":
                    song.key = val;
                    break;
                case "copyright":
                    song.copyright = val;
                    break;
                case "start_of_chorus":
                case "soc":
                    in_chorus = true;
                    break;
                case "end_of_chorus":
                case "eoc":
                    in_chorus = false;
                    break;
                case "start_of_tab":
                case "sot":
                    in_tab = true;
                    current_tab = new TabBlock ();
                    song.items.add (current_tab);
                    break;
                case "end_of_tab":
                case "eot":
                    in_tab = false;
                    current_tab = null;
                    break;
                case "comment":
                case "c":
                    song.items.add (new Comment (val, CommentType.REGULAR));
                    break;
                case "comment_italic":
                case "ci":
                    song.items.add (new Comment (val, CommentType.ITALIC));
                    break;
                case "comment_box":
                case "cb":
                    song.items.add (new Comment (val, CommentType.BOX));
                    break;
            }
        }
    }
}
