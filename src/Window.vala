using Gtk;

namespace PrettyChord {
    public class Window : ApplicationWindow {
        private TextView text_view;
        private DrawingArea drawing_area;
        private ChordParser parser;
        private ChordRenderer renderer;
        private Song current_song;

        public Window (Application app) {
            Object (application: app);
            title = "PrettyChord";
            default_width = 800;
            default_height = 600;

            parser = new ChordParser ();
            renderer = new ChordRenderer ();
            current_song = new Song ();

            // Header Bar
            var header = new HeaderBar ();
            this.set_titlebar (header);

            var export_btn = new Button.with_label ("Export PDF");
            export_btn.clicked.connect (on_export_clicked);
            header.pack_end (export_btn);

            var paned = new Paned (Orientation.HORIZONTAL);
            paned.position = 400;
            
            // Editor
            text_view = new TextView ();
            text_view.wrap_mode = WrapMode.WORD;
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
            var file_dialog = new FileChooserNative ("Export PDF", this, FileChooserAction.SAVE, "Save", "Cancel");
            var filter = new FileFilter ();
            filter.add_pattern ("*.pdf");
            filter.set_filter_name ("PDF Files");
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
