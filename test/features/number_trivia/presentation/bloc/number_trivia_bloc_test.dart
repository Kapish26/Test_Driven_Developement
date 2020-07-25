import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/failure.dart';
import 'package:number_trivia/core/usecase/usecase.dart';
import 'package:number_trivia/core/util/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;
  NumberTriviaBloc bloc;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();
    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initial state should be Empty', () {
    //assert
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber ', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(text: 'Test Trivia', number: 1);

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Right(tNumberParsed));
    test(
        'should call the input converter to validate and convert the string to an unsigned integer',
        () async {
      // arrange
      setUpMockInputConverterSuccess();
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
      //assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
    });

    test(
      'should emit [Error] when the input is invalid',
      () async {
        // arrange
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await emitsExactly(
            bloc, [Error(message: INVALID_INPUT_FAILURE_MESSAGE)]);
      },
    );

    test('should get data from the concrete usecase ', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));
      //assert
      verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    });

    test('should emit [Loading , Loaded] when data is gotten successfully', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      //assert
      final expected = [
        Loading(),
        Loaded(numberTrivia: tNumberTrivia),
      ];
      await emitsExactly(bloc, expected);
    });

     test('should emit [Loading , Error] when getting data is failed', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      //assert
      final expected = [
        Loading(),
        Error(message: STRING_SERVER_FAILURE_MESSAGE),
      ];
      await emitsExactly(bloc, expected);
    });

    test(
      'should emit [Loading , Error] with a proper message when getting data is failed', 
      () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      //assert
      final expected = [
        Loading(),
        Error(message: STRING_CACHE_FAILURE_MESSAGE),
      ];
      await emitsExactly(bloc, expected);
    });
  });

  group('GetTriviaForRandomNumber ', () {
    final tNumberTrivia = NumberTrivia(text: 'Test Trivia', number: 1);

    test('should get data from the concrete usecase ', () async {
      // arrange
      when(mockGetRandomNumberTrivia(NoParams()))
          .thenAnswer((_) async => Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(mockGetRandomNumberTrivia (any));
      //assert
      verify(mockGetRandomNumberTrivia(NoParams()));
    });

    test('should emit [Loading , Loaded] when data is gotten successfully', () async {
      // arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForRandomNumber());
      //assert
      final expected = [
        Loading(),
        Loaded(numberTrivia: tNumberTrivia),
      ];
      await emitsExactly(bloc, expected);
    });

     test('should emit [Loading , Error] when getting data is failed', () async {
      // arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));
      //act
      bloc.add(GetTriviaForRandomNumber());
      //assert
      final expected = [
        Loading(),
        Error(message: STRING_SERVER_FAILURE_MESSAGE),
      ];
      await emitsExactly(bloc, expected);
    });

    test(
      'should emit [Loading , Error] with a proper message when getting data is failed', 
      () async {
      // arrange
      when(mockGetRandomNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));
      //act
      bloc.add(GetTriviaForRandomNumber());
      //assert
      final expected = [
        Loading(),
        Error(message: STRING_CACHE_FAILURE_MESSAGE),
      ];
      await emitsExactly(bloc, expected);
    });
  
  });

}













