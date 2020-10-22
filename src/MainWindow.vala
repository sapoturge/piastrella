class MainWindow : Gtk.ApplicationWindow {
    public MainWindow (Gtk.Application app) {
        Object (application: app, title: "Piastrella");
    }

    construct {
    }

    public void open (Png image) {
        var tileset = new TileSetView (image);
        tileset.valign = CENTER;

        var tiles = new TileView ();
        tiles.image = image;

        var tile_window = new Gtk.ScrolledWindow (null, null);
        tile_window.add (tiles);
        
        var palette = new Gtk.FlowBox ();
        palette.bind_model (image.get_palette (), (obj) => {
            var entry = (PaletteEntry) obj;
            var chooser = new ColorButton.with_rgba (entry.color);
            chooser.bind_property ("rgba", entry, "color");
            chooser.margin = 0;
            return chooser;
        });
        palette.homogeneous = true;
        // palette.min_children_per_line = 8;
        palette.max_children_per_line = 8;
        palette.selection_mode = 0;
        palette.row_spacing = 0;
        palette.column_spacing = 0;

        var toolbox = new Gtk.FlowBox ();

        var palette_window = new Gtk.ScrolledWindow (null, null);
        palette_window.add (palette);

        var sidebar = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
        sidebar.pack_start (toolbox, false);
        sidebar.pack_start (palette_window, true);
        sidebar.pack_start (tileset, false);
        sidebar.hexpand = false;

        var layout = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        layout.pack_start (sidebar, false);
        layout.pack_start (tile_window, true, true);
        layout.expand = true;

        add(layout);
    }
}
