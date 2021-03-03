from moderngl_window import resources
from pathlib import Path
from typing import Any, Tuple

import datetime
import moderngl_window as mglw
import numpy as np


resources.register_dir(
    (Path(__file__).parent / "resources").resolve()
)


class FakeUniform:
    def __init__(self, value: Any) -> None:
        self.value = value


class NPS(mglw.WindowConfig):
    title       : str             = "Nano Pixel Shader"
    gl_version  : Tuple[int, int] = (3, 3)
    window_size : Tuple[int, int] = 1280, 720
    aspect_ratio: float           = 16 / 9
    vsync       : bool            = False
    resizable   : bool            = False
    samples     : int             = 8

    def __init__(self, *args, **kwargs) -> None:
        super().__init__(*args, **kwargs)
        program = self.load_program("programs/solar_clock.glsl")

        faces = np.array([0, 1, 2, 1, 2, 3], dtype=np.int32)
        verts = np.array([
            # x,    y,   z,    u,   v
            -1.0, -1.0, 0.0,  0.0, 0.0,
            +1.0, -1.0, 0.0,  1.0, 0.0,
            -1.0, +1.0, 0.0,  0.0, 1.0,
            +1.0, +1.0, 0.0,  1.0, 1.0,
        ], dtype=np.float32)

        vba = [(self.ctx.buffer(verts), "3f 2f", "in_vert", "in_uv")]
        ibo = self.ctx.buffer(faces)

        self.quad = self.ctx.vertex_array(program, vba, ibo)
        self.wnd.fullscreen = True

        self.u_time = program.get("u_time", FakeUniform(0.0))
        self.u_time.value = 0.0

        self.u_aspect = program.get("u_aspect", FakeUniform(16 / 9))
        self.u_aspect.value = self.aspect_ratio

        self.u_date = program.get("u_date", FakeUniform((0.0, 0.0, 0.0)))
        self.u_date.value = self.date

    def render(self, time: float, frametime: float) -> None:
        self.ctx.clear()

        self.u_time.value = time
        self.u_date.value = self.date

        self.quad.render()

    @property
    def date(self) -> Tuple[float, float, float]:
        date = datetime.datetime.now()
        return (date.hour % 12) / 12, date.minute / 60, date.second / 60


NPS.run()