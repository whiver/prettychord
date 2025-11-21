using Gtk;
using GtkSource;

namespace PrettyChord {
    public class Window : ApplicationWindow {
        private View text_view;
        private DrawingArea drawing_area;
        private ChordParser parser;
        private ChordRenderer renderer;
        private Song current_song;
        private string? current_filename = null;

        public Window (Application app) {
            Object (application: app);
            title = _("PrettyChord");
            default_width = 800;
            default_height = 600;

            parser = new ChordParser ();
            renderer = new ChordRenderer ();
            current_song = new Song ();

            // Header Bar
            var header = new HeaderBar ();
            this.set_titlebar (header);

            var open_btn = new Button.from_icon_name ("document-open-symbolic");
            open_btn.tooltip_text = _("Open");
            open_btn.clicked.connect (on_open_clicked);
            header.pack_start (open_btn);

            var save_btn = new Button.from_icon_name ("document-save-symbolic");
            save_btn.tooltip_text = _("Save");
            save_btn.clicked.connect (on_save_clicked);
            header.pack_start (save_btn);

            // Menu
            var action_save_as = new SimpleAction ("save-as", null);
            action_save_as.activate.connect (() => { on_save_as_clicked (); });
            this.add_action (action_save_as);

            var menu = new GLib.Menu ();
            menu.append (_("Save As"), "win.save-as");

            var menu_btn = new MenuButton ();
            menu_btn.icon_name = "open-menu-symbolic";
            menu_btn.menu_model = menu;
            menu_btn.tooltip_text = _("Menu");
            header.pack_end (menu_btn);

            var export_btn = new Button.from_icon_name ("document-send-symbolic");
            export_btn.tooltip_text = _("Export PDF");
            export_btn.clicked.connect (on_export_clicked);
            header.pack_end (export_btn);

            var paned = new Paned (Orientation.HORIZONTAL);
            paned.position = 400;
            
            // Editor
            text_view = new View ();
            text_view.wrap_mode = WrapMode.WORD;
            text_view.show_line_numbers = true;
            text_view.monospace = true;
            
            setup_syntax_highlighting ();
            
            text_view.buffer.changed.connect (on_text_changed);
            
            var scroll1 = new ScrolledWindow ();
            scroll1.child = text_view;
            paned.start_child = scroll1;

            // Preview
            drawing_area = new DrawingArea ();
            drawing_area.set_draw_func (draw_preview);
            
            var scroll2 = new ScrolledWindow ();
            scroll2.child = drawing_area;
            paned.end_child = scroll2;

            this.child = paned;
            
            // Initial parse
            on_text_changed ();
        }

        private void on_open_clicked () {
            var file_dialog = new FileChooserNative (_("Open File"), this, FileChooserAction.OPEN, _("Open"), _("Cancel"));
            var filter = new FileFilter ();
            filter.add_pattern ("*.cho");
            filter.add_pattern ("*.crd");
            filter.add_pattern ("*.pro");
            filter.add_pattern ("*.chordpro");
            filter.add_pattern ("*.txt");
            filter.set_filter_name (_("ChordPro Files"));
            file_dialog.add_filter (filter);
            
            file_dialog.response.connect ((response) => {
                if (response == ResponseType.ACCEPT) {
                    var file = file_dialog.get_file ();
                    load_file (file);
                }
                file_dialog.destroy ();
            });
            file_dialog.show ();
        }

        private void load_file (GLib.File file) {
            try {
                uint8[] contents;
                string etag;
                file.load_contents (null, out contents, out etag);
                text_view.buffer.text = (string) contents;
                current_filename = file.get_path ();
                update_title ();
            } catch (Error e) {
                warning ("Error loading file: %s", e.message);
            }
        }

        private void on_save_clicked () {
            if (current_filename != null) {
                save_to_file (GLib.File.new_for_path (current_filename));
            } else {
                on_save_as_clicked ();
            }
        }

        private void on_save_as_clicked () {
            var file_dialog = new FileChooserNative (_("Save File"), this, FileChooserAction.SAVE, _("Save"), _("Cancel"));
            var filter = new FileFilter ();
            filter.add_pattern ("*.cho");
            filter.set_filter_name (_("ChordPro Files"));
            file_dialog.add_filter (filter);
            
            file_dialog.response.connect ((response) => {
                if (response == ResponseType.ACCEPT) {
                    var file = file_dialog.get_file ();
                    save_to_file (file);
                }
                file_dialog.destroy ();
            });
            file_dialog.show ();
        }

        private void save_to_file (GLib.File file) {
            try {
                file.replace_contents (text_view.buffer.text.data, null, false, FileCreateFlags.NONE, null);
                current_filename = file.get_path ();
                update_title ();
            } catch (Error e) {
                warning ("Error saving file: %s", e.message);
            }
        }

        private void update_title () {
            if (current_filename != null) {
                title = "%s - %s".printf (Path.get_basename (current_filename), _("PrettyChord"));
            } else {
                title = _("PrettyChord");
            }
        }

        private void setup_syntax_highlighting () {
            var lm = LanguageManager.get_default ();
            
            // Add current directory/data to search path for development
            string[] search_path = lm.get_search_path ();
            search_path += Path.build_filename (Environment.get_current_dir (), "data");
            lm.set_search_path (search_path);

            var lang = lm.get_language ("chordpro");
            if (lang != null) {
                var buffer = text_view.buffer as Buffer;
                if (buffer != null) {
                    buffer.set_language (lang);
                }
            }
        }

        private void on_text_changed () {
            string text = text_view.buffer.text;
            current_song = parser.parse (text);
            drawing_area.queue_draw ();
        }

        private void draw_preview (DrawingArea area, Cairo.Context cr, int width, int height) {
            // Fill background
            cr.set_source_rgb (1, 1, 1);
            cr.paint ();
            
            renderer.draw_song (cr, current_song, width);
        }

        private void on_export_clicked () {
            var file_dialog = new FileChooserNative (_("Export PDF"), this, FileChooserAction.SAVE, _("Save"), _("Cancel"));
            var filter = new FileFilter ();
            filter.add_pattern ("*.pdf");
            filter.set_filter_name (_("PDF Files"));
            file_dialog.add_filter (filter);
            
            file_dialog.response.connect ((response) => {
                if (response == ResponseType.ACCEPT) {
                    var file = file_dialog.get_file ();
                    if (file != null) {
                        export_to_pdf (file.get_path ());
                    }
                }
                file_dialog.destroy ();
            });
            file_dialog.show ();
        }

        private void export_to_pdf (string filename) {
            var surface = new Cairo.PdfSurface (filename, 595, 842); // A4
            var cr = new Cairo.Context (surface);
            
            // White background for PDF
            cr.set_source_rgb (1, 1, 1);
            cr.paint ();
            
            renderer.draw_song (cr, current_song, 595);
            surface.finish ();
        }
    }
}
