using Cairo;

namespace PrettyChord {
    public class ChordRenderer : Object {
        public void draw_song (Context cr, Song song, double width) {
            cr.set_source_rgb (0, 0, 0);
            
            double y = 40;
            
            // Draw Header
            if (song.title != _("Untitled") || song.artist != "" || song.key != "") {
                // Title
                cr.select_font_face ("Sans", FontSlant.NORMAL, FontWeight.BOLD);
                cr.set_font_size (24);
                TextExtents extents;
                cr.text_extents (song.title, out extents);
                cr.move_to ((width - extents.width) / 2, y);
                cr.show_text (song.title);
                y += extents.height + 10;

                // Artist
                if (song.artist != "") {
                    cr.select_font_face ("Sans", FontSlant.NORMAL, FontWeight.NORMAL);
                    cr.set_font_size (18);
                    cr.text_extents (song.artist, out extents);
                    cr.move_to ((width - extents.width) / 2, y);
                    cr.show_text (song.artist);
                    y += extents.height + 10;
                }

                // Key
                if (song.key != "") {
                    cr.select_font_face ("Sans", FontSlant.NORMAL, FontWeight.NORMAL);
                    cr.set_font_size (14);
                    cr.move_to (10, y);
                    cr.show_text (_("Key: ") + song.key);
                    y += 20;
                }
                
                y += 20; // Spacing after header
            }

            cr.select_font_face ("Monospace", FontSlant.NORMAL, FontWeight.NORMAL);
            
            double line_height = 20;
            
            foreach (var line in song.lines) {
                double x = 10;
                double next_min_x = 0;
                
                foreach (var token in line.tokens) {
                    if (token.is_chord) {
                        cr.set_font_size (12);
                        cr.set_source_rgb (0, 0, 1); // Blue chords
                        cr.move_to (x, y - 15);
                        cr.show_text (token.text);
                        
                        TextExtents extents;
                        cr.text_extents (token.text, out extents);
                        
                        if (x + extents.width > next_min_x) {
                            next_min_x = x + extents.width + 5;
                        }
                    } else {
                        cr.set_font_size (14);
                        cr.set_source_rgb (0, 0, 0); // Black lyrics
                        cr.move_to (x, y);
                        cr.show_text (token.text);
                        
                        TextExtents extents;
                        cr.text_extents (token.text, out extents);
                        x += extents.x_advance;
                        
                        if (x < next_min_x) {
                            x = next_min_x;
                        }
                    }
                }
                y += (line_height + 20);
            }
        }
    }
}
