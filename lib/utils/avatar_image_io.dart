import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider fileImage(String path) => FileImage(File(path));
