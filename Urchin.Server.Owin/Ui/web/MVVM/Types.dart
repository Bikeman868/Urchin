import 'dart:html';

import 'Model.dart';
import 'View.dart';
import 'ViewModel.dart';

typedef String FormatFunction<T>(T value);
typedef T ParseFunction<T>(String value);

typedef T PropertyGetFunction<T>();
typedef void PropertySetFunction<T>(T value);

typedef T ModelFactory<T extends Model>(Map json);
typedef TVM ViewModelFactory<TM extends Model, TVM extends ViewModel>(TM model);
typedef TV ViewFactory<TVM extends ViewModel, TV extends View>(TVM viewModel);
typedef void ViewModelUpdater<TM extends Model, TVM extends ViewModel>(TVM viewModel, TM model);

typedef void ViewModelMethod<TVM extends ViewModel>(TVM viewModel);

typedef Formatter(String text, Element container);

typedef bool Filter<T>(T element);