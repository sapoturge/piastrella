class TileSetView : Gtk.DrawingArea {
    private Png image;

    public TileSetView (Png image) {
        this.image = image;
        set_size_request (image.width, image.height);
    }

    construct {
        draw.connect ((cr) => {
            cr.set_source_surface (image.get_surface (), 0, 0);
            var source = cr.get_source ();
            source.set_filter (Cairo.Filter.NEAREST);
            cr.rectangle (0, 0, image.width, image.height);
            cr.fill ();
        });
    }
}
