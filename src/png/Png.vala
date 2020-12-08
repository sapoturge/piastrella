public class Png : Object {
    private Chunk[] chunks;
    private Header header;
    private Palette palette;
    private ImageData data;

    private UndoStack stack;
    private uint8[,] last_pixels;

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

    private uint8 _color;
    public Gdk.RGBA color {
        get {
            return ((PaletteEntry) palette.get_item (_color)).color;
        }
        set {
            for (_color = 0; _color < 256; _color++) {
                if (((PaletteEntry) palette.get_item (_color)).color == value) {
                    break;
                }
            }
        }
    }
            

    public signal void update ();

    public bool editing { get; private set; default=false; }
    private bool changed { get; private set; default=false; }

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

        refresh_pixels (0, width, 0, height);

        surface = new Cairo.ImageSurface.for_data (pixel_data, Cairo.Format.ARGB32, header.width, header.height, header.width * 4);

        stack = new UndoStack ();
    }

    public bool save (OutputStream stream) {
        try {
            size_t written = 0;
            stream.write_all ({137, 80, 78, 71, 13, 10, 26, 10}, out written);

            foreach (Chunk chunk in chunks) {
                chunk.write_out (stream);
            }
            return true;
        } catch (IOError err) {
            print ("Error saving file: %s\n", err.message);
            return false;
        }
    }

    public Gdk.RGBA get_pixel_color (int x, int y) {
        int index = data.pixels [y, x];
        return ((PaletteEntry) palette.get_item (index)).color;
    }

    public void start_editing() {
        last_pixels = data.pixels;
        editing = true;
    }

    public void set_pixel(int x, int y) {
        if (!editing) {
            start_editing ();
        }
        changed = true;
        data.pixels[y, x] = _color;
        refresh_pixels (x, x+1, y, y+1);
        update ();
    }

    public void finish_editing() {
        editing = false;
        if (changed) {
            changed = false;
            stack.add_command(new EditingCommand(this, last_pixels, data.pixels));
        }
    }
        
    public void set_pixels (uint8[,] pixels) {
        data.pixels = pixels;
        refresh_pixels (0, width, 0, height);
        update ();
    }

    public Cairo.Surface get_surface () {
        return surface;
    }

    private void refresh_pixels (int start_x, int end_x, int start_y, int end_y) {
        for (int y = start_y; y < end_y; y++) {
            for (int x = start_x; x < end_x; x++) {
                var color = get_pixel_color (x, y);
                pixel_data [(y * width + x) * 4 + 0] = (uchar) (color.blue * 255);
                pixel_data [(y * width + x) * 4 + 1] = (uchar) (color.green * 255);
                pixel_data [(y * width + x) * 4 + 2] = (uchar) (color.red * 255);
                pixel_data [(y * width + x) * 4 + 3] = (uchar) (color.alpha * 255);
            }
        }
    }
}
