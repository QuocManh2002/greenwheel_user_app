// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/tag.dart';

List<Tag> tags = [
  Tag(
      id: "1",
      title: "Hồ",
      type: "topographic",
      enumName: "LAKE",
      mainColor: Colors.white,
      strokeColor: Color(0xFF59CDFF)),
  Tag(
      id: "2",
      title: "Núi",
      type: "topographic",
      enumName: "MOUNTAIN",
      mainColor: Colors.white,
      strokeColor: Color(0xFFE79901)),
  Tag(
      id: "3",
      title: "Biển",
      type: "topographic",
      enumName: "BEACH",
      mainColor: Colors.white,
      strokeColor: Color(0xFF006590)),
  Tag(
      id: "4",
      title: "Suối",
      type: "topographic",
      enumName: "BROOK",
      mainColor: Colors.white,
      strokeColor: Color(0xFF5869FF)),
  Tag(
      id: "5",
      title: "Rừng",
      type: "topographic",
      enumName: "JUNGLE",
      mainColor: Colors.white,
      strokeColor: Color(0xFF007613)),
  Tag(
      id: "6",
      title: "Hang động",
      type: "topographic",
      enumName: "CAVE",
      mainColor: Colors.white,
      strokeColor: Color(0xFF5C645E)),
  Tag(
      id: "7",
      title: "Đồi cát",
      type: "topographic",
      enumName: "DUNE",
      mainColor: Colors.white,
      strokeColor: Color(0xFFFFE500)),
  Tag(
      id: "8",
      title: "Thác",
      type: "topographic",
      enumName: "WATERFALL",
      mainColor: Colors.white,
      strokeColor: Color(0xFF31FFE6)),
  Tag(
      id: "9",
      title: "Tắm",
      type: "activities",
      enumName: "BATHING",
      mainColor: Color(0xFF59CDFF),
      strokeColor: Colors.black),
  Tag(
      id: "10",
      title: "Cắm trại",
      type: "activities",
      enumName: "CAMPING",
      mainColor: Color(0xFF82E0AA),
      strokeColor: Colors.black),
  Tag(
      id: "11",
      title: "Leo trèo",
      type: "activities",
      enumName: "CLIMBING",
      mainColor: Color(0xFFE79901),
      strokeColor: Colors.black),
  Tag(
      id: "12",
      title: "Chèo thuyền",
      type: "activities",
      enumName: "PADDLING",
      mainColor: Color(0xFF01E7BD),
      strokeColor: Colors.black),
  Tag(
      id: "13",
      title: "Lặn",
      type: "activities",
      enumName: "DIVING",
      mainColor: Color(0xFF96A1FF),
      strokeColor: Colors.black),
  Tag(
      id: "14",
      title: "Lướt sóng",
      type: "activities",
      enumName: "SURFING",
      mainColor: Color(0xFFA5FFEF),
      strokeColor: Colors.black),
  Tag(
      id: "15",
      title: "Câu cá",
      type: "activities",
      enumName: "FISHING",
      mainColor: Color(0xFF49B9F9),
      strokeColor: Colors.black),
  Tag(
    id: "16",
    title: "Xuân",
    type: "seasons",
    enumName: "SPRING",
    mainColor: Color(0xFF82E0AA),
  ),
  Tag(
    id: "17",
    title: "Hạ",
    type: "seasons",
    enumName: "SUMMER",
    mainColor: Color(0xFFFFB967),
  ),
  Tag(
    id: "18",
    title: "Thu",
    type: "seasons",
    enumName: "FALL",
    mainColor: Color(0xFFF0D984),
  ),
  Tag(
    id: "19",
    title: "Đông",
    type: "seasons",
    enumName: "PADDLING",
    mainColor: Color(0xFF33D8D8),
  ),
  Tag(
      id: "20",
      title: "M.Bắc",
      type: "region",
      enumName: "NORTHERN",
      mainColor: Color(0xFF8DFF71),
      strokeColor: Color(0xFF00889A)),
  Tag(
      id: "21",
      title: "M.Trung",
      type: "region",
      enumName: "CENTRAL",
      mainColor: Color(0xFF6EDCFF),
      strokeColor: Color(0xFF7B1BC6)),
  Tag(
      id: "22",
      title: "M.Nam",
      type: "region",
      enumName: "SOUTHERN",
      mainColor: Color(0xFFFFD771),
      strokeColor: Color(0xFFFFD771)),
  Tag(
      id: "23",
      title: "Tỉnh",
      type: "province",
      enumName: "PROVINCE",
      mainColor: Colors.white,
      strokeColor: Colors.black),
];

Tag getTag(String tagName) {
  Tag tag = Tag(
    id: "default",
    title: "Default",
    type: "default",
    enumName: "DEFAULT",
    mainColor: Colors.white,
  );
  switch (tagName) {
    case "SPRING":
      tag = Tag(
        id: tagName,
        title: "Xuân",
        type: "seasons",
        enumName: "SPRING",
        mainColor: Color(0xFF82E0AA),
      );
      break;
    case "SUMMER":
      tag = Tag(
        id: tagName,
        title: "Hạ",
        type: "seasons",
        enumName: "SUMMER",
        mainColor: Color(0xFFFFB967),
      );
      break;
    case "FALL":
      tag = Tag(
        id: tagName,
        title: "Thu",
        type: "seasons",
        enumName: "FALL",
        mainColor: Color(0xFFF0D984),
      );
      break;
    case "WINTER":
      tag = Tag(
        id: tagName,
        title: "Đông",
        type: "seasons",
        enumName: "WINTER",
        mainColor: Color(0xFF33D8D8),
      );
      break;
    case "BATHING":
      tag = Tag(
          id: tagName,
          title: "Tắm",
          type: "activities",
          enumName: "BATHING",
          mainColor: Color(0xFF59CDFF),
          strokeColor: Colors.black);
      break;
    case "CAMPING":
      tag = Tag(
          id: tagName,
          title: "Cắm trại",
          type: "activities",
          enumName: "CAMPING",
          mainColor: Color(0xFF82E0AA),
          strokeColor: Colors.black);
      break;
    case "CLIMBING":
      tag = Tag(
          id: tagName,
          title: "Leo trèo",
          type: "activities",
          enumName: "CLIMBING",
          mainColor: Color(0xFFE79901),
          strokeColor: Colors.black);
      break;
    case "PADDLING":
      tag = Tag(
          id: tagName,
          title: "Chèo thuyền",
          type: "activities",
          enumName: "PADDLING",
          mainColor: Color(0xFF01E7BD),
          strokeColor: Colors.black);
      break;
    case "DIVING":
      tag = Tag(
          id: tagName,
          title: "Lặn",
          type: "activities",
          enumName: "DIVING",
          mainColor: Color(0xFF96A1FF),
          strokeColor: Colors.black);
      break;
    case "SURFING":
      tag = Tag(
          id: tagName,
          title: "Lướt sóng",
          type: "activities",
          enumName: "SURFING",
          mainColor: Color(0xFFA5FFEF),
          strokeColor: Colors.black);
      break;
    case "FISHING":
      tag = Tag(
          id: tagName,
          title: "Câu cá",
          type: "activities",
          enumName: "FISHING",
          mainColor: Color(0xFF49B9F9),
          strokeColor: Colors.black);
      break;
    case "LAKE":
      tag = Tag(
          id: tagName,
          title: "Hồ",
          type: "topographic",
          enumName: "LAKE",
          mainColor: Colors.white,
          strokeColor: Color(0xFF59CDFF));
      break;
    case "MOUNTAIN":
      tag = Tag(
          id: tagName,
          title: "Núi",
          type: "topographic",
          enumName: "MOUNTAIN",
          mainColor: Colors.white,
          strokeColor: Color(0xFFE79901));
      break;
    case "BEACH":
      tag = Tag(
          id: tagName,
          title: "Biển",
          type: "topographic",
          enumName: "BEACH",
          mainColor: Colors.white,
          strokeColor: Color(0xFF006590));
      break;
    case "BROOK":
      tag = Tag(
          id: tagName,
          title: "Suối",
          type: "topographic",
          enumName: "BROOK",
          mainColor: Colors.white,
          strokeColor: Color(0xFF5869FF));
      break;
    case "JUNGLE":
      tag = Tag(
          id: tagName,
          title: "Rừng",
          type: "topographic",
          enumName: "JUNGLE",
          mainColor: Colors.white,
          strokeColor: Color(0xFF007613));
      break;
    case "CAVE":
      tag = Tag(
          id: tagName,
          title: "Hang động",
          type: "topographic",
          enumName: "CAVE",
          mainColor: Colors.white,
          strokeColor: Color(0xFF5C645E));
      break;
    case "DUNE":
      tag = Tag(
          id: tagName,
          title: "Đồi cát",
          type: "topographic",
          enumName: "DUNE",
          mainColor: Colors.white,
          strokeColor: Color(0xFFFFE500));
      break;
    case "WATERFALL":
      tag = Tag(
          id: tagName,
          title: "Thác",
          type: "topographic",
          enumName: "WATERFALL",
          mainColor: Colors.white,
          strokeColor: Color(0xFF31FFE6));
      break;
    case "HILL":
      tag = Tag(
          id: tagName,
          title: "Đồi",
          type: "topographic",
          enumName: "HILL",
          mainColor: Colors.white,
          strokeColor: Color(0xFF4EFF31));
      break;
  }
  return tag;
}
