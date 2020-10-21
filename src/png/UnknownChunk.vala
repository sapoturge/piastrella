public class UnknownChunk : Chunk {
    private uint8[] data;

    public UnknownChunk () {
        base ("unKN", 0);
        data = {};
    }

    public UnknownChunk.from_data (string type, uint8[] data, int crc) {
        base (type, data.length);
        this.data = data;
    }

    public override uint8[] get_data () {
        return data;
    }
}
