﻿import '../MVVM/Mvvm.dart';

class VersionNameModel extends Model
{
	VersionNameModel(Map json) : super(json);

	String get name => getProperty('name');
	set name(String value) { setProperty('name', value); }
  
	int get version => getProperty('version');
	set version(int value) { setProperty('version', value); }

	String toString() => name + ' version name';
}
