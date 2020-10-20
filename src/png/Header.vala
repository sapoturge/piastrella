public class Header : Chunk {
    private int width;
    private int height;
    private int bit_depth;
    private int color_type;
    private int compression;
    private int filter;
    private int interlace;

    public Header () {
        base ("IHDR", 13);

        width = 256;
        height = 256;
        bit_depth = 8;
        color_type = 3;
        compression = 0;
        filter = 0;
        interlace = 0;
    }

    public Header.from_data (uint8[] data, uint32 crc) {
        this ();
        width = *(int*) data;
        height = *(int*) data[4:8];
        bit_depth = data[8];
        color_type = data[9];
        compression = data[10];
        filter = data[11];
        interlace = data[12];
    }
}
