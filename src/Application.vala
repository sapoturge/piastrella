public class Piastrella : Gtk.Application {
    private uint configure_id;

    public static Settings settings;

    public Piastrella () {
        Object (
            application_id: "com.github.sapoturge.piastrella",
            flags: ApplicationFlags.FLAGS_NONE
        );
    }

    public SimpleActionGroup actions { get; construct; }

    public const string ACTION_UNDO = "action_undo";
    public const string ACTION_REDO = "action_redo";

    static construct {
        settings = new Settings ("com.github.sapoturge.piastrella");
    }

    construct {
        var undo_action = new SimpleAction (ACTION_UNDO, null);
        var redo_action = new SimpleAction (ACTION_REDO, null);
        actions = new SimpleActionGroup ();
        actions.add_action (undo_action);
        actions.add_action (redo_action);

        set_accels_for_action ("piastrella.action_undo", {"<Control>Z", null});
        set_accels_for_action ("piastrella.action_redo", {"<Control>Y", null});
    }

    protected override void activate () {
        var main_window = new MainWindow (this);
        main_window.insert_action_group ("piastrella", actions);
        main_window.title = _("Piastrella");

        int window_x, window_y;
        var rect = Gtk.Allocation ();

        settings.get ("window-position", "(ii)", out window_x, out window_y);
        settings.get ("window-size", "(ii)", out rect.width, out rect.height);

        if (window_x != -1 || window_y != -1) {
            main_window.move (window_x, window_y);
        }
        main_window.set_allocation (rect);

        if (settings.get_boolean ("window-maximized")) {
            main_window.maximize ();
        }

        main_window.configure_event.connect (() => {
            if (configure_id != 0) {
                Source.remove (configure_id);
            }

            configure_id = Timeout.add (100, () => {
               configure_id = 0;
               if (main_window.is_maximized) {
                   settings.set_boolean ("window-maximized", true);
               } else {
                   settings.set_boolean ("window-maximized", false);

                   Gdk.Rectangle new_rect;
                   main_window.get_allocation (out new_rect);
                   settings.set ("window-size", "(ii)", new_rect.width, new_rect.height);

                   int root_x, root_y;
                   main_window.get_position (out root_x, out root_y);
                   settings.set ("window-position", "(ii)", root_x, root_y);
               }
               return false;
           });
           return false;
        });

        var file = File.new_for_commandline_arg ("test.png");

        Png image;

        if (file.query_exists ()) {
            image = new Png.from_file (file);
            var save_file = File.new_for_commandline_arg ("test2.png");
            var output = save_file.replace (null, false, FileCreateFlags.REPLACE_DESTINATION);
            image.save (output);
        } else {
            image = new Png ();
        }

        main_window.open (image);

        main_window.show_all ();
    }

    public static int main (string[] args) {
        var app = new Piastrella ();
        return app.run (args);
    }
}
