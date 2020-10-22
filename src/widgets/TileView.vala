class TileView : Gtk.DrawingArea, Gtk.Scrollable {
    private int[,] tiles;

    private int zoom;

    public Png image { get; set; }

    public Gtk.Adjustment hadjustment { get; set construct; }
    public Gtk.Adjustment vadjustment { get; set construct; }

    public TileView () {
    }

    public bool get_border (out Gtk.Border border) {
        border = {0, 0, 0, 0};
        return true;
    }

    construct {
        draw.connect ((cr) => {
            for (int i = 0; i < 16; i++) {
                for (int j = 0; j < 16; j++) {
                    var tile = tiles[i,j];
                    var tile_x = (tile % 16) * 16;
                    var tile_y = (tile / 16) * 16;
                    for (int x = 0; x < 16; x++) {
                        for (int y = 0; y < 16; y++) {
                            cr.rectangle (i * 16 + x, j * 16 + y, 1, 1);
                            var color = image.get_color (tile_x + x, tile_y + y);
                            cr.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                            cr.fill ();
                        }
                    }
                }
            }
        });

        tiles = new int[16,16];
        for (int i = 0; i < 256; i++) {
            tiles[i % 16, i / 16] = i;
        }
    }
}
