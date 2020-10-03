public class Piastrella : Gtk.Application {
    public Piastrella () {
        Object (
            application_id: "com.github.sapoturge.piastrella",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    protected override void activate () {
        var main_window = new Gtk.ApplicationWindow (this);
        main_window.title = _("Piastrella");
        main_window.show_all ();
    }

    public static int main (string[] args) {
        var app = new Piastrella ();
        return app.run (args);
    }
}
