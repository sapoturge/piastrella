class TileView : Gtk.DrawingArea, Gtk.Scrollable {
    private int[,] tiles;

    private int zoom;
    private int width;
    private int height;

    private Png _image;
    public Png image {
        get {
            return _image;
        }
        set {
            _image = value;
            _image.update.connect (() => {
                update ();
            });
        }
    }

    private Gtk.Adjustment _hadjustment;
    private Gtk.Adjustment _vadjustment;

    private int last_x;
    private int last_y;

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
                    Gdk.EventMask.BUTTON_MOTION_MASK |
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
            int x = (int) ((event.x - hadjustment.value) / zoom);
            int y = (int) ((event.y - vadjustment.value) / zoom);
            image.start_editing ();
            
            draw_pixel (x, y);

            update ();
            last_x = x;
            last_y = y;
        });

        motion_notify_event.connect ((event) => {
            int x = (int) ((event.x - hadjustment.value) / zoom);
            int y = (int) ((event.y - vadjustment.value) / zoom);
            
            draw_line(x, y);

            last_x = x;
            last_y = y;
        });

        button_release_event.connect ((event) => {
            if (image.editing) {
                image.finish_editing ();
            }
        });
    }

    private void draw_pixel (int x, int y) {
        int tile_x = x / 16;
        int inner_x = x % 16;
        int tile_y = y / 16;
        int inner_y = y % 16;
        int tile_index = tiles[tile_x, tile_y];
        image.set_pixel ((tile_index % 16) * 16 + inner_x, (tile_index / 16) * 16 + inner_y, 0);
    }

    private void draw_line (int x, int y) {
        if (x == last_x) {
            if (y < last_y) {
                for (int i = y; i <last_y; i++) {
                    draw_pixel (x, i);
                }
            } else {
                for (int i = last_y + 1; i <= y; i++) {
                    draw_pixel (x, i);
                }
            }
        } else if (y == last_y) {
            if (x < last_x) {
                for (int i = x; i < last_x; i++) {
                    draw_pixel (i, y);
                }
            } else {
                for (int i = last_x + 1; i <= x; i++) {
                    draw_pixel (i, y);
                }
            }
        } else {
            int x_diff = x - last_x;
            int y_diff = y - last_y;
            int start_x, start_y;
            int end_x, end_y;
            int e;
            if (x_diff.abs () > y_diff.abs ()) {
                if (x_diff > 0) {
                    start_x = last_x;
                    start_y = last_y;
                    end_x = x;
                    end_y = y;
                } else {
                    start_x = x;
                    start_y = y;
                    end_x = last_x;
                    end_y = last_y;
                    x_diff = -x_diff;
                    y_diff = -y_diff;
                }
                y = start_y;
                e = 0;
                print("X: %d -> %d, %d->%d\n", start_x, end_x, start_y, end_y);
                for (x = start_x; x <= end_x; x++) {
                    draw_pixel (x, y);
                    if (2*(e + y_diff.abs ()) < x_diff) {
                        e += y_diff.abs ();
                    } else {
                        if (y_diff > 0) {
                            y++;
                        } else {
                            y--;
                        }
                        e += y_diff.abs () - x_diff;
                    }
                }
            } else {
                if (y_diff > 0) {
                    start_x = last_x;
                    start_y = last_y;
                    end_x = x;
                    end_y = y;
                } else {
                    start_x = x;
                    start_y = y;
                    end_x = last_x;
                    end_y = last_y;
                    x_diff = -x_diff;
                    y_diff = -y_diff;
                }
                x = start_x;
                e = 0;
                print("Y: %d -> %d, %d->%d\n", start_x, end_x, start_y, end_y);
                for (y = start_y; y <= end_y; y++) {
                    draw_pixel (x, y);
                    if (2*(e + x_diff.abs ()) < y_diff) {
                        e += x_diff.abs ();
                    } else {
                        if (x_diff > 0) {
                            x++;
                        } else {
                            x--;
                        }
                        e += x_diff.abs () - y_diff;
                    }
                }
            }
        }
    }
}
