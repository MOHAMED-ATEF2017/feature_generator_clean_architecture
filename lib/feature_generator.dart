/// A CLI tool for generating Clean Architecture feature structures
///
/// {@category Main}
library feature_generator;

export 'src/code_writers.dart'
    show
        writeCubitCode,
        writeStateCode,
        writeUseCaseCode,
        writeEntityCode,
        writeModelCode,
        writeUseCaseCodeWithoutEntity,
        writeEmptyModelCode,
        writeUseCaseDataSourceCode,
        writeUseCaseRepositoryCode,
        writeUseCaseDomainRepositoryCode;
export 'src/directory_creator.dart'
    show createFeatureStructure, addUseCaseToFeature;
export 'src/extensions.dart' show StringCapitalization;
