class TileView : Gtk.DrawingArea {
    construct {
        draw.connect ((cr) => {
            cr.set_source_rgb (0, 1, 0);
            cr.paint ();
        });
    }
}