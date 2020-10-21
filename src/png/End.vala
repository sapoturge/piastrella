public class End : Chunk {
    public End () {
        base ("IEND", 0);
    }

    public End.from_data (uint8[] data, int crc) {
        base ("IEND", 0);
    }
}
