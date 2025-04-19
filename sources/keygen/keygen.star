load("render.star", "render")
load("animation.star", "animation")


def main():
    return render.Root(
        delay=250,
        child=render.Animation(
            children=[
                render.Box(child=render.Text("keygen", color="#fff", font="6x13")),
                render.Box(child=render.Text("keygen.", color="#fff", font="6x13")),
                render.Box(child=render.Text("keygen..", color="#fff", font="6x13")),
                render.Box(child=render.Text("keygen...", color="#fff", font="6x13")),
                render.Box(child=render.Text("keygen..", color="#fff", font="6x13")),
                render.Box(child=render.Text("keygen.", color="#fff", font="6x13")),
            ]
        ),
    )
