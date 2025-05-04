/// A CLI tool for generating Clean Architecture feature structures
/// 
/// {@category Main}
library feature_generator;

export 'src/code_writers.dart' show writeCubitCode, writeStateCode;
export 'src/directory_creator.dart' show createFeatureStructure;
export 'src/extensions.dart' show StringCapitalization;