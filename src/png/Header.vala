internal class Header : Chunk {
    public int width { get; set; }
    public int height { get; set; }
    public int bit_depth { get; set; }
    public int color_type { get; set; }
    public int compression { get; set; }
    public int filter { get; set; }
    public int interlace { get; set; }

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
        uint8[] size_data = data[0:4];
        if (ByteOrder.HOST == ByteOrder.LITTLE_ENDIAN) {
            size_data = {size_data[3], size_data[2], size_data[1], size_data[0]};
        }
        width = *(int*) size_data;
        size_data = data[4:8];
        if (ByteOrder.HOST == ByteOrder.LITTLE_ENDIAN) {
            size_data = {size_data[3], size_data[2], size_data[1], size_data[0]};
        }
        height = *(int*) size_data;
        bit_depth = data[8];
        color_type = data[9];
        compression = data[10];
        filter = data[11];
        interlace = data[12];
    }

    public override uint8[] get_content () {
        var data = new uint8[] {};
        var size = width;
        var size_data = (uint8[]) (&size);

        if (ByteOrder.HOST == ByteOrder.LITTLE_ENDIAN) {
            data += size_data[3];
            data += size_data[2];
            data += size_data[1];
            data += size_data[0];
        } else {
            data += size_data[0];
            data += size_data[1];
            data += size_data[2];
            data += size_data[3];
        }

        size = height;
        size_data = (uint8[]) (&size);

        if (ByteOrder.HOST == ByteOrder.LITTLE_ENDIAN) {
            data += size_data[3];
            data += size_data[2];
            data += size_data[1];
            data += size_data[0];
        } else {
            data += size_data[0];
            data += size_data[1];
            data += size_data[2];
            data += size_data[3];
        }

        data += (uint8) bit_depth;
        data += (uint8) color_type;
        data += (uint8) compression;
        data += (uint8) filter;
        data += (uint8) interlace;
        return data;
    }
}
