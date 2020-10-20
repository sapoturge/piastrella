class MainWindow : Gtk.ApplicationWindow {
    public MainWindow (Gtk.Application app) {
        Object (application: app, title: "Piastrella");
    }

    construct {
        var tileset = new TileSetView ();
        tileset.expand = true;

        var tiles = new TileView ();
        tiles.expand = true;
        
        var palette = new Gtk.FlowBox ();
        palette.expand = true;

        var toolbox = new Gtk.FlowBox ();
        toolbox.expand = true;

        var sidebar = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
        sidebar.pack_start (toolbox);
        sidebar.pack_start (palette);

        var layout = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        layout.pack_start (sidebar);
        layout.pack_start (tileset);
        layout.pack_start (tiles);
        layout.expand = true;

        add(layout);
    }
}