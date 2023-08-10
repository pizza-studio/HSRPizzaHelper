import requests
from pathlib import Path
import shutil
import json
from typing import Literal

language_map = {
    "cn": "zh-cn",
    "cht": "zh-tw",
    "de": "de-de",
    "en": "en-us",
    "es": "es-es",
    "fr": "fr-fr",
    "id": "id-id",
    "jp": "ja-jp",
    "kr": "ko-kr",
    "pt": "pt-pt",
    "ru": "ru-ru",
    "th": "th-th",
    "vi": "vi-vn"
}

def get_data_and_update(lang: str, update_dict: dict, type: Literal["characters", "light_cones"]):
    url = f"https://raw.githubusercontent.com/Mar-7th/StarRailRes/master/index_new/{lang}/{type}.json"
    api_lang = language_map[lang]
    res = requests.get(url)
    for id, meta in res.json().items():
        update_dict.setdefault(id, {})
        update_dict[id].setdefault("name_localization_map", {})
        update_dict[id]["icon_file_path"] = meta["icon"]
        update_dict[id]["rank"] = meta["rarity"]
        update_dict[id]["name_localization_map"][api_lang] = meta["name"]

def get_character_data() -> dict:
    result = {}
    for lang in language_map.keys():
        get_data_and_update(lang, result, type="characters")
    return result

def get_light_cones_data() -> dict:
    result = {}
    for lang in language_map.keys():
        get_data_and_update(lang, result, type="light_cones")
    return result

def get_data() -> dict:
    result = {}
    result["character"] = get_character_data()
    result["light_cone"] = get_light_cones_data()
    return result

def download_image(relative_url_path: str):
    base = "https://raw.githubusercontent.com/Mar-7th/StarRailRes/master/"
    if relative_url_path == "":
        return
    print("downloading: ", relative_url_path)
    url = f"{base}{relative_url_path}"
    res = requests.get(url)
    meta_folder = Path("./Assets/gacha_meta")
    to = meta_folder / relative_url_path
    to.parent.mkdir(parents=True, exist_ok=True)
    print("saving to: ", to)
    with open(to, "wb") as f:
        f.write(res.content)

def main():
    assets_folder = Path("./Assets")
    gacha_meta_folder = assets_folder / "gacha_meta"
    gacha_meta_file = gacha_meta_folder / "gacha_meta.json"
    if gacha_meta_folder.exists():
        shutil.rmtree(gacha_meta_folder)
    gacha_meta_folder.mkdir(parents=True)
    data = get_data()
    with open(gacha_meta_file, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False)
    for type, detail in data.items():
        for id, meta in detail.items():
            download_image(meta["icon_file_path"])

if __name__ == "__main__":
    main()