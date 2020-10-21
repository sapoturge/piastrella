class MainWindow : Gtk.ApplicationWindow {
    public MainWindow (Gtk.Application app) {
        Object (application: app, title: "Piastrella");
    }

    construct {
    }

    public void open (Png image) {
        var tileset = new TileSetView (image);
        tileset.set_size_request(256, 256);
        tileset.halign = CENTER;
        tileset.valign = CENTER;

        var tiles = new TileView ();
        
        var palette = new Gtk.FlowBox ();

        var toolbox = new Gtk.FlowBox ();

        var sidebar = new Gtk.Box(Gtk.Orientation.VERTICAL, 6);
        sidebar.pack_start (toolbox, true);
        sidebar.pack_start (palette, true);
        sidebar.pack_start (tileset, false);
        sidebar.hexpand = false;

        var layout = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        layout.pack_start (sidebar, false);
        layout.pack_start (tiles, true, true);
        layout.expand = true;

        add(layout);
    }
}
