<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

一个简单的CategoryTitle 支持PageController

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

[示例](https://github.com/gxhx/gx_category_view/tree/main/example)

```dart

 GXCategoryView(
              items: const ["全部", "待完成", "已完成", "已过期a"],
              selectedTitleColor: Colors.red,
              selectedFontWeight: FontWeight.bold,
              // selectedFontSize: 20,
              onPageChanged: (index) {
                _incrementCounter(index: index);
              },
            )

```

