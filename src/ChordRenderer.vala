using Cairo;

namespace PrettyChord {
    public class ChordRenderer : Object {
        public void draw_song (Context cr, Song song, double width) {
            cr.set_source_rgb (0, 0, 0);
            cr.select_font_face ("Monospace", FontSlant.NORMAL, FontWeight.NORMAL);
            
            double y = 40;
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
