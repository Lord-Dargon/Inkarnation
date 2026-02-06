# save_circles_32x32_transparent.py
# Creates 3 PNGs (32x32) with a white filled circle and transparent background.

from PIL import Image, ImageDraw

SIZE = 32
RADII = [6, 10, 13]

def make_circle_image(radius: int) -> Image.Image:
    # RGBA: transparent background
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    cx, cy = SIZE // 2, SIZE // 2
    bbox = [
        cx - radius,
        cy - radius,
        cx + radius,
        cy + radius
    ]

    # White circle, fully opaque
    draw.ellipse(bbox, fill=(255, 255, 255, 255))
    return img

def main():
    for r in RADII:
        img = make_circle_image(r)
        out_path = f"circle_32x32_r{r}_transparent.png"
        img.save(out_path)
        print(f"Saved {out_path}")

if __name__ == "__main__":
    main()
