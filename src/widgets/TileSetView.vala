class TileSetView : Gtk.DrawingArea {
    construct {
        draw.connect ((cr) => {
            cr.set_source_rgb (1, 0, 0);
            cr.paint ();
        });
    }
}