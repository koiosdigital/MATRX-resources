load("render.star", "render")
load("animation.star", "animation")


def main():
    return render.Root(
        delay=100,
        child=render.Animation(
            children=[
                render.Box(child=render.Text("", color="#fff", font="6x13")),
                render.Box(child=render.Text("_", color="#fff", font="6x13")),
                render.Box(child=render.Text("M_", color="#fff", font="6x13")),
                render.Box(child=render.Text("MA_", color="#fff", font="6x13")),
                render.Box(child=render.Text("MAT_", color="#fff", font="6x13")),
                render.Box(child=render.Text("MATR_", color="#fff", font="6x13")),
                render.Box(child=render.Text("MATRX", color="#fff", font="6x13")),
                render.Box(child=render.Text("MATRX", color="#fff", font="6x13")),
                render.Box(child=render.Text("MATRX", color="#fff", font="6x13")),
                render.Box(child=render.Text("MATRX", color="#fff", font="6x13")),
                render.Box(child=render.Text("MATRX", color="#fff", font="6x13")),
                render.Box(child=render.Text("MATRX", color="#fff", font="6x13")),
                render.Box(child=render.Text("MATRX", color="#fff", font="6x13")),
                render.Box(child=render.Text("MATRX", color="#fff", font="6x13")),
                render.Box(child=render.Text("MATRX", color="#fff", font="6x13")),
            ]
        ),
    )
