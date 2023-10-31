import 'package:greenwheel_user_app/constants/menu_items.dart';
import 'package:greenwheel_user_app/models/supplier.dart';

List<Supplier> suppliers = [
  Supplier(
    id: 1,
    imgUrl:
        "https://media-cdn.tripadvisor.com/media/photo-s/15/c5/84/65/khong-gian-nha-hang-vu.jpg",
    name: "Nhà hàng Ngọc Thịnh",
    address: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
    rating: 4,
    numberOfReviews: 20,
    items: [
      items[0],
      items[1],
      items[2],
      items[3],
      items[4],
      items[5],
      items[6],
      items[7],
    ],
  ),
  Supplier(
    id: 2,
    imgUrl:
        "https://i1.wp.com/www.slightlypretentious.co/wp-content/uploads/2022/12/Double-Chicken-Please-2.jpg?fit=1600%2C1200&ssl=1",
    name: "Bar Đức Duy",
    address: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
    rating: 1,
    numberOfReviews: 100,
    items: [
      items[0],
      items[1],
      items[2],
    ],
  ),
  Supplier(
    id: 3,
    imgUrl:
        "https://www.barniescoffee.com/cdn/shop/articles/bar-1869656_1920.jpg?v=1660683986",
    name: "Coffee Thanh Huy",
    address: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
    rating: 1,
    numberOfReviews: 100,
    items: [
      items[0],
      items[1],
      items[2],
    ],
  ),
  Supplier(
    id: 4,
    imgUrl:
        "https://lotel.xyz/sites/default/files/styles/wide/public/2023-03/271768038_4913607791993943_7907971340722469119_n.jpg?itok=EGhz2rE2",
    name: "Nhà nghỉ Mường Thanh",
    address: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
    rating: 1,
    numberOfReviews: 100,
    items: [
      items[3],
      items[4],
      items[5],
    ],
  ),
  Supplier(
    id: 5,
    imgUrl:
        "https://pix10.agoda.net/hotelImages/2817185/-1/4406a970306a452300f94532410dab2c.jpg?ca=10&ce=1&s=702x392",
    name: "Khách sạn Mỹ Trâm",
    address: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
    rating: 1,
    numberOfReviews: 100,
    items: [
      items[3],
      items[4],
      items[5],
    ],
  ),
  Supplier(
    id: 6,
    imgUrl:
        "https://glamptrip.vn/wp-content/uploads/2022/08/san-may-doi-thien-phuc-duc-da-lat-3.jpg",
    name: "Thành Công Camping",
    address: "113 Hồng Lĩnh, Đá Bạc, Long Tân, Bà Rịa - Vũng Tàu",
    rating: 1,
    numberOfReviews: 100,
    items: [items[8], items[9], items[10]],
  ),
];
