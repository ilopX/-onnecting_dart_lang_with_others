import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:ffi_interpop_c/color_printer.dart';
import 'package:ffi_interpop_c/lib_builder.dart';

void main() async {
  final delphi = await Delphi.load();
  final dartFuncAddress = Pointer.fromFunction<Delphi_CallNative>(dartFunction);
  delphi.applyDartFunction(dartFuncAddress);

  printGreen('Output:');
  final result1 = delphi.callNative(1, 'Hello');
  print(result1);

  final result2 = delphi.callNative(2, 'Hi');
  print(result2);
}

// This function should call from pascal code
Pointer<Utf8> dartFunction(int index, Pointer<Utf8> s) {
  final emoji = (index == 1)
      ? '😋'
      : '📙';
  return emoji.toNativeUtf8();
}

class Delphi {
  final Dart_ApplyMethod applyDartFunction;
  final Dart_CallNative _callNative;

  static Future<Delphi> load() async {
    final libFileName = await buildAndGetFileNameLib('delphi_callback');

    final lib = DynamicLibrary.open(libFileName);


    final applyDartMethod = lib.lookupFunction<
        Delphi_ApplyMethod,
        Dart_ApplyMethod>('ApplyDartMethod');

    final callNative = lib.lookupFunction<
        Delphi_CallNative,
        Dart_CallNative>('CallNative');

    return  Delphi._internals(applyDartMethod, callNative);
  }

  Delphi._internals(this.applyDartFunction, this._callNative);


  String callNative(int arg, String text) {
    final utfText = text.toNativeUtf8();
    final result = _callNative(arg, utfText);
    return result.toDartString();
  }
}

typedef Delphi_ApplyMethod = Void Function(Pointer);
typedef Dart_ApplyMethod = void Function(Pointer);

typedef Delphi_CallNative = Pointer<Utf8> Function(Int32, Pointer<Utf8>);
typedef Dart_CallNative = Pointer<Utf8> Function(int, Pointer<Utf8>);
