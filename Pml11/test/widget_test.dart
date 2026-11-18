import 'package:flutter_test/flutter_test.dart';
import 'package:pml11/models/global_variables.dart';
import 'package:pml11/screens/home_screen.dart';

void main() {
  test('GlobalVariables url test', () {
    expect(GlobalVariables.url, '');
    GlobalVariables.url = 'https://youtube.com';
    expect(GlobalVariables.url, 'https://youtube.com');
  });

  test('URLs constant verification', () {
    expect(HomeScreen.urlTiktok, 'https://www.tiktok.com');
    expect(HomeScreen.urlYoutube, 'https://youtube.com');
    expect(HomeScreen.urlSendMessage, 'https://aistudiollms.pythonanywhere.com/');
    expect(HomeScreen.urlShop, 'https://www.shopee.co.id');
    expect(HomeScreen.urlProfile, 'https://www.instagram.com/d3mipolinema/');
  });
}
