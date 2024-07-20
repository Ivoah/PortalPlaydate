from PIL import Image
from dataclasses import dataclass
import re
import base64
import io
import argparse

@dataclass
class PlaydateFont:
    glyphs_image: Image
    glyph_width: int
    glyph_height: int
    glyph_map: list[(str, int)]
    tracking: int
    extra: dict[str, str]
    
    @classmethod
    def loadFromFile(cls, filename):
        map = []
        extra = {}
        with open(filename) as f:
            for line in f.readlines():
                if m := re.match(r'(.+?)\s*=\s*(.+)', line):
                    match m.groups():
                        case ('width', w):
                            width = int(w)
                        case ('height', h):
                            height = int(h)
                        case ('tracking', t):
                            tracking = int(t)
                        case ('datalen', _): pass
                        case ('data', d):
                            img = Image.open(io.BytesIO(base64.b64decode(d)))
                        case (k, v):
                            extra[k] = v
                elif m := re.match(r'(.|space)\s+(\d+)', line):
                    map.append((m.group(1), int(m.group(2))))
        
        return cls(img, width, height, map, tracking, extra)

    def writeToFile(self, filename):
        with open(filename, 'w') as f:
            for k, v in self.extra.items():
                f.write(f'{k}={v}\n')
            png = io.BytesIO()
            self.glyphs_image.save(png, 'png')
            data = base64.b64encode(png.getvalue())
            f.write(f'datalen={len(data)}\ndata={data.decode('ascii')}\n')
            f.write(f'width={self.glyph_width}\nheight={self.glyph_height}\n\n')
            f.write(f'tracking={self.tracking}\n\n')
            f.writelines([
                f'{char}\t{width}\n'
                for (char, width) in self.glyph_map
            ])
    
    def scaled(self, scale):
        return self.__class__(
            self.glyphs_image.resize((self.glyphs_image.width*scale, self.glyphs_image.height*scale), Image.Resampling.NEAREST),
            self.glyph_width*scale,
            self.glyph_height*scale,
            [(c, w*scale) for (c, w) in self.glyph_map],
            self.tracking*scale,
            self.extra
        )

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Scale playdate .fnt files')
    parser.add_argument('filename')
    parser.add_argument('-s', '--scale', action='append', type=int, default=[])
    
    args = parser.parse_args()

    font = PlaydateFont.loadFromFile(args.filename)
    filename = re.match(r'(.+)\.fnt', args.filename).group(1)

    for scale in args.scale:
        scaled = font.scaled(scale)
        scaled.writeToFile(f'{filename}-{scale}x.fnt')
