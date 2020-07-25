import 'dart:convert';
import 'package:matcher/matcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  MockSharedPreferences mockSharedPreferences;
  NumberTriviaLocalDataSourceImpl dataSource;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource =
        NumberTriviaLocalDataSourceImpl(sharedPreferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    test('should return Number trivia from shared preferences when there is one in the cache', 
    () async {
      // arrange
      when(mockSharedPreferences.getString(any))
      .thenReturn(fixture('trivia_cached.json'));
      //act
      final result = await dataSource.getLastNumberTrivia();
      //assert
      verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a cache exception hen there is no cached value ', 
    () async {
      // arrange
      when(mockSharedPreferences.getString(any))
      .thenReturn(null);
      //act
      final call = dataSource.getLastNumberTrivia;
      //assert
      // verify(mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(() => call(), throwsA(TypeMatcher<CacheException>()));
    });
  });

  group(
    'cacheNumberTrivia', 
    () {
      final tNumberTriviaModel = NumberTriviaModel(text: 'Test Text', number: 1);
      test(
        'should call SharedPreferences to cache data',
        () async {
          //act 
          dataSource.cacheNumberTrivia(tNumberTriviaModel);
          //assert
          final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
          verify(mockSharedPreferences.setString(CACHED_NUMBER_TRIVIA, expectedJsonString));
        });
    });
}
