Программироавние корпоративных систем

Отчет по практической работе №12

Тучин Владислав ЭФБО-06-23

Одна и самая главная проблема: 

У эмулятора нет камеры и у меня винда и айфон. Поэтому вс код просто не видит его и я не могу сделать фото с телефоно, поэтому прикркпил что дает эмулятор при нажатии камеры, когда нажимаешь на кнопку сделать фото эмблема того что камера эмулятора есть, а значит он рабоатет.

Скриншот главного экрана при запуске:


<img width="864" height="1053" alt="маин" src="https://github.com/user-attachments/assets/110d649d-d96a-4300-917d-a1f00d0f292c" />


Скриншот камеры в действии:


<img width="885" height="1044" alt="дел фото" src="https://github.com/user-attachments/assets/ff142a58-ef9b-4015-8534-0c6528945bc2" />


<img width="745" height="1055" alt="подтверд" src="https://github.com/user-attachments/assets/477a8b5c-232a-4be8-a998-b8f4b0de6227" />


Скриншот отображения выбранного фото:


<img width="761" height="1048" alt="после всего" src="https://github.com/user-attachments/assets/41889749-3703-405a-9d25-d327d4ad4b68" />


Интеграция необходимых зависимостей

В файле pubspec.yaml добавлены следующие пакеты:

image_picker: ^1.1.1 – обеспечивает доступ к камере и галерее устройства

permission_handler: ^11.3.0 – управляет системными разрешениями

path_provider: ^2.1.4 – предоставляет доступ к путям файловой системы

image: ^4.1.3 – позволяет применять фильтры к изображениям

Конфигурация системных разрешений

Для корректной работы с камерой и хранилищем настроены соответствующие разрешения:

Для Android (файл android/app/src/main/AndroidManifest.xml):

<uses-permission android:name="android.permission.CAMERA" />

<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

Для iOS (файл ios/Runner/Info.plist):

<key>NSCameraUsageDescription</key>

<string>Для работы приложения требуется доступ к камере</string>

<key>NSPhotoLibraryUsageDescription</key>

<string>Для выбора изображений из галереи требуется разрешение</string>

Реализация основной логики приложения

Создание пользовательского интерфейса

Разработан интерфейс с тремя основными кнопками:

"Сделать фото" – вызов камеры устройства

"Выбрать из галереи" – открытие медиатеки

"Сохранить фото" – сохранение в локальное хранилище

Местоположение: Файл lib/main.dart, метод build() класса _CameraPageState 

Реализация работы с камерой и галереей

Основная логика получения изображений реализована в методе _getImage():


<img width="925" height="673" alt="image" src="https://github.com/user-attachments/assets/0a72575f-273c-4283-9253-9cf5597a8a73" />


Механизм сохранения изображений

Функция _saveImage() обеспечивает сохранение снимков в приватную директорию приложения:


<img width="990" height="474" alt="image" src="https://github.com/user-attachments/assets/e9df071f-d8e9-49d1-a922-7a8b06da860f" />
