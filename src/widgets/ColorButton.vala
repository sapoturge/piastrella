public class ColorButton : Gtk.DrawingArea {
    public Gdk.RGBA rgba { get; set; }

    public ColorButton () {
        rgba = {0, 0, 0, 1};
    }

    public ColorButton.with_rgba (Gdk.RGBA rgba) {
        this.rgba = rgba;
    }

    construct {
        draw.connect ((cr) => {
            cr.set_source_rgba (rgba.red, rgba.green, rgba.blue, rgba.alpha);
            cr.paint ();
        });

        set_size_request (16, 16);
        expand = false;
    }
}
