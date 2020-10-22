public class DataCommand : Object, Command {
    private Object[] objects;
    private string[] properties;
    private Value[] old_values;
    private Value[] new_values;

    public DataCommand () {}

    public void add_command (Object object, string property, Value old_value, Value new_value) {
        objects += object;
        properties += property;
        old_values += old_value;
        new_values += new_value;
    }

    public void undo () {
        for (int i = objects.length - 1; i >= 0; i--) {
            objects [i].set_property (properties [i], old_values [i]);
        }
    }

    public void redo () {
        for (int i = 0; i < objects.length; i++) {
            objects [i].set_property (properties [i], new_values [i]);
        }
    }
}
