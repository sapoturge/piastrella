class UndoStack : Object {
    private Command[] commands;
    private int index;


    construct {
        commands = {};
        index = 0;
    }

    public UndoStack () {}

    public void add_command (Command command) {
        commands = commands[0:index];
        commands += command;
        index++;
    }

    public void undo () {
        if (index > 0) {
            index--;
            commands[index].undo ();
        }
    }

    public void redo () {
        if (index < commands.length) {
            commands[index].redo ();
            index++;
        }
    }
}
        
