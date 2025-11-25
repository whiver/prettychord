using Cairo;

namespace PrettyChord {
    public class ChordRenderer : Object {
        public void draw_song (Context cr, Song song, double width, double page_height = 0) {
            cr.set_source_rgb (0, 0, 0);
            
            double margin_top = 40;
            double margin_bottom = 40;
            double y = margin_top;
            
            // Draw Header
            if (song.title != _("Untitled") || song.artist != "" || song.key != "") {
                // Title
                cr.select_font_face ("Sans", FontSlant.NORMAL, FontWeight.BOLD);
                cr.set_font_size (24);
                TextExtents extents;
                cr.text_extents (song.title, out extents);
                cr.move_to ((width - extents.width) / 2, y);
                cr.show_text (song.title);
                y += extents.height + 5;

                // Subtitle
                if (song.subtitle != "") {
                    cr.select_font_face ("Sans", FontSlant.NORMAL, FontWeight.NORMAL);
                    cr.set_font_size (16);
                    cr.text_extents (song.subtitle, out extents);
                    cr.move_to ((width - extents.width) / 2, y);
                    cr.show_text (song.subtitle);
                    y += extents.height + 10;
                }

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

            double line_height = 20;
            
            foreach (var item in song.items) {
                // Calculate item height
                double item_height = 0;
                if (item is LyricLine) {
                    item_height = line_height + 20;
                    // Add extra spacing after chorus if next item is not chorus
                    if (((LyricLine)item).is_chorus) {
                        int index = song.items.index_of(item);
                        if (index + 1 < song.items.size) {
                            var next_item = song.items[index + 1];
                            if (next_item is LyricLine && !((LyricLine)next_item).is_chorus) {
                                item_height += 10;
                            }
                        }
                    }
                } else if (item is TabBlock) {
                    item_height = ((TabBlock)item).lines.size * 15 + 10;
                } else if (item is Comment) {
                    item_height = 25;
                }

                // Check pagination
                if (page_height > 0 && y + item_height > page_height - margin_bottom) {
                    cr.show_page ();
                    y = margin_top;
                }

                if (item is LyricLine) {
                    var line = (LyricLine) item;
                    double x = 10;
                    
                    // Chorus indentation and bar
                    if (line.is_chorus) {
                        x += 20;
                        cr.save ();
                        cr.set_line_width (2);
                        cr.set_source_rgb (0, 0, 0); // Ensure black for line
                        cr.move_to (15, y - 25);
                        cr.line_to (15, y + 15);
                        cr.stroke ();
                        cr.restore ();
                    }

                    cr.select_font_face ("Monospace", FontSlant.NORMAL, FontWeight.NORMAL);
                    double next_min_x = 0;
                    
                    for (int i = 0; i < line.tokens.size; i++) {
                        var token = line.tokens[i];
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

                            // If next token is also a chord, advance x
                            if (i + 1 < line.tokens.size && line.tokens[i+1].is_chord) {
                                x += extents.width + 10;
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
                    
                    // Add extra spacing after chorus if next item is not chorus
                    if (line.is_chorus) {
                        int index = song.items.index_of(item);
                        if (index + 1 < song.items.size) {
                            var next_item = song.items[index + 1];
                            if (next_item is LyricLine && !((LyricLine)next_item).is_chorus) {
                                y += 10;
                            }
                        }
                    }
                } else if (item is TabBlock) {
                    var tab = (TabBlock) item;
                    cr.select_font_face ("Monospace", FontSlant.NORMAL, FontWeight.NORMAL);
                    cr.set_font_size (12);
                    cr.set_source_rgb (0, 0, 0);
                    
                    foreach (var tab_line in tab.lines) {
                        cr.move_to (10, y);
                        cr.show_text (tab_line);
                        y += 15;
                    }
                    y += 10;
                } else if (item is Comment) {
                    var comment = (Comment) item;
                    cr.set_font_size (14);
                    cr.set_source_rgb (0.3, 0.3, 0.3); // Grey
                    
                    var slant = (comment.comment_type == CommentType.ITALIC) ? FontSlant.ITALIC : FontSlant.NORMAL;
                    var weight = (comment.comment_type == CommentType.BOX) ? FontWeight.BOLD : FontWeight.NORMAL;
                    cr.select_font_face ("Sans", slant, weight);
                    
                    TextExtents extents;
                    cr.text_extents (comment.text, out extents);
                    
                    if (comment.comment_type == CommentType.BOX) {
                        cr.rectangle (8, y - extents.height - 6, extents.width + 10, extents.height + 12);
                        cr.stroke ();
                    }
                    
                    cr.move_to (13, y);
                    cr.show_text (comment.text);
                    y += 40;
                }
            }
            
            // Copyright footer
            if (song.copyright != "") {
                // Check if footer fits
                if (page_height > 0 && y + 20 > page_height - margin_bottom) {
                    cr.show_page();
                    y = margin_top;
                }
                y += 20;
                cr.select_font_face ("Sans", FontSlant.NORMAL, FontWeight.NORMAL);
                cr.set_font_size (10);
                cr.set_source_rgb (0.5, 0.5, 0.5);
                cr.move_to (10, y);
                cr.show_text ("© " + song.copyright);
            }
        }
    }
}
