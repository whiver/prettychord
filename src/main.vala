int main (string[] args) {
    Intl.setlocale (LocaleCategory.ALL, "");
    Intl.bindtextdomain ("prettychord", "/usr/local/share/locale");
    Intl.bind_textdomain_codeset ("prettychord", "UTF-8");
    Intl.textdomain ("prettychord");

    var app = new PrettyChord.Application ();
    return app.run (args);
}
