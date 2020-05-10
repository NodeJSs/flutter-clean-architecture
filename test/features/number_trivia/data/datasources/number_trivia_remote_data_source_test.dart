import 'dart:convert';

import 'package:clean_architecture/core/error/exceptions.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:matcher/matcher.dart' as matcher;

import '../../../../fixtures/fixture_reader.dart';
import '../../presentation/bloc/number_trivia_bloc_test.dart';


class MockHttpClient extends Mock implements http.Client{

}


void main(){
  NumberTriviaRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;

  setUp((){
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(
      client: mockHttpClient
    );
  });

  void setUpMockHttpClientSuccess200(){
     when(mockHttpClient.get(
          any, headers: anyNamed("headers")
        )).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404(){
    when(
          mockHttpClient.get(any, headers: anyNamed('headers'))
        ).thenAnswer((_) async => http.Response('Something went wrong', 404));
  }



  group('getRandomNumberTrivia', (){
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with number
       being the endpoint and with application/json header''',
      () async {

        // arrange
        setUpMockHttpClientSuccess200();

        // act
        dataSource.getConcreteNumberTrivia(tNumber);

        //assert
        verify(mockHttpClient.get(
          'http://numbersapi.com/$tNumber',
          headers: {'Content-Type': 'application/json'}
        ));
      }
    );

    test(
      'should return NumebrTrivia when the response code is 200 (success)',
      () async{

        // arrange
        setUpMockHttpClientSuccess200();
        // act
        final result = await dataSource.getConcreteNumberTrivia(tNumber);

        expect(result, equals(tNumberTriviaModel));
      }
        
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async{

        // arrange
        setUpMockHttpClientFailure404();

        // act
        final call = dataSource.getConcreteNumberTrivia;

        expect(() => call(tNumber), throwsA(matcher.TypeMatcher<ServerException>()));
      }
    );
  });

   
  group('getRandomNumberTrivia', (){
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with number
       being the endpoint and with application/json header''',
      () async {

        // arrange
        setUpMockHttpClientSuccess200();

        // act
        dataSource.getRandomNumberTrivia();

        //assert
        verify(mockHttpClient.get(
          'http://numbersapi.com/random',
          headers: {'Content-Type': 'application/json'}
        ));
      }
    );

    test(
      'should return NumebrTrivia when the response code is 200 (success)',
      () async{

        // arrange
        setUpMockHttpClientSuccess200();
        // act
        final result = await dataSource.getRandomNumberTrivia();

        expect(result, equals(tNumberTriviaModel));
      }
        
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async{

        // arrange
        setUpMockHttpClientFailure404();

        // act
        final call = dataSource.getRandomNumberTrivia;

        expect(() => call(), throwsA(matcher.TypeMatcher<ServerException>()));
      }
    );

    
  });


}