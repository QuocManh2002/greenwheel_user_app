import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greenwheel_user_app/constants/tags.dart';
import 'package:greenwheel_user_app/models/location.dart';

List<Location> locations = [
  Location(
      id: "1",
      description: "Địa điểm du lịch Vũng Tàu ...",
      imageUrl:
          "https://glamptrip.vn/wp-content/uploads/2022/08/Ho_Da_den.jpeg",
      name: "Hồ Đá Bàng",
      numberOfRating: 100,
      tags: [tags[1],tags[2], tags[3], tags[4], tags[5], tags[6], tags[7], tags[8], tags[9]],
      rating: 5,
      hotlineNumber: "0912312345",
      lifeGuardNumber: "0912312345",
      lifeGuardAddress: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
      clinicNumber: "0912312345",
      clinicAddress: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
      locationLatLng:const LatLng(10.554411364780098, 107.2505359801003),
      ),
  Location(
      id: "2",
      description: "Địa điểm du lịch Vũng Tàu ...",
      imageUrl:
          "https://ik.imagekit.io/tvlk/blog/2023/09/ho-coc-4.jpg?tr=dpr-2,w-675",
      name: "Hồ Cốc",
      numberOfRating: 75,
      tags: [tags[1],tags[2], tags[3], tags[4], tags[5], tags[6], tags[7], tags[8], tags[9]],
      rating: 3.5,
      hotlineNumber: "0912312345",
      lifeGuardNumber: "0912312345",
      lifeGuardAddress: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
      clinicNumber: "0912312345",
      clinicAddress: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
      locationLatLng: const LatLng(10.500131412056358, 107.47757431718013)
      ),
  Location(
      id: "3",
      description: "Địa điểm du lịch Vũng Tàu ...",
      imageUrl:
          "https://phanri.plus/wp-content/uploads/2019/02/thac-daguri.jpg",
      name: "Thác Daguri",
      numberOfRating: 80,
      tags: [tags[1],tags[2], tags[3], tags[4], tags[5], tags[6], tags[7]],
      rating: 4,
      hotlineNumber: "0912312345",
      lifeGuardNumber: "0912312345",
      lifeGuardAddress: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
      clinicNumber: "0912312345",
      clinicAddress: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
      locationLatLng:const LatLng(11.25744127768411, 107.88268447823675)
      ),
      
  Location(
      id: "4",
      description: "Địa điểm du lịch Vũng Tàu ...",
      imageUrl:
          "https://phuot3mien.com/wp-content/uploads/2020/08/doi-thien-phuc-duc-1.jpeg",
      name: "Đồi Thiên Phúc Đức",
      numberOfRating: 50,
      tags: [tags[1],tags[2], tags[3], tags[4], tags[5], tags[6], tags[8]],
      rating: 2.7,
      hotlineNumber: "0912312345",
      lifeGuardNumber: "0912312345",
      lifeGuardAddress: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
      clinicNumber: "0912312345",
      clinicAddress: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
      locationLatLng:const LatLng(11.994721228758529, 108.42856959567486)),
  Location(
      id: "5",
      description: "Địa điểm du lịch Vũng Tàu ...",
      imageUrl:
          "https://dulichtoivaban.com/wp-content/uploads/2020/08/Kham-pha-Khu-du-lich-Dao-O-Dong-Truong-tai-Dong-Nai.jpg",
      name: "Đảo Ó",
      numberOfRating: 45,
      rating: 3,
      tags: [tags[1],tags[2], tags[3]],
      hotlineNumber: "0912312345",
      lifeGuardNumber: "0912312345",
      lifeGuardAddress: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
      clinicNumber: "0912312345",
      clinicAddress: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
      locationLatLng: const LatLng(11.111790144544416, 107.10330964196373)
      ),
];
