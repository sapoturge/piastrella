public class ImageData : Chunk {
    private uint8[] data;

    public ImageData () {
        base ("IDAT", 0);
    }

    public ImageData.from_data (uint8[] data, int crc) {
        this ();
        this.data = data;
    }
}
