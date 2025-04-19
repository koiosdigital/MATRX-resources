load("render.star", "render")
load("animation.star", "animation")
load("schema.star", "schema")


def main(config):
    width = config.str("width", 64)
    height = config.str("height", 32)

    height_int = int(height)
    width_int = int(width)

    return render.Root(
        delay=100,
        child=render.Column(
            children=[
                render.Row(
                    children=[
                        render.Text("H"),
                        animation.Transformation(
                            child=render.Box(
                                child=render.Stack(
                                    children=[
                                        render.Box(
                                            render.PieChart(
                                                colors=["#fff", "#000"],
                                                weights=[300, 60],
                                                diameter=int(height_int / 2),
                                            )
                                        ),
                                        render.Box(
                                            render.Circle(
                                                diameter=int(height_int / 2) - 2,
                                                color="#000",
                                            )
                                        ),
                                    ]
                                )
                            ),
                            duration=50,
                            delay=0,
                            direction="normal",
                            keyframes=[
                                animation.Keyframe(
                                    percentage=0.0,
                                    transforms=[
                                        animation.Rotate(0),
                                    ],
                                ),
                                animation.Keyframe(
                                    percentage=1.0,
                                    transforms=[
                                        animation.Rotate(360),
                                    ],
                                ),
                            ],
                            width=int(height_int / 2),
                            height=int(height_int / 2),
                        ),
                    ],
                    main_align="space_evenly",
                    cross_align="center",
                    expanded=True,
                )
            ],
            main_align="center",
            expanded=True,
        ),
    )


def get_schema():
    return schema.Schema(
        version="1",
        fields=[
            schema.Text(id="width", name="Width", desc="Width of the screen", icon=""),
            schema.Text(
                id="height",
                name="Height",
                desc="Height of the screen",
                icon="",
            ),
        ],
    )
