import 'package:clean_architecture/core/error/exceptions.dart';
import 'package:clean_architecture/core/platform/network_info.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:dartz/dartz.dart';

import 'package:meta/meta.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/repositories/number_trivia_repository.dart';


typedef Future<NumberTrivia> _ConcreteOrRandomChooser();

//typedefs are basically nicknames

class NumberTriviaRepositoryImpl implements NumberTriviaRepository{
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    @required this.remoteDataSource,
    @required this.localDataSource,
    @required this.networkInfo
  });
  
  
  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number) async {
   return await _getTrivia((){
      return remoteDataSource.getConcreteNumberTrivia(number);
    });
    
    

    
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async{
    return await _getTrivia((){
      return remoteDataSource.getRandomNumberTrivia();
    });
    
  }

  
  Future<Either<Failure, NumberTrivia>> _getTrivia(
    // a function that returns Future<NumberTrivia>
    _ConcreteOrRandomChooser getConcreteOrRandom
  ) async {
    if(await networkInfo.isConnected){
      try{
        final remoteTrivia = await getConcreteOrRandom();
        localDataSource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      }on ServerException {
        return Left(ServerFailure());
      }
    }
    else{
      try{
      return Right(await localDataSource.getLastNumberTrivia());
      }
      on CacheException{
        return Left(CacheFailure());
      }
    }
  }
}