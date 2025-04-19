load("render.star", "render")


def main(config):
    return render.Root(
        delay=500,
        child=render.Animation(
            children=[
                render.Box(color="#000"),
                render.Box(color="#fff"),
                render.Box(color="#f00"),
                render.Box(color="#0f0"),
                render.Box(color="#00f"),
                render.Box(color="#ff0"),
                render.Box(color="#f0f"),
                render.Box(color="#0ff"),
            ]
        ),
    )
