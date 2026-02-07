from collections import deque
import numpy as np
from PIL import Image

def make_edge_black_transparent(
    img_np: np.ndarray,
    black_value: int = 0,
    fill_gray: int = 128
) -> Image.Image:
    """
    - Black pixels (== black_value) connected to the image border become transparent.
    - Remaining black pixels (fully enclosed) are filled with gray.
    - All other pixels remain unchanged.
    Returns an RGBA PIL Image.
    """
    if img_np.ndim != 2:
        raise ValueError("Expected a 2D grayscale array")

    if img_np.dtype != np.uint8:
        img_np = img_np.astype(np.uint8)

    h, w = img_np.shape

    black = (img_np == black_value)
    visited = np.zeros((h, w), dtype=bool)
    q = deque()

    def push(y, x):
        if 0 <= y < h and 0 <= x < w and black[y, x] and not visited[y, x]:
            visited[y, x] = True
            q.append((y, x))

    # Seed from borders
    for x in range(w):
        push(0, x)
        push(h - 1, x)
    for y in range(h):
        push(y, 0)
        push(y, w - 1)

    # Flood-fill
    while q:
        y, x = q.popleft()
        push(y - 1, x)
        push(y + 1, x)
        push(y, x - 1)
        push(y, x + 1)

    # Build RGBA
    rgba = np.zeros((h, w, 4), dtype=np.uint8)

    # Start with original grayscale
    rgba[..., 0] = img_np
    rgba[..., 1] = img_np
    rgba[..., 2] = img_np
    rgba[..., 3] = 255  # fully opaque

    # Edge-connected black → transparent
    rgba[visited, 3] = 0

    # Remaining black (interior) → gray
    interior_black = black & (~visited)
    rgba[interior_black, 0:3] = fill_gray

    return Image.fromarray(rgba, mode="RGBA")



if __name__ == "__main__":
    make_edge_black_transparent()