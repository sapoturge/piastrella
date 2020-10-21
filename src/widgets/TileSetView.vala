class TileSetView : Gtk.DrawingArea {
    private Png image;

    public TileSetView (Png image) {
        this.image = image;
    }

    construct {
        draw.connect ((cr) => {
            for (int x = 0; x < image.width; x++) {
                for (int y = 0; y < image.height; y++) {
                    cr.rectangle (x, y, 1, 1);
                    var color = image.get_color (x, y);
                    cr.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                    cr.fill ();
                }
            }
        });
    }
}
