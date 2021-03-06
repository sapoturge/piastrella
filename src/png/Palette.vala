internal class Palette : Chunk, ListModel {
    private PaletteEntry[] colors;

    public Palette () {
        base ("PLTE", 0);
    }

    public Palette.from_data (uint8[] data, int crc) {
        base ("PLTE", data.length);
        for (int i = 0; i < data.length / 3; i++) {
            colors += new PaletteEntry ({data[i * 3] / 255.0, data[i * 3 + 1] / 255.0, data [i * 3 + 2] / 255.0, 1});
        }
    }

    public Object? get_item (uint position) {
        return colors [position];
    }

    public Type get_item_type () {
        return typeof (PaletteEntry);
    }

    public uint get_n_items () {
        return colors.length;
    }

    public override uint8[] get_content () {
        uint8[] data = {};
        foreach (PaletteEntry pe in colors) {
            data += (uint8) (pe.color.red * 255);
            data += (uint8) (pe.color.green * 255);
            data += (uint8) (pe.color.blue * 255);
        }
        
        return data;
    }
}

public class PaletteEntry : Object {
    public Gdk.RGBA color { get; set; }

    public PaletteEntry (Gdk.RGBA color) {
        this.color = color;
    }
}
