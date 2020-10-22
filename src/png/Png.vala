public class Png : Object {
    private Chunk[] chunks;
    private Header header;
    private Palette palette;
    private ImageData data;

    private uchar[] pixel_data;
    private Cairo.Surface surface;

    public int width {
        get {
            return header.width;
        }
        set {
            header.width = value;
        }
    }

    public int height {
        get {
            return header.height;
        }
        set {
            header.height = value;
        }
    }

    public Png () {
        header = new Header ();
        palette = new Palette ();
        data = new ImageData ();
        chunks = {header, palette, data, new End ()};
    }

    public ListModel get_palette () {
        return palette;
    }

    public Png.from_file (File file) {
        FileInputStream input = file.read ();

        var buffer = new uint8[8];
        size_t read = 0;

        input.read_all (buffer, out read);

        if (buffer[0] != 137 ||
            buffer[1] != 80 ||
            buffer[2] != 78 ||
            buffer[3] != 71 ||
            buffer[4] != 13 ||
            buffer[5] != 10 ||
            buffer[6] != 26 ||
            buffer[7] != 10) {
            print ("Error: Invalid file\n");
        }

        var length = 0;
        var chunk_type = "";
        uint8[] content;
        var crc = 0;

        buffer = new uint8[4];

        input.read_all (buffer, out read);

        while (read == 4) {
            if (ByteOrder.HOST == ByteOrder.LITTLE_ENDIAN) {
                buffer = {buffer[3], buffer[2], buffer[1], buffer[0]};
            }
            length = *(int*)(buffer);

            input.read_all (buffer, out read);
            chunk_type = (string) buffer;

            buffer = new uint8[length];
            input.read_all (buffer, out read);
            content = buffer;

            buffer = new uint8[4];
            input.read_all (buffer, out read);
            if (ByteOrder.HOST == ByteOrder.LITTLE_ENDIAN) {
                buffer = {buffer[3], buffer[2], buffer[1], buffer[0]};
            }
            crc = *(int*)(buffer);

            switch (chunk_type) {
                case "IHDR":
                    header = new Header.from_data (content, crc);
                    chunks += header;
                    break;
                case "IEND":
                    chunks += new End.from_data (content, crc);
                    break;
                case "PLTE":
                    palette = new Palette.from_data (content, crc);
                    chunks += palette;
                    break;
                case "IDAT":
                    data = new ImageData.from_data (header, content, crc);
                    chunks += data;
                    break;
                default:
                    chunks += new UnknownChunk.from_data (chunk_type, content, crc);
                    break;
            }

            buffer = new uint8[4];
            input.read_all (buffer, out read);
        }

        pixel_data = new uchar[header.width * header.height * 4];

        refresh_pixels ();

        surface = new Cairo.ImageSurface.for_data (pixel_data, Cairo.Format.ARGB32, header.width, header.height, header.width * 4);
    }

    public Gdk.RGBA get_color (int x, int y) {
        int index = data.pixels [y, x];
        return ((PaletteEntry) palette.get_item (index)).color;
    }

    public void set_pixels (uint8[,] pixels) {
        data.pixels = pixels;
        refresh_pixels ();
    }

    public Cairo.Surface get_surface () {
        return surface;
    }

    private void refresh_pixels () {
        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                var color = get_color (x, y);
                pixel_data [(y * width + x) * 4 + 0] = (uchar) (color.blue * 255);
                pixel_data [(y * width + x) * 4 + 1] = (uchar) (color.green * 255);
                pixel_data [(y * width + x) * 4 + 2] = (uchar) (color.red * 255);
                pixel_data [(y * width + x) * 4 + 3] = (uchar) (color.alpha * 255);
            }
        }
    }
}
