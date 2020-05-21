import 'package:LaCoro/core/bloc/base_bloc.dart';
import 'package:LaCoro/core/ui_utils/mappers/item_ui_mapper.dart';
import 'package:LaCoro/core/ui_utils/model/item_ui.dart';
import 'package:LaCoro/core/ui_utils/model/store_ui.dart';
import 'package:domain/entities/item_entity.dart';
import 'package:domain/result.dart';
import 'package:domain/use_cases/store_use_cases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderStoreDetailsBloc extends Bloc<BaseEvent, BaseState> {
  final StoreUseCases _storeUseCases;

  StoreUI store;

  Map<ItemUI, int> products = Map();

  OrderStoreDetailsBloc(this._storeUseCases);

  @override
  BaseState get initialState => InitialState();

  @override
  Stream<BaseState> mapEventToState(BaseEvent event) async* {
    try {
      if(event is GetOrderSummaryEvent) {
        yield OrderSummarySate(cartTotal: _getCartTotal(), deliveryCost: store?.deliveryCost ?? 0);
      }
      else if (event is UpdateProductEvent) {
        products.update(event.product, (value) => event.quantity, ifAbsent: () => 1);
        yield OrderSummarySate(cartTotal: _getCartTotal(), deliveryCost: store.deliveryCost);
      }
    } catch (error) {
      yield ErrorState();
    }
  }

  Stream<BaseState> loadStoreItems() async* {
    yield LoadingState();
    final result = await _storeUseCases.getStoreItems(store.id);
    if (result is Success<Map<ItemEntity, List<ItemEntity>>>) {
      final items = result.data.map((key, value) => MapEntry(ItemUIMapper().processSingleElement(key), ItemUIMapper().processList(value)));
      yield SuccessState(data: items);
    } else {
      yield ErrorState();
    }
  }

  double _getCartTotal() {
    return products.isEmpty ? 0 : products.entries.map((entry) => (entry.key.price * entry.value.toDouble())).reduce((a, b) => a + b);
  }
}

/// Events
class UpdateProductEvent extends BaseEvent {
  final ItemUI product;
  final int quantity;

  UpdateProductEvent(this.product, this.quantity);
}

class GetOrderSummaryEvent extends BaseEvent {}

/// States
class OrderSummarySate extends BaseState {
  final double cartTotal;
  final int deliveryCost;

  OrderSummarySate({this.cartTotal, this.deliveryCost}) : super([cartTotal, deliveryCost]);
}