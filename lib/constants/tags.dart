// ignore_for_file: constant_pattern_never_matches_value_type

import 'package:flutter/material.dart';
import 'package:greenwheel_user_app/models/tag.dart';

List<Tag> tags = [
  Tag(
      id: "1",
      title: "Hồ",
      mainColor: Colors.white,
      strokeColor: Color(0xFF59CDFF)),
  Tag(
      id: "2",
      title: "Núi",
      mainColor: Colors.white,
      strokeColor: Color(0xFFE79901)),
  Tag(
      id: "3",
      title: "Biển",
      mainColor: Colors.white,
      strokeColor: Color(0xFF006590)),
  Tag(
      id: "4",
      title: "Suối",
      mainColor: Colors.white,
      strokeColor: Color(0xFF5869FF)),
  Tag(
      id: "5",
      title: "Rừng",
      mainColor: Colors.white,
      strokeColor: Color(0xFF007613)),
  Tag(
      id: "6",
      title: "Hang động",
      mainColor: Colors.white,
      strokeColor: Color(0xFF5C645E)),
  Tag(
      id: "7",
      title: "Đồi cát",
      mainColor: Colors.white,
      strokeColor: Color(0xFFFFE500)),
  Tag(
      id: "8",
      title: "Thác",
      mainColor: Colors.white,
      strokeColor: Color(0xFF31FFE6)),
  Tag(
      id: "9",
      title: "Tắm",
      mainColor: Color(0xFF59CDFF),
      strokeColor: Colors.black),
  Tag(
      id: "10",
      title: "Cắm trại",
      mainColor: Color(0xFF82E0AA),
      strokeColor: Colors.black),
  Tag(
      id: "11",
      title: "Leo trèo",
      mainColor: Color(0xFFE79901),
      strokeColor: Colors.black),
  Tag(
      id: "12",
      title: "Chèo thuyền",
      mainColor: Color(0xFF01E7BD),
      strokeColor: Colors.black),
  Tag(
      id: "13",
      title: "Lặn",
      mainColor: Color(0xFF96A1FF),
      strokeColor: Colors.black),
  Tag(
      id: "14",
      title: "Lướt sóng",
      mainColor: Color(0xFFA5FFEF),
      strokeColor: Colors.black),
  Tag(
      id: "15",
      title: "Câu cá",
      mainColor: Color(0xFF49B9F9),
      strokeColor: Colors.black),
  Tag(
    id: "16",
    title: "Xuân",
    mainColor: Color(0xFF82E0AA),
  ),
  Tag(
    id: "17",
    title: "Hạ",
    mainColor: Color(0xFFFFB967),
  ),
  Tag(
    id: "18",
    title: "Thu",
    mainColor: Color(0xFFF0D984),
  ),
  Tag(
    id: "19",
    title: "Đông",
    mainColor: Color(0xFF33D8D8),
  ),
  Tag(
      id: "20",
      title: "M.Bắc",
      mainColor: Color(0xFF8DFF71),
      strokeColor: Color(0xFF00889A)),
  Tag(
      id: "21",
      title: "M.Trung",
      mainColor: Color(0xFF6EDCFF),
      strokeColor: Color(0xFF7B1BC6)),
  Tag(
      id: "22",
      title: "M.Nam",
      mainColor: Color(0xFFFFD771),
      strokeColor: Color(0xFFFFD771)),
  Tag(
      id: "23",
      title: "Tỉnh",
      mainColor: Colors.white,
      strokeColor: Colors.black),
];

Tag getTag(String tagName) {
  Tag tag = Tag(id: "default", title: "Default", mainColor: Colors.white);
  switch (tagName) {
    case "SPRING":
      tag = Tag(id: tagName, title: "Xuân", mainColor: Color(0xFF82E0AA));
      break;
    case "SUMMER":
      tag = Tag(
        id: tagName,
        title: "Hạ",
        mainColor: Color(0xFFFFB967),
      );
      break;
    case "FALL":
      tag = Tag(id: tagName, title: "Thu", mainColor: Color(0xFFF0D984));
      break;
    case "WINTER":
      tag = Tag(id: tagName, title: "Đông", mainColor: Color(0xFF33D8D8));
      break;
    case "BATHING":
      tag = Tag(
          id: tagName,
          title: "Tắm",
          mainColor: Color(0xFF59CDFF),
          strokeColor: Colors.black);
      break;
    case "CAMPING":
      tag = Tag(
          id: tagName,
          title: "Cắm trại",
          mainColor: Color(0xFF82E0AA),
          strokeColor: Colors.black);
      break;
    case "CLIMBING":
      tag = Tag(
          id: tagName,
          title: "Leo trèo",
          mainColor: Color(0xFFE79901),
          strokeColor: Colors.black);
      break;
    case "PADDLING":
      tag = Tag(
          id: tagName,
          title: "Chèo thuyền",
          mainColor: Color(0xFF01E7BD),
          strokeColor: Colors.black);
      break;
    case "DIVING":
      tag = Tag(
          id: tagName,
          title: "Lặn",
          mainColor: Color(0xFF96A1FF),
          strokeColor: Colors.black);
      break;
    case "SURFING":
      tag = Tag(
          id: tagName,
          title: "Lướt sóng",
          mainColor: Color(0xFFA5FFEF),
          strokeColor: Colors.black);
      break;
    case "FISHING":
      tag = Tag(
          id: tagName,
          title: "Câu cá",
          mainColor: Color(0xFF49B9F9),
          strokeColor: Colors.black);
      break;
    case "LAKE":
      tag = Tag(
          id: tagName,
          title: "Hồ",
          mainColor: Colors.white,
          strokeColor: Color(0xFF59CDFF));
      break;
    case "MOUNTAIN":
      tag = Tag(
          id: tagName,
          title: "Núi",
          mainColor: Colors.white,
          strokeColor: Color(0xFFE79901));
      break;
    case "BEACH":
      tag = Tag(
          id: tagName,
          title: "Biển",
          mainColor: Colors.white,
          strokeColor: Color(0xFF006590));
      break;
    case "BROOK":
      tag = Tag(
          id: tagName,
          title: "Suối",
          mainColor: Colors.white,
          strokeColor: Color(0xFF5869FF));
      break;
    case "JUNGLE":
      tag = Tag(
          id: tagName,
          title: "Rừng",
          mainColor: Colors.white,
          strokeColor: Color(0xFF007613));
      break;
    case "CAVE":
      tag = Tag(
          id: tagName,
          title: "Hang động",
          mainColor: Colors.white,
          strokeColor: Color(0xFF5C645E));
      break;
    case "DUNE":
      tag = Tag(
          id: tagName,
          title: "Đồi cát",
          mainColor: Colors.white,
          strokeColor: Color(0xFFFFE500));
      break;
    case "WATERFALL":
      tag = Tag(
          id: tagName,
          title: "Thác",
          mainColor: Colors.white,
          strokeColor: Color(0xFF31FFE6));
      break;
    case "HILL":
      tag = Tag(
          id: tagName,
          title: "Đồi",
          mainColor: Colors.white,
          strokeColor: Color(0xFF4EFF31));
      break;
  }
  return tag;
}
