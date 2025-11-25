[![prettychord](https://snapcraft.io/prettychord/badge.svg)](https://snapcraft.io/prettychord)

# PrettyChord

A modern, native GTK4 application for writing, viewing, and exporting chord sheets using the [ChordPro](https://www.chordpro.org/) format.

![PrettyChord Screenshot](https://github.com/user-attachments/assets/27b3e3b1-c569-4ac6-9180-94e06622a100)

## Features

*   **Real-time Preview**: See your chord sheet rendered instantly as you type.
*   **Syntax Highlighting**: Built-in editor with syntax highlighting for ChordPro directives and chords.
*   **PDF Export**: Generate beautiful, paginated PDF files for printing or sharing.
*   **Native Experience**: Built with Vala and GTK4 for a fast, native Linux experience.
*   **ChordPro Support**: Supports common directives like `{title}`, `{artist}`, `{start_of_chorus}`, `{start_of_tab}`, and more.

## Installation

### Snap Store

[![Get it from the Snap Store](https://snapcraft.io/en/light/install.svg)](https://snapcraft.io/prettychord)

PrettyChord is available on the Snap Store:

```bash
sudo snap install prettychord
```

### Building from Source

To build PrettyChord from source, you'll need the following dependencies:

*   meson
*   ninja-build
*   valac
*   libgtk-4-dev
*   libgee-0.8-dev
*   libcairo2-dev
*   libgtksourceview-5-dev

**Build steps:**

1.  Clone the repository:
    ```bash
    git clone https://github.com/whiver/prettychord.git
    cd prettychord
    ```

2.  Setup the build directory:
    ```bash
    meson setup build
    ```

3.  Compile:
    ```bash
    meson compile -C build
    ```

4.  Run:
    ```bash
    ./build/src/prettychord
    ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
