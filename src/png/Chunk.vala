public class Chunk : Object {
    private static uint32[] crc_table;
    public string chunk_type { get; private set; }
    public bool ancillary { get; private set; }
    public bool private { get; private set; }
    public bool safe_to_copy { get; private set; }
    public int length { get; private set; }

    public Chunk (string type, int length) {
        this.chunk_type = type;
        this.ancillary = (type[0] & 0x20) == 0x20;
        this.private = (type[1] & 0x20) == 0x20;
        this.safe_to_copy = (type[3] & 0x20) == 0x20;
        this.length = length;
    }

    public void write_out (FileOutputStream output) {
        uint8[] buffer = (uint8[])(&_length);
        size_t written;
        output.write_all (buffer, out written);
        output.write_all (chunk_type.data, out written);
        uint8[] data = get_data ();
        output.write_all (data, out written);
        uint32 crc = calculate_crc (data);
        buffer = (uint8[])(&crc);
        output.write_all (buffer, out written);
    }

    public virtual uint8[] get_data () {
        return {};
    }

    static construct {
        crc_table = new uint32[256];
        for (int n = 0; n < 256; n++) {
            uint32 c = n;
            for (int k = 0; k < 8; k++) {
                if ((c & 1) == 1) {
                    c = (uint32) 0xedb88320 ^ (c >> 1);
                } else {
                    c = c >> 1;
                }
            }
            crc_table[n] = c;
        }
    }

    private uint32 calculate_crc (uint8[] data) {
        uint32 crc = (uint32) 0xffffffff;
        for (int i = 0; i < 4; i++) {
            crc = crc_table[(crc ^ chunk_type[i]) & 0xff] ^ (crc >> 8);
        }
        for (int i = 0; i < data.length; i++) {
            crc = crc_table[(crc ^ data[i]) & 0xff] ^ (crc >> 8);
        }
        return crc ^ 0xffffffff;
    }
}
