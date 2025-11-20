namespace PrettyChord {
    public class Application : Gtk.Application {
        public Application () {
            Object (
                application_id: "com.example.prettychord",
                flags: ApplicationFlags.FLAGS_NONE
            );
        }

        protected override void activate () {
            var win = this.active_window;
            if (win == null) {
                win = new PrettyChord.Window (this);
            }
            win.present ();
        }
    }
}
