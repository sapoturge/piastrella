class TileView : Gtk.DrawingArea, Gtk.Scrollable {
    private int[,] tiles;

    private int zoom;
    private int width;
    private int height;

    public Png image { get; set; }

    private Gtk.Adjustment _hadjustment;
    private Gtk.Adjustment _vadjustment;

    public Gtk.Adjustment hadjustment {
        get {
            return _hadjustment;
        }
        set {
            _hadjustment = value;

            if (_hadjustment == null) {
                _hadjustment = new Gtk.Adjustment (0, 0, 0, 0, 0, 0);
            }

            if (image != null) {
                _hadjustment.lower = -width/ 2;
                _hadjustment.upper = image.width * zoom - 3 * width / 2;
                _hadjustment.page_size = width;
                _hadjustment.page_increment = 1;
                _hadjustment.step_increment = 1;
            }

            _hadjustment.value_changed.connect (() => { update (); });
        }
    }

    public Gtk.Adjustment vadjustment {
        get {
            return _vadjustment;
        }
        set {
            _vadjustment = value;

            if (_vadjustment == null) {
                _vadjustment = new Gtk.Adjustment (0, 0, 0, 0, 0, 0);
            }

            if (image != null) {
                _vadjustment.lower = -height / 2;
                _vadjustment.upper = image.height * zoom - 3 * height / 2;
                _vadjustment.page_size = height;
                _vadjustment.page_increment = 1;
                _vadjustment.step_increment = 1;
            }

            _vadjustment.value_changed.connect (() => { update (); });
        }
    }

    public Gtk.ScrollablePolicy hscroll_policy { get; set; default = NATURAL; }

    public Gtk.ScrollablePolicy vscroll_policy { get; set; default = NATURAL; }

    public signal void update ();

    public TileView () {
    }

    public bool get_border (out Gtk.Border border) {
        border = {0, 0, 0, 0};
        return true;
    }

    construct {
        add_events (Gdk.EventMask.BUTTON_PRESS_MASK |
                    Gdk.EventMask.BUTTON_RELEASE_MASK);
        draw.connect ((cr) => {
            cr.save ();
            cr.translate ((int) (-hadjustment.value), (int) (-vadjustment.value));
            cr.scale (zoom, zoom);

            var surface = image.get_surface ();

            for (int i = 0; i < 16; i++) {
                for (int j = 0; j < 16; j++) {
                    var tile = tiles[i,j];
                    var tile_x = tile % 16;
                    var tile_y = tile / 16;
                    cr.set_source_surface (surface, (i - tile_x) * 16, (j - tile_y) * 16);
                    var pattern = cr.get_source ();
                    pattern.set_filter (Cairo.Filter.NEAREST);
                    cr.rectangle (i*16, j*16, 16, 16);
                    cr.fill ();
                }
            }
            
            cr.restore ();
        });

        zoom = 4;

        tiles = new int[16,16];
        for (int i = 0; i < 256; i++) {
            tiles[i % 16, i / 16] = i;
        }

        update.connect (() => {
            queue_draw ();
        });

        size_allocate.connect ((alloc) => {
            width = alloc.width;
            height = alloc.height;

            hadjustment.page_size = width;
            vadjustment.page_size = height;

            hadjustment.lower = -width / 2;
            hadjustment.upper = image.width * zoom + width / 2;

            vadjustment.lower = -height / 2;
            vadjustment.upper = image.height * zoom + height / 2;
        });

        button_press_event.connect ((event) => {
            double x = (event.x - hadjustment.value) / zoom;
            double y = (event.y - vadjustment.value) / zoom;
            image.start_editing ();
            
            image.set_pixel ((int)x, (int)y, 0);
            update ();
        });

        button_release_event.connect ((event) => {
            if (image.editing) {
                image.finish_editing ();
            }
        });
    }
}
