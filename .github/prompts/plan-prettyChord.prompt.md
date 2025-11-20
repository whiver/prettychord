## Plan: Build Vala GTK ChordPro App

We will build a GTK4 application in Vala using the Meson build system. The app will feature a split-pane interface: a text editor on the left and a live graphical preview on the right. We will implement a custom ChordPro parser and use Cairo for rendering, which allows sharing the same drawing code for both the screen preview and PDF export.

### Steps
1.  **Initialize Project**: Set up the standard GNOME directory structure (`src/`, `data/`) and `meson.build` configuration for Vala and GTK4.
2.  **Create Data Model & Parser**: Implement a `ChordParser` class in `src/ChordParser.vala` to parse text into a structured `Song` object.
3.  **Implement Renderer**: Create a `ChordRenderer` class in `src/ChordRenderer.vala` that draws a `Song` object onto any `Cairo.Context`.
4.  **Build User Interface**: Create the main window with a `Gtk.Paned` containing a `Gtk.TextView` (editor) and a custom `Gtk.DrawingArea` (preview).
5.  **Connect & Export**: Wire the editor's `changed` signal to update the preview, and add a "Export PDF" header bar button.

### Further Considerations
1.  **Pagination**: For the first version, should the preview simulate A4 pages or just be one continuous scrolling sheet?
2.  **Fonts**: We will start with a default monospaced font for chords to ensure alignment, but can add font selection later.
