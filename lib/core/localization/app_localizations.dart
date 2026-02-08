import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'menu': 'Menu',
      'cart': 'Cart',
      'total': 'Total',
      'submit_order': 'SUBMIT ORDER',
      'cart_empty': 'Cart is Empty',
      'current_order': 'Current Order',
      'no_items': 'No Items Found',
      'no_items_msg': 'There are no items in this category yet.',
      'error_title': 'Oops! Something went wrong',
      'order_sent': 'Order Sent to Kitchen!',
      'everyone_favs': 'Everyone\'s Favorites',
      'new_delicacy': 'NEW DELICACY',
      'gallery': 'Gallery',
      'camera': 'Camera',
      'add_photo': 'ADD PHOTO',
      'category_label': 'CATEGORY',
      'category_hint': 'e.g., Signature Dishes',
      'dish_name_label': 'DISH NAME',
      'dish_name_hint': 'e.g., Golden Saffron Risotto',
      'description_label': 'DESCRIPTION',
      'description_hint': 'Describe the sensory experience...',
      'price_label': 'PRICE',
      'available_label': 'AVAILABLE',
      'save_to_menu': 'SAVE TO MENU',
      'select_image': 'Please select an image',
      'delicacy_added': 'Delicacy Added Successfully!',
      'required_field': 'Required',
      'invalid_price': 'Invalid Price',
      'error': 'Error: ',
      'your_order': 'YOUR ORDER',
      'bag_empty': 'YOUR BAG IS EMPTY',
      'back_to_menu': 'BACK TO MENU',
      'place_order': 'PLACE ORDER',
      'clear_order_title': 'Clear Order?',
      'clear_order_msg': 'Remove all items from your bag?',
      'cancel': 'Cancel',
      'clear': 'Clear',
      'order_placed': 'ORDER PLACED',
      'order_placed_msg': 'Your selection is being prepared.',
      'item_added': 'added',
      'undo': 'UNDO',
      'sold_out': 'SOLD OUT',
      'add_to_order': 'ADD TO ORDER',
    },
    'ru': {
      'menu': 'Меню',
      'cart': 'Корзина',
      'total': 'Итого',
      'submit_order': 'ОФОРМИТЬ ЗАКАЗ',
      'cart_empty': 'Корзина пуста',
      'current_order': 'Текущий заказ',
      'no_items': 'Ничего не найдено',
      'no_items_msg': 'В этой категории пока нет товаров.',
      'error_title': 'Ой! Что-то пошло не так',
      'order_sent': 'Заказ отправлен на кухню!',
      'everyone_favs': 'Популярное',
      'new_delicacy': 'НОВЫЙ ДЕЛИКАТЕС',
      'gallery': 'Галерея',
      'camera': 'Камера',
      'add_photo': 'ДОБАВИТЬ ФОТО',
      'category_label': 'КАТЕГОРИЯ',
      'category_hint': 'напр., Фирменные блюда',
      'dish_name_label': 'НАЗВАНИЕ БЛЮДА',
      'dish_name_hint': 'напр., Золотое ризотто с шафраном',
      'description_label': 'ОПИСАНИЕ',
      'description_hint': 'Опишите вкусовые качества...',
      'price_label': 'ЦЕНА',
      'available_label': 'ДОСТУПНО',
      'save_to_menu': 'СОХРАНИТЬ В МЕНЮ',
      'select_image': 'Пожалуйста, выберите изображение',
      'delicacy_added': 'Деликатес успешно добавлен!',
      'required_field': 'Обязательно',
      'invalid_price': 'Неверная цена',
      'error': 'Ошибка: ',
      'your_order': 'ВАШ ЗАКАЗ',
      'bag_empty': 'ВАША КОРЗИНА ПУСТА',
      'back_to_menu': 'В МЕНЮ',
      'place_order': 'ОФОРМИТЬ',
      'clear_order_title': 'Очистить заказ?',
      'clear_order_msg': 'Удалить все товары?',
      'cancel': 'Отмена',
      'clear': 'Очистить',
      'order_placed': 'ЗАКАЗ ОФОРМЛЕН',
      'order_placed_msg': 'Ваш заказ готовится.',
      'item_added': 'добавлено',
      'undo': 'ОТМЕНА',
      'sold_out': 'ПРОДАНО',
      'add_to_order': 'В ЗАКАЗ',
    },
    'tk': {
      'menu': 'Menu',
      'cart': 'Sebet',
      'total': 'Jemi',
      'submit_order': 'SARGYT ETMEK',
      'cart_empty': 'Sebet boş',
      'current_order': 'Häzirki sargyt',
      'no_items': 'Haryt tapylmady',
      'no_items_msg': 'Bu kategoriýada entek haryt ýok.',
      'error_title': 'Bagyşlaň! Bir zat ýalňyş boldy',
      'order_sent': 'Sargyt aşhana ugradyldy!',
      'everyone_favs': 'Hemmäniň halanýanlary',
      'new_delicacy': 'TÄZE TAGAM',
      'gallery': 'Galereýa',
      'camera': 'Kamera',
      'add_photo': 'SURAT GOŞ',
      'category_label': 'KATEGORIÝA',
      'category_hint': 'meselem, Aýratyn tagamlar',
      'dish_name_label': 'TAGAM ADY',
      'dish_name_hint': 'meselem, Altyn şafran rizotto',
      'description_label': 'DÜŞÜNDIRIŞ',
      'description_hint': 'Tagamyň aýratynlyklaryny düşündiriň...',
      'price_label': 'BAHASY',
      'available_label': 'ELÝETERLI',
      'save_to_menu': 'MENÝUWA GOŞ',
      'select_image': 'Surat saýlaň',
      'delicacy_added': 'Tagam üstünlikli goşuldy!',
      'required_field': 'Hökmany',
      'invalid_price': 'Nädogry baha',
      'error': 'Ýalňyşlyk: ',
      'your_order': 'SARGYDYŇYZ',
      'bag_empty': 'SEBEDIŇIZ BOŞ',
      'back_to_menu': 'MENÝUWA DOLAN',
      'place_order': 'SARGYT ET',
      'clear_order_title': 'Sargydy bozmak?',
      'clear_order_msg': 'Sebetdäki ähli harytlary aýyrmalymy?',
      'cancel': 'Goýbolsun',
      'clear': 'Arassala',
      'order_placed': 'SARGYT EDILDI',
      'order_placed_msg': 'Sargydyňyz taýýarlanylýar.',
      'item_added': 'goşuldy',
      'undo': 'YZA AL',
      'sold_out': 'SATYLDY',
      'add_to_order': 'SARGYT ET',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ru', 'tk'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class TkMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const TkMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'tk';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return DefaultMaterialLocalizations.load(const Locale('en'));
  }

  @override
  bool shouldReload(TkMaterialLocalizationsDelegate old) => false;
}
