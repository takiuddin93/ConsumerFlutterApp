import 'package:LaCoro/core/bloc/base_bloc.dart';
import 'package:LaCoro/core/preferences/preferences.dart';
import 'package:domain/entities/ciity_entity.dart';
import 'package:domain/result.dart';
import 'package:domain/use_cases/city_use_cases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CitySelectionBloc extends Bloc<BaseEvent, BaseState> {
  final CityUseCases _cityUseCases;
  final Preferences _preferences;

  CitySelectionBloc(this._cityUseCases, this._preferences);

  @override
  BaseState get initialState => InitialState();

  @override
  Stream<BaseState> mapEventToState(BaseEvent event) async* {
    try {
      if (event is GetAllCitiesEvent) {
        yield LoadingState();
        final result = await _cityUseCases.getAllCities();
        if (result is Success<List<CityEntity>>) {
          yield SuccessState(data: result.data);
        } else {
          yield ErrorState();
        }
      } else if (event is SubmitCitySelected) {
        await _preferences.saveCity(event.cityEntity);
      }
    } catch (e) {
      yield ErrorState();
    }
  }

  CityEntity loadSavedCity() {
    return _preferences.getCity();
  }

  Future<void> submitCitySelected(CityEntity cityEntity) async {
    await _preferences.saveCity(cityEntity);
  }
}

/// Events
class GetAllCitiesEvent extends BaseEvent {}

class SubmitCitySelected extends BaseEvent {
  final CityEntity cityEntity;

  SubmitCitySelected(this.cityEntity);
}