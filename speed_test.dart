import 'package:http/http.dart' as http; //網路請求所需
import 'package:flutter/foundation.dart'; // compute 在此套件中 故需引入
import 'dart:convert';  // jsonDecode,jsonEncode 需要的套件


class SpeedTest {
  static var imgDomains = [
    "a.com",
    "b.com",
    "c.com"
  ];

    static  List<String> get toUrls => imgDomains.map((d) =>"https://$d/test-img").toList() ;

  static String result = "";

/* 實際測速時使用的函數, 使用compute 於background 執行
/  此處假設 domain 皆成功返回請求, 若實際專案考慮請求可能不成功, 將計算時間差改成-1 回傳, 在排列時排除負數 domain 即可
*/
  static void testSpeed() {
    compute(Future.wait<int>, toUrls.map((s) => downloadImg(s))).then((v) {
      set(v);
    });
  }

  //題目中1.請求圖片的 function，請求必須背景執行，圖片不需要儲存，最後回傳圖片的下載時間(ms)：downloadImg(domain: String): double
  static Future<int> downloadImg(String domain) =>
      timeDiff(() => dlImg(domain));

/*題目中2.儲存結果的 function，傳入參數由撰寫者自行決定，傳入後必須要照下載時間順序排序後儲存：set({由撰寫者自行決定}): void
  (平常專案 我會引入 collection 套件, 可以直接with index  並且排列  可以使程式更簡約)
   此處我只使用dart 內建函數
*/
  static void set(List<int> timeDiffs) {
    List<MapEntry<int, int>> indxWithTime = [];

    //紀錄index
    timeDiffs.forEach((t) {
      indxWithTime.add(MapEntry(indxWithTime.length, t));
    });

    //根據time 排列
    indxWithTime.sort((v1, v2) => v1.value - v2.value);

  //將index 轉換成domain 並且存成object list
  List<Map<String, dynamic>>  sortedDomainTimes = indxWithTime.map((a) => genObj(imgDomains[a.key], a.value)).toList();

  /* 單純 json 轉換
    平常專案會引入sharePreference 存入 , 這邊僅示意存入result
  */ 
   result =  jsonEncode(sortedDomainTimes);

    debugPrint("speed result : $result");

  }

 //題目中3.取出結果的 function，回傳結果由撰寫者自行決定，請搭配 set 傳入參數一起考慮：get(): {由撰寫者自行決定}

  static List<dynamic> get() => jsonDecode(result) as List<dynamic>;

// 轉換成object,  平常專案我會建立model 並且配合json_serializable 套件
  static Map<String, dynamic> genObj(String domain, int timeElape) =>
      {"domain": domain, "time": timeElape};


//實際download image 函數
  static Future<void> dlImg(String url) async {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      debugPrint("img DL $url succeed ");
    } else {
      debugPrint("img DL $url failed: ${response.statusCode}");
    }
  }

//計算 時間差函數
  static Future<int> timeDiff(Future<void> Function() execute) async {
    DateTime startTime = DateTime.now();

    await execute();

    DateTime endTime = DateTime.now();

    return endTime.difference(startTime).inMilliseconds;
  }
}