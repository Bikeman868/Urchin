import '../DataBinding/View.dart';
import '../DataBinding/ViewModel.dart';

typedef String FormatFunction<T>(T value);
typedef T ParseFunction<T>(String value);
typedef T PropertyGetFunction<T>();
typedef void PropertySetFunction<T>(T value);

typedef T ModelFactory<T>();
typedef TVM ViewModelFactory<TM, TVM extends ViewModel>(TM model);
typedef TV ViewFactory<TVM extends ViewModel, TV extends View>(TVM viewModel);

