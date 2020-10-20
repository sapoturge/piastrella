public class Png : Object {
    private Chunk[] chunks;
    private Header header;
    private Palette palette;
    private ImageData data;

    public Png () {
        header = new Header ();
        palette = new Palette ();
        data = new ImageData ();
        chunks = {header, palette, data, new End ()};
    }

    public Png.from_file (File file) {
        FileInputStream input = file.open_readwrite () as FileInputStream;

        var buffer = new uint8[8];
        size_t read = 0;

        input.read_all (buffer, out read);

        if (buffer != new uint8[]{137, 80, 78, 71, 13, 10, 26, 10}) {
            return;
        }

        var length = 0;
        var chunk_type = "";
        uint8[] content;
        var crc = 0;

        buffer = new uint8[4];

        input.read_all (buffer, out read);

        while (read == 4) {
            length = *(int*)(buffer);

            input.read_all (buffer, out read);
            chunk_type = (string) buffer;

            buffer = new uint8[length];
            input.read_all (buffer, out read);
            content = buffer;

            buffer = new uint8[4];
            input.read_all (buffer, out read);
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
                    data = new ImageData.from_data (content, crc);
                    chunks += data;
                    break;
                default:
                    chunks += new UnknownChunk.from_data (chunk_type, content, crc);
                    break;
            }
            
            buffer = new uint8[4];
            input.read_all (buffer, out read);
        }
    }
}
