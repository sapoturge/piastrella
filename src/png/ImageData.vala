internal class ImageData : Chunk {
    private uint8[] data;
    public uint8[,] pixels { get; set; }

    public ImageData () {
        base ("IDAT", 0);
    }

    public ImageData.from_data (Header header, uint8[] data, int crc) {
        this ();

        var output = new MemoryOutputStream.resizable ();
        var converter = new ZlibDecompressor (ZlibCompressorFormat.ZLIB);
        var conv_stream = new ConverterOutputStream (output, converter);

        size_t written;
        try {
            conv_stream.write_all (data, out written);
        } catch (IOError ex) {
            print ("Writing error.\n");
            return;
        } 

        output.close ();

        this.data = output.steal_data ();
        this.data.length = (int) output.get_data_size ();

        pixels = new uint8[header.height, header.width];
        for (int y = 0; y < header.height; y++) {
            var filter = this.data [y * (header.width + 1)];
            for (int x = 0; x < header.width; x++) {
                switch (filter) {
                    case 0:
                        pixels[y,x] = this.data[y * (header.width + 1) + x + 1];
                        break;
                    default:
                        print ("I don't understand filter method %d\n", filter);
                        break;
                }
            }
        }
    }
}
