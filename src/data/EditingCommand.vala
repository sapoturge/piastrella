public class EditingCommand : Object, Command {
    private uint8[,] old_pixels;
    private uint8[,] new_pixels;
    private Png image;

    public EditingCommand (Png image, uint8[,] old_pixels, uint8[,] new_pixels) {
        this.image = image;
        this.old_pixels = old_pixels;
        this.new_pixels = new_pixels;
    }

    public void undo () {
        image.set_pixels (old_pixels);
    }

    public void redo () {
        image.set_pixels (new_pixels);
    }
}
