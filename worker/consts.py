BRIDGE_VERSION = 22
RELEASE = f"{BRIDGE_VERSION}.0.5"
BRIDGE_CONFIG_FILE = "bridgeData.yaml"
KNOWN_UPSCALERS = {
    "RealESRGAN_x4plus",
    "RealESRGAN_x2plus",
    "RealESRGAN_x4plus_anime_6B",
    "NMKD_Siax",
    "4x_AnimeSharp",
}
KNOWN_FACE_FIXERS = {
    "GFPGAN",
    "CodeFormers",
}
POST_PROCESSORS_HORDELIB_MODELS = KNOWN_UPSCALERS | KNOWN_FACE_FIXERS
KNOWN_POST_PROCESSORS = POST_PROCESSORS_HORDELIB_MODELS | {
    "strip_background",
}
KNOWN_INTERROGATORS = {
    "ViT-L/14",
}
